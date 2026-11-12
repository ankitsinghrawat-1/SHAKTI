# SHAKTI Backend API Specification & Integration Guide

This backend reference implements the official **SHAKTI Technical Project Blueprint (Version 2.0, Section 19: Backend, Database and API Design)**.

## Quick Start (Local Running)

```bash
# Run the structured server on port 3000 (default)
cd backend
npm start

# Verify server health
curl http://localhost:3000/api/v1/health
```

## API Endpoint Matrix

| Method | Endpoint | Description | Headers |
|---|---|---|---|
| `GET` | `/api/v1/health` | Service uptime and incident telemetry health check | None |
| `POST` | `/api/v1/auth/register` | Register new user with 4-digit PIN | `Content-Type: application/json` |
| `POST` | `/api/v1/auth/login` | Login with credentials or PIN (handles Duress 0000) | `Content-Type: application/json` |
| `GET` | `/api/v1/auth/me` | Fetch authenticated citizen profile | `Authorization: Bearer <token>` |
| `GET` | `/api/v1/guardians` | List trusted guardian circle contacts | `Authorization: Bearer <token>` |
| `POST` | `/api/v1/guardians` | Add a new trusted guardian | `Authorization: Bearer <token>` |
| `POST` | `/api/v1/incidents` | **Create Emergency SOS Incident** | `X-Idempotency-Key: <id>` |
| `GET` | `/api/v1/incidents/:id` | Fetch emergency incident status and audit trail | `Authorization: Bearer <token>` |
| `POST` | `/api/v1/incidents/:id/locations` | Stream GNSS breadcrumb coordinates (30s interval) | `Authorization: Bearer <token>` |
| `POST` | `/api/v1/evidence/manifest` | Register encrypted evidence metadata and SHA-256 digest | `Authorization: Bearer <token>` |
| `GET` | `/api/v1/nearby-alerts` | Query localized camera & public safety alerts | `Authorization: Bearer <token>` |
| `POST` | `/api/v1/reports/hazard` | Publish community hazard report (broken light, isolated stretch) | `Authorization: Bearer <token>` |
| `POST` | `/api/v1/feedback` | User feedback and bug report ingestion | `Authorization: Bearer <token>` |

## Idempotency Rules

Emergency SOS dispatches must provide `X-Idempotency-Key` or `incidentId`. Re-sent requests due to cellular drops or network reconnects return `200 OK` with `serverReceived: true` without creating duplicate incidents or dispatch cascades.

## Delivery States

Per Section 16 & 22 of the Technical Blueprint:
- `CREATED_LOCAL`: Event recorded on device.
- `QUEUED_OFFLINE`: Event preserved locally, awaiting network transport.
- `SERVER_RECEIVED`: Backend acknowledges event with HTTP 201 receipt.
- `RECIPIENT_ACKNOWLEDGED`: Contact or monitoring operator acknowledges receipt.
