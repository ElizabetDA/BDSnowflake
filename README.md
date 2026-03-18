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

### Параметры подключения
- Host: `localhost`
- Port: `5432`
- Database: `bigdata_lab`
- User: `postgres`
- Password: `postgres`

### Подключение через psql
```bash
docker exec -it bigdata_snowflake_pg psql -U postgres -d bigdata_lab
```

После входа можно отключить pager:
```sql
\pset pager off
```


## Структура проекта

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
