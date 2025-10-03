const express = require('express');
const { body, validationResult, param } = require('express-validator');
const { PrismaClient } = require('@prisma/client');
const { authenticateToken, requireSeller } = require('../middleware/auth');
const aiService = require('../services/aiService');
const priceService = require('../services/priceService');

const router = express.Router();
const prisma = new PrismaClient();

// Apply authentication to all seller routes
router.use(authenticateToken);
router.use(requireSeller);

// Validation rules
const productValidation = [
  body('name')
    .trim()
    .isLength({ min: 2, max: 200 })
    .withMessage('Product name must be between 2-200 characters'),
  body('spiceType')
    .isIn(['JAHE', 'KUNYIT', 'LENGKUAS', 'KENCUR', 'TEMULAWAK', 'SERAI', 'DAUN_JERUK', 'CABE_RAWIT', 'KEMIRI', 'PALA', 'CENGKEH', 'KAYU_MANIS', 'MERICA', 'JINTAN', 'KETUMBAR', 'KAPULAGA', 'BUNGA_LAWANG', 'OTHER'])
    .withMessage('Invalid spice type'),
  body('stockQuantity')
    .isInt({ min: 0 })
    .withMessage('Stock quantity must be a positive integer'),
  body('unitPrice')
    .isFloat({ min: 0 })
    .withMessage('Unit price must be a positive number'),
  body('qualityGrade')
    .isIn(['A_PREMIUM', 'B_STANDARD', 'C_ECONOMY'])
    .withMessage('Quality grade must be A_PREMIUM, B_STANDARD, or C_ECONOMY'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description cannot exceed 1000 characters'),
  body('minOrderQty')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Minimum order quantity must be at least 1'),
  body('unit')
    .optional()
    .isIn(['kg', 'gram', 'ton'])
    .withMessage('Unit must be kg, gram, or ton')
];

// GET /api/seller/dashboard - Seller dashboard data
router.get('/dashboard', async (req, res) => {
  try {
    const sellerId = req.user.id;

    // Get seller's products count
    const totalProducts = await prisma.product.count({
      where: { sellerId, isActive: true }
    });

    // Get total sales
    const salesData = await prisma.transaction.aggregate({
      where: {
        items: {
          some: {
            product: {
              sellerId
            }
          }
        },
        status: 'DELIVERED'
      },
      _sum: {
        totalAmount: true
      },
      _count: {
        id: true
      }
    });

    // Get recent transactions
    const recentTransactions = await prisma.transaction.findMany({
      where: {
        items: {
          some: {
            product: {
              sellerId
            }
          }
        }
      },
      include: {
        items: {
          include: {
            product: true
          }
        },
        buyer: {
          select: {
            name: true,
            email: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      },
      take: 10
    });

    // Get low stock products
    const lowStockProducts = await prisma.product.findMany({
      where: {
        sellerId,
        isActive: true,
        stockQuantity: {
          lte: 10
        }
      },
      select: {
        id: true,
        name: true,
        stockQuantity: true,
        spiceType: true
      },
      take: 5
    });

    res.json({
      summary: {
        totalProducts,
        totalSales: salesData._sum.totalAmount || 0,
        totalOrders: salesData._count || 0,
        averageOrderValue: salesData._count > 0 
          ? (salesData._sum.totalAmount || 0) / salesData._count 
          : 0
      },
      recentTransactions,
      lowStockProducts
    });

  } catch (error) {
    console.error('Seller dashboard error:', error);
    res.status(500).json({
      error: 'Dashboard Error',
      message: 'Failed to fetch dashboard data'
    });
  }
});

// POST /api/seller/product - Add new product
router.post('/product', productValidation, async (req, res) => {
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

    const sellerId = req.user.id;
    const {
      name,
      spiceType,
      description,
      stockQuantity,
      unitPrice,
      qualityGrade,
      harvestDate,
      expiryDate,
      images,
      minOrderQty,
      unit
    } = req.body;

    const product = await prisma.product.create({
      data: {
        name,
        spiceType,
        description,
        stockQuantity: parseInt(stockQuantity),
        unitPrice: parseFloat(unitPrice),
        qualityGrade,
        harvestDate: harvestDate ? new Date(harvestDate) : null,
        expiryDate: expiryDate ? new Date(expiryDate) : null,
        images: images ? JSON.stringify(images) : null,
        sellerId,
        minOrderQty: parseInt(minOrderQty) || 1,
        unit: unit || 'kg'
      }
    });

    res.status(201).json({
      message: 'Product added successfully',
      product
    });

  } catch (error) {
    console.error('Add product error:', error);
    res.status(500).json({
      error: 'Product Creation Failed',
      message: 'Failed to add product'
    });
  }
});

// GET /api/seller/products - Get seller's products
router.get('/products', async (req, res) => {
  try {
    const sellerId = req.user.id;
    const { page = 1, limit = 10, search, spiceType, isActive } = req.query;

    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Build where clause
    const where = {
      sellerId
    };

    if (search) {
      where.name = {
        contains: search,
        mode: 'insensitive'
      };
    }

    if (spiceType) {
      where.spiceType = spiceType;
    }

    if (isActive !== undefined) {
      where.isActive = isActive === 'true';
    }

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,
        skip,
        take: parseInt(limit),
        orderBy: {
          createdAt: 'desc'
        },
        include: {
          _count: {
            select: {
              reviews: true,
              transactionItems: true
            }
          }
        }
      }),
      prisma.product.count({ where })
    ]);

    res.json({
      products,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });

  } catch (error) {
    console.error('Get seller products error:', error);
    res.status(500).json({
      error: 'Products Fetch Failed',
      message: 'Failed to fetch products'
    });
  }
});

// POST /api/seller/predict-price - Get AI price prediction
router.post('/predict-price', [
  body('spiceType').notEmpty().withMessage('Spice type is required'),
  body('qualityGrade').notEmpty().withMessage('Quality grade is required')
], async (req, res) => {
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

    const { spiceType, qualityGrade } = req.body;

    // Check for recent prediction first
    const recentPrediction = await aiService.getLatestPrediction(spiceType, qualityGrade);
    
    if (recentPrediction) {
      return res.json({
        prediction: {
          predictedPrice: parseFloat(recentPrediction.predictedPrice),
          confidence: recentPrediction.confidence,
          recommendation: recentPrediction.recommendation,
          reasoning: recentPrediction.reasoning
        },
        fromCache: true,
        validUntil: recentPrediction.validUntil
      });
    }

    // Get historical price data
    const historicalData = await prisma.priceHistory.findMany({
      where: {
        spiceType,
        quality: qualityGrade,
        createdAt: {
          gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) // Last 30 days
        }
      },
      orderBy: {
        createdAt: 'asc'
      },
      take: 100
    });

    if (historicalData.length < 3) {
      // Collect fresh price data if insufficient historical data
      await priceService.collectPriceData(spiceType, qualityGrade);
      
      // Try again with updated data
      const updatedHistoricalData = await prisma.priceHistory.findMany({
        where: {
          spiceType,
          quality: qualityGrade
        },
        orderBy: {
          createdAt: 'asc'
        },
        take: 100
      });

      if (updatedHistoricalData.length < 3) {
        return res.status(400).json({
          error: 'Insufficient Data',
          message: 'Not enough historical price data for prediction. Please try again later.'
        });
      }

      historicalData.push(...updatedHistoricalData);
    }

    // Generate AI prediction
    const predictionResult = await aiService.predictPrice(spiceType, qualityGrade, historicalData);

    res.json({
      ...predictionResult,
      fromCache: false
    });

  } catch (error) {
    console.error('Price prediction error:', error);
    res.status(500).json({
      error: 'Prediction Failed',
      message: 'Failed to generate price prediction'
    });
  }
});

// PUT /api/seller/product/:id - Update product
router.put('/product/:id', [
  param('id').isInt().withMessage('Invalid product ID'),
  ...productValidation
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation Error',
        details: errors.array()
      });
    }

    const productId = parseInt(req.params.id);
    const sellerId = req.user.id;

    // Check if product exists and belongs to seller
    const existingProduct = await prisma.product.findFirst({
      where: {
        id: productId,
        sellerId
      }
    });

    if (!existingProduct) {
      return res.status(404).json({
        error: 'Product Not Found',
        message: 'Product not found or you do not have permission to update it'
      });
    }

    const {
      name,
      spiceType,
      description,
      stockQuantity,
      unitPrice,
      qualityGrade,
      harvestDate,
      expiryDate,
      images,
      minOrderQty,
      unit,
      isActive
    } = req.body;

    const updatedProduct = await prisma.product.update({
      where: { id: productId },
      data: {
        name,
        spiceType,
        description,
        stockQuantity: parseInt(stockQuantity),
        unitPrice: parseFloat(unitPrice),
        qualityGrade,
        harvestDate: harvestDate ? new Date(harvestDate) : null,
        expiryDate: expiryDate ? new Date(expiryDate) : null,
        images: images ? JSON.stringify(images) : null,
        minOrderQty: parseInt(minOrderQty) || 1,
        unit: unit || 'kg',
        isActive: isActive !== undefined ? isActive : existingProduct.isActive
      }
    });

    res.json({
      message: 'Product updated successfully',
      product: updatedProduct
    });

  } catch (error) {
    console.error('Update product error:', error);
    res.status(500).json({
      error: 'Product Update Failed',
      message: 'Failed to update product'
    });
  }
});

// DELETE /api/seller/product/:id - Delete/deactivate product
router.delete('/product/:id', [
  param('id').isInt().withMessage('Invalid product ID')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation Error',
        details: errors.array()
      });
    }

    const productId = parseInt(req.params.id);
    const sellerId = req.user.id;

    // Check if product exists and belongs to seller
    const product = await prisma.product.findFirst({
      where: {
        id: productId,
        sellerId
      }
    });

    if (!product) {
      return res.status(404).json({
        error: 'Product Not Found',
        message: 'Product not found or you do not have permission to delete it'
      });
    }

    // Soft delete by setting isActive to false
    await prisma.product.update({
      where: { id: productId },
      data: { isActive: false }
    });

    res.json({
      message: 'Product deactivated successfully'
    });

  } catch (error) {
    console.error('Delete product error:', error);
    res.status(500).json({
      error: 'Product Deletion Failed',
      message: 'Failed to delete product'
    });
  }
});

module.exports = router;