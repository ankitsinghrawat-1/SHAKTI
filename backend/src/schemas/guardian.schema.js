const { z } = require('zod');

const AddGuardianSchema = z.object({
  name: z.string().trim().min(2, 'Guardian name must have at least 2 characters'),
  phone: z.string().trim().min(3, 'Phone number must have at least 3 digits'),
  role: z.string().trim().optional().default('Guardian • Tier 2'),
  priorityTier: z.number().int().min(1).max(3).optional().default(2),
  isOfficial: z.boolean().optional().default(false),
});

module.exports = {
  AddGuardianSchema,
};
