FROM python:3.13-alpine3.22 AS builder

RUN mkdir -p /app/ && python -m venv /app/.venv

WORKDIR /app
COPY requirements.txt .
RUN source .venv/bin/activate && pip install -r requirements.txt

FROM python:3.13-alpine3.22 AS runtime-image
ENV PYTHONUNBUFFERED=1
RUN apk --purge del apk-tools
RUN adduser -D -s /bin/sh -u 8000 opencost
COPY --from=builder /app /app
COPY src/opencost_parquet_exporter.py /app/opencost_parquet_exporter.py
COPY src/data_types.json /app/data_types.json
COPY src/rename_cols.json /app/rename_cols.json
COPY src/ignore_alloc_keys.json /app/ignore_alloc_keys.json
COPY src/storage_factory.py /app/storage_factory.py
COPY src/storage /app/storage
RUN chmod 755 /app/opencost_parquet_exporter.py && chown -R opencost /app/
USER opencost
ENV PATH="/app/.venv/bin:$PATH"
ENTRYPOINT ["/app/.venv/bin/python3", "/app/opencost_parquet_exporter.py"]
