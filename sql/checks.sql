-- Проверка объёма загруженных исходных данных
SELECT COUNT(*) AS raw_rows FROM staging.mock_data;

-- Количество строк в факте продаж
SELECT COUNT(*) AS fact_rows FROM dwh.fact_sales;

-- Размерности
SELECT 'dim_country' AS table_name, COUNT(*) AS cnt FROM dwh.dim_country
UNION ALL
SELECT 'dim_city', COUNT(*) FROM dwh.dim_city
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dwh.dim_customer
UNION ALL
SELECT 'dim_customer_pet', COUNT(*) FROM dwh.dim_customer_pet
UNION ALL
SELECT 'dim_seller', COUNT(*) FROM dwh.dim_seller
UNION ALL
SELECT 'dim_supplier', COUNT(*) FROM dwh.dim_supplier
UNION ALL
SELECT 'dim_store', COUNT(*) FROM dwh.dim_store
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dwh.dim_product
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dwh.dim_date
ORDER BY table_name;

-- Пример аналитического запроса
SELECT
    d.year_num,
    d.month_num,
    p.product_name,
    SUM(f.sale_quantity) AS total_qty,
    SUM(f.sale_total_price) AS total_revenue
FROM dwh.fact_sales f
JOIN dwh.dim_date d ON d.date_key = f.sale_date_key
JOIN dwh.dim_product p ON p.product_key = f.product_key
GROUP BY d.year_num, d.month_num, p.product_name
ORDER BY d.year_num, d.month_num, total_revenue DESC;
