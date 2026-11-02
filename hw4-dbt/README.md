# Fraud Analytics dbt Project

dbt-проект для анализа транзакций и выявления фрода на основе данных из ClickHouse (таблица `fraud_db.transactions`). Реализована слоистая архитектура: raw → staging → marts.

## 🏗️ Архитектура

- **Source:** `fraud_source.transactions` (сырые данные из ClickHouse).
- **Staging:** `stg_transactions` — очистка (сумма >= 0), приведение типов, сегментация суммы через макрос `amount_bucket`.
- **Marts:** 4 аналитические витрины.

## 📊 Витрины

| Витрина | Описание |
|---------|----------|
| `mart_daily_state_metrics` | Дневные метрики по штатам: количество, сумма, средний чек, P95, доля крупных транзакций. |
| `mart_fraud_by_category` | Уровень мошенничества по категориям: fraud_rate, суммы. |
| `mart_fraud_by_state` | Географический анализ фрода: fraud_rate по штатам. |
| `mart_hourly_fraud_pattern` | Временные паттерны фрода по дням недели и часам. |

## 🧪 Тесты и пакеты

- Базовые тесты: `not_null`, `unique`, `accepted_values` (для `gender`).
- Пакеты: `dbt_utils` (accepted_range), `dbt_expectations` (expect_column_values_to_be_between).
- Singular test: `assert_no_negative_amounts` (проверка отсутствия отрицательных сумм).
- Всего: **15 тестов**, все проходят (`dbt test` → PASS=15).

## 🚀 Запуск

1. Поднять базу данных и загрузить данные (папка `hw2-clickhouse`):
```bash
cd hw2-clickhouse
docker compose up -d    
```

2. Перейти в папку dbt-проекта и запустить модели:
```bash
cd ../hw4-dbt
dbt deps
dbt run
dbt test
dbt docs generate
dbt docs serve
```

*Примечание:* 

- profiles.yml должен лежать в ~/.dbt/profiles.yml и указывать на user: dbt_user, schema: fraud_db, port: 8123

## Структура проекта

```text
hw4-dbt/
├── models/
│   ├── sources/sources.yml
│   ├── staging/stg_transactions.sql
│   └── marts/ (4 витрины)
├── macros/amount_bucket.sql
├── tests/assert_no_negative_amounts.sql
├── schema.yml
├── packages.yml
└── dbt_project.yml
```