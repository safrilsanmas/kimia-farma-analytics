CREATE OR REPLACE TABLE `Rakamin_KF_Analytics.Analisis` AS
SELECT
    t.transaction_id,
    t.date,
    
    -- Kolom waktu untuk analisis
    EXTRACT(YEAR FROM t.date) AS year,
    FORMAT_DATE('%Y-%m', t.date) AS month,

    -- Informasi cabang
    t.branch_id,
    k.branch_name,
    k.kota,
    k.provinsi,
    k.rating AS rating_cabang,

    -- Informasi transaksi & produk
    t.customer_name,
    t.product_id,
    p.product_name,
    t.price AS actual_price,
    t.discount_percentage,

    -- Persentase gross laba berdasarkan harga
    CASE 
        WHEN t.price <= 50000 THEN 0.10
        WHEN t.price > 50000 AND t.price <= 100000 THEN 0.15
        WHEN t.price > 100000 AND t.price <= 300000 THEN 0.20
        WHEN t.price > 300000 AND t.price <= 500000 THEN 0.25
        ELSE 0.30
    END AS persentase_gross_laba,

    -- Nett sales = harga - diskon
    (t.price - (t.price * t.discount_percentage)) AS nett_sales,

    -- Nett profit = nett_sales * persentase gross laba
    (t.price - (t.price * t.discount_percentage)) *
    CASE 
        WHEN t.price <= 50000 THEN 0.10
        WHEN t.price > 50000 AND t.price <= 100000 THEN 0.15
        WHEN t.price > 100000 AND t.price <= 300000 THEN 0.20
        WHEN t.price > 300000 AND t.price <= 500000 THEN 0.25
        ELSE 0.30
    END AS nett_profit,

    -- Rating transaksi sebagai indikator layanan
    t.rating AS rating_transaksi

FROM `Rakamin_KF_Analytics.transaksi` AS t
JOIN `Rakamin_KF_Analytics.kantor_cabang` AS k
    ON t.branch_id = k.branch_id
JOIN `Rakamin_KF_Analytics.product` AS p
    ON t.product_id = p.product_id;
