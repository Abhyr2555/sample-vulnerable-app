# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

WORKDIR /app
COPY . /app

# SECURITY-FIX: CVE-2026-45843 (linux-image-aws) — drm/amdgpu ABBA deadlock in amdgpu_cs_parser_fini()
# A potential deadlock exists in the AMDGPU command submission parser cleanup path.
# When multiple contexts are submitted simultaneously and one fails, the cleanup can
# acquire locks in a different order than the submission path, leading to ABBA deadlock.
# Remediation: Update linux-image-aws and all OS packages to their latest patched versions.
# See: https://nvd.nist.gov/vuln/detail/CVE-2026-45843
# AWS Inspector Finding: arn:aws:inspector2:us-west-2:381492157536:finding/c606d5e4f2h7ffe2666b4a924730db51
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
