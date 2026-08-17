# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

WORKDIR /app
COPY . /app

# SECURITY-FIX: CVE-2025-68764 (linux-image-aws) — NFS automounted filesystems should inherit ro,noexec,nodev,sync flags.
# When a filesystem is being automounted, it needs to preserve the user-set superblock mount options,
# such as the "ro" flag. This Linux kernel vulnerability can lead to security policy bypass on
# automounted NFS filesystems running linux-image-aws.
# Remediation: Update linux-image-aws and all OS packages to their latest patched versions.
# See: https://nvd.nist.gov/vuln/detail/CVE-2025-68764
# AWS Inspector Finding: arn:aws:inspector2:us-west-2:381492157536:finding/a7cb9943e0521ad955cde6bc42628645
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
