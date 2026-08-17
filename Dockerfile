# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# SECURITY-FIX: CVE-2025-68301 (linux-image-aws) — use-after-free in uvc_queue_buffer()
# A use-after-free vulnerability exists in the UVC video driver when handling buffer
# queuing operations. Ensure all OS packages including linux-image-aws are updated
# to their latest patched versions at image build time.
# See: https://nvd.nist.gov/vuln/detail/CVE-2025-68301
# Remediation: Update linux-image-aws to fixed version (AWS Inspector finding).
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
