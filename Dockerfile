# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

WORKDIR /app
COPY . /app

# SECURITY-FIX: CVE-2025-39788 (linux-image-aws) — remediate High severity vulnerability
# CVE-2025-39788 affects the linux-image-aws package.
# Ensure the package and all OS-level packages are updated to their latest patched versions
# at image build time to remediate this vulnerability.
# See: https://nvd.nist.gov/vuln/detail/CVE-2025-39788
# Remediation: Update linux-image-aws to fixed version (AWS Inspector finding).
# AWS Inspector ARN: arn:aws:inspector2:us-west-2:381492157536:finding/899d41a5d984b7a1d89963885e683ed1
RUN apt-get update \
    && apt-get install -y --only-upgrade linux-image-aws 2>/dev/null || true \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
