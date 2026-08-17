# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

WORKDIR /app
COPY . /app

# SECURITY-FIX: CVE-2026-43051 (linux-image-aws) — vulnerability in linux-image-aws package.
# CVE-2026-43051 affects linux-image-aws. Update package to fixed version.
# Remediation: Update linux-image-aws to fixed version (AWS Inspector finding).
# See: https://nvd.nist.gov/vuln/detail/CVE-2026-43051
# Finding ARN: arn:aws:inspector2:us-west-2:381492157536:finding/85cf51f4d1ff86a3299a9cb0cb653930
RUN apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
