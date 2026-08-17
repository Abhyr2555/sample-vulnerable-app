# NOTE: contains patterns commonly flagged by scanners (for testing).
# SECURITY-TODO: CVE-2026-53096 — linux-image-aws: Update linux-image-aws package to fixed version on the host EC2 instance. In the Linux kernel, the following vulnerability has been resolved: bpf: Use RCU-safe iteration in dev_map_redirect_mul. Ensure the underlying EC2 instance OS is patched via `apt-get update && apt-get install --only-upgrade linux-image-aws`.
FROM python:3.9-slim

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
