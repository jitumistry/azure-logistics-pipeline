-- View 1 — City Risk Dashboard:

CREATE VIEW vw_city_risk_dashboard AS
SELECT
    city, country_name, region, event_hour,
    temperature, rain_1h, congestion_level,
    incident_count, pm25, delay_flag, route_risk_score,
    CASE
        WHEN route_risk_score >= 60 THEN 'HIGH'
        WHEN route_risk_score >= 30 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_category
FROM gold_logistics;


-- View 2 — Delay by Region:


CREATE VIEW vw_delay_by_region AS
SELECT
    region, country_name, city,
    COUNT(*)                                           AS total_hours,
    SUM(delay_flag)                                    AS delayed_hours,
    ROUND(AVG(CAST(delay_flag AS FLOAT)) * 100, 1)    AS delay_pct,
    ROUND(AVG(CAST(route_risk_score AS FLOAT)), 1)    AS avg_risk_score,
    ROUND(AVG(rain_1h), 2)                            AS avg_rain,
    ROUND(AVG(CAST(congestion_level AS FLOAT)), 1)    AS avg_congestion,
    ROUND(AVG(CAST(pm25 AS FLOAT)), 1)                AS avg_pm25
FROM gold_logistics
GROUP BY region, country_name, city;



-- View 3 — Weather Traffic Correlation:


CREATE VIEW vw_weather_traffic_correlation AS
SELECT
    city,
    CASE
        WHEN rain_1h = 0             THEN 'No Rain'
        WHEN rain_1h BETWEEN 0 AND 2 THEN 'Light Rain'
        WHEN rain_1h BETWEEN 2 AND 5 THEN 'Moderate Rain'
        ELSE                              'Heavy Rain'
    END AS rain_category,
    ROUND(AVG(CAST(congestion_level AS FLOAT)), 1) AS avg_congestion,
    ROUND(AVG(CAST(route_risk_score AS FLOAT)), 1) AS avg_risk,
    COUNT(*)                                        AS data_points
FROM gold_logistics
GROUP BY city,
    CASE
        WHEN rain_1h = 0             THEN 'No Rain'
        WHEN rain_1h BETWEEN 0 AND 2 THEN 'Light Rain'
        WHEN rain_1h BETWEEN 2 AND 5 THEN 'Moderate Rain'
        ELSE                              'Heavy Rain'
    END;



-- View 4 — Air Quality Alerts:


CREATE VIEW vw_air_quality_alerts AS
SELECT
    city, country_name, region,
    dominant_pollutant, pm25, pm10, o3, no2,
    CASE
        WHEN pm25 > 150 THEN 'HAZARDOUS'
        WHEN pm25 > 100 THEN 'UNHEALTHY'
        WHEN pm25 > 50  THEN 'MODERATE'
        ELSE                 'GOOD'
    END AS air_quality_category,
    event_hour
FROM gold_logistics;



-- View 5 — Hourly Risk Trend:

CREATE VIEW vw_hourly_risk_trend AS
SELECT
    city, country_name,
    DATEPART(HOUR, event_hour)                     AS hour_of_day,
    ROUND(AVG(CAST(route_risk_score AS FLOAT)), 1) AS avg_risk,
    ROUND(AVG(CAST(congestion_level AS FLOAT)), 1) AS avg_congestion,
    ROUND(AVG(rain_1h), 2)                         AS avg_rain,
    SUM(delay_flag)                                AS total_delays
FROM gold_logistics
GROUP BY city, country_name, DATEPART(HOUR, event_hour);




SELECT * FROM vw_city_risk_dashboard  ORDER BY route_risk_score DESC;
SELECT * FROM vw_delay_by_region      ORDER BY delay_pct DESC;
SELECT * FROM vw_weather_traffic_correlation;
SELECT * FROM vw_air_quality_alerts   ORDER BY pm25 DESC;
SELECT * FROM vw_hourly_risk_trend    ORDER BY avg_risk DESC;
