# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# SECURITY-FIX: CVE-2026-40468 (gawk) — heap buffer overflow in regex matching subsystem.
# Boundary checks are insufficient for certain multi-byte character sequences in gawk,
# potentially leading to arbitrary code execution or denial of service.
# Ensure gawk is updated to its patched version at image build time.
# See: https://nvd.nist.gov/vuln/detail/CVE-2026-40468
# Remediation: Update gawk to fixed version (AWS Inspector finding).
RUN apt-get update && apt-get install -y --only-upgrade gawk && apt-get clean && rm -rf /var/lib/apt/lists/*

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
