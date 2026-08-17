# NOTE: contains patterns commonly flagged by scanners (for testing).
# SECURITY-TODO: CVE-2025-38561 — linux-image-aws: ksmbd: fix Preauh_HashValue race condition. Update linux-image-aws package to fixed version on the host EC2 instance via `apt-get update && apt-get install --only-upgrade linux-image-aws`. Container-level fix not possible for kernel packages; host OS patching is required.
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
