// in spark shell, code from Advanced Analytics with Spark
val rawblocks = sc.textFile("/home/storm/spark/linkage")

// get first 10 obs
val head = rawblocks.take(10)
// tell if the line is the header
def isHeader(line: String) = line.contains("id_1")
//
head.filter(x => !isHeader(x)).length
head.filter(!isHeader(_)).length
head.filterNot(isHeader).length

val noheader = rawblocks.filter(x => !isHeader(x))
noheader.first

val line = head(5)
val pieces = line.split(',')
val id1 = pieces(0).toInt
val id2 = pieces(1).toInt
val matched = pieces(11).toBoolean

val rawscores = pieces.slice(2, 11)
//rawscores.map(s => s.toDouble) // wrong

def toDouble(s:String) = if ("?".equals(s)) Double.NaN else s.toDouble

val scores = rawscores.map(toDouble)

def parse(line: String) = {
    val pieces = line.split(',')
    val id1 = pieces(0).toInt
    val id2 = pieces(1).toInt
    val scores = pieces.slice(2, 11).map(toDouble)
    val matched = pieces(11).toBoolean
    (id1, id2, scores, matched)
}


val tup = parse(line)

tup._1
tup.productElement(0)
tup.productArity


// case class

case class MatchData(id1: Int, id2: Int,
     scores: Array[Double], matched: Boolean)

def parse(line: String) = {
    val pieces= line.split(',')
    val id1 = pieces(0).toInt
    val id2 = pieces(1).toInt
    val scores = pieces.slice(2,11).map(toDouble)
    val matched = pieces(11).toBoolean
    MatchData(id1,id2, scores, matched)
}

val md = parse(line)

val mds = head.filter(x => !isHeader(x)).map(x => parse(x))

// parse the RDD
val parsed = noheader.map(line => parse(line))

// cache
parsed.cache()

// aggregation
val grouped = mds.groupBy(md => md.matched)

grouped.mapValues(x => x.size).foreach(println)

// 2013/03/23
val matchCounts = parsed.map(md => md.matched).countByValue()
val matchCountsSeq = matchCounts.toSeq

matchCountSeq.sortBy(_._1).foreach(println)
matchCountSeq.sortBy(_._2).foreach(println)

// summary statistics for countinuous variables
parsed.map(md => md.scores(0)).stats()
parsed.map(md => md.scores(1)).stats()

//using java.lang.Double.isNaN to omit NaNs
import java.lang.Double.isNaN
parsed.map(md => md.scores(1)).filter(!isNaN(_)).stats()

val stats = (0 until 9).map(i => {
    parsed.map(md => md.scores(i)).filter(!isNaN(_)).stats()
})


// creating reusable code for computing summary statistics
// StatsWithMissing.scala
import org.apache.spark.util.StatCounter

class NAStatCounter extends Serializable {
  val stats: StatCounter = new StatCounter()
  var missing: Long = 0
  
  def add(x: Double): NAStatCounter = {
    if (java.lang.Double.isNaN(x)) {
      missing += 1
    } else {
      stats.merge(x)
    }
    this
  }
  def merge(other: NAStatCounter): NAStatCounter = {
    stats.merge(other.stats)
    missing += other.missing
    this
  }

  override def toString = {
    "stats: " + stats.toString + " NaN: " + missing
  }
}

object NAStatCounter extends Serializable {
  def apply(x: Double) = new NAStatCounter().add(x)
}



