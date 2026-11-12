const { z } = require('zod');

const HazardReportSchema = z.object({
  type: z.string().trim().min(2, 'Hazard type is required'),
  location: z.string().trim().min(2, 'Hazard location description is required'),
  severity: z.string().optional().default('Medium'),
  notes: z.string().optional().default(''),
  latitude: z.number().min(-90).max(90).optional(),
  longitude: z.number().min(-180).max(180).optional(),
});

module.exports = {
  HazardReportSchema,
};
