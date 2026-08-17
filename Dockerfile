# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# SECURITY-FIX: CVE-2026-28387 (libssl1.1, openssl) — use-after-free/double-free in DANE TLSA-based server authentication
# An uncommon configuration of clients performing DANE TLSA-based server authentication,
# when paired with uncommon server DANE TLSA records, may result in a use-after-free
# and/or double-free on the client side.
# Remediation: Update libssl1.1 and openssl to fixed versions.
# See: https://nvd.nist.gov/vuln/detail/CVE-2026-28387
# AWS Inspector Finding: arn:aws:inspector2:us-west-2:381492157536:finding/a9322d0d5bb2b23b5ad1ad3a5d6c16ee
RUN apt-get update && apt-get install -y --only-upgrade libssl1.1 openssl && apt-get clean && rm -rf /var/lib/apt/lists/*

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
