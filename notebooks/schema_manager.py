from pyspark.sql.types import *
from pyspark.sql import functions as F
from pyspark.sql import DataFrame
from typing import List, Tuple


class SchemaManager:
    """Centralized schema management with timestamp handling"""

    @staticmethod
    def get_citibike_schema() -> StructType:
        """Base schema for CitiBike data with string timestamps"""
        return StructType(
            [
                StructField("ride_id", StringType(), False),
                StructField("rideable_type", StringType(), True),
                StructField("started_at", StringType(), True),  # Initially as string
                StructField("ended_at", StringType(), True),  # Initially as string
                StructField("start_station_name", StringType(), True),
                StructField("start_station_id", StringType(), True),
                StructField("end_station_name", StringType(), True),
                StructField("end_station_id", StringType(), True),
                StructField("start_lat", DoubleType(), True),
                StructField("start_lng", DoubleType(), True),
                StructField("end_lat", DoubleType(), True),
                StructField("end_lng", DoubleType(), True),
                StructField("member_casual", StringType(), True),
            ]
        )

    @staticmethod
    def get_control_schema() -> StructType:
        """Schema for control table"""
        return StructType(
            [
                StructField("source_file", StringType(), False),
                StructField("file_path", StringType(), False),
                StructField("processing_date", TimestampType(), False),
                StructField("record_count", LongType(), True),
                StructField("status", StringType(), False),
                StructField("year", IntegerType(), False),
                StructField("month", IntegerType(), False),
            ]
        )

    @staticmethod
    def get_timestamp_format(layer: str) -> str:
        """Get timestamp format for specific layer"""
        formats = {
            "bronze": "yyyy-MM-dd HH:mm:ss",
            "silver": "yyyy-MM-dd HH:mm:ss.SSS",
            "gold": "yyyy-MM-dd HH:mm:ss",
        }
        return formats.get(layer, formats["bronze"])


class DataFrameTransformer:
    """Handles DataFrame transformations with consistent timestamp handling"""

    @staticmethod
    def convert_timestamps(df: DataFrame) -> DataFrame:
        """Convert string timestamps to timestamp type"""
        return df.withColumn("started_at", F.to_timestamp("started_at")).withColumn(
            "ended_at", F.to_timestamp("ended_at")
        )

    @staticmethod
    def add_time_dimensions(df: DataFrame) -> DataFrame:
        """Add time-based dimensions to DataFrame"""
        return (
            df.withColumn("year", F.year("started_at"))
            .withColumn("month", F.month("started_at"))
            .withColumn("day", F.dayofmonth("started_at"))
            .withColumn("hour", F.hour("started_at"))
            .withColumn("day_of_week", F.dayofweek("started_at"))
            .withColumn(
                "is_weekend", F.dayofweek("started_at").isin([1, 7]).cast(IntegerType())
            )
            .withColumn(
                "part_of_day",
                F.when(F.hour("started_at").between(5, 11), "morning")
                .when(F.hour("started_at").between(12, 16), "afternoon")
                .when(F.hour("started_at").between(17, 21), "evening")
                .otherwise("night"),
            )
        )


class DataValidator:
    """Validates data quality and schema consistency"""

    @staticmethod
    def validate_timestamps(
        df: DataFrame, timestamp_cols: List[str]
    ) -> Tuple[bool, List[str]]:
        """Validate timestamp columns for null values and future dates"""
        errors = []

        for col in timestamp_cols:
            # Check for nulls
            null_count = df.filter(F.col(col).isNull()).count()
            if null_count > 0:
                errors.append(f"Column {col} has {null_count} null values")

            # Check for future dates
            future_count = df.filter(F.col(col) > F.current_timestamp()).count()
            if future_count > 0:
                errors.append(f"Column {col} has {future_count} future dates")

        return len(errors) == 0, errors
