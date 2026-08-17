# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

WORKDIR /app
COPY . /app

# SECURITY-FIX: CVE-2026-43502 (linux-image-aws) — net/rds zerocopy send cleanup vulnerability
# A zerocopy send can fail after user pages have been pinned but before the message is attached
# to the sending socket. The purge path currently infers zerocopy state from rm->m_rs, so an
# unqueued message can be cleaned up as if it owned normal payload pages.
# Ensure all OS packages including linux-image-aws are updated to their latest patched versions.
# See: https://nvd.nist.gov/vuln/detail/CVE-2026-43502
# Remediation: Update linux-image-aws to fixed version (AWS Inspector finding).
RUN apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
