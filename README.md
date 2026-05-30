<div align="center">

![Azure](https://img.shields.io/badge/Azure-Data_Factory-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![Delta Lake](https://img.shields.io/badge/Delta_Lake-003366?style=for-the-badge&logo=apachespark&logoColor=white)
![Synapse](https://img.shields.io/badge/Synapse_Analytics-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![PySpark](https://img.shields.io/badge/PySpark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![Python](https://img.shields.io/badge/Python_3.9-3776AB?style=for-the-badge&logo=python&logoColor=white)

<br/>

# 🚚 Real-Time Logistics & Weather Intelligence Pipeline

**Production-grade Data Engineering Capstone Project on Microsoft Azure**

*Medallion Architecture · 5 Live APIs · 10 Global Cities · Fully Automated*

<br/>

| 🏗️ Architecture | ⚡ Processing | 🌍 Coverage | 🔄 Refresh |
|:---:|:---:|:---:|:---:|
| Medallion (Bronze→Silver→Gold) | PySpark on Databricks | 10 Global Cities | Hourly + Daily |

</div>

---

## 🎯 What This Project Does

This pipeline ingests **real-time weather, traffic and air quality data** from 5 live APIs across 10 global cities, transforms it through a **Medallion Architecture** on Azure, and produces a unified **logistics risk intelligence dataset** — queryable directly from Azure Synapse Analytics.

The Gold layer computes two KPIs used by real logistics companies:
- **`delay_flag`** — binary alert when conditions make delivery delays likely
- **`route_risk_score`** — composite 0–100 score combining weather severity, traffic congestion and air quality

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                    REAL-TIME LOGISTICS INTELLIGENCE PIPELINE                     │
│                                                                                  │
│  DATA SOURCES          BRONZE LAYER        SILVER LAYER       GOLD + SERVING    │
│  ─────────────         ────────────        ────────────       ──────────────    │
│                                                                                  │
│  🌤 OpenWeatherMap ──► ADF Copy       ──► PySpark Clean ──►                    │
│  🚗 TomTom Traffic ──► Activity           Flatten            Databricks         │
│  🌦 Open-Meteo    ──► (ForEach 10         City Mapping       Gold Notebook      │
│  🌍 REST Countries──► cities)             Delta Write        ┌──────────────┐   │
│  💨 WAQI Air Index──►                                        │ Join 5 tables│   │
│          │              ADLS Gen2          5 Silver          │ delay_flag   │   │
│          │              bronze/            Delta Tables       │ risk_score   │   │
│          │              Partitioned        Partitioned        │ MERGE upsert │   │
│    Hourly & Daily       by date            by date           └──────┬───────┘   │
│                                                                      │           │
│                                                               Synapse Analytics  │
│                                                               External Table     │
│                                                               5 SQL Views → BI   │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## ⚡ Tech Stack

| Layer | Technology | Why This Choice |
|---|---|---|
| **Ingestion** | Azure Data Factory | Managed orchestration, ForEach batch, GUI pipeline builder |
| **Storage** | ADLS Gen2 (HNS enabled) | Hierarchical namespace required for Databricks Unity Catalog |
| **Processing** | Databricks Runtime 14.3 | Optimized PySpark, Delta Lake native, Unity Catalog support |
| **Format** | Delta Lake | ACID transactions, time travel, schema evolution, MERGE support |
| **Serving** | Synapse Analytics Serverless | Pay-per-query, no cluster needed, reads Delta directly |
| **Security** | Managed Identity + Key Vault | Zero hardcoded credentials across all Azure services |
| **Orchestration** | ADF Schedule Triggers | 6 triggers automating full Bronze → Silver → Gold pipeline |

---

## 📡 Data Sources

| # | Source | Data | Frequency | Cities per Call | API |
|---|---|---|---|---|---|
| 1 | **OpenWeatherMap** | Live temp, rain, wind, humidity, pressure | Hourly | 1 | Key required |
| 2 | **TomTom Traffic Incidents** | Live accidents, jams, road closures | Hourly | 1 (bbox) | Key required |
| 3 | **Open-Meteo** | 7-day hourly forecast (temp, rain, wind) | Hourly | 1 | Free |
| 4 | **REST Countries** | Country metadata (region, capital, timezone) | Daily | Batch | Free |
| 5 | **WAQI** | PM2.5, PM10, O3, NO2, CO air quality | Daily | 1 | Key required |

---

## 🌍 10 Global Cities

```
🇮🇳 Mumbai    🇩🇪 Berlin    🇬🇧 London    🇺🇸 New York    🇹🇭 Bangkok
🇦🇪 Dubai     🇸🇬 Singapore 🇦🇺 Sydney    🇫🇷 Paris       🇧🇷 Sao Paulo
```

Cities defined in `config/cities_config.json` with lat/lon coordinates used for:
- ADF pipeline ForEach iteration (one API call per city per source)
- TomTom bbox query construction (`lat±0.1, lon±0.1`)
- Silver layer coordinate-to-city mapping via crossJoin distance matching

---

## 📁 Repository Structure

```
azure-logistics-pipeline/
│
├── 📂 adf/                                              # Azure Data Factory
│   ├── 📂 factory/                                      # All pipeline JSON definitions
│   ├── 📂 linkedTemplates/                              # Linked service templates
│   ├── 📄 ARMTemplateForFactory.json                    # Full ADF infrastructure as code
│   └── 📄 ARMTemplateParametersForFactory.example.json # ← copy this, add your keys
│
├── 📂 databricks/
│   ├── 📂 silver/                                       # 5 silver transformation notebooks
│   │   ├── 📓 silver_openweathermap.py                  # Flatten nested JSON, dedup weather array
│   │   ├── 📓 silver_tomtom.py                          # Parse GeoJSON coords, map city, congestion_level
│   │   ├── 📓 silver_openmeteo.py                       # arrays_zip + explode hourly forecast arrays
│   │   ├── 📓 silver_restcountries.py                   # ISO2 country code mapping, dimension table
│   │   └── 📓 silver_waqi.py                            # AQI flatten, coordinate city mapping
│   └── 📂 gold/
│       └── 📓 gold_logistics.py                         # Star schema join + KPIs + Delta MERGE
│
├── 📂 synapse/                                          # Synapse Analytics SQL scripts
│   ├── 📄 setupDatabase.sql                             # Master key, credential, external data source
│   ├── 📄 setup_schema.sql                              # External table on Gold Delta
│   └── 📄 views.sql                                     # 5 BI reporting views
│
├── 📂 config/
│   └── 📄 cities_config.json                            # 10 city lat/lon definitions
│
├── 📄 .gitignore                                        # Blocks all credential files
└── 📄 README.md
```

---

## 🔄 Automated Pipeline Schedule

```
Every Hour (00:00, 01:00, 02:00 ... 23:00)
├── openWeatherMap_Trigger  ──► OWM bronze ingestion   ──► silver_openweathermap.py
├── openMeteo_Trigger       ──► OpenMeteo bronze        ──► silver_openmeteo.py
└── TomTom_Trigger          ──► TomTom bronze           ──► silver_tomtom.py

Every Day at Midnight (00:00)
├── RestCountry_Trigger     ──► REST Countries bronze   ──► silver_restcountries.py
└── Wagi_Trigger            ──► WAQI bronze             ──► silver_waqi.py

Every Day at 01:00 AM
└── trigger_gold_daily      ──► gold_master_pipeline
                                 └── gold_logistics.py
                                     ├── Read all 5 silver Delta tables
                                     ├── Join: OWM (spine) + TomTom + OpenMeteo
                                     ├── Broadcast join: WAQI + REST Countries
                                     ├── Compute delay_flag + route_risk_score
                                     └── Delta MERGE into gold/logistics_gold/
                                                    ↓
                                     Synapse External Table auto-reflects new data
```

---

## 🏅 ADLS Gen2 Storage Layout

```
logisticdatalakestorage/
│
├── bronze/
│   ├── config/cities_config.json
│   ├── openweathermap/year=2026/month=05/day=30/hour=14/Mumbai_2026053014.json
│   ├── tomtom/year=2026/month=05/day=30/hour=14/Paris_2026053014.json
│   ├── openmeteo/year=2026/month=05/day=30/hour=14/London_2026053014.json
│   ├── restcountries/year=2026/month=05/day=30/Singapore_20260530.json
│   └── waqi/year=2026/month=05/day=30/Mumbai_20260530.json
│
├── silver/
│   ├── openweathermap/  [Delta Lake — _delta_log + year/month/day partitions]
│   ├── tomtom/          [Delta Lake — _delta_log + year/month/day partitions]
│   ├── openmeteo/       [Delta Lake — _delta_log + year/month/day partitions]
│   ├── restcountries/   [Delta Lake — _delta_log + year/month/day partitions]
│   └── waqi/            [Delta Lake — _delta_log + year/month/day partitions]
│
└── gold/
    └── logistics_gold/  [Delta Lake — MERGE target, 33 columns, year/month/day]
```

---

## 🔑 Key Engineering Challenges Solved

### 1. City name mapping (TomTom + OpenMeteo + WAQI)
These APIs don't return clean city names — TomTom returns raw GeoJSON coordinates, WAQI returns neighbourhood strings like `"Kurla, Mumbai, India"`, OpenMeteo returns only lat/lon.

**Solution:** `crossJoin` all data with `cities_config.json` reference, compute Euclidean distance (`abs(lat_diff) + abs(lon_diff)`), use `row_number()` window function to keep the single closest city match within tolerance.

```python
window_city = Window.partitionBy('latitude', 'longitude', 'event_time').orderBy('_dist')

df_mapped = df_flat \
    .crossJoin(broadcast(df_city_ref)) \
    .withColumn('_dist', abs(col('latitude') - col('c_lat')) + abs(col('longitude') - col('c_lon'))) \
    .filter(col('_dist') < 1.0) \
    .withColumn('_rn', row_number().over(window_city)) \
    .filter(col('_rn') == 1)
```

### 2. OpenMeteo parallel array explosion
OpenMeteo returns hourly forecasts as parallel arrays — `time: [t0,t1...]`, `temperature_2m: [v0,v1...]`. Naive explode breaks the pairing.

**Solution:** `arrays_zip` to pair arrays element-wise before exploding:

```python
df_zipped = df_clean.withColumn('hourly_zipped',
    arrays_zip(col('hourly.time'), col('hourly.temperature_2m'),
               col('hourly.rain'), col('hourly.wind_speed_10m')))

df_exploded = df_zipped.select(explode(col('hourly_zipped')).alias('h'))
```

### 3. TomTom GeoJSON coordinate extraction
TomTom incidents store coordinates as `array<string>` — each element is a stringified point like `"[-46.74,-23.51]"`. Direct array indexing fails because the element is a string, not an array.

**Solution:** Extract first element via `[0]`, then use `regexp_extract` + safe `when()` cast:

```python
df_flat = df_flat \
    .withColumn('lon_str', regexp_extract(col('coordinates_raw')[0], r'\[([^\,]+),', 1)) \
    .withColumn('tt_lon', when(col('lon_str') != '', col('lon_str').cast('double')).otherwise(None))
```

### 4. Gold layer upsert (no duplicate rows on re-run)
Simple overwrite loses history. Append creates duplicates. 

**Solution:** Delta Lake `MERGE` — updates matching `city + event_hour` rows, inserts new ones:

```python
delta_table.alias('existing') \
    .merge(df_gold.alias('new'),
           'existing.city = new.city AND existing.event_hour = new.event_hour') \
    .whenMatchedUpdateAll() \
    .whenNotMatchedInsertAll() \
    .execute()
```

---

## 📊 Gold Layer — KPIs

### delay_flag
```python
delay_flag = when(
    (col('rain_1h') > 5) |            # Heavy rain (mm/hr)
    (col('congestion_level') > 7) |   # Severe traffic (TomTom iconCategory mapped 1-10)
    (col('pm25') > 150), 1            # Hazardous air quality (WHO threshold)
).otherwise(0)
```

### route_risk_score (0–100)

| Component | Max Points | Signals |
|---|---|---|
| 🌧 Weather | 40 pts | `rain_1h` + `wind_speed` |
| 🚗 Traffic | 35 pts | `congestion_level` + `incident_count` |
| 💨 Air Quality | 25 pts | `pm25` |

---

## 🗄️ Synapse Analytics — SQL Views

```sql
-- 5 views available in logistics_db on Synapse Serverless SQL Pool

vw_city_risk_dashboard         -- City + risk_category (HIGH/MEDIUM/LOW) + all KPIs
vw_delay_by_region             -- Aggregated delay % and avg risk by region
vw_weather_traffic_correlation -- Rain category vs avg congestion level
vw_air_quality_alerts          -- Cities with HAZARDOUS/UNHEALTHY air quality
vw_hourly_risk_trend           -- Hour-of-day risk pattern per city (for time series charts)
```

**Example query:**
```sql
SELECT TOP 5 city, country_name, route_risk_score, risk_category, delay_flag
FROM vw_city_risk_dashboard
ORDER BY route_risk_score DESC;
```

---

## 🛡️ Security Architecture

```
NO HARDCODED CREDENTIALS ANYWHERE IN THIS CODEBASE

ADF Pipelines      ──► API keys via ADF Pipeline Parameters (encrypted at rest)
Databricks         ──► dbutils.secrets (Secret Scope: logistic-scope)
Synapse → ADLS     ──► Managed Identity (Storage Blob Data Contributor role)
ADF → Databricks   ──► PAT token in ADF Linked Service (encrypted)
GitHub             ──► .example parameter files only — real keys never committed
```

---

## 🔬 Key Concepts Demonstrated

| Concept | Implementation |
|---|---|
| **Medallion Architecture** | Bronze (raw JSON) → Silver (clean Delta) → Gold (joined KPIs) → Synapse |
| **Delta Lake MERGE** | Gold upsert on `city + event_hour` — no duplicates, preserves history |
| **Coordinate city mapping** | `crossJoin + row_number()` distance matching for TomTom, OpenMeteo, WAQI |
| **arrays_zip + explode** | OpenMeteo parallel hourly array pairing before explosion |
| **Broadcast joins** | `broadcast(dim_waqi)` + `broadcast(dim_restcountries)` — small dimension tables |
| **Window deduplication** | `row_number().over(Window.partitionBy(...).orderBy(...))` across all silver notebooks |
| **Partition pruning** | `partitionBy('year','month','day')` on all Delta tables + Synapse reads it automatically |
| **Managed Identity** | Keyless auth — Synapse reads Gold via `CREDENTIAL = Managed Identity` |
| **Serverless SQL** | Synapse external table — zero compute cost, reads Delta Parquet directly |
| **ADF ForEach** | `items=activity('LookupConfigFile').output.value[0].cities` — 10-city batch |
| **explode_outer vs explode** | Null-safe weather array handling in OWM silver notebook |
| **Schema evolution** | `overwriteSchema = true` on Delta rewrites when column structure changes |
| **try_cast safety** | `when(col('str') != '', col('str').cast('double')).otherwise(None)` — no CAST_INVALID_INPUT |

---

## 🚀 Setup & Deployment

### Prerequisites
- Azure Subscription (free tier works for dev)
- Databricks Workspace (Standard tier)
- API Keys: OpenWeatherMap, TomTom, WAQI

### Step 1 — Deploy ADF via ARM Template
```bash
# 1. Copy the example parameters file
cp adf/ARMTemplateParametersForFactory.example.json \
   adf/ARMTemplateParametersForFactory.json

# 2. Fill in your API keys in the parameters file

# 3. Import into Azure Data Factory:
#    ADF → Manage → ARM Template → Import ARM template
#    Upload both JSON files
```

### Step 2 — Set up Databricks Secret Scope
```bash
# Install Databricks CLI, then:
databricks secrets create-scope --scope logistic-scope

databricks secrets put --scope logistic-scope --key owm-api-key
databricks secrets put --scope logistic-scope --key tomtom-api-key
databricks secrets put --scope logistic-scope --key waqi-api-key
databricks secrets put --scope logistic-scope --key adls-account-key
```

### Step 3 — Upload Databricks Notebooks
```
Databricks → Workspace → Import
Upload all .py files from databricks/silver/ and databricks/gold/
```

### Step 4 — Run Silver Notebooks (in order)
```
1. silver_openweathermap   — requires bronze OWM data
2. silver_tomtom           — requires bronze TomTom data
3. silver_openmeteo        — requires bronze OpenMeteo data
4. silver_restcountries    — requires bronze REST Countries data
5. silver_waqi             — requires bronze WAQI data
```

### Step 5 — Run Gold Notebook
```
gold_logistics  — reads all 5 silver tables, writes Gold Delta
```

### Step 6 — Set up Synapse Analytics
```sql
-- Run in Synapse Studio → Develop → SQL Script
-- Connect to: Built-in (Serverless SQL Pool)

-- In master database:
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'YourPassword123!';
CREATE DATABASE logistics_db;

-- In logistics_db:
-- Run setupDatabase.sql → setup_schema.sql → views.sql (in that order)
```

### Step 7 — Activate ADF Triggers
```
ADF → Manage → Triggers → Activate all 6 triggers → Publish all
```

---

## 📈 Project Outcomes

<div align="center">

| Metric | Value |
|:---|:---:|
| Cities monitored | 10 global cities across 4 continents |
| Live data sources | 5 APIs (weather + traffic + air quality) |
| Gold table columns | 33 columns per city per hour |
| Pipeline automation | 6 ADF triggers (hourly + daily + gold) |
| Synapse views | 5 business-ready SQL views |
| Delta tables | 6 (5 silver + 1 gold) |
| Engineering patterns | 12+ production data engineering patterns |

</div>

---

## 👤 Author

**Jitu Mistry** — Data Engineering Portfolio

[![GitHub](https://img.shields.io/badge/GitHub-jitumistry-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/jitumistry)

---

<div align="center">

*Built with Azure Data Factory · Databricks · Delta Lake · PySpark · Synapse Analytics*

**This project demonstrates production data engineering patterns used at scale in real logistics and supply chain systems.**

</div>
