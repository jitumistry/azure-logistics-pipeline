CREATE EXTERNAL TABLE gold_logistics (
    city                        VARCHAR(100),
    country_code                VARCHAR(10),
    event_hour                  DATETIME2,
    temperature                 FLOAT,
    feels_like                  FLOAT,
    humidity                    BIGINT,
    pressure                    BIGINT,
    wind_speed                  FLOAT,
    wind_direction              BIGINT,
    rain_1h                     FLOAT,
    visibility                  BIGINT,
    weather_main                VARCHAR(100),
    weather_description         VARCHAR(200),
    forecast_temperature        FLOAT,
    forecast_rain               FLOAT,
    forecast_wind_speed         FLOAT,
    precipitation_probability   BIGINT,
    congestion_level            INT,
    incident_count              BIGINT,
    pm25                        BIGINT,
    pm10                        BIGINT,
    o3                          FLOAT,
    no2                         FLOAT,
    dominant_pollutant          VARCHAR(50),
    country_name                VARCHAR(100),
    region                      VARCHAR(100),
    timezone                    VARCHAR(50),
    capital                     VARCHAR(100),
    delay_flag                  INT,
    route_risk_score            INT,
    year                        INT,
    month                       INT,
    day                         INT
)
WITH (
    LOCATION = 'logistics_gold/**',
    DATA_SOURCE = gold_delta_source,
    FILE_FORMAT = parquet_ff
);


SELECT TOP 10 * FROM gold_logistics ORDER BY route_risk_score DESC;

