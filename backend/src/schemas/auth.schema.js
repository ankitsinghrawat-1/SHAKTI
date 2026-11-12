const { z } = require('zod');

const RegisterSchema = z.object({
  name: z.string().trim().min(2, 'Name must be at least 2 characters').max(100),
  phone: z.string().trim().min(5, 'Phone number must have at least 5 digits'),
  email: z.string().email('Invalid email address').optional().or(z.literal('')),
  pin: z.string().regex(/^\d{4}$/, 'Security PIN must be exactly 4 numeric digits'),
});

const LoginSchema = z.object({
  identifier: z.string().trim().min(1, 'Phone, email or identifier is required'),
  pin: z.string().regex(/^\d{4}$/, 'Security PIN must be exactly 4 numeric digits'),
});

module.exports = {
  RegisterSchema,
  LoginSchema,
};
