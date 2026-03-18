# BigDataSnowflake

## Инструкция по запуску

1. Клонировать репозиторий:
```bash
git clone https://github.com/ElizabetDA/BDSnowflake.git
cd BDSnowflake
```

2. Запустить проект:
```bash
docker compose up -d
```

3. Подключиться к PostgreSQL через DBeaver или psql.


## Параметры подключения

- Host: `localhost`
- Port: `5433`
- Database: `bigdata_lab`
- User: `postgres`
- Password: `postgres`

## Структура проекта

```text
.
├── docker-compose.yml
├── README.md
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
├── sql/
│   └── checks.sql
└── er_diagram.png
```

## Содержание проекта

- `staging.mock_data` — исходная широкая таблица после загрузки CSV;
- `dwh.fact_sales` — таблица фактов продаж;
- `dwh.dim_*` — таблицы измерений аналитической модели;
- `diagram.png` — ER-диаграмма snowflake-модели.


## Результат

В проекте реализованы:
- загрузка 10 CSV-файлов в PostgreSQL;
- staging-слой `staging.mock_data`;
- DDL-скрипты создания snowflake-модели;
- DML-скрипты заполнения таблиц фактов и измерений;
- запуск проекта через Docker Compose.
