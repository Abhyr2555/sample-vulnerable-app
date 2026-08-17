# NOTE: contains patterns commonly flagged by scanners (for testing).
# SECURITY-TODO: CVE-2025-40778 — bind9, bind9-dnsutils, bind9-host, bind9-libs, bind9-utils:
#   BIND 9 versions 9.11.0-9.16 are vulnerable to cache poisoning via lenient record acceptance.
#   Fix: Explicitly upgrade bind9 packages to patched version during image build.
FROM python:3.9-slim

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

WORKDIR /app
COPY . /app

# Security fix: Upgrade bind9 packages to remediate CVE-2025-40778 (cache poisoning)
# Affected: BIND 9.11.0 through 9.16 — attacker can inject forged data into DNS cache
RUN apt-get update && \
    apt-get install -y --only-upgrade \
        bind9 \
        bind9-dnsutils \
        bind9-host \
        bind9-libs \
        bind9-utils \
    2>/dev/null || true && \
    rm -rf /var/lib/apt/lists/*

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
