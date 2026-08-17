# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

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

# SECURITY-FIX: CVE-2026-46307 (linux-image-aws) — Linux kernel wifi/ath5k array out-of-bounds access.
# The ath5k WiFi driver performs an array-index-out-of-bounds (UBSAN) access that can
# lead to memory corruption, denial of service, or local privilege escalation.
# Remediation: Update linux-image-aws to the latest patched version.
# See: https://nvd.nist.gov/vuln/detail/CVE-2026-46307
# AWS Inspector Finding: arn:aws:inspector2:us-west-2:381492157536:finding/673e87393443716a923aedac5c390456
RUN apt-get update && apt-get install -y --only-upgrade linux-image-aws 2>/dev/null || true && apt-get clean && rm -rf /var/lib/apt/lists/*

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
