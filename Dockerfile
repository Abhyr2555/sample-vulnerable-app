# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# SECURITY-TODO: CVE-2026-43047 — linux-image-aws: Update package to fixed version
# Remediation: Upgrade OS packages to address CVE-2026-43047 on the host EC2 instance.
# Host-level fix: sudo apt-get update && sudo apt-get install --only-upgrade linux-image-aws
# Container-level mitigation: ensure base image is up-to-date with latest security patches.
RUN apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

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
