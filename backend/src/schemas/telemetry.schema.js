const { z } = require('zod');

const TelemetryPointSchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  accuracy: z.number().nonnegative().optional(),
  speed: z.number().nonnegative().optional(),
  altitude: z.number().optional(),
  bearing: z.number().min(0).max(360).optional(),
  provider: z.string().optional().default('GNSS'),
  timestamp: z.string().optional(),
});

const BatchTelemetrySchema = z.object({
  incidentId: z.string().optional(),
  points: z.array(TelemetryPointSchema).min(1, 'At least one telemetry point is required'),
  sentAt: z.string().optional(),
});

module.exports = {
  TelemetryPointSchema,
  BatchTelemetrySchema,
};
