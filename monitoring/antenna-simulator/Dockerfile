FROM python:3.12-alpine

WORKDIR /app

# prometheus-client exposes metrics in the format Prometheus can scrape.
RUN pip install --no-cache-dir prometheus-client==0.22.1

COPY antenna_simulator.py /app/antenna_simulator.py

EXPOSE 8000

# Lab healthcheck: verifies that the local HTTP health endpoint answers.
HEALTHCHECK --interval=30s --timeout=5s --retries=5 --start-period=10s \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1:8000/health || exit 1

CMD ["python", "/app/antenna_simulator.py"]
