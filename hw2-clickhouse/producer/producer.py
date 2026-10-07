"""
Читает CSV с транзакциями и шлёт каждую строку в Kafka.
"""
import os
import json
import time
import logging

import pandas as pd
from kafka import KafkaProducer


logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")
logger = logging.getLogger(__name__)


KAFKA_BROKERS = os.getenv("KAFKA_BROKERS", "kafka:29092")
KAFKA_TOPIC = os.getenv("KAFKA_TOPIC", "transactions")
CSV_PATH = os.getenv("CSV_PATH", "/app/data/train_sample.csv")


def main():
    logger.info(f"Reading {CSV_PATH}")
    df = pd.read_csv(CSV_PATH)
    logger.info(f"Loaded {len(df)} rows")

    # в Kafka шлём только нужные поля
    keep = [
        "transaction_time", "merch", "cat_id", "amount",
        "gender", "one_city", "us_state", "population_city", "jobs",
    ]
    df = df[keep]

    producer = KafkaProducer(
        bootstrap_servers=KAFKA_BROKERS,
        value_serializer=lambda v: json.dumps(v).encode("utf-8"),
    )

    n = len(df)
    for i, row in df.iterrows():
        producer.send(KAFKA_TOPIC, value=row.to_dict())

        if (i + 1) % 1000 == 0:
            producer.flush()
            logger.info(f"Sent{i + 1} / {n}")

    producer.flush()
    logger.info(f"Done: {n} messages sent to topic '{KAFKA_TOPIC}'")


if __name__ == "__main__":
    time.sleep(5)
    main()