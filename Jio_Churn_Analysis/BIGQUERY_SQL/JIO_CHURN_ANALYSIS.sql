SELECT
    COUNT(*) AS total_records
FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_raw`;

-- check duplicates
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT customerID) AS unique_customers,
    COUNT(*) - COUNT(DISTINCT customerID) AS duplicate_records
FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_raw`;

-- Check missing values
SELECT
    COUNTIF(customerID IS NULL) AS missing_customer_id,
    COUNTIF(gender IS NULL) AS missing_gender,
    COUNTIF(tenure IS NULL) AS missing_tenure,
    COUNTIF(Contract IS NULL) AS missing_contract,
    COUNTIF(MonthlyCharges IS NULL) AS missing_monthly_charges,
    COUNTIF(TotalCharges IS NULL) AS missing_total_charges,
    COUNTIF(Churn IS NULL) AS missing_churn
FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_raw`;

-- Check churn distribution
SELECT
    Churn,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(), 2
    ) AS percentage
FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_raw`
GROUP BY Churn
ORDER BY customer_count DESC;

-- Check blank TotalCharges
SELECT
    COUNTIF(TRIM(TotalCharges) = '') AS blank_total_charges,
    COUNTIF(TotalCharges IS NULL) AS null_total_charges
FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_raw`;

-- Create a cleaned table
CREATE OR REPLACE TABLE
`dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned` AS 

SELECT
    customerID,
    gender,
    SeniorCitizen,
    Partner,
    Dependents,
    tenure,
    PhoneService,
    MultipleLines,
    InternetService,
    OnlineSecurity,
    OnlineBackup,
    DeviceProtection,
    TechSupport,
    StreamingTV,
    StreamingMovies,
    Contract,
    PaperlessBilling,
    `Payment Mode` as PaymentMethod,
    MonthlyCharges,

    SAFE_CAST(
        NULLIF(TRIM(TotalCharges), '') AS NUMERIC
    ) AS TotalCharges,

    Churn

FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_raw`;


SELECT
    ordinal_position,
    column_name,
    data_type
FROM `dsml-sql-470814.jio_churn_analysis.INFORMATION_SCHEMA.COLUMNS`
WHERE
    table_name = 'jio_churn_raw'
ORDER BY
    ordinal_position;

SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customerID) AS unique_customers,
    COUNTIF(TotalCharges IS NULL) AS missing_total_charges,
    COUNTIF(Churn = TRUE) AS churned_customers,
    COUNTIF(Churn = FALSE) AS retained_customers
FROM
`dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`;

-- Insight 1 – Customer Base Analysis
SELECT
    COUNT(*) AS total_customers,

    COUNTIF(Churn = TRUE) AS churned_customers,

    COUNTIF(Churn = FALSE) AS retained_customers,

    ROUND(
        COUNTIF(Churn = TRUE) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_percentage,

    ROUND(
        COUNTIF(Churn = FALSE) * 100.0 / COUNT(*),
        2
    ) AS retention_rate_percentage

FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`;


-- Insight 2 – Overall Churn Rate Analysis
SELECT
    COUNT(*) AS total_customers,

    COUNTIF(Churn = TRUE) AS churned_customers,

    COUNTIF(Churn = FALSE) AS retained_customers,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS churn_rate,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = FALSE) * 100,
            COUNT(*)
        ), 2
    ) AS retention_rate

FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`;


-- Insight 3 – Gender-wise Churn Analysis
SELECT
    gender,

    COUNT(*) AS total_customers,

    COUNTIF(Churn = TRUE) AS churned_customers,

    COUNTIF(Churn = FALSE) AS retained_customers,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS churn_rate_percentage,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = FALSE) * 100,
            COUNT(*)
        ), 2
    ) AS retention_rate_percentage

FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`

GROUP BY
    gender

ORDER BY
    churn_rate_percentage DESC;

-- Insight 4 – Tenure-wise Churn Analysis
SELECT
    CASE
        WHEN tenure <= 12 THEN '0-12 Months'
        WHEN tenure <= 24 THEN '13-24 Months'
        WHEN tenure <= 48 THEN '25-48 Months'
        ELSE '49-72 Months'
    END AS tenure_group,

    COUNT(*) AS total_customers,

    COUNTIF(Churn = TRUE) AS churned_customers,

    COUNTIF(Churn = FALSE) AS retained_customers,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS churn_rate_percentage

FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`

GROUP BY
    tenure_group

ORDER BY
    MIN(tenure);

-- Insight 5 – Contract-wise Churn Analysis
SELECT
    Contract,

    COUNT(*) AS total_customers,

    COUNTIF(Churn = TRUE) AS churned_customers,

    COUNTIF(Churn = FALSE) AS retained_customers,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS churn_rate_percentage,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = FALSE) * 100,
            COUNT(*)
        ), 2
    ) AS retention_rate_percentage

FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`

GROUP BY
    Contract

ORDER BY
    churn_rate_percentage DESC;

-- Insight 6 – Internet Service-wise Churn Analysis
SELECT
    InternetService,

    COUNT(*) AS total_customers,

    COUNTIF(Churn = TRUE) AS churned_customers,

    COUNTIF(Churn = FALSE) AS retained_customers,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS churn_rate_percentage,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = FALSE) * 100,
            COUNT(*)
        ), 2
    ) AS retention_rate_percentage

FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`

GROUP BY
    InternetService

ORDER BY
    churn_rate_percentage DESC;

-- Insight 7 – Payment Method-wise Churn Analysis
SELECT
    PaymentMethod,

    COUNT(*) AS total_customers,

    COUNTIF(Churn = TRUE) AS churned_customers,

    COUNTIF(Churn = FALSE) AS retained_customers,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS churn_rate_percentage,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = FALSE) * 100,
            COUNT(*)
        ), 2
    ) AS retention_rate_percentage

FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`

GROUP BY
    PaymentMethod

ORDER BY
    churn_rate_percentage DESC;

-- Insight 8 – Senior Citizen-wise Churn Analysis
SELECT
    CASE
        WHEN SeniorCitizen = 1 THEN 'Senior Citizen'
        ELSE 'Non-Senior Citizen'
    END AS customer_category,

    COUNT(*) AS total_customers,

    COUNTIF(Churn = TRUE) AS churned_customers,

    COUNTIF(Churn = FALSE) AS retained_customers,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS churn_rate_percentage,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = FALSE) * 100,
            COUNT(*)
        ), 2
    ) AS retention_rate_percentage

FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`

GROUP BY
    customer_category

ORDER BY
    churn_rate_percentage DESC;

-- Insight 9 – Monthly Charges-wise Churn Analysis
SELECT
    CASE
        WHEN MonthlyCharges < 30 THEN '0-30'
        WHEN MonthlyCharges < 60 THEN '30-60'
        WHEN MonthlyCharges < 90 THEN '60-90'
        ELSE '90-120'
    END AS monthly_charge_range,

    COUNT(*) AS total_customers,

    COUNTIF(Churn = TRUE) AS churned_customers,

    COUNTIF(Churn = FALSE) AS retained_customers,

    ROUND(AVG(MonthlyCharges), 2) AS average_monthly_charge,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS churn_rate_percentage,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = FALSE) * 100,
            COUNT(*)
        ), 2
    ) AS retention_rate_percentage

FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`

GROUP BY
    monthly_charge_range

ORDER BY
    MIN(MonthlyCharges);

-- Insight 10 – Total Charges-wise Churn Analysis
SELECT
    CASE
        WHEN TotalCharges < 1000 THEN '0-1000'
        WHEN TotalCharges < 3000 THEN '1000-3000'
        WHEN TotalCharges < 5000 THEN '3000-5000'
        ELSE '5000+'
    END AS total_charge_range,

    COUNT(*) AS total_customers,

    COUNTIF(Churn = TRUE) AS churned_customers,

    COUNTIF(Churn = FALSE) AS retained_customers,

    ROUND(AVG(TotalCharges), 2) AS average_total_charges,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS churn_rate_percentage,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = FALSE) * 100,
            COUNT(*)
        ), 2
    ) AS retention_rate_percentage

FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`

WHERE
    TotalCharges IS NOT NULL

GROUP BY
    total_charge_range

ORDER BY
    MIN(TotalCharges);

-- Insight 11 – Partner Status-wise Churn Analysis
SELECT
    CASE
        WHEN Partner = TRUE THEN 'Has Partner'
        ELSE 'No Partner'
    END AS partner_status,

    COUNT(*) AS total_customers,

    COUNTIF(Churn = TRUE) AS churned_customers,

    COUNTIF(Churn = FALSE) AS retained_customers,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS churn_rate_percentage,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = FALSE) * 100,
            COUNT(*)
        ), 2
    ) AS retention_rate_percentage

FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`

GROUP BY
    partner_status

ORDER BY
    churn_rate_percentage DESC;

-- Insight 12 – Dependents-wise Churn Analysis
SELECT
    CASE
        WHEN Dependents = TRUE THEN 'Has Dependents'
        ELSE 'No Dependents'
    END AS dependent_status,

    COUNT(*) AS total_customers,

    COUNTIF(Churn = TRUE) AS churned_customers,

    COUNTIF(Churn = FALSE) AS retained_customers,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = TRUE) * 100,
            COUNT(*)
        ), 2
    ) AS churn_rate_percentage,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = FALSE) * 100,
            COUNT(*)
        ), 2
    ) AS retention_rate_percentage

FROM
    `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`

GROUP BY
    dependent_status

ORDER BY
    churn_rate_percentage DESC;

-- Insight 13 – Add-on Services-wise Churn Analysis
WITH service_data AS (

    SELECT
        customerID,
        Churn,
        service_name,
        service_status

    FROM
        `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`

    UNPIVOT (
        service_status FOR service_name IN (
            OnlineSecurity,
            OnlineBackup,
            DeviceProtection,
            TechSupport,
            StreamingTV,
            StreamingMovies
        )
    )
),

service_analysis AS (

    SELECT
        service_name,
        service_status,

        COUNT(*) AS total_customers,

        COUNTIF(Churn = TRUE) AS churned_customers,

        COUNTIF(Churn = FALSE) AS retained_customers,

        ROUND(
            SAFE_DIVIDE(
                COUNTIF(Churn = TRUE) * 100,
                COUNT(*)
            ), 2
        ) AS churn_rate_percentage,

        ROUND(
            SAFE_DIVIDE(
                COUNTIF(Churn = FALSE) * 100,
                COUNT(*)
            ), 2
        ) AS retention_rate_percentage

    FROM service_data

    GROUP BY
        service_name,
        service_status
)

SELECT *
FROM service_analysis

ORDER BY
    service_name,
    churn_rate_percentage DESC;

-- Insight 14 – Revenue at Risk Analysis
WITH revenue_summary AS (

    SELECT
        COUNT(*) AS total_customers,

        SUM(MonthlyCharges) AS total_monthly_revenue,

        SUM(
            IF(Churn = TRUE, MonthlyCharges, 0)
        ) AS churned_monthly_revenue,

        SUM(
            IF(Churn = FALSE, MonthlyCharges, 0)
        ) AS retained_monthly_revenue,

        AVG(
            IF(Churn = TRUE, MonthlyCharges, NULL)
        ) AS avg_charges_churned_customers,

        AVG(
            IF(Churn = FALSE, MonthlyCharges, NULL)
        ) AS avg_charges_retained_customers

    FROM
        `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`
)

SELECT

    total_customers,

    ROUND(total_monthly_revenue, 2)
        AS total_monthly_revenue,

    ROUND(churned_monthly_revenue, 2)
        AS churned_monthly_revenue,

    ROUND(retained_monthly_revenue, 2)
        AS retained_monthly_revenue,

    ROUND(
        SAFE_DIVIDE(
            churned_monthly_revenue * 100,
            total_monthly_revenue
        ), 2
    ) AS revenue_at_risk_percentage,

    ROUND(avg_charges_churned_customers, 2)
        AS avg_charges_churned_customers,

    ROUND(avg_charges_retained_customers, 2)
        AS avg_charges_retained_customers

FROM revenue_summary;

-- Insight 15 – High-Risk Customer Segmentation
WITH customer_segments AS (

    SELECT
        customerID,
        Churn,
        MonthlyCharges,

        CASE
            WHEN tenure <= 12 THEN 'New Customer (0-12 Months)'
            ELSE 'Established Customer (13+ Months)'
        END AS tenure_segment,

        CASE
            WHEN Contract = 'Pay-as-you-go'
                THEN 'Pay-as-you-go'
            WHEN Contract = 'Jio Prime (1 Year)'
                THEN '1-Year Contract'
            WHEN Contract = 'Jio Prime (2 Years)'
                THEN '2-Year Contract'
        END AS contract_segment,

        CASE
            WHEN MonthlyCharges > 60
                THEN 'High Charges (>60)'
            ELSE 'Standard Charges (<=60)'
        END AS charges_segment,

        CASE
            WHEN OnlineSecurity = 'Yes'
                 AND TechSupport = 'Yes'
                THEN 'Both Services'

            WHEN OnlineSecurity = 'No'
                 AND TechSupport = 'No'
                THEN 'Neither Service'

            WHEN OnlineSecurity = 'No internet service'
                 AND TechSupport = 'No internet service'
                THEN 'No Internet Service'

            ELSE 'One Service'
        END AS support_segment

    FROM
        `dsml-sql-470814.jio_churn_analysis.jio_churn_cleaned`
),

risk_analysis AS (

    SELECT
        tenure_segment,
        contract_segment,
        charges_segment,
        support_segment,

        COUNT(*) AS total_customers,

        COUNTIF(Churn = TRUE) AS churned_customers,

        COUNTIF(Churn = FALSE) AS retained_customers,

        ROUND(
            SAFE_DIVIDE(
                COUNTIF(Churn = TRUE) * 100,
                COUNT(*)
            ), 2
        ) AS churn_rate_percentage,

        ROUND(
            SAFE_DIVIDE(
                COUNTIF(Churn = FALSE) * 100,
                COUNT(*)
            ), 2
        ) AS retention_rate_percentage

    FROM customer_segments

    GROUP BY
        tenure_segment,
        contract_segment,
        charges_segment,
        support_segment
)

SELECT *
FROM risk_analysis

ORDER BY
    churn_rate_percentage DESC,
    total_customers DESC;

