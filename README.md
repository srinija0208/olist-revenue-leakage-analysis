# Olist E-Commerce Revenue Leakage Analysis

## Problem Statement

Olist generated approximately $13.59M in realized revenue across nearly 100K e-commerce orders 71 product categories between 2016 and 2018. 
This project investigates operational revenue leakage by analyzing the impact of delivery delays, logistics costs, cancellations, and seller performance 
to identify areas where business profitability may be at risk.

## Dataset
- **Source:** Olist Brazilian E-Commerce Public Dataset (Kaggle)
- **Records:** 99K orders, 112K order items, 99K reviews, 3K sellers, 71 categories
- **Time Period:** 2016–2018

## Tools & Technologies
- **Python:** Pandas, Matplotlib (EDA & visualization)
- **SQL:** MySQL (10 analytical queries covering trends, risk analysis, cohort breakdowns)
- **Power BI:** DAX measures, data modeling, drillthrough, conditional formatting

## Key Skills Demonstrated
- Data Cleaning & Exploratory Data Analysis (Python, Pandas)
- Relational Data Modeling & Multi-table SQL Joins
- Advanced SQL (CTEs, Window Functions, Aggregations)
- Business KPI Design & DAX Measures
- Interactive Dashboard Development (Power BI)
- Business Insight Generation & Executive Reporting

## Key Findings

### Leakage #1 — Late Delivery Impact (₹9.86L at risk)
- **8.11%** of delivered orders arrived late
- Late deliveries correlate with avg review scores **dropping 1.8 points** (from 4.2 to 2.2)
- Revenue from late orders: **₹9.86L (7.46% of gross revenue)**
- Geographic concentration: PI, CE, AL contribute disproportionately to late delivery volumes.
  
### Leakage #2 — High Freight Logistics (₹9.52L at risk)
- **16.57%** of product revenue is consumed by freight costs
- 6 product categories exceed **40% freight-to-price ratio** (home_comfort, electronics, christmas_supplies)
- High-freight categories collectively represent approximately ₹9.52L in revenue exposed to elevated logistics costs.
- Freight cost trend: **increasing month-over-month**, worst in Q2

### Leakage #3 — Seller Quality Concentration (₹2.64L at risk)
- **186 sellers (6% of total)** have avg review scores below 3.0
- These lower-rated sellers contribute approximately ₹2.64L in revenue while accounting for a disproportionately high share of order cancellations.
- The analysis suggests that improving seller quality standards could reduce operational inefficiencies and enhance customer satisfaction.
  
## Business Recommendations

## Business Recommendations

1. **Logistics Optimization:** Prioritize carrier SLA improvements in high-delay states such as PI, CE, AL to reduce the current 8.11% late delivery rate.
2. **Freight Cost Monitoring:** Review pricing and fulfillment strategies for categories where freight costs exceed 40% of product value.
3. **Seller Performance Management:** Introduce minimum seller quality thresholds and continuously monitor review-based risk indicators to improve platform reliability.
   
## Dashboard Features

- **4 Interactive Pages:** Executive Summary, Leakage Deep Dive, Final Insights, Category Drillthrough
- **Drillthrough Capability:** Click any product category to see category-specific risk metrics, revenue trends by state, and freight analysis
- Category Risk Flag (High / Medium / Low) derived from freight ratio, late delivery %, and customer review score.
- **10 SQL Analytical Queries:** Covering monthly trends, customer cohorts, risk concentration, geographic patterns

## Project Structure

├── notebooks/
│   └── pandas_exploration.ipynb
├── sql/
│   └── revenue_leakage_queries.sql
├── outputs/
│   └── dashboard.pdf          (4-page Power BI report)
└── README.md

## How to Use

1. Download dataset from [Kaggle Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
2. Place CSVs in `/data` folder
3. Run `pandas_exploration.ipynb` for EDA
4. Execute SQL queries in `revenue_leakage_queries.sql` for deeper analysis
5. Open `dashboard.pdf` to explore interactive Power BI report

## Dashboard Preview

### Executive Summary
![Executive Summary](outputs/executive_summary.png)

### Leakage Deep Dive
![Leakage Deep Dive](outputs/leakage_deep_dive.png)

### Category Drillthrough
![Category Details](outputs/category_details.png)
