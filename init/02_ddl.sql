DROP TABLE IF EXISTS dwh.fact_sales CASCADE;
DROP TABLE IF EXISTS dwh.dim_customer_pet CASCADE;
DROP TABLE IF EXISTS dwh.dim_product CASCADE;
DROP TABLE IF EXISTS dwh.dim_store CASCADE;
DROP TABLE IF EXISTS dwh.dim_supplier CASCADE;
DROP TABLE IF EXISTS dwh.dim_seller CASCADE;
DROP TABLE IF EXISTS dwh.dim_customer CASCADE;
DROP TABLE IF EXISTS dwh.dim_date CASCADE;
DROP TABLE IF EXISTS dwh.dim_product_size CASCADE;
DROP TABLE IF EXISTS dwh.dim_product_color CASCADE;
DROP TABLE IF EXISTS dwh.dim_product_material CASCADE;
DROP TABLE IF EXISTS dwh.dim_product_brand CASCADE;
DROP TABLE IF EXISTS dwh.dim_product_category CASCADE;
DROP TABLE IF EXISTS dwh.dim_pet_category CASCADE;
DROP TABLE IF EXISTS dwh.dim_pet_breed CASCADE;
DROP TABLE IF EXISTS dwh.dim_pet_type CASCADE;
DROP TABLE IF EXISTS dwh.dim_city CASCADE;
DROP TABLE IF EXISTS dwh.dim_country CASCADE;

CREATE TABLE dwh.dim_country (
    country_id BIGSERIAL PRIMARY KEY,
    country_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dwh.dim_city (
    city_id BIGSERIAL PRIMARY KEY,
    city_name TEXT NOT NULL,
    country_id BIGINT REFERENCES dwh.dim_country(country_id),
    UNIQUE (city_name, country_id)
);

CREATE TABLE dwh.dim_pet_type (
    pet_type_id BIGSERIAL PRIMARY KEY,
    pet_type_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dwh.dim_pet_breed (
    pet_breed_id BIGSERIAL PRIMARY KEY,
    breed_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dwh.dim_pet_category (
    pet_category_id BIGSERIAL PRIMARY KEY,
    pet_category_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dwh.dim_product_category (
    product_category_id BIGSERIAL PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dwh.dim_product_brand (
    brand_id BIGSERIAL PRIMARY KEY,
    brand_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dwh.dim_product_material (
    material_id BIGSERIAL PRIMARY KEY,
    material_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dwh.dim_product_color (
    color_id BIGSERIAL PRIMARY KEY,
    color_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dwh.dim_product_size (
    size_id BIGSERIAL PRIMARY KEY,
    size_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dwh.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_num SMALLINT NOT NULL,
    month_num SMALLINT NOT NULL,
    month_name TEXT NOT NULL,
    quarter_num SMALLINT NOT NULL,
    year_num INTEGER NOT NULL
);

CREATE TABLE dwh.dim_customer (
    customer_key BIGSERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER,
    email TEXT NOT NULL UNIQUE,
    country_id BIGINT REFERENCES dwh.dim_country(country_id),
    postal_code TEXT
);

CREATE TABLE dwh.dim_customer_pet (
    customer_pet_key BIGSERIAL PRIMARY KEY,
    customer_key BIGINT NOT NULL REFERENCES dwh.dim_customer(customer_key),
    pet_type_id BIGINT REFERENCES dwh.dim_pet_type(pet_type_id),
    pet_name TEXT,
    pet_breed_id BIGINT REFERENCES dwh.dim_pet_breed(pet_breed_id),
    UNIQUE (customer_key, pet_type_id, pet_name, pet_breed_id)
);

CREATE TABLE dwh.dim_seller (
    seller_key BIGSERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    country_id BIGINT REFERENCES dwh.dim_country(country_id),
    postal_code TEXT
);

CREATE TABLE dwh.dim_supplier (
    supplier_key BIGSERIAL PRIMARY KEY,
    supplier_name TEXT NOT NULL,
    supplier_contact TEXT,
    supplier_email TEXT NOT NULL UNIQUE,
    supplier_phone TEXT,
    supplier_address TEXT,
    city_id BIGINT REFERENCES dwh.dim_city(city_id)
);

CREATE TABLE dwh.dim_store (
    store_key BIGSERIAL PRIMARY KEY,
    store_name TEXT NOT NULL,
    store_location TEXT,
    city_id BIGINT REFERENCES dwh.dim_city(city_id),
    state_code TEXT,
    phone TEXT,
    email TEXT NOT NULL UNIQUE
);

CREATE TABLE dwh.dim_product (
    product_key BIGSERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    product_category_id BIGINT REFERENCES dwh.dim_product_category(product_category_id),
    pet_category_id BIGINT REFERENCES dwh.dim_pet_category(pet_category_id),
    brand_id BIGINT REFERENCES dwh.dim_product_brand(brand_id),
    material_id BIGINT REFERENCES dwh.dim_product_material(material_id),
    color_id BIGINT REFERENCES dwh.dim_product_color(color_id),
    size_id BIGINT REFERENCES dwh.dim_product_size(size_id),
    supplier_key BIGINT REFERENCES dwh.dim_supplier(supplier_key),
    price NUMERIC(12,2),
    stock_quantity INTEGER,
    weight NUMERIC(12,2),
    description TEXT,
    rating NUMERIC(3,1),
    reviews_count INTEGER,
    release_date DATE,
    expiry_date DATE,
    UNIQUE (
        product_name, product_category_id, pet_category_id, brand_id, material_id,
        color_id, size_id, supplier_key, price, stock_quantity, weight,
        description, rating, reviews_count, release_date, expiry_date
    )
);

CREATE TABLE dwh.fact_sales (
    sale_key BIGSERIAL PRIMARY KEY,
    source_row_id INTEGER NOT NULL,
    sale_date_key INTEGER NOT NULL REFERENCES dwh.dim_date(date_key),
    customer_key BIGINT NOT NULL REFERENCES dwh.dim_customer(customer_key),
    customer_pet_key BIGINT REFERENCES dwh.dim_customer_pet(customer_pet_key),
    seller_key BIGINT NOT NULL REFERENCES dwh.dim_seller(seller_key),
    store_key BIGINT NOT NULL REFERENCES dwh.dim_store(store_key),
    product_key BIGINT NOT NULL REFERENCES dwh.dim_product(product_key),
    sale_quantity INTEGER NOT NULL,
    sale_total_price NUMERIC(12,2) NOT NULL
);

CREATE INDEX idx_fact_sales_date ON dwh.fact_sales(sale_date_key);
CREATE INDEX idx_fact_sales_customer ON dwh.fact_sales(customer_key);
CREATE INDEX idx_fact_sales_product ON dwh.fact_sales(product_key);
CREATE INDEX idx_fact_sales_store ON dwh.fact_sales(store_key);
