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

Применены следующие способы оптимизации из лекции:

| Версия | Что применено |
|---|---|
| `transactions` | Базовая (точка отсчёта) |
| `transactions_v1` | `LowCardinality(String)` для текстовых колонок |
| `transactions_v2` | v1 + `DateTime` + `PARTITION BY toYYYYMM(transaction_time)` |
| `transactions_v3` | v2 + `CODEC(ZSTD(1))` + `CODEC(DoubleDelta, ZSTD(1))` + `UInt32` |

### Сравнение размеров

| Таблица | Размер на диске | Строк | Партиций |
|---|---|---|---|
| `transactions` | 1.43 MiB | 50 000 | 2 |
| `transactions_v1` | 1.18 MiB | 50 000 | 1 |
| `transactions_v2` | 1.37 MiB | 50 000 | 15 |
| `transactions_v3` | **1.02 MiB** | 50 000 | 15 |

### Сравнение скорости запросов

Запрос: `SELECT us_state, cat_id, sum(amount) FROM ... GROUP BY us_state, cat_id ORDER BY us_state, total DESC LIMIT 1 BY us_state`.

| Таблица | Время |
|---|---|
| `transactions` | 0.015 сек |
| `transactions_v1` | 0.127 сек |
| `transactions_v2` | 0.011 сек |
| `transactions_v3` | **0.009 сек** |

### Выводы

- **`LowCardinality(String)`** уменьшает размер текстовых колонок за счёт словарного кодирования. Но при выполнении запросов ClickHouse тратится дополнительное время на то, чтобы «расшифровать» эти значения обратно. Из-за этого v1 оказалась медленнее базовой таблицы. (v1: 0.127 сек).
- **`PARTITION BY toYYYYMM`** разбивает таблицу на 15 партиций (по месяцам). Из-за этого общий размер чуть больше, зато когда мы ищем транзакции за конкретный месяц, ClickHouse читает только одну маленькую часть, а не всю таблицу целиком.
- **`CODEC(ZSTD(1))` + `DoubleDelta`** дают **максимальное сжатие**. v3 — самая компактная (1.02 MiB, -29% от базовой) и самая быстрая (0.009 сек).
- **`UInt32` вместо `Int32`** для `population_city` — небольшая, но бесплатная экономия.

**Итоговая рекомендация:** для продакшена используем `transactions_v3` — она даёт лучший баланс между размером и скоростью.
