# tech-layoffs-sQL-cleaning
Data cleaning and standardization pipeline overhauling 3,000+ rows of messy global tech layoffs data from Kaggle using SQL. Handled structural anomalies, duplicates, and type casting to build an analytics-ready database schema


## Project Overview: Tech Layoffs Data Transformation Pipeline

**Dataset Source:** [Kaggle - Tech Layoffs Dataset (2020 - Present)]([https://www.kaggle.com/](https://www.kaggle.com/datasets/swaptr/layoffs-2022?resource=download))
**Database Flavor:** PostgreSQL

### The Challenge
Raw, crowdsourced tech sector data is notoriously messy. Initial exploratory analysis of this dataset revealed widespread structural defects that made accurate analytical querying impossible:
*   **Data Redundancy:** Multiple duplicate rows caused by overlapping scraper runs.
*   **Text Inconsistencies:** White spaces and duplicate categorical entries for identical entities (e.g., 'Crypto', 'Crypto Currency', and 'Cryptocurrency' listed as separate industries).
*   **Malformed Geographies:** Inconsistent labeling of cities and countries due to user formatting differences.
*   **Type Constraints:** The crucial `date` column was imported as a `TEXT` string, completely preventing time-series profiling.
*   **Structural Gaps:** Missing and null values across `total_laid_off` and `percentage_laid_off` columns.

### The Objective
To build a repeatable SQL transformation script that ingests the raw, unformatted csv data, isolates the defects without altering the source records, and exports a fully normalized, high-integrity relational schema ready for data visualization or predictive modeling.

### Key Database Engineering Practices Demonstrated
*   **Defensive Data Modeling:** Initialized a `staging` table architecture to preserve the immutable raw dataset during testing and processing.
*   **Advanced Deduplication:** Deployed Window Functions (`ROW_NUMBER() OVER(PARTITION BY...)`) inside Common Table Expressions (CTEs) to isolate and eliminate redundant rows.
*   **Data Normalization & Standardization:** Applied advanced string manipulation functions like `TRIM`  to harmonize chaotic categorical text variables.
*   **Schema Modification:** Handled strict explicit data type casting (`STR_TO_DATE`, `ALTER TABLE`) to convert text strings into true structural time-series fields.
