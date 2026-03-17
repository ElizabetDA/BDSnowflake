# Лабораторная работа №1  
## BigDataSnowflake — нормализация исходных данных в аналитическую модель snowflake

## Описание работы

В рамках лабораторной работы выполнена трансформация исходных денормализованных данных из CSV-файлов в аналитическую модель данных типа **snowflake** в СУБД PostgreSQL.

Исходные данные содержат информацию о:
- покупателях;
- питомцах покупателей;
- продавцах;
- магазинах;
- поставщиках;
- товарах для домашних животных;
- продажах.

Работа выполнена в соответствии с алгоритмом задания:
1. подготовлен репозиторий с исходными CSV-файлами;
2. настроен запуск PostgreSQL через Docker;
3. все исходные файлы загружены в таблицу `staging.mock_data`;
4. выполнен анализ структуры данных;
5. выделены сущности фактов и измерений;
6. реализованы DDL-скрипты создания аналитической модели;
7. реализованы DML-скрипты заполнения таблиц;
8. выполнена проверка корректности загрузки и аналитических запросов.

---

## Состав репозитория

```text
.
├── docker-compose.yml
├── data/
│   ├── MOCK_DATA.csv
│   ├── MOCK_DATA (1).csv
│   ├── MOCK_DATA (2).csv
│   ├── MOCK_DATA (3).csv
│   ├── MOCK_DATA (4).csv
│   ├── MOCK_DATA (5).csv
│   ├── MOCK_DATA (6).csv
│   ├── MOCK_DATA (7).csv
│   ├── MOCK_DATA (8).csv
│   └── MOCK_DATA (9).csv
├── init/
│   ├── 00_init.sql
│   ├── 01_load_raw.sh
│   ├── 02_ddl.sql
│   └── 03_dml.sql
└── sql/
    └── checks.sql
```

## Аналитическая модель

Таблица фактов содержит:
- дату продажи;
- покупателя;
- питомца покупателя;
- продавца;
- магазин;
- товар;
- количество проданных единиц;
- итоговую стоимость продажи.

### Таблицы измерений
В проекте реализованы следующие измерения:
- `dwh.dim_date`
- `dwh.dim_customer`
- `dwh.dim_customer_pet`
- `dwh.dim_seller`
- `dwh.dim_store`
- `dwh.dim_product`
- `dwh.dim_supplier`

Дополнительно используются нормализованные справочники, что соответствует модели **snowflake**.

---

## Команды для запуска и проверки проекта

### Клонирование репозитория
```bash
git clone https://github.com/ElizabetDA/BDSnowflake
cd BDSnowflake
docker compose up -d
docker ps
docker exec -it bigdata_snowflake_pg psql -U postgres -d bigdata_lab
\pset pager off
```

### Проверка загрузки исходных данных
```sql
SELECT COUNT(*) FROM staging.mock_data;
```

Ожидаемый результат:
```text
10000
```

### Проверка таблицы фактов
```sql
SELECT COUNT(*) FROM dwh.fact_sales;
```

Ожидаемый результат:
```text
10000
```

### Проверка таблицы дат
```sql
SELECT COUNT(*) FROM dwh.dim_date;
```

### Проверочный аналитический запрос по месяцам и товарам
```sql
SELECT 
    d.year_num,
    d.month_num,
    p.product_name,
    SUM(f.sale_quantity) AS total_qty,
    ROUND(SUM(f.sale_total_price), 2) AS total_revenue
FROM dwh.fact_sales f
JOIN dwh.dim_date d ON f.sale_date_key = d.date_key
JOIN dwh.dim_product p ON f.product_key = p.product_key
GROUP BY d.year_num, d.month_num, p.product_name
ORDER BY d.year_num, d.month_num, total_revenue DESC;
```

### Выход из psql
```sql
\q
```

---

## Как подключиться через DBeaver

Параметры подключения:
- **Host:** `localhost`
- **Port:** `5432`
- **Database:** `bigdata_lab`
- **User:** `postgres`
- **Password:** `postgres`

---

## Порядок автоматической инициализации

При первом запуске контейнера выполняются следующие шаги:
1. создаётся staging-слой;
2. исходные CSV-файлы загружаются в таблицу `staging.mock_data`;
3. создаются таблицы snowflake-модели;
4. таблицы измерений и таблица фактов заполняются данными из staging-слоя.

---

## Проверка результата

Минимальный набор проверок:
```sql
SELECT COUNT(*) FROM staging.mock_data;
SELECT COUNT(*) FROM dwh.fact_sales;
SELECT COUNT(*) FROM dwh.dim_date;
```

---

## Результат работы

В результате выполнения лабораторной работы:
- исходные денормализованные данные были загружены в PostgreSQL;
- построена аналитическая модель типа **snowflake**;
- созданы таблица фактов и таблицы измерений;
- реализованы DDL- и DML-скрипты;
- обеспечен воспроизводимый запуск проекта и проверка результата через Docker.
