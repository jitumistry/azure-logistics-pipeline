<div align="center">

<img src="https://img.shields.io/badge/Azure-Data_Factory-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white"/>
<img src="https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white"/>
<img src="https://img.shields.io/badge/Delta_Lake-00ADD8?style=for-the-badge&logo=apache-spark&logoColor=white"/>
<img src="https://img.shields.io/badge/Azure_Synapse-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white"/>
<img src="https://img.shields.io/badge/PySpark-E25A1C?style=for-the-badge&logo=apache-spark&logoColor=white"/>

<br/><br/>

# 🚚 Real-Time Logistics & Weather Intelligence Pipeline

### A production-grade Data Engineering capstone project built on Azure
### using Medallion Architecture — Bronze → Silver → Gold → Synapse

<br/>

> **Role:** Data Engineer Interview Prep — Project 04 (Capstone)
> **Pattern:** Medallion Architecture | **Cities:** 10 Global | **Sources:** 5 Live APIs

<br/>

</div>

---

## 📐 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     REAL-TIME LOGISTICS PIPELINE                        │
├──────────────┬──────────────┬──────────────┬───────────────────────────┤
│   SOURCES    │    BRONZE    │    SILVER    │      GOLD + SERVING       │
│              │              │              │                            │
│ 🌤 OWM API  │              │  ✅ Clean    │                            │
│ 🚗 TomTom   │  ADF Copy    │  ✅ Flatten  │  Databricks Gold          │
│ 🌦 OpenMeteo│  Activity    │  ✅ Map City │  ┌─ delay_flag            │
│ 🌍 REST Ctry│  ──────────► │  ✅ Delta    │  ├─ route_risk_score      │
│ 💨 WAQI AQI │  ADLS Gen2   │  Write       │  └─ Star Schema           │
│              │  (Bronze/)   │  (Silver/)   │         │                 │
│  Hourly ──► │              │              │         ▼                 │
│  Daily  ──► │  JSON Raw    │  5 Delta     │  Synapse Analytics        │
│              │  Partitioned │  Tables      │  External Table           │
│              │  by date     │  Partitioned │  5 SQL Views              │
└──────────────┴──────────────┴──────────────┴───────────────────────────┘
```

---

## ⚡ Tech Stack

| Layer | Service | Purpose |
|---|---|---|
| **Ingestion** | Azure Data Factory | 5 pipelines, ForEach batch, schedule triggers |
| **Storage** | ADLS Gen2 (Hierarchical NS) | Bronze / Silver / Gold containers |
| **Processing** | Databricks + PySpark | Flatten, transform, join, compute KPIs |
| **Format** | Delta Lake | ACID transactions, upsert, time travel |
| **Serving** | Synapse Analytics Serverless | External tables + 5 BI SQL views |
| **Security** | Managed Identity + Key Vault | Keyless auth between Azure services |
| **Orchestration** | ADF Schedule Triggers | Hourly bronze + daily gold automation |

---

## 📡 Data Sources

| # | Source | Data Type | Frequency | Auth |
|---|---|---|---|---|
| 1 | **OpenWeatherMap** | Live weather (temp, rain, wind, humidity) | Every Hour | API Key |
| 2 | **TomTom Traffic** | Live incidents (congestion, accidents, closures) | Every Hour | API Key |
| 3 | **Open-Meteo** | 7-day hourly weather forecast | Every Hour | Free |
| 4 | **REST Countries** | Country metadata (region, capital, timezone) | Daily | Free |
| 5 | **WAQI** | Air quality index (PM2.5, PM10, O3, NO2) | Daily | API Key |

---

## 🌍 10 Global Cities

| City | Country | Code | Region |
|---|---|---|---|
| 🇮🇳 Mumbai | India | IN | Asia |
| 🇩🇪 Berlin | Germany | DE | Europe |
| 🇬🇧 London | United Kingdom | GB | Europe |
| 🇺🇸 New York | United States | US | Americas |
| 🇹🇭 Bangkok | Thailand | TH | Asia |
| 🇦🇪 Dubai | UAE | AE | Asia |
| 🇸🇬 Singapore | Singapore | SG | Asia |
| 🇦🇺 Sydney | Australia | AU | Oceania |
| 🇫🇷 Paris | France | FR | Europe |
| 🇧🇷 Sao Paulo | Brazil | BR | Americas |

---

## 📁 Repository Structure

```
azure-logistics-pipeline/
│
├── 📂 adf/                                         # Azure Data Factory
│   ├── 📂 factory/                                 # Pipeline definitions
│   ├── 📂 linkedTemplates/                         # Linked service templates
│   ├── 📄 ARMTemplateForFactory.json               # Full ADF ARM template
│   └── 📄 ARMTemplateParametersForFactory.example.json  # ← copy & fill keys
│
├── 📂 databricks/
│   ├── 📂 silver/                                  # Silver layer notebooks
│   │   ├── 📓 silver_openweathermap.py             # OWM → flatten + city map
│   │   ├── 📓 silver_tomtom.py                     # TomTom → coord extract + city map
│   │   ├── 📓 silver_openmeteo.py                  # arrays_zip + explode hourly
│   │   ├── 📓 silver_restcountries.py              # Country ISO2 mapping
│   │   └── 📓 silver_waqi.py                       # AQI + coord city mapping
│   └── 📂 gold/
│       └── 📓 gold_logistics.py                    # Join all 5 + KPIs + upsert
│
├── 📂 synapse/                                     # Synapse Analytics SQL
│   ├── 📄 setupDatabase.sql                        # Master key + credential + source
│   ├── 📄 setup_schema.sql                         # External table definition
│   └── 📄 views.sql                                # 5 BI reporting views
│
├── 📂 config/
│   └── 📄 cities_config.json                       # 10 city lat/lon definitions
│
├── 📄 .gitignore
└── 📄 README.md
```

---

## 🔄 Pipeline Flow

```
⏰ HOURLY TRIGGER (every 1 hour)
└── ADF: openweathermap_ingestion  ──► Bronze JSON ──► silver_openweathermap.py
└── ADF: tomtom_ingestion          ──► Bronze JSON ──► silver_tomtom.py
└── ADF: openmeteo_ingestion       ──► Bronze JSON ──► silver_openmeteo.py

⏰ DAILY TRIGGER (every day at midnight)
└── ADF: restcountries_ingestion   ──► Bronze JSON ──► silver_restcountries.py
└── ADF: waqi_ingestion            ──► Bronze JSON ──► silver_waqi.py

⏰ GOLD TRIGGER (every day at 01:00 AM)
└── ADF: gold_master_pipeline      ──► gold_logistics.py
                                        ├── Join all 5 silver tables
                                        ├── Compute delay_flag
                                        ├── Compute route_risk_score
                                        └── Delta MERGE (upsert) to Gold
                                                    │
                                                    ▼
                                        Synapse Serverless SQL
                                        External Table auto-refreshes
```

---

## 🏅 ADLS Gen2 Structure

```
logisticdatalakestorage/
│
├── bronze/
│   ├── config/cities_config.json
│   ├── openweathermap/year=.../month=.../day=.../hour=.../
│   ├── tomtom/year=.../month=.../day=.../hour=.../
│   ├── openmeteo/year=.../month=.../day=.../hour=.../
│   ├── restcountries/year=.../month=.../day=.../
│   └── waqi/year=.../month=.../day=.../
│
├── silver/
│   ├── openweathermap/  ✅ Delta Lake
│   ├── tomtom/          ✅ Delta Lake
│   ├── openmeteo/       ✅ Delta Lake
│   ├── restcountries/   ✅ Delta Lake
│   └── waqi/            ✅ Delta Lake
│
└── gold/
    └── logistics_gold/  ✅ Delta Lake (partitioned year/month/day)
```

---

## 📊 Gold Layer — KPIs

### delay_flag
Binary alert — fires when any dangerous logistics condition is present:
```python
delay_flag = when(
    (col("rain_1h") > 5) |           # Heavy rain
    (col("congestion_level") > 7) |  # Severe traffic
    (col("pm25") > 150), 1           # Hazardous air quality
).otherwise(0)
```

### route_risk_score (0–100)
Weighted composite score across weather, traffic and air quality:

| Component | Weight | Signals Used |
|---|---|---|
| 🌧 Weather | 40 pts | rain_1h, wind_speed |
| 🚗 Traffic | 35 pts | congestion_level, incident_count |
| 💨 Air Quality | 25 pts | pm25 |

---

## 🗄️ Synapse SQL Views

| View | Answers |
|---|---|
| `vw_city_risk_dashboard` | Which cities are highest risk right now? |
| `vw_delay_by_region` | Which regions experience the most delays? |
| `vw_weather_traffic_correlation` | Does rain increase congestion? |
| `vw_air_quality_alerts` | Which cities have dangerous air quality? |
| `vw_hourly_risk_trend` | How does risk change throughout the day? |

---

## 🔑 Key Engineering Concepts Demonstrated

| Concept | Where Used |
|---|---|
| **Medallion Architecture** | Bronze → Silver → Gold → Synapse |
| **Delta Lake MERGE (Upsert)** | Gold table — no duplicates, preserves history |
| **Coordinate city mapping** | lat/lon crossJoin with tolerance matching |
| **arrays_zip + posexplode** | OpenMeteo parallel hourly array handling |
| **Broadcast joins** | WAQI + REST Countries dimension tables |
| **Window functions** | row_number() deduplication across all silver tables |
| **Partition pruning** | year/month/day on all Delta tables |
| **Managed Identity** | Keyless auth — ADF → ADLS, Synapse → ADLS |
| **Serverless SQL Pool** | Zero compute cost on Synapse external tables |
| **ADF ForEach batch** | 10-city parallel ingestion pattern |
| **Schema evolution** | overwriteSchema on Delta rewrites |
| **explode vs explode_outer** | Null-safe weather array handling |

---

## 🚀 Setup Instructions

### Prerequisites
- Azure Subscription
- Databricks Workspace
- API Keys for: OpenWeatherMap, TomTom, WAQI

### Step 1 — Deploy ADF
```bash
# Copy and fill in your credentials
cp adf/ARMTemplateParametersForFactory.example.json \
   adf/ARMTemplateParametersForFactory.json

# Edit the file and replace all YOUR_*_KEY placeholders
# Then import via: ADF → Manage → ARM Template → Import
```

### Step 2 — Set up Databricks Secret Scope
```bash
databricks secrets create-scope --scope logistic-scope

databricks secrets put --scope logistic-scope --key owm-api-key
databricks secrets put --scope logistic-scope --key tomtom-api-key
databricks secrets put --scope logistic-scope --key waqi-api-key
databricks secrets put --scope logistic-scope --key adls-account-key
```

### Step 3 — Upload Databricks Notebooks
```
Databricks Workspace → Import → upload all .py files from databricks/
```

### Step 4 — Run Silver Notebooks (in order)
```
1. silver_openweathermap
2. silver_tomtom
3. silver_openmeteo
4. silver_restcountries
5. silver_waqi
```

### Step 5 — Run Gold Notebook
```
gold_logistics  ← joins all 5 silver tables
```

### Step 6 — Set up Synapse
```sql
-- Run scripts in order in Synapse Studio (logistics_db):
1. setupDatabase.sql   -- master key + credential + data source + file format
2. setup_schema.sql    -- external table
3. views.sql           -- 5 reporting views
```

### Step 7 — Activate ADF Triggers
```
ADF → Manage → Triggers → Activate all 6 triggers → Publish all
```

---

## 📈 Results

<div align="center">

| Metric | Value |
|---|---|
| 🌍 Cities monitored | 10 global cities |
| 📡 Data sources | 5 live APIs |
| 📋 Gold table columns | 33 columns |
| ⚡ Refresh frequency | Hourly (weather + traffic) |
| 🗄️ Synapse views | 5 BI-ready views |
| 🔄 Pipeline pattern | Full Medallion Architecture |
| 🔐 Security | Managed Identity + Key Vault |

</div>

---

## 🛡️ Security

- ✅ All API keys stored in **Azure Key Vault**
- ✅ ADF uses **Managed Identity** — no connection strings
- ✅ Databricks uses **Secret Scopes** — no hardcoded credentials
- ✅ GitHub contains **zero real credentials** — `.example` files only
- ✅ ADLS access via **Storage Blob Data Contributor** role assignment

---

## 👤 Author

**Jitu Mistry**
Data Engineering Portfolio Project — Azure Capstone

[![GitHub](https://img.shields.io/badge/GitHub-jitumistry-181717?style=for-the-badge&logo=github)](https://github.com/jitumistry)

---

<div align="center">

*Built with Azure Data Factory · Databricks · Delta Lake · Synapse Analytics*

</div>
