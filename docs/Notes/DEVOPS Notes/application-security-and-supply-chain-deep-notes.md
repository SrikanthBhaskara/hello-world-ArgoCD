# Application Security and Supply Chain Deep Notes

## Why This Matters
- Security interviews at mid and senior level are about practical threat reduction.
- Teams are expected to protect applications, secrets, dependencies, and release pipelines together.

## CORS
- browser policy for cross-origin access
- not an auth mechanism

## CSP
- limits allowed script and content sources
- useful to reduce XSS impact

## Clickjacking
- attacker frames your site and tricks the user into unwanted actions
- mitigate with frame restrictions and UI hardening

## SSRF
- server-side request forgery tricks backend systems into making attacker-controlled outbound requests
- dangerous in cloud environments with metadata services and internal endpoints

## SQL Injection
- happens when untrusted input changes query meaning
- use parameterized queries, not string concatenation

## File Upload Security
- validate file type and size
- do not trust extension only
- scan files when needed
- isolate uploaded content from direct execution context

## Secret Rotation
- short-lived credentials are better than static long-lived secrets
- rotate keys and tokens with minimal service disruption

## SAST, DAST, SCA

### SAST
- static code analysis for source vulnerabilities

### DAST
- dynamic testing against running application

### SCA
- software composition analysis for dependency risk

## SBOM
- software bill of materials
- inventory of dependencies and components
- useful for security response and compliance

## Good Practices
- secure defaults
- least privilege
- dependency review
- secret scanning
- artifact signing where possible
- keep upload paths and runtime execution paths separate

## Interview Questions

### What is the difference between SAST, DAST, and SCA?
Short answer:
SAST scans source, DAST tests running apps, SCA checks dependency risk.

Better answer:
I treat them as complementary. SAST helps find insecure code patterns early, DAST validates behavior in a running application, and SCA highlights vulnerable third-party components. None of them alone is enough for real release safety.
