# HW2 — ClickHouse Analytics

Загрузка данных о транзакциях из CSV в Kafka, затем в ClickHouse через Kafka Table Engine, аналитический SQL-запрос и оптимизация хранения.

## 🏗️ Архитектура

 CSV-файл ▶ Kafka  ▶ ClickHouse  


Компоненты:

1. **`producer`** (Python):
   - Читает `train_sample.csv` (50 000 строк).
   - Отправляет каждую строку в топик Kafka `transactions` в формате JSON.

2. **Kafka Infrastructure**:
   - Zookeeper + Kafka broker.
   - `kafka-setup`: автоматически создаёт топик `transactions`.
   - Топик: `transactions`, 3 партиции, retention 7 дней.

3. **ClickHouse**:
   - `kafka_transactions_stream` — Kafka Table Engine, читает из топика.
   - `transactions` — целевая таблица на движке MergeTree.
   - `mv_kafka_to_transactions` — Materialized View, мост между ними.

## 🚀 Быстрый старт

### Требования
- Docker 20.10+
- Docker Compose 2.0+

### Запуск

```bash
git clone https://github.com/kmurza/mlops-course-hw.git
cd mlops-course-hw/hw2-clickhouse
docker-compose up --build -d
```

Подожди 1–2 минуты, пока контейнеры поднимутся.

### Проверка

**1. Проверь, что все контейнеры запущены:**

```bash
docker ps
```

Должны быть: `zookeeper`, `kafka` (healthy), `kafka-setup` (Exited 0), `clickhouse`, `producer`.

**2. Проверь, что данные попали в ClickHouse:**

```bash
docker exec -it hw2-clickhouse-clickhouse-1 clickhouse-client \
  --query "SELECT COUNT(*) FROM fraud_db.transactions"
```

Должно быть **50 000**.

**3. Посмотри первые строки:**

```bash
docker exec -it hw2-clickhouse-clickhouse-1 clickhouse-client \
  --query "SELECT * FROM fraud_db.transactions LIMIT 5"
```

## 📊 SQL-запросы (пункт 3)

Задача: **категория наибольшей транзакции по каждому штату**.

Формулировка допускает два толкования, поэтому реализовала оба.

### Первый вариант — категория с максимальной суммой транзакций

Файл: `queries/top_category_by_state_sum.sql`

```sql
SELECT
    us_state,
    cat_id,
    sum(amount) AS total_amount
FROM fraud_db.transactions
GROUP BY us_state, cat_id
ORDER BY us_state, total_amount DESC
LIMIT 1 BY us_state;
```

### Второй вариант — категория самой крупной единичной транзакции

Файл: `queries/top_category_by_state_max.sql`

```sql
SELECT
    us_state,
    cat_id,
    amount
FROM fraud_db.transactions
ORDER BY us_state, amount DESC
LIMIT 1 BY us_state;
```

Результаты лежат в:

- `results/top_category_by_state_sum.csv`
- `results/top_category_by_state_max.csv`

## ⚡ Оптимизация хранения (пункт 4)

