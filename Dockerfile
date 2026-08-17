# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

WORKDIR /app
COPY . /app

# SECURITY-FIX: CVE-2025-38211 (linux-image-aws) — use-after-free of work objects after cm_id destruction.
# The RDMA/iwcm subsystem had a use-after-free bug in work object handling after cm_id destruction
# (commit 59c68ac31e15). Ensure the linux-image-aws OS package is updated to its fixed version.
# See: https://nvd.nist.gov/vuln/detail/CVE-2025-38211
# Remediation: Update linux-image-aws to patched version (AWS Inspector finding — High severity).
#
# SECURITY-FIX: CVE-2025-39994 (linux-image-aws) — use-after-free in xc5000_release.
# See: https://nvd.nist.gov/vuln/detail/CVE-2025-39994
# Remediation: Update linux-image-aws to fixed version (AWS Inspector finding).
RUN apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
