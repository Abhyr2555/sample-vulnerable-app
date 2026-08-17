# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# SECURITY-TODO: CVE-2025-37739 — linux-image-aws: In the Linux kernel, the following vulnerability
# has been resolved: CVE-2025-37739 affects linux-image-aws.
# Remediation: Update linux-image-aws package to fixed version on the host EC2 instance:
#   sudo apt-get update && sudo apt-get install --only-upgrade linux-image-aws
# Container-level mitigation: ensure OS packages are upgraded at build time.
# AWS Inspector Finding: arn:aws:inspector2:us-west-2:381492157536:finding/826470fe61d51f2e7f322aea
# Guardian Task: TASK-8ffd18360943
RUN apt-get update && apt-get install -y --only-upgrade linux-image-aws 2>/dev/null || true && rm -rf /var/lib/apt/lists/*

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
