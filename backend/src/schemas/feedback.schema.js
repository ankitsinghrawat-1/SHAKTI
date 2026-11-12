const { z } = require('zod');

const FeedbackSchema = z.object({
  type: z.string().optional().default('general'),
  message: z.string().trim().min(3, 'Feedback message must be at least 3 characters'),
  rating: z.number().int().min(1).max(5).optional(),
  deviceInfo: z.record(z.string(), z.any()).optional(),
});

module.exports = {
  FeedbackSchema,
};
