const { z } = require('zod');

const FeedbackSchema = z.object({
  type: z.string().optional(),
  category: z.string().optional(),
  message: z.string().trim().optional(),
  description: z.string().trim().optional(),
  rating: z.number().int().min(1).max(5).optional(),
  deviceInfo: z.record(z.string(), z.any()).optional(),
}).transform((data, ctx) => {
  const message = data.message || data.description;
  if (!message || message.trim().length < 3) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['message'],
      message: 'Feedback message must be at least 3 characters',
    });
    return z.NEVER;
  }
  return {
    type: data.type || data.category || 'general',
    message: message.trim(),
    rating: data.rating,
    deviceInfo: data.deviceInfo,
  };
});

module.exports = {
  FeedbackSchema,
};
