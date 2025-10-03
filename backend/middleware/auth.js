const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// JWT Authentication middleware
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        error: 'Access Denied',
        message: 'No token provided'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Fetch user details from database
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      include: {
        sellerProfile: true
      }
    });

    if (!user) {
      return res.status(401).json({
        error: 'Invalid Token',
        message: 'User not found'
      });
    }

    req.user = user;
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    
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
      error: 'Authentication Error',
      message: 'Failed to authenticate token'
    });
  }
};

// Role-based authorization middleware
const requireRole = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        error: 'Authentication Required',
        message: 'Please login first'
      });
    }

    const userRoles = Array.isArray(roles) ? roles : [roles];
    
    if (!userRoles.includes(req.user.role)) {
      return res.status(403).json({
        error: 'Access Forbidden',
        message: `Required role: ${userRoles.join(' or ')}, but user has role: ${req.user.role}`
      });
    }

    next();
  };
};

// Seller-specific middleware
const requireSeller = requireRole(['SELLER', 'ADMIN']);

// Buyer-specific middleware  
const requireBuyer = requireRole(['BUYER', 'ADMIN']);

// Admin-only middleware
const requireAdmin = requireRole('ADMIN');

// Seller ownership middleware (for protecting seller's own resources)
const requireSellerOwnership = async (req, res, next) => {
  try {
    const sellerId = req.params.sellerId || req.body.sellerId;
    
    if (req.user.role === 'ADMIN') {
      // Admins can access any seller's data
      return next();
    }
    
    if (req.user.role !== 'SELLER') {
      return res.status(403).json({
        error: 'Access Forbidden',
        message: 'Only sellers can access this resource'
      });
    }
    
    if (sellerId && parseInt(sellerId) !== req.user.id) {
      return res.status(403).json({
        error: 'Access Forbidden',
        message: 'You can only access your own data'
      });
    }
    
    next();
  } catch (error) {
    console.error('Seller ownership middleware error:', error);
    res.status(500).json({
      error: 'Authorization Error',
      message: 'Failed to verify ownership'
    });
  }
};

module.exports = {
  authenticateToken,
  requireRole,
  requireSeller,
  requireBuyer,
  requireAdmin,
  requireSellerOwnership
};