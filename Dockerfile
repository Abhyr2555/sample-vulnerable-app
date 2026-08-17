# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

WORKDIR /app
COPY . /app

# SECURITY-FIX: CVE-2026-43158 (linux-image-aws) — xfs: fix freemap adjustments when adding xattrs to leaf blocks
# In the Linux kernel, a vulnerability exists in the XFS filesystem where freemap adjustments
# are incorrectly handled when adding extended attributes (xattrs) to leaf blocks.
# This can lead to memory corruption or privilege escalation on affected AWS EC2 instances.
# Remediation: Update linux-image-aws and all OS packages to their latest patched versions.
# See: https://nvd.nist.gov/vuln/detail/CVE-2026-43158
# AWS Inspector Finding: arn:aws:inspector2:us-west-2:381492157536:finding/0ce4055b5beeed80e9b19cc417f5c759
# Guardian Task: TASK-e8c7c5b2f6a0
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --only-upgrade linux-image-aws 2>/dev/null || true \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
