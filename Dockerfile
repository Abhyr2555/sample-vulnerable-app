# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

WORKDIR /app
COPY . /app

# SECURITY-FIX: CVE-2024-47691 (linux-image-aws, linux-libc-dev) — use-after-free in ext4_xattr_set_entry()
# When setting extended attributes, a use-after-free can occur if the xattr block is modified
# concurrently. The issue is in ext4_xattr_set_entry() where a pointer to the old value is
# retained after the block may have been reallocated.
# Remediation: Update linux-image-aws and linux-libc-dev to their latest patched versions.
# See: https://nvd.nist.gov/vuln/detail/CVE-2024-47691
# AWS Inspector Finding: arn:aws:inspector2:us-west-2:381492157536:finding/c617e6f5g3i8e44b6a25296d77d6b9df
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
