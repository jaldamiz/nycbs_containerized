def model(dbt, session):
    dbt.config(
        materialized="table",
        packages=["pyspark"]
    )

    from snowflake.snowpark.functions import col, unix_timestamp, to_date
    import snowflake.snowpark.functions as F
    # DataFrame representing an upstream model
    df = dbt.ref("tripdata")
    # extract rental_date from started_at
    df = df.withColumn("rental_date", to_date(col("started_at")))

    # Convert time columns to timestamp and compute trip duration in minutes
    df = df.withColumn("start_ts", unix_timestamp("started_at")) \
       .withColumn("end_ts", unix_timestamp("ended_at"))

    # Calculate duration (in minutes) and filter out invalid records
    df = df.withColumn("trip_duration", (col("end_ts") - col("start_ts")) / 60)
    df = df.filter(col("trip_duration") > 0)
    
    #add a column to flag trips that are longer than 30 minutes
    df = df.withColumn("insurance_trip", F.when(col("trip_duration") > 30, 1).otherwise(0))

    # Earth's radius in kilometers
    EARTH_RADIUS = 6371.0

    # Convert coordinates and calculate haversine 'a' factor
    df = df.withColumn("start_lat_rad", F.radians(col("start_lat"))) \
        .withColumn("start_lon_rad", F.radians(col("start_lng"))) \
        .withColumn("end_lat_rad", F.radians(col("end_lat"))) \
        .withColumn("end_lon_rad", F.radians(col("end_lng")))

    df = df.withColumn("dlat", col("end_lat_rad") - col("start_lat_rad")) \
        .withColumn("dlon", col("end_lon_rad") - col("start_lon_rad"))

    # Compute haversine distance in km
    df = df.withColumn("a", F.pow(F.sin(col("dlat")/2), 2) + 
                    F.cos(col("start_lat_rad")) * F.cos(col("end_lat_rad")) * 
                    F.pow(F.sin(col("dlon")/2), 2))
    df = df.withColumn("distance_km", 2 * EARTH_RADIUS * F.asin(F.sqrt(col("a"))))

    df = df.withColumn("distance_bucket",
    F.when(col("distance_km") <= 1, "0-1 km")
     .when((col("distance_km") > 1) & (col("distance_km") <= 4), "2-4 km")
     .when((col("distance_km") > 4) & (col("distance_km") <= 9), "4-9 km")
     .otherwise("10+ km")
    )
    

    return df
    return upstream_model
