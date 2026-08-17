# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

WORKDIR /app
COPY . /app

# SECURITY-FIX: CVE-2025-38555 (linux-image-aws) — use-after-free in composite_dev_cleanup().
# The USB gadget subsystem has a use-after-free vulnerability in composite_dev_cleanup().
# Ensure all OS packages including linux-image-aws are updated to their latest patched versions.
# See: https://nvd.nist.gov/vuln/detail/CVE-2025-38555
# Remediation: Update linux-image-aws to fixed version (AWS Inspector finding).
RUN apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
