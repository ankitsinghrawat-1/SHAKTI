const { z } = require('zod');

const EvidenceItemSchema = z.object({
  fileType: z.enum(['AUDIO', 'VIDEO', 'PHOTO', 'BLE_LOG', 'ACCELEROMETER', 'OTHER']).default('AUDIO'),
  fileName: z.string().min(1),
  sha256Digest: z.string().regex(/^[a-fA-F0-9]{64}$/, 'sha256Digest must be a 64-character hexadecimal SHA-256 hash'),
  fileSizeBytes: z.number().int().positive('File size must be greater than 0'),
  capturedAt: z.string().optional(),
  encryptionAlgo: z.string().optional().default('AES-256-GCM'),
});

const EvidenceManifestSchema = z.object({
  incidentId: z.string().min(1, 'Incident ID is required'),
  items: z.array(EvidenceItemSchema).min(1, 'Manifest must contain at least one evidence item'),
  sealedAt: z.string().optional(),
});

module.exports = {
  EvidenceItemSchema,
  EvidenceManifestSchema,
};
