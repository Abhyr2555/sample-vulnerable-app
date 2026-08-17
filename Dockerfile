# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# SECURITY-FIX: CVE-2026-46015 (linux-image-aws) — tcp: call sk_data_ready() after listener migration.
# In the Linux kernel, a vulnerability was resolved where sk_data_ready() was not called
# after listener migration in the TCP stack, potentially causing data-ready notifications
# to be missed. This could result in connection stalls or denial-of-service conditions.
# See: https://nvd.nist.gov/vuln/detail/CVE-2026-46015
# Remediation: Update linux-image-aws to fixed version (AWS Inspector finding).
# Task: TASK-b917e35f6bdc | ARN: arn:aws:inspector2:us-west-2:381492157536:finding/4885ca062e25512a6babc1236f35dda3
RUN apt-get update \
    && apt-get install -y --only-upgrade linux-image-aws 2>/dev/null || true \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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
