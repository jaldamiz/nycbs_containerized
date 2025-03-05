from pyspark.sql import SparkSession
import time

# Initialize Spark
spark = (SparkSession.builder
        .appName("CitiBike-Processing")
        .getOrCreate())

# Keep the application running
while True:
    time.sleep(1) 