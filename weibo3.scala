import org.ansj.splitWord.analysis.BaseAnalysis
import org.ansj.splitWord.analysis.ToAnalysis
import org.ansj.domain.Term
import org.ansj.util.FilterModifWord
import org.ansj.library.UserDefineLibrary
import java.util.Arrays
import org.apache.spark.sql.types.{StructType,StructField,StringType, DoubleType}
import org.apache.spark.sql.Row
import org.apache.spark.sql.functions._

import scala.collection.mutable
import org.apache.spark.mllib.clustering.LDA
import org.apache.spark.mllib.clustering.{KMeans, KMeansModel}
import org.apache.spark.mllib.linalg.{Vector, Vectors}
import org.apache.spark.rdd.RDD


// we can add user defined stopwords and broadcast it 
// val bhv_rdd = sc.textFile("hdfs://16.152.122.117:9000/weibo/bhv_03_20150624.zip")
//val cont_rdd = sc.wholeTextFiles("hdfs://16.152.122.117:9000/weibo/wb_content/20150629/part-r-0005*").map(_._2).map(_.split("\t"))
val cont_rdd = sc.textFile("hdfs://16.152.122.117:9000/weibo/wb_content/20150629/part-r-0002[6789]").map(_.split("\t"))
val columns = Array("id1", "id2", "date", "text", "url")


val schema = StructType(columns.map(fieldName => StructField(fieldName.trim, StringType, true)))
val cont_rowRDD = cont_rdd.map(a => Row.fromSeq(a))
val cont_DF = sqlContext.createDataFrame(cont_rowRDD, schema)

val source = scala.io.Source.fromFile("/home/grid/data/stopwords.txt")

val stopwords = try source.mkString.split("\n") finally source.close()

val seg_udf = udf {(x: String) => {
    val temp = ToAnalysis.parse(x)
     // add stopwords
     FilterModifWord.insertStopWords(Arrays.asList("r","n", "m", "a"))
     // add stop Natures
     FilterModifWord.insertStopNatures("w",null,"ns","r","u","e", "nr","p", "o", "s","u","t", "tg", "en", "m","d", "s","z","a","c", "uj", "ul")
     val filter = FilterModifWord.modifResult(temp)

     val word = for(i<-Range(0,filter.size())) yield filter.get(i).getName
     //word.map(_.replaceAll(" ", "")).filter{w => !bc_stopwords.value.contains(w)}.mkString(" ")
     """\d+""".r.replaceAllIn(word.map(_.trim.replaceAll(" ", "")).mkString(" "), "")
    }
}

val cont_DF2 = cont_DF.select(
    cont_DF.columns.map {
    	case text @ "text" => seg_udf(cont_DF(text)).as(text)
	case other => cont_DF(other).as(other)
    }:_*)


val cont_text_rdd_ =cont_DF2.select("text").rdd.map(_.getAs[String](0)).map(_.split(" ")).map(x=> x.filter(w=> w.length>1))

//val cont_text_id_rdd = cont_text_rdd.zipWithIndex
def rm_stop(rdd:RDD[Array[String]], stopwords:Array[String]) = {
    	val bc = sc.broadcast(stopwords)
        rdd.map{x => x.filter{w => !bc.value.contains(w)}}
}

val cont_text_rdd = rm_stop(cont_text_rdd_, stopwords)

cont_text_rdd.cache()
// Creating TF matrix
import org.apache.spark.mllib.feature.HashingTF
val hashingTF = new HashingTF()
val hashingTF_rdd = hashingTF.transform(cont_text_rdd.map(_.toSeq))

val words = cont_text_rdd.flatMap(x => x).distinct().collect()
val indices = words.map(x => hashingTF.indexOf(x) % hashingTF.numFeatures)

val vocab = words.zip(indices).toMap
val indexVocab = vocab.map(_.swap)

// idf transform
import org.apache.spark.mllib.feature.IDF
hashingTF_rdd.cache()
val idf = new IDF(minDocFreq = 10).fit(hashingTF_rdd)
val documents = idf.transform(hashingTF_rdd).zipWithIndex.map{case (vector, id) => (id, vector)}

/*
val numClusters = 5
val numIters = 20
documents.cache()

val clusters = KMeans.train(documents.map(_._2), numClusters, numIters)

val WSSSE = clusters.computeCost(documents.map(_._2 ))

// print centers
clusters.clusterCenters.foreach {

}

// FIXME using the centers of kmeans, to represent the features ???

*/


val numTopics = 20
val lda = new LDA().setK(numTopics).setMaxIterations(30)
documents.cache()
//val documents2 = hashingTF_rdd.zipWithIndex.map(_.swap)
val ldaModel = lda.run(documents)

// Print topics, showing top-weighted 10 terms for each topic.
val topicIndices = ldaModel.describeTopics(maxTermsPerTopic = 100)

var topicStr = "term, weight, topic\n"
topicIndices.zipWithIndex.foreach { case ((terms, termWeights), i) =>
    terms.zip(termWeights).foreach { case (term, weight) =>
        topicStr += s"${indexVocab(term.toInt)}, $weight, ${i+1}\n"
    }
}
// save to local files
import java.io._
new PrintWriter("/home/grid/term_topic.csv") { write(topicStr); close}


topicIndices.zipWithIndex.foreach { case ((terms, termWeights), i) =>
  println(s"TOPIC: ${i+1} ")
  terms.zip(termWeights).foreach { case (term, weight) =>
    println(s"${indexVocab(term.toInt)}\t$weight")
  }
  println()
}



//println(topicStr)

import org.apache.spark.mllib.clustering.{EMLDAOptimizer, OnlineLDAOptimizer, DistributedLDAModel, LDA}
val actualCorpusSize = documents.count()
if (ldaModel.isInstanceOf[DistributedLDAModel]) {
      val distLDAModel = ldaModel.asInstanceOf[DistributedLDAModel]
      val avgLogLikelihood = distLDAModel.logLikelihood / actualCorpusSize.toDouble
      println(s"\t Training data average log likelihood: $avgLogLikelihood")
      println()
}




val distLDAModel = ldaModel.asInstanceOf[DistributedLDAModel]
val lda_topic_rdd = distLDAModel.topTopicsPerDocument(5)
