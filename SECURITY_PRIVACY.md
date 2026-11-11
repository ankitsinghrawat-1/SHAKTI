# Shakti Security, Privacy, and Responsible AI

This document describes design requirements for a future implementation. It is
not a security certification or legal opinion.

## Security Controls

| Control area | Required direction |
|---|---|
| Identity | Unique device identity and per-device credentials |
| Transport | Encrypted app, band, backend, camera, and operator communication |
| BLE | Authenticated pairing and authorized commands |
| Secrets | Secure key storage; no production secrets in firmware |
| Operations | RBAC and MFA for monitoring operators |
| Audit | Record sensitive reads, exports, changes, and escalations |
| Firmware | Signed updates, secure boot, rollback protection where supported |
| Resilience | Rate limits that do not block genuine emergency ingestion |
| Response | Vulnerability reporting, patching, and incident response process |

## Privacy Principles

- Collect only the location, media, and camera data required for the stated
  safety purpose.
- Obtain clear consent for location sharing and recording.
- Define retention periods before collecting data.
- Restrict camera access to authorized people and documented purposes.
- Avoid facial recognition and identity inference by default.
- Keep safety alerts separate from surveillance or employee monitoring.
- Provide access, correction, deletion, and grievance processes where required.
- Explain uncertainty, degraded service, and missing delivery honestly.

## Responsible AI

AI output is a candidate signal, not proof of a crime, identity, intent, or
guilt. CCTV development should begin with authorized recorded data, person
detection, and anonymous tracking. Models should be evaluated using:

| Metric | Why it matters |
|---|---|
| Precision | How many alerts are correct |
| Recall | How many relevant events are found |
| False alerts | Operational burden and alert fatigue |
| Missed events | Safety risk from failures |
| Latency | Time from event to warning |
| Calibration | Whether confidence matches observed likelihood |
| Coverage | Performance across lighting, environments, and groups |

Consequential camera-based escalation requires authorized human review. Review
outcomes, false positives, and missed events should be recorded.

## Evidence Integrity

Evidence metadata should include the incident ID, device identity, capture
times, clock source, location quality, upload time, software version, digest,
and access history. SHA-256 helps detect file changes after hashing, but
provenance also requires secure devices, trusted time, access control, consent,
and appropriate legal process.

## Regulatory Dependencies

Before any real deployment, specialist review is required for:

| Area | Questions to resolve |
|---|---|
| Privacy | Data protection, consent, retention, deletion |
| CCTV | Access authorization, surveillance limits, operator duties |
| Telecom | Modem bands, spectrum, operator and SIM requirements |
| Satellite | Equipment approval, service, antenna, sky visibility |
| Recording | Consent and jurisdiction-specific rules |
| Emergency response | Agency agreements and dispatch procedures |

## Security Testing Plan

- Threat-model the app, wristband, APIs, operator tools, and evidence store.
- Test pairing, device identity, firmware updates, and key storage.
- Test queue recovery, duplicate submission, replay, and outage behaviour.
- Test authorization for every incident, evidence, and camera operation.
- Test rate limits, abuse resistance, and denial-of-service resilience.
- Verify audit integrity and retention/deletion policies.
- Review privacy of location, media, and camera data flows.
- Conduct human-factors testing for accidental SOS and misleading status text.
