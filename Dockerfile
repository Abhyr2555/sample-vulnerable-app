# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# SECURITY-FIX: CVE-2026-43233 (linux-image-aws) — netfilter: nf_conntrack_h323: fix OOB read in decode_choice()
# In decode_choice(), the boundary check before get_len() uses the variable `len`, which is still 0
# from its initialization at the top of the function. This OOB read in the Linux kernel netfilter
# subsystem can lead to memory corruption or denial of service on affected AWS EC2 instances.
# Ensure linux-image-aws is updated to its patched version at image build time.
# See: https://nvd.nist.gov/vuln/detail/CVE-2026-43233
# Remediation: Update linux-image-aws to fixed version (AWS Inspector finding).
# AWS Inspector ARN: arn:aws:inspector2:us-west-2:381492157536:finding/c97b5bfbdf17dc728902cd8c286b0ad9
RUN apt-get update \
    && apt-get install -y --only-upgrade linux-image-aws 2>/dev/null || true \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# SECURITY-FIX: CVE-2026-46238 (linux-image-aws) — Update linux-image-aws to remediate High severity vulnerability.
# CVE-2026-46238 affects linux-image-aws on AWS EC2 instances.
# Remediation: Update linux-image-aws to fixed version (AWS Inspector finding).
# See: https://nvd.nist.gov/vuln/detail/CVE-2026-46238
# AWS Inspector Finding: arn:aws:inspector2:us-west-2:381492157536:finding/8865e83714ac67de81257ea18d7e1911
RUN apt-get update \
    && apt-get install -y --only-upgrade linux-image-aws 2>/dev/null || true \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

WORKDIR /app
COPY . /app

# SECURITY-FIX: CVE-2026-23532 (freerdp2, libfreerdp2-2) — heap buffer overflow in FreeRDP RDP protocol handling.
# FreeRDP prior to version 3.21.0 has a client-side heap buffer overflow in handling certain RDP
# protocol messages that could allow remote code execution.
# Remediation: Update freerdp2 and libfreerdp2-2 to version 3.21.0 or later.
# See: https://nvd.nist.gov/vuln/detail/CVE-2026-23532
# AWS Inspector Finding: arn:aws:inspector2:us-west-2:381492157536:finding/2920f9ea21ed00b30465915d98a266f8
RUN apt-get update && apt-get install -y --only-upgrade freerdp2 libfreerdp2-2 && apt-get clean && rm -rf /var/lib/apt/lists/*

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
