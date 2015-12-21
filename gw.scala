import java.util.Arrays
import org.apache.spark.sql.types.{StructType,StructField,StringType, DoubleType}
import org.apache.spark.sql.Row
import org.apache.spark.sql.functions._
import scala.collection.mutable
import org.apache.spark.mllib.linalg.{Vector, Vectors}
import org.apache.spark.rdd.RDD
import org.apache.spark.rdd.PairRDDFunctions  
import scala.io.Source

import org.apache.spark.ml.feature.VectorAssembler
import org.apache.spark.ml.feature.StandardScaler

import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.PipelineModel
import org.apache.spark.ml.regression.GBTRegressor
import org.apache.spark.ml.evaluation.RegressionEvaluator


val gw_rdd = sc.textFile("hdfs://16.152.122.117:9000/kaze/gw_all_trans.csv").map(_.split(","))
val columns = Source.fromFile("/home/grid/data/scripts/columns.txt").getLines.mkString.split(",")


val schema = StructType(columns.map(fieldName => StructField(fieldName.trim, StringType, true)))
val gw_rdd_row = gw_rdd.map(a => Row.fromSeq(a))
val gw_DF = sqlContext.createDataFrame(gw_rdd_row, schema)

val target = "wnac_wspd_instmag_f_avg"
val features = Source.fromFile("/home/grid/data/scripts/features.txt").getLines.mkString.split(",")

val toDouble = udf[Double, String]( _.toDouble)
val gw_DF2 = gw_DF.select(
    gw_DF.columns.map {
        case wtur_id @ "wtur_id" => gw_DF(wtur_id).as(wtur_id)
	case wman_tm @ "wman_tm" => gw_DF(wman_tm).as(wman_tm)
        case other => toDouble(gw_DF(other)).as(other)
    }:_*)

val gw_DF_filtered = gw_DF2.filter($"wtur_id" <= "150033").filter($"wman_tm" < "2015").filter($"wnac_wspd_instmag_f_avg" > 2.0).filter($"wgen_spd_instmag_i_avg" > 1.0)

// FIXME pipeline

val assembler = new VectorAssembler()
assembler.setInputCols(features)
assembler.setOutputCol("raw_features")

//val gw_DF3 = assembler.transform(gw_DF_filtered)

val scaler = new StandardScaler()
scaler.setInputCol("raw_features")
scaler.setOutputCol("scaled_features")
//val scalerModel = scaler.fit(gw_DF3)
//val scaledData = scalerModel.transform(gw_DF3)

val gbt = new GBTRegressor()
gbt.setFeaturesCol("scaled_features")
gbt.setLabelCol(target)
gbt.setMaxIter(200)
gbt.setMaxDepth(6)


val pipeline = new Pipeline().setStages(Array(assembler, scaler, gbt))
val model = pipeline.fit(gw_DF_filtered)

val predictions = model.transform(gw_DF_filtered)
val evaluator = new RegressionEvaluator().setLabelCol(target).setPredictionCol("prediction").setMetricName("rmse")

val rmse = evaluator.evaluate(predictions)

// save model in hdfs
sc.parallelize(Seq(model), 1).saveAsObjectFile("hdfs://16.152.122.117:9000/kaze/gbt.model")
// retieve model from hdfs
val model2 = sc.objectFile[PipelineModel]("hdfs://16.152.122.117:9000/kaze/gbt.model" )

val pred = model.transform(gw_DF_filtered).select("wtur_id", "wman_tm","wtur_flt_main",  target, "prediction")
pred.withColumn("resid", pred(target) - pred("prediction"))

