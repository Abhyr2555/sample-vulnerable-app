# NOTE: contains patterns commonly flagged by scanners (for testing).
FROM python:3.9-slim

# storing credentials in ENV (Issue 1)
ENV AWS_ACCESS_KEY_ID=EXAMPLEKEY123
ENV AWS_SECRET_ACCESS_KEY=EXAMPLESECRET123

WORKDIR /app
COPY . /app

# SECURITY-FIX: CVE-2025-41244 (open-vm-tools) — local privilege escalation vulnerability
# VMware Aria Operations and VMware Tools contain a local privilege escalation vulnerability.
# A malicious local actor with non-administrative privileges having access to a VM with
# VMware Tools installed can exploit this vulnerability to escalate privileges.
# Remediation: Update open-vm-tools to the fixed version.
# See: https://nvd.nist.gov/vuln/detail/CVE-2025-41244
# AWS Inspector Finding: arn:aws:inspector2:us-west-2:381492157536:finding/4660a38e24f1ef273e44cce831ae1106
RUN apt-get update && apt-get install -y --only-upgrade open-vm-tools && apt-get clean && rm -rf /var/lib/apt/lists/*

# installs without a lockfile and no --no-cache-dir used (Issue 2)
RUN pip install -r requirements.txt

# running as root (no USER directive) and exposing an app port (Issue 3)
EXPOSE 5000
CMD ["python", "main.py"]
