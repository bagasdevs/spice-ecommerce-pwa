const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const { PrismaClient } = require('@prisma/client');

const router = express.Router();
const prisma = new PrismaClient();

// Validation rules
const registerValidation = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long'),
  body('role')
    .isIn(['SELLER', 'BUYER'])
    .withMessage('Role must be either SELLER or BUYER'),
  body('name')
    .optional()
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Name must be between 2-100 characters'),
  body('phone')
    .optional()
    .matches(/^(\+62|62|0)[0-9]{9,13}$/)
    .withMessage('Please provide a valid Indonesian phone number')
];

const loginValidation = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .notEmpty()
    .withMessage('Password is required')
];

// Helper function to generate JWT token
const generateToken = (userId, role) => {
  return jwt.sign(
    { userId, role },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
};

// POST /api/auth/register
router.post('/register', registerValidation, async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation Error',
        message: 'Please check your input data',
        details: errors.array()
      });
    }

    const { email, password, role, name, phone, address, city, province, postalCode } = req.body;

    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { email }
    });

    if (existingUser) {
      return res.status(409).json({
        error: 'User Already Exists',
        message: 'Email is already registered'
      });
    }

    // Hash password
    const saltRounds = 12;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Create user
    const user = await prisma.user.create({
      data: {
        email,
        password: passwordHash,
        role,
        name,
        phone,
        address,
        city,
        province,
        postalCode,
        verified: false
      }
    });

    // Create seller profile if role is SELLER
    if (role === 'SELLER') {
      await prisma.sellerProfile.create({
        data: {
          userId: user.id
        }
      });
    }

    // Generate JWT token
    const token = generateToken(user.id, user.role);

    // Return user data (excluding password hash)
    const { password: _, ...userWithoutPassword } = user;

    res.status(201).json({
      message: 'User registered successfully',
      user: userWithoutPassword,
      token,
      tokenType: 'Bearer'
    });

  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      error: 'Registration Failed',
      message: 'An error occurred during registration'
    });
  }
});

// POST /api/auth/login
router.post('/login', loginValidation, async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation Error',
        message: 'Please check your input data',
        details: errors.array()
      });
    }

    const { email, password } = req.body;

    // Find user with profile and seller profile
    const user = await prisma.user.findUnique({
      where: { email },
      include: {
        profile: true,
        sellerProfile: true
      }
    });

    if (!user) {
      return res.status(401).json({
        error: 'Invalid Credentials',
        message: 'Email or password is incorrect'
      });
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({
        error: 'Invalid Credentials',
        message: 'Email or password is incorrect'
      });
    }

    // Generate JWT token
    const token = generateToken(user.id, user.role);

    // Return user data (excluding password hash)
    const { password: _, ...userWithoutPassword } = user;

    res.json({
      message: 'Login successful',
      user: userWithoutPassword,
      token,
      tokenType: 'Bearer'
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      error: 'Login Failed',
      message: 'An error occurred during login'
    });
  }
});

// GET /api/auth/me - Get current user profile
router.get('/me', async (req, res) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        error: 'Access Denied',
        message: 'No token provided'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      include: {
        profile: true,
        sellerProfile: true
      }
    });

    if (!user) {
      return res.status(404).json({
        error: 'User Not Found',
        message: 'User does not exist'
      });
    }

    // Return user data (excluding password hash)
    const { password: _, ...userWithoutPassword } = user;

    res.json({
      user: userWithoutPassword
    });

  } catch (error) {
    console.error('Get user profile error:', error);

    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Invalid Token',
        message: 'Token is malformed'
      });
    }

    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Token Expired',
        message: 'Please login again'
      });
    }

    res.status(500).json({
      error: 'Profile Fetch Failed',
      message: 'Failed to fetch user profile'
    });
  }
});

// POST /api/auth/refresh - Refresh JWT token
router.post('/refresh', async (req, res) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        error: 'Access Denied',
        message: 'No token provided'
      });
    }

    // Verify token (even if expired, we can still decode it)
    const decoded = jwt.decode(token);

    if (!decoded) {
      return res.status(401).json({
        error: 'Invalid Token',
        message: 'Token is malformed'
      });
    }

    // Check if user still exists
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      include: {
        profile: true,
        sellerProfile: true
      }
    });

    if (!user) {
      return res.status(404).json({
        error: 'User Not Found',
        message: 'User does not exist'
      });
    }

    // Generate new token
    const newToken = generateToken(user.id, user.role);

    res.json({
      message: 'Token refreshed successfully',
      token: newToken,
      tokenType: 'Bearer'
    });

  } catch (error) {
    console.error('Token refresh error:', error);
    res.status(500).json({
      error: 'Token Refresh Failed',
      message: 'Failed to refresh token'
    });
  }
});

// GET /api/auth/profile - Alias for /me endpoint
router.get('/profile', async (req, res) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        error: 'Access Denied',
        message: 'No token provided'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      include: {
        profile: true,
        sellerProfile: true
      }
    });

    if (!user) {
      return res.status(404).json({
        error: 'User Not Found',
        message: 'User does not exist'
      });
    }

    // Return user data (excluding password hash)
    const { password: _, ...userWithoutPassword } = user;

    res.json({
      user: userWithoutPassword
    });

  } catch (error) {
    console.error('Get user profile error:', error);

    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Invalid Token',
        message: 'Token is malformed'
      });
    }

    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Token Expired',
        message: 'Please login again'
      });
    }

    res.status(500).json({
      error: 'Profile Fetch Failed',
      message: 'Failed to fetch user profile'
    });
  }
});

module.exports = router;
