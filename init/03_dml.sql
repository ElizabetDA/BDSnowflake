INSERT INTO dwh.dim_country(country_name)
SELECT DISTINCT country_name
FROM (
    SELECT customer_country AS country_name FROM staging.mock_data
    UNION
    SELECT seller_country FROM staging.mock_data
    UNION
    SELECT store_country FROM staging.mock_data
    UNION
    SELECT supplier_country FROM staging.mock_data
) s
WHERE country_name IS NOT NULL;

INSERT INTO dwh.dim_city(city_name, country_id)
SELECT DISTINCT m.store_city, c.country_id
FROM staging.mock_data m
JOIN dwh.dim_country c ON c.country_name = m.store_country
WHERE m.store_city IS NOT NULL
UNION
SELECT DISTINCT m.supplier_city, c.country_id
FROM staging.mock_data m
JOIN dwh.dim_country c ON c.country_name = m.supplier_country
WHERE m.supplier_city IS NOT NULL;

INSERT INTO dwh.dim_pet_type(pet_type_name)
SELECT DISTINCT customer_pet_type
FROM staging.mock_data
WHERE customer_pet_type IS NOT NULL;

INSERT INTO dwh.dim_pet_breed(breed_name)
SELECT DISTINCT customer_pet_breed
FROM staging.mock_data
WHERE customer_pet_breed IS NOT NULL;

INSERT INTO dwh.dim_pet_category(pet_category_name)
SELECT DISTINCT pet_category
FROM staging.mock_data
WHERE pet_category IS NOT NULL;

INSERT INTO dwh.dim_product_category(category_name)
SELECT DISTINCT product_category
FROM staging.mock_data
WHERE product_category IS NOT NULL;

INSERT INTO dwh.dim_product_brand(brand_name)
SELECT DISTINCT product_brand
FROM staging.mock_data
WHERE product_brand IS NOT NULL;

INSERT INTO dwh.dim_product_material(material_name)
SELECT DISTINCT product_material
FROM staging.mock_data
WHERE product_material IS NOT NULL;

INSERT INTO dwh.dim_product_color(color_name)
SELECT DISTINCT product_color
FROM staging.mock_data
WHERE product_color IS NOT NULL;

INSERT INTO dwh.dim_product_size(size_name)
SELECT DISTINCT product_size
FROM staging.mock_data
WHERE product_size IS NOT NULL;

INSERT INTO dwh.dim_date(date_key, full_date, day_num, month_num, month_name, quarter_num, year_num)
SELECT DISTINCT
    TO_CHAR(sale_date, 'YYYYMMDD')::INTEGER AS date_key,
    sale_date,
    EXTRACT(DAY FROM sale_date)::SMALLINT,
    EXTRACT(MONTH FROM sale_date)::SMALLINT,
    TO_CHAR(sale_date, 'Month'),
    EXTRACT(QUARTER FROM sale_date)::SMALLINT,
    EXTRACT(YEAR FROM sale_date)::INTEGER
FROM staging.mock_data
WHERE sale_date IS NOT NULL;

INSERT INTO dwh.dim_customer(first_name, last_name, age, email, country_id, postal_code)
SELECT DISTINCT
    m.customer_first_name,
    m.customer_last_name,
    m.customer_age,
    m.customer_email,
    c.country_id,
    m.customer_postal_code
FROM staging.mock_data m
LEFT JOIN dwh.dim_country c ON c.country_name = m.customer_country;

INSERT INTO dwh.dim_customer_pet(customer_key, pet_type_id, pet_name, pet_breed_id)
SELECT DISTINCT
    dc.customer_key,
    dpt.pet_type_id,
    m.customer_pet_name,
    dpb.pet_breed_id
FROM staging.mock_data m
JOIN dwh.dim_customer dc ON dc.email = m.customer_email
LEFT JOIN dwh.dim_pet_type dpt ON dpt.pet_type_name = m.customer_pet_type
LEFT JOIN dwh.dim_pet_breed dpb ON dpb.breed_name = m.customer_pet_breed;

INSERT INTO dwh.dim_seller(first_name, last_name, email, country_id, postal_code)
SELECT DISTINCT
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    c.country_id,
    m.seller_postal_code
FROM staging.mock_data m
LEFT JOIN dwh.dim_country c ON c.country_name = m.seller_country;

INSERT INTO dwh.dim_supplier(
    supplier_name, supplier_contact, supplier_email, supplier_phone, supplier_address, city_id
)
SELECT DISTINCT
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    m.supplier_address,
    city.city_id
FROM staging.mock_data m
LEFT JOIN dwh.dim_country c ON c.country_name = m.supplier_country
LEFT JOIN dwh.dim_city city ON city.city_name = m.supplier_city AND city.country_id = c.country_id;

INSERT INTO dwh.dim_store(store_name, store_location, city_id, state_code, phone, email)
SELECT DISTINCT
    m.store_name,
    m.store_location,
    city.city_id,
    m.store_state,
    m.store_phone,
    m.store_email
FROM staging.mock_data m
LEFT JOIN dwh.dim_country c ON c.country_name = m.store_country
LEFT JOIN dwh.dim_city city ON city.city_name = m.store_city AND city.country_id = c.country_id;

INSERT INTO dwh.dim_product(
    product_name, product_category_id, pet_category_id, brand_id, material_id,
    color_id, size_id, supplier_key, price, stock_quantity, weight, description,
    rating, reviews_count, release_date, expiry_date
)
SELECT DISTINCT
    m.product_name,
    pc.product_category_id,
    petc.pet_category_id,
    pb.brand_id,
    pm.material_id,
    pcol.color_id,
    psz.size_id,
    s.supplier_key,
    m.product_price,
    m.product_quantity,
    m.product_weight,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    m.product_release_date,
    m.product_expiry_date
FROM staging.mock_data m
LEFT JOIN dwh.dim_product_category pc ON pc.category_name = m.product_category
LEFT JOIN dwh.dim_pet_category petc ON petc.pet_category_name = m.pet_category
LEFT JOIN dwh.dim_product_brand pb ON pb.brand_name = m.product_brand
LEFT JOIN dwh.dim_product_material pm ON pm.material_name = m.product_material
LEFT JOIN dwh.dim_product_color pcol ON pcol.color_name = m.product_color
LEFT JOIN dwh.dim_product_size psz ON psz.size_name = m.product_size
LEFT JOIN dwh.dim_supplier s ON s.supplier_email = m.supplier_email;

INSERT INTO dwh.fact_sales(
    source_row_id, sale_date_key, customer_key, customer_pet_key,
    seller_key, store_key, product_key, sale_quantity, sale_total_price
)
SELECT
    m.id,
    TO_CHAR(m.sale_date, 'YYYYMMDD')::INTEGER,
    dc.customer_key,
    dcp.customer_pet_key,
    ds.seller_key,
    st.store_key,
    dp.product_key,
    m.sale_quantity,
    m.sale_total_price
FROM staging.mock_data m
JOIN dwh.dim_customer dc ON dc.email = m.customer_email
LEFT JOIN dwh.dim_pet_type dpt ON dpt.pet_type_name = m.customer_pet_type
LEFT JOIN dwh.dim_pet_breed dpb ON dpb.breed_name = m.customer_pet_breed
LEFT JOIN dwh.dim_customer_pet dcp
    ON dcp.customer_key = dc.customer_key
   AND dcp.pet_name IS NOT DISTINCT FROM m.customer_pet_name
   AND dcp.pet_type_id IS NOT DISTINCT FROM dpt.pet_type_id
   AND dcp.pet_breed_id IS NOT DISTINCT FROM dpb.pet_breed_id
JOIN dwh.dim_seller ds ON ds.email = m.seller_email
JOIN dwh.dim_store st ON st.email = m.store_email
JOIN dwh.dim_supplier sup ON sup.supplier_email = m.supplier_email
LEFT JOIN dwh.dim_product_category pc ON pc.category_name = m.product_category
LEFT JOIN dwh.dim_pet_category petc ON petc.pet_category_name = m.pet_category
LEFT JOIN dwh.dim_product_brand pb ON pb.brand_name = m.product_brand
LEFT JOIN dwh.dim_product_material pm ON pm.material_name = m.product_material
LEFT JOIN dwh.dim_product_color pcol ON pcol.color_name = m.product_color
LEFT JOIN dwh.dim_product_size psz ON psz.size_name = m.product_size
JOIN dwh.dim_product dp
    ON dp.product_name = m.product_name
   AND dp.product_category_id IS NOT DISTINCT FROM pc.product_category_id
   AND dp.pet_category_id IS NOT DISTINCT FROM petc.pet_category_id
   AND dp.brand_id IS NOT DISTINCT FROM pb.brand_id
   AND dp.material_id IS NOT DISTINCT FROM pm.material_id
   AND dp.color_id IS NOT DISTINCT FROM pcol.color_id
   AND dp.size_id IS NOT DISTINCT FROM psz.size_id
   AND dp.supplier_key = sup.supplier_key
   AND dp.price IS NOT DISTINCT FROM m.product_price
   AND dp.stock_quantity IS NOT DISTINCT FROM m.product_quantity
   AND dp.weight IS NOT DISTINCT FROM m.product_weight
   AND dp.description IS NOT DISTINCT FROM m.product_description
   AND dp.rating IS NOT DISTINCT FROM m.product_rating
   AND dp.reviews_count IS NOT DISTINCT FROM m.product_reviews
   AND dp.release_date IS NOT DISTINCT FROM m.product_release_date
   AND dp.expiry_date IS NOT DISTINCT FROM m.product_expiry_date;
