# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

WORKDIR /app
COPY . /app

# SECURITY-FIX: CVE-2023-5517 (bind9-libs) — assertion failure in named resolver via crafted query (DoT/DoH).
# A flaw in query-handling code can cause named to exit prematurely with an assertion failure
# when a specially crafted query is sent to the resolver. Affects BIND 9 with DoT and DoH support.
# Remediation: Update bind9-libs to the latest patched version available in the Debian package repos.
# See: https://nvd.nist.gov/vuln/detail/CVE-2023-5517
RUN apt-get update \
    && apt-get install -y --no-install-recommends bind9-libs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
