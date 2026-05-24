# Analytics pipeline using Instacart Open source Data

## Goal of the project
The goal of this project is for me to practice dbt and build a report in Google GCP.


## Tech Stack
- BigQuery (via bq CLI 2.1.31)
- dbt Core 1.11.7
- dbt-bigquery 1.11.1
- dbt-utils 1.3.3

## Architecture
A very simple structure with raw data coming from Kaggle.
Staging with views of the raw data.
Marts the tables that will be used for visualization

raw → staging → (intermediate) → marts

## Data source
Data source is coming from [Kaggle](https://www.kaggle.com/datasets/snegii/instacart-dataset).
There are 6 tables
1. aisles -- 134 rows
2. departments -- 21 rows
3. order_products__prior -- 32434489 rows
4. order_products__train -- 1384617 rows
5. orders -- 3421083 rows
6. products -- 49688 rows


## Setup Instructions
Make sure you have the following ready to use
1. Python, gcloud CLI, dbt-core, dbt-bigquery
2. Using Kaggle data source, upload the data sources into BQ
Try running the following commands:
- dbt deps
- dbt run
- dbt test

## advanced commands
dbt run --select stg_instacart__orders — build one model
dbt docs generate && dbt docs serve — view docs site

## Design Decisions
### Merge sources for stg_instacart__order_products
We are not going to use this data for training a model. The goal is to build an analytics pipeline now. Therefore, we are going to merge the two tables order_products__prior and order_products__train into one table called stg_instacart__order_products. 
There will be a flag to indicate whether the record is from the prior or train table. This will allow us to use the same table for both analytics and modeling purposes in the future.

### Unique cols of stg_instacart__order_products
Since there isn't a col where we can check if the data is unique or not, here we have used generate_surrogate_key from dbt_utils to generate the unique combination of orders and products.

## Project tree
```.
├── aisles.csv
├── departments.csv
├── instacart_analysis
│   ├── analyses
│   ├── dbt_project.yml
│   ├── macros
│   ├── models
│   ├── package-lock.yml
│   ├── packages.yml
│   ├── README.md
│   ├── seeds
│   ├── snapshots
│   └── tests
├── order_products__prior.csv
├── order_products__train.csv
├── orders.csv
└── products.csv
```
8 directories, 10 files


## Project Status

### ✅ Completed
- BigQuery project setup with raw Instacart data loaded
- dbt Core project initialized with BigQuery adapter
- Source definitions (`_sources.yml`) for all 6 raw tables
- Staging layer: 5 models with light transformations
  - `stg_instacart__aisles`
  - `stg_instacart__departments`
  - `stg_instacart__products`
  - `stg_instacart__orders`
  - `stg_instacart__order_products` (combines prior + train with surrogate key)
- Generic tests (`not_null`, `unique`) on all staging primary keys (all passing)
- Documentation and GitHub setup

### ⬜ Planned
- Intermediate layer: customer-level aggregations for CLV calculation
- Marts layer: 3 reporting tables to power final dashboards
  - Customer Purchasing Patterns (CLV, repeat rate, AOV)
  - Product & Department Performance
  - Shopping Basket Analysis
- Source freshness configurations
- CI/CD with GitHub Actions (PR validation, no scheduler)
- BI dashboard connection


## Future Work

### Near-term (Next Few Sessions)
- [ ] Build intermediate model: `int_customer_orders_enriched` (joins orders + order_products + products)
- [ ] Build intermediate model: `int_customer_lifetime_metrics` (per-user aggregations)
- [ ] Build mart: `mart_customer_clv` (final CLV table)
- [ ] Build mart: `mart_product_performance`
- [ ] Build mart: `mart_basket_analysis`

### Polish
- [ ] Add `relationships` tests (foreign keys: `order_products.order_id` → `orders.order_id`)
- [ ] Add source freshness configurations
- [ ] Add column-level descriptions to all marts
- [ ] Add custom data tests for business logic

### Infrastructure
- [ ] GitHub Actions workflow: run `dbt compile` and `dbt test` on every PR
- [ ] Pre-commit hooks for SQL linting (e.g., `sqlfluff`)
- [ ] Connect a BI tool (Looker Studio, Metabase) to BQ marts for visualization

### Stretch Goals
- [ ] Convert one mart to incremental materialization as a learning exercise
- [ ] Write a custom dbt macro for repeated logic
- [ ] Explore dbt exposures to document downstream BI consumers