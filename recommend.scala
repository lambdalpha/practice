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


   

