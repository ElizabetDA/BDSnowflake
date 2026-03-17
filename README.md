# BigDataSnowflake — Лабораторная работа №1

Готовая структура проекта для загрузки 10 CSV-файлов в PostgreSQL и трансформации исходной таблицы `staging.mock_data` в аналитическую модель `snowflake` (`dwh.fact_sales` + измерения).

## Структура

- `docker-compose.yml` — PostgreSQL в Docker
- `data/` — исходные CSV
- `init/00_init.sql` — создание схемы и staging-таблицы
- `init/01_load_raw.sh` — загрузка всех CSV в `staging.mock_data`
- `init/02_ddl.sql` — DDL для измерений и фактов
- `init/03_dml.sql` — DML для заполнения snowflake-модели
- `sql/checks.sql` — проверки и пример аналитического запроса

## Как установить Docker на Ubuntu

Официальная документация Docker рекомендует ставить Docker Engine через apt-репозиторий. Поддерживаются 64-bit Ubuntu 22.04, 24.04 и 25.10, а после установки можно проверить работу командой `sudo docker run hello-world`. Также пост-установка для запуска без `sudo` — добавить пользователя в группу `docker`. citeturn786005search0turn786005search6turn350985search0

### Команды установки

```bash
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"${UBUNTU_CODENAME:-$VERSION_CODENAME}\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker run hello-world
```

### Чтобы запускать без `sudo`

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```

## Как запустить лабораторную

Открой терминал в папке проекта и выполни:

```bash
docker compose up -d
```

Важно: официальный образ `postgres` запускает все `*.sql` и `*.sh` из `/docker-entrypoint-initdb.d` **только при первом старте на пустом volume**. Поэтому если хочешь перезалить данные с нуля, сначала делай: citeturn350985search0turn350985search7

```bash
docker compose down -v
docker compose up -d
```

## Как проверить, что всё загрузилось

```bash
docker exec -it bigdata_snowflake_pg psql -U postgres -d bigdata_lab
```

Внутри `psql`:

```sql
SELECT COUNT(*) FROM staging.mock_data;
SELECT COUNT(*) FROM dwh.fact_sales;
\i /workspace/sql/checks.sql
```

## Что важно для защиты

1. Исходная модель — одна широкая денормализованная таблица `staging.mock_data`.
2. Поля `sale_customer_id`, `sale_seller_id`, `sale_product_id` нельзя считать глобальными ключами, потому что они повторяются между файлами.
3. Поэтому в аналитической модели используются surrogate keys (`BIGSERIAL`) и загрузка по бизнес-полям.
4. Факт: `dwh.fact_sales`.
5. Измерения: покупатель, питомец покупателя, продавец, магазин, поставщик, товар, дата и вспомогательные нормализованные справочники (страна, город, категория, бренд, материал, цвет, размер, тип питомца и т.д.).
6. Это уже именно snowflake, а не просто звезда, потому что часть измерений вынесена в отдельные подизмерения.

## Если Docker совсем не хочется

Можно сделать то же самое через локальный PostgreSQL + DBeaver:
1. установить PostgreSQL,
2. создать БД `bigdata_lab`,
3. выполнить `00_init.sql`, `02_ddl.sql`, `03_dml.sql`,
4. а CSV загрузить в `staging.mock_data` через Import Data в DBeaver.

Но для сдачи у тебя по ТЗ лучше иметь именно `docker-compose.yml`.
