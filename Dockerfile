# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

# SECURITY FIX: CVE-2025-71238 (linux-image-aws, High)
# AWS Inspector finding: io_uring race condition — use-after-free in io_req_complete_post()
# Remediation: Update system packages including linux-image-aws to latest patched versions.
# NOTE: linux-image-aws is a host kernel package; this apt-get upgrade ensures any
# available in-container package updates (including kernel headers) are applied.
# Full remediation requires patching the underlying EC2 host:
#   sudo apt-get update && sudo apt-get install --only-upgrade linux-image-aws
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
