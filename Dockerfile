FROM python:3.13.18-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app/src:/app

WORKDIR /app

RUN useradd --create-home --uid 10001 --shell /usr/sbin/nologin appuser

COPY requirements.txt requirements.lock.txt /app/
RUN python -c 'import urllib.request,hashlib,pathlib;files=[{'"'"'url'"'"': '"'"'https://apt.postgresql.org/pub/repos/apt/pool/main/p/postgresql-18/libpq5_18.6-1.pgdg13+2_amd64.deb'"'"', '"'"'sha256'"'"': '"'"'c6cc459bb499db4697686533e50bf5943f7e7d6929c04ef55eec184d5436859b'"'"', '"'"'path'"'"': '"'"'/tmp/libpq5.deb'"'"'}, {'"'"'url'"'"': '"'"'https://apt.postgresql.org/pub/repos/apt/pool/main/p/postgresql-18/libpq-dev_18.6-1.pgdg13+2_amd64.deb'"'"', '"'"'sha256'"'"': '"'"'b2add61e7fe0e9328140de456a85c96737b517f9cf62b44fd88e86aa2b765f29'"'"', '"'"'path'"'"': '"'"'/tmp/libpq-dev.deb'"'"'}];[(pathlib.Path(f["path"]).write_bytes(urllib.request.urlopen(f["url"],timeout=60).read())) for f in files];assert all(hashlib.sha256(pathlib.Path(f["path"]).read_bytes()).hexdigest()==f["sha256"] for f in files),"PostgreSQL package SHA256 mismatch"' \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gcc libc6-dev /tmp/libpq5.deb /tmp/libpq-dev.deb \
    && apt-mark manual libpq5 \
    && pip install --no-cache-dir -r /app/requirements.lock.txt \
    && pip uninstall -y pip setuptools wheel \
    && apt-get purge -y --auto-remove gcc libc6-dev libpq-dev \
    && rm -f /tmp/libpq5.deb /tmp/libpq-dev.deb \
    && rm -rf /var/lib/apt/lists/*

COPY contracts /app/contracts
COPY docs /app/docs
COPY sample_data /app/sample_data
COPY scripts /app/scripts
COPY sql /app/sql
COPY src /app/src

EXPOSE 8075

CMD ["uvicorn", "authaudit.api:app", "--host", "0.0.0.0", "--port", "8075"]

USER appuser
