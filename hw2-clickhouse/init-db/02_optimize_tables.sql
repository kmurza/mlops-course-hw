-- V1 - LowCardinality для текстовых колонок
CREATE TABLE IF NOT EXISTS fraud_db.transactions_v1 (
    transaction_time String,
    merch            String,
    cat_id           LowCardinality(String),
    amount           Float64,
    gender           LowCardinality(String),
    one_city         LowCardinality(String),
    us_state         LowCardinality(String),
    population_city  Int32,
    jobs             LowCardinality(String)
)
ENGINE = MergeTree()
ORDER BY (us_state, cat_id, transaction_time);

INSERT INTO fraud_db.transactions_v1
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
FROM fraud_db.transactions;


-- V2 - V1 + DateTime + партиционирование по месяцам
CREATE TABLE IF NOT EXISTS fraud_db.transactions_v2 (
    transaction_time DateTime,
    merch            String,
    cat_id           LowCardinality(String),
    amount           Float64,
    gender           LowCardinality(String),
    one_city         LowCardinality(String),
    us_state         LowCardinality(String),
    population_city  Int32,
    jobs             LowCardinality(String)
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(transaction_time)
ORDER BY (us_state, cat_id, transaction_time);

INSERT INTO fraud_db.transactions_v2
SELECT
    parseDateTimeBestEffort(transaction_time) AS transaction_time,
    merch,
    cat_id,
    amount,
    gender,
    one_city,
    us_state,
    population_city,
    jobs
FROM fraud_db.transactions;


-- V3 - V2 + кодеки + UInt32
CREATE TABLE IF NOT EXISTS fraud_db.transactions_v3 (
    transaction_time DateTime CODEC(DoubleDelta, ZSTD(1)),
    merch            String   CODEC(ZSTD(1)),
    cat_id           LowCardinality(String) CODEC(ZSTD(1)),
    amount           Float64  CODEC(ZSTD(1)),
    gender           LowCardinality(String) CODEC(ZSTD(1)),
    one_city         LowCardinality(String) CODEC(ZSTD(1)),
    us_state         LowCardinality(String) CODEC(ZSTD(1)),
    population_city  UInt32   CODEC(ZSTD(1)),
    jobs             LowCardinality(String) CODEC(ZSTD(1))
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(transaction_time)
ORDER BY (us_state, cat_id, transaction_time);

INSERT INTO fraud_db.transactions_v3
SELECT
    parseDateTimeBestEffort(transaction_time) AS transaction_time,
    merch,
    cat_id,
    amount,
    gender,
    one_city,
    us_state,
    toUInt32(population_city) AS population_city,
    jobs
FROM fraud_db.transactions;