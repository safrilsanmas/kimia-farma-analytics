CREATE OR REPLACE TABLE `Rakamin_KF_Analytics.Analisis` AS

WITH base_data AS (
    SELECT
        t.transaction_id,
        t.date,
        EXTRACT(YEAR FROM t.date) AS year,
        DATE_TRUNC(t.date, MONTH) AS month_date,

        t.branch_id,
        k.branch_name,
        k.kota,
        k.provinsi,
        k.rating AS rating_cabang,

        t.customer_name,
        t.product_id,
        p.product_name,
        t.price AS actual_price,
        t.discount_percentage,
        t.rating AS rating_transaksi

    FROM `Rakamin_KF_Analytics.transaksi` t
    JOIN `Rakamin_KF_Analytics.kantor_cabang` k
        ON t.branch_id = k.branch_id
    JOIN `Rakamin_KF_Analytics.product` p
        ON t.product_id = p.product_id
),

margin_calculation AS (
    SELECT
        *,
        CASE 
            WHEN actual_price <= 50000 THEN 0.10
            WHEN actual_price <= 100000 THEN 0.15
            WHEN actual_price <= 300000 THEN 0.20
            WHEN actual_price <= 500000 THEN 0.25
            ELSE 0.30
        END AS persentase_gross_laba
    FROM base_data
)

SELECT
    transaction_id,
    date,
    year,
    FORMAT_DATE('%Y-%m', month_date) AS month,

    branch_id,
    branch_name,
    kota,
    provinsi,
    rating_cabang,

    customer_name,
    product_id,
    product_name,
    actual_price,
    discount_percentage,
    persentase_gross_laba,

    -- Nett sales (aman untuk persentase)
    actual_price - (actual_price * discount_percentage / 100) AS nett_sales,

    -- Nett profit
    (actual_price - (actual_price * discount_percentage / 100)) 
        * persentase_gross_laba AS nett_profit,

    rating_transaksi

FROM margin_calculation;
