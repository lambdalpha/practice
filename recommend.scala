// Chapter 3 Recommendig music and the audioscrobbler data set
// Using ASL algorithm
// load the data
val rawUserArtistData = sc.textFile("/opt/mount/spark/profiledata_06-May-2005/user_artist_data.txt")

val rawArtistData = sc.textFile("/opt/mount/spark/profiledata_06-May-2005/artist_data.txt")

// this may cause some error, for same 
/*
val artistByID = rawArtistData.map { line => 
    val (id, name) = line.span(_ != '\t')
    (id.toInt, name.trim)
}
*/

val artistByID = rawArtistData.flatMap{ line =>
    val (id, name) = line.span(_ != '\t')
    if (name.isEmpty) {
       None
    } else {
      try {
	    Some((id.toInt, name.trim))
   	  } catch {
      	    case e: NumberFormatException => None
      	  }
    }
}


   
// read artist_alias
val rawArtistAlias = sc.textFile("/opt/mount/spark/profiledata_06-May-2005/artist_alias.txt")
//val rawArtistAlias = sc.textFile("/home/hime/spark/profiledata_06-May-2005/artist_alias.txt")

val artistAlias = rawArtistAlias.flatMap { line =>
    val  tokens = line.split('\t')
    if (tokens(0).isEmpty) {
       None
    } else {
       Some((tokens(0).toInt, tokens(1).toInt))
    }
}.collectAsMap()


