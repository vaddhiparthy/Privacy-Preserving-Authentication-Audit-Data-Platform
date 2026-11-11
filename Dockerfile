FROM python:3.11-slim@sha256:da047cb8f9d1d98e5c070f5300ba9f7274e33b8fc0e5be5ed88740aed1b95ba9

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app/src:/app

WORKDIR /app

RUN useradd --create-home --uid 10001 --shell /usr/sbin/nologin appuser

COPY requirements.txt requirements.lock.txt /app/
RUN pip install --no-cache-dir -r /app/requirements.lock.txt \
    && pip uninstall -y pip setuptools wheel

COPY contracts /app/contracts
COPY docs /app/docs
COPY sample_data /app/sample_data
COPY scripts /app/scripts
COPY sql /app/sql
COPY src /app/src

EXPOSE 8075

CMD ["uvicorn", "authaudit.api:app", "--host", "0.0.0.0", "--port", "8075"]

USER appuser
