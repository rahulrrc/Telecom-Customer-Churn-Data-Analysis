# Telecom-Customer-Churn-Data-Analysis

End-to-end churn analytics project covering data cleaning, star-schema data modeling, SQL business analysis, and an interactive Power BI dashboard — built to identify why customers leave and what a telecom provider can do about it.

## Business Problem

Analyze customer churn for a telecommunications company, identify the key factors associated with churn, and provide actionable insights to improve customer retention.

## Key Result

- **7,043 customers analyzed → 26.5% overall churn rate**
- Highest-risk segment: **month-to-month contract + fiber-optic internet + tenure under 12 months**
- Full findings and recommendations: [`Docs_and_Architecture/Customer_Churn_Insights_Report.docx`](./Docs_and_Architecture/Customer_Churn_Insights_Report.docx)

## Tech Stack

| Stage | Tool |
|---|---|
| Data Cleaning & EDA | Python (Pandas, Matplotlib) |
| Data Modeling | MySQL (star schema) |
| Business Analysis | SQL |
| Reporting & Dashboard | Power BI |

## Project Workflow

```
Raw CSV → Python (clean + explore) → cleaned CSV
        → MySQL (staging → star schema → validation → business questions)
        → Power BI (interactive dashboard)
        → Word report (insights & recommendations)
```

## Folder Structure

```
├── Data/
│   ├── telco_churn_unclean.csv        # raw source data
│   └── customer_churn_cleaned.csv     # cleaned output from Python
├── SQL_Scripts/
│   ├── 01_staging.sql                 # staging table + load
│   ├── 02_star_schema.sql             # dimension & fact tables
│   ├── 03_validation.sql              # row counts, referential integrity checks
│   ├── 04_business_questions.sql      # the 10 business questions
│   └── Customer_Churn_Analysis_SQL_file.sql   # full master script
├── Python/
│   └── Customer_Churn_EDA_Analysis.ipynb      # cleaning + exploratory analysis
├── PowerBI_Dashboard/
│   └── Customer_churn.pbix            # interactive Power BI dashboard
├── Docs_and_Architecture/
│   ├── Customer_Churn_Insights_Report.docx    # client-facing insights report
│   ├── star_schema.mwb                # MySQL Workbench data model
│   └── Star_schema.png                # data model diagram
└── Output_Screenshots/
    └── Q1_output ... Q10_output        # SQL results for each business question
```

## Data Model

Star schema built in MySQL: one fact table (`fact_churn`) linked to four dimensions.

| Table | Type | Grain / Purpose |
|---|---|---|
| `fact_churn` | Fact | One row per customer — charges, churn outcome, FKs to all dimensions |
| `dim_customer` | Dimension | Demographics, tenure, tenure group |
| `dim_contract` | Dimension | Contract type, paperless billing |
| `dim_service` | Dimension | Full service bundle (internet, phone, security, support, streaming) |
| `dim_payment` | Dimension | Payment method |

See `Docs_and_Architecture/Star_schema.png` for the full diagram.

## Data Cleaning Summary

- Removed 5 duplicate records (7,048 → 7,043 rows)
- Resolved missing `total_charges` values (imputed from `monthly_charges` for zero-tenure customers)
- Converted `monthly_charges` / `total_charges` from text to numeric
- Standardized inconsistent category labels (e.g. `month to month` → `Month-to-month`)
- Engineered a `tenure_group` feature (0–12, 13–24, 25–48, 49+ months)

## Business Questions Answered

1. What is the overall churn rate? → **26.54%**
2. Which contract type has the highest churn? → **Month-to-month (42.7%)**
3. Are new customers more likely to churn? → **Yes — 47.4% in first 12 months vs. 9.5% at 49+ months**
4. Which internet service has the highest churn? → **Fiber optic (41.9%)**
5. Which payment method has the highest churn? → **Electronic check (45.3%)**
6. Does Tech Support reduce churn? → **Yes — 41.6% without vs. 15.2% with**
7. Does Online Security relate to lower churn? → **Yes — 41.8% without vs. 14.6% with**
8. Do higher monthly charges relate to higher churn? → **Yes — $74.42 avg. for churned vs. $61.27 for retained**
9. Which customer segments are most at risk? → **New, month-to-month, fiber-optic customers**
10. What actions can reduce churn? → See recommendations below

Full queries: [`SQL_Scripts/Customer_Churn_Analysis_SQL_file.sql`](./SQL_Scripts/Customer_Churn_Analysis_SQL_file.sql) · Results: [`Output_Screenshots/`](./Output_Screenshots/)

## Recommendations

1. Target new, month-to-month fiber customers with proactive retention outreach
2. Incentivize migration from month-to-month to one/two-year contracts
3. Investigate the fiber-optic customer experience (price, reliability, expectations)
4. Promote Tech Support and Online Security add-ons at onboarding
5. Encourage migration off electronic check to automatic payment methods
6. Build a dedicated retention track for senior-citizen customers
7. Prioritize retention spend on high-monthly-value, high-risk customers

## Dashboard

The Power BI dashboard (`PowerBI_Dashboard/Customer_churn.pbix`) provides an interactive view of churn KPIs by contract, tenure, service, and payment method, intended for ongoing monitoring as new billing data is loaded.

## How to Reproduce

1. **Python**: Open `Python/Customer_Churn_EDA_Analysis.ipynb`, point it at `Data/telco_churn_unclean.csv`, and run all cells. This produces `customer_churn_cleaned.csv`.
2. **MySQL**: Run `SQL_Scripts/Customer_Churn_Analysis_SQL_file.sql` (or the split `01`–`04` scripts in order) against a MySQL instance to build the staging table, star schema, and run the business-question queries.
3. **Power BI**: Open `PowerBI_Dashboard/Customer_churn.pbix` and refresh the data source to point at your MySQL instance or the cleaned CSV.

## Author

[Your Name] — feel free to update this section with your name, LinkedIn, and portfolio link.
