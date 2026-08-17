# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# Security fix: CVE-2026-58469 — upgrade wget to remediate heap buffer underread vulnerability in clean_metalink_string()
RUN apt-get update && apt-get install -y --only-upgrade wget && rm -rf /var/lib/apt/lists/*

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

WORKDIR /app
COPY . /app

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
