# COVID-19 Data Analysis Project

## Overview
This project analyzes COVID-19 case trends, mortality rates, and vaccination progress using SQL. The dataset is sourced from the **CovidProjectForPortfolio** database, which includes tables on COVID spread statistics and vaccination data.

## Repository Contents
- **`queries.sql`** - SQL scripts for data analysis.
- **`README.md`** - Documentation for the project.

## Key Analyses

### COVID-19 Spread & Mortality
- Identified **total cases, deaths, and new cases per day**.
- Analyzed **death percentage by country**.
- Ranked **countries with the highest death percentage**.
- Determined **continents with the highest infection rate**.

### Vaccination Insights
- Analyzed **total vaccinated people per country**.
- Calculated **percent of people vaccinated** with safety classification.
- Implemented **rolling vaccination totals** for trend analysis.

### Time-Series & Rolling Aggregations
- Tracked **global daily new cases and deaths**.
- Created a **rolling sum of COVID cases and deaths**.
- Implemented **vaccination trends over time**.

##  Technologies Used
- **Microsoft SQL Server (T-SQL)**
- **Window Functions** (`ROW_NUMBER()`, `RANK()`, `LAG()`, `SUM()`)
- **Common Table Expressions (CTEs)**
- **Temporary Tables for Aggregations**
