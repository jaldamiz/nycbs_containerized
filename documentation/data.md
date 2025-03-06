# NYC Bike Share Analytics Data Dictionary

This document describes the schema and content of all tables in the gold analytics layer.

## Tables Overview

### revenue_metrics
Aggregated revenue metrics by year and month.

| Column | Type | Description |
|--------|------|-------------|
| year | integer | Year of the data |
| month | integer | Month of the data (1-12) |
| total_trips | bigint | Total number of trips in the period |
| charged_trips | bigint | Number of trips that were charged |
| avg_duration_min | double | Average trip duration in minutes |
| revenue_potential | double | Total potential revenue in USD |

### station_metrics
Station-level metrics aggregated by year and month.

| Column | Type | Description |
|--------|------|-------------|
| year | integer | Year of the data |
| month | integer | Month of the data (1-12) |
| start_station_name | string | Name of the starting station |
| start_lat | double | Latitude of the station |
| start_lng | double | Longitude of the station |
| total_starts | bigint | Total number of trips starting from this station |
| avg_duration_min | double | Average trip duration in minutes |
| avg_distance_km | double | Average trip distance in kilometers |
| unique_destinations | bigint | Number of unique destination stations |

### temporal_metrics
Time-based analysis metrics aggregated by year, month, part of day, and weekend status.

| Column | Type | Description |
|--------|------|-------------|
| year | integer | Year of the data |
| month | integer | Month of the data (1-12) |
| part_of_day | string | Time period (morning, afternoon, evening, night) |
| is_weekend | boolean | Whether the data is for weekends |
| total_rides | bigint | Total number of rides |
| avg_duration_min | double | Average trip duration in minutes |
| avg_distance_km | double | Average trip distance in kilometers |
| avg_speed_kmh | double | Average speed in kilometers per hour |

### route_metrics
Route-level metrics aggregated by year, month, and station pairs.

| Column | Type | Description |
|--------|------|-------------|
| year | integer | Year of the data |
| month | integer | Month of the data (1-12) |
| start_station_name | string | Name of the starting station |
| end_station_name | string | Name of the ending station |
| route_count | bigint | Number of trips on this route |
| avg_distance_km | double | Average trip distance in kilometers |
| avg_duration_min | double | Average trip duration in minutes |
| avg_speed_kmh | double | Average speed in kilometers per hour |

### distance_metrics
Distance-based analysis metrics aggregated by year, month, and distance buckets.

| Column | Type | Description |
|--------|------|-------------|
| year | integer | Year of the data |
| month | integer | Month of the data (1-12) |
| distance_bucket | string | Distance range category |
| trip_count | bigint | Number of trips in this distance range |
| avg_duration_min | double | Average trip duration in minutes |
| avg_speed_kmh | double | Average speed in kilometers per hour | 