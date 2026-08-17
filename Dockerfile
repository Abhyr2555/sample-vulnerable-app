# NOTE: contains patterns commonly flagged by scanners (for testing).
# SECURITY-TODO: CVE-2026-22980 — linux-image-aws: nfsd v4_end_grace locking vulnerability.
# Writing to v4_end_grace can race with server shutdown causing use-after-free on reclaim_str_hashtbl.
# Remediation: Update linux-image-aws package on the host EC2 instance:
#   sudo apt-get update && sudo apt-get install --only-upgrade linux-image-aws
# This is a kernel-level package; container-level fix is not possible. Host OS patching required.
# AWS Inspector Finding: arn:aws:inspector2:us-west-2:381492157536:finding/a821dcb6b73a7f6b1f83aeeaae0659a4
# Guardian Task: TASK-58dd24b1eb99
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
