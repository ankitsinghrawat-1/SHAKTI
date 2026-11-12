const { z } = require('zod');

const CreateIncidentSchema = z.object({
  incidentId: z.string().min(1, 'Incident ID is required'),
  source: z.string().default('appSosButton'),
  latitude: z.number().min(-90).max(90, 'Latitude must be between -90 and 90'),
  longitude: z.number().min(-180).max(180, 'Longitude must be between -180 and 180'),
  accuracy: z.number().nonnegative().optional(),
  speed: z.number().nonnegative().optional(),
  severity: z.string().default('Urgent'),
  userName: z.string().optional(),
  deviceSequence: z.number().int().nonnegative().optional().default(1),
  isCovert: z.boolean().optional().default(false),
  timestamp: z.string().optional(),
});

const AcknowledgeIncidentSchema = z.object({
  actorName: z.string().trim().min(1, 'Actor or responder name is required'),
  ackType: z.enum(['READ_RECEIPT', 'RESPONDING', 'ON_SCENE', 'FALSE_ALARM', 'RESOLVED']).default('RESPONDING'),
  notes: z.string().trim().optional(),
});

const ResolveIncidentSchema = z.object({
  pin: z.string().regex(/^\d{4}$/, 'Security PIN is required to close emergency incident'),
  reason: z.string().trim().optional().default('Emergency resolved safely'),
});

module.exports = {
  CreateIncidentSchema,
  AcknowledgeIncidentSchema,
  ResolveIncidentSchema,
};
