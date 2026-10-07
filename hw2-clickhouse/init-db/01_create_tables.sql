-- Kafka Table Engine
CREATE TABLE IF NOT EXISTS fraud_db.kafka_transactions_stream (
    transaction_time String,
    merch            String,
    cat_id           String,
    amount           Float64,
    gender           String,
    one_city         String,
    us_state         String,
    population_city  Int32,
    jobs             String
) ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka:29092',
    kafka_topic_list = 'transactions',
    kafka_group_name = 'clickhouse_consumer',
    kafka_format = 'JSONEachRow',
    kafka_num_consumers = 1;

-- MergeTree (целевая таблица для хранения транзакций)
CREATE TABLE IF NOT EXISTS fraud_db.transactions (
    transaction_time String,
    merch            String,
    cat_id           String,
    amount           Float64,
    gender           String,
    one_city         String,
    us_state         String,
    population_city  Int32,
    jobs             String
) ENGINE = MergeTree()
ORDER BY (us_state, cat_id);


-- Materialized View (связующий мост Kafka -> MergeTree)
CREATE MATERIALIZED VIEW IF NOT EXISTS fraud_db.mv_kafka_to_transactions
TO fraud_db.transactions AS
SELECT
    transaction_time,
    merch,
    cat_id,
    amount,
    gender,
    one_city,
    us_state,
    population_city,
    jobs
FROM fraud_db.kafka_transactions_stream;