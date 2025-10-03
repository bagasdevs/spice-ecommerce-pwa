const express = require('express');
const { body, validationResult, param } = require('express-validator');
const { PrismaClient } = require('@prisma/client');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();
const prisma = new PrismaClient();

// Apply authentication and admin role to all routes
router.use(authenticateToken);
router.use(requireAdmin);

// GET /api/admin/dashboard - Admin dashboard with system overview
router.get('/dashboard', async (req, res) => {
  try {
    // Get overall statistics
    const [
      totalUsers,
      totalSellers,
      totalBuyers,
      totalProducts,
      totalTransactions,
      totalRevenue,
      activeProducts,
      pendingTransactions
    ] = await Promise.all([
      prisma.user.count(),
      prisma.user.count({ where: { role: 'SELLER' } }),
      prisma.user.count({ where: { role: 'BUYER' } }),
      prisma.product.count(),
      prisma.transaction.count(),
      prisma.transaction.aggregate({
        where: { status: 'DELIVERED' },
        _sum: { totalAmount: true }
      }),
      prisma.product.count({ where: { isActive: true } }),
      prisma.transaction.count({ where: { status: 'PENDING' } })
    ]);

    // Get recent activities
    const recentUsers = await prisma.user.findMany({
      take: 5,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        createdAt: true,
        verified: true
      }
    });

    const recentTransactions = await prisma.transaction.findMany({
      take: 10,
      orderBy: { createdAt: 'desc' },
      include: {
        buyer: {
          select: { name: true, email: true }
        },
        items: {
          include: {
            product: {
              select: { name: true }
            }
          }
        }
      }
    });

    // Get top selling products
    const topProducts = await prisma.transactionItem.groupBy({
      by: ['productId'],
      _sum: {
        quantity: true,
        totalPrice: true
      },
      orderBy: {
        _sum: {
          quantity: 'desc'
        }
      },
      take: 5
    });

    const topProductsWithDetails = await Promise.all(
      topProducts.map(async (item) => {
        const product = await prisma.product.findUnique({
          where: { id: item.productId },
          select: {
            id: true,
            name: true,
            spiceType: true,
            seller: {
              select: { name: true }
            }
          }
        });
        return {
          ...product,
          totalSold: item._sum.quantity,
          totalRevenue: item._sum.totalPrice
        };
      })
    );

    res.json({
      statistics: {
        totalUsers,
        totalSellers,
        totalBuyers,
        totalProducts,
        activeProducts,
        totalTransactions,
        pendingTransactions,
        totalRevenue: totalRevenue._sum.totalAmount || 0
      },
      recentUsers,
      recentTransactions,
      topProducts: topProductsWithDetails
    });

  } catch (error) {
    console.error('Admin dashboard error:', error);
    res.status(500).json({
      error: 'Dashboard Error',
      message: 'Failed to fetch dashboard data'
    });
  }
});

// GET /api/admin/users - Manage users with pagination and filters
router.get('/users', async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      role, 
      verified, 
      search,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;

    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Build where clause
    const where = {};

    if (role && ['SELLER', 'BUYER', 'ADMIN'].includes(role)) {
      where.role = role;
    }

    if (verified !== undefined) {
      where.verified = verified === 'true';
    }

    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } }
      ];
    }

    // Validate sort parameters
    const validSortFields = ['createdAt', 'name', 'email', 'role'];
    const validSortOrders = ['asc', 'desc'];
    
    const orderBy = {};
    orderBy[validSortFields.includes(sortBy) ? sortBy : 'createdAt'] = 
      validSortOrders.includes(sortOrder) ? sortOrder : 'desc';

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        skip,
        take: parseInt(limit),
        orderBy,
        select: {
          id: true,
          name: true,
          email: true,
          role: true,
          phone: true,
          city: true,
          province: true,
          verified: true,
          createdAt: true,
          updatedAt: true,
          sellerProfile: {
            select: {
              farmName: true,
              totalSales: true,
              averageRating: true,
              totalReviews: true
            }
          },
          _count: {
            select: {
              products: true,
              buyerTransactions: true
            }
          }
        }
      }),
      prisma.user.count({ where })
    ]);

    res.json({
      users,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });

  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({
      error: 'Users Fetch Failed',
      message: 'Failed to fetch users'
    });
  }
});

// PUT /api/admin/user/:id/verify - Verify user account
router.put('/user/:id/verify', [
  param('id').isInt().withMessage('Invalid user ID')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation Error',
        details: errors.array()
      });
    }

    const userId = parseInt(req.params.id);

    const user = await prisma.user.findUnique({
      where: { id: userId }
    });

    if (!user) {
      return res.status(404).json({
        error: 'User Not Found',
        message: 'User not found'
      });
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: { verified: true },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        verified: true
      }
    });

    res.json({
      message: 'User verified successfully',
      user: updatedUser
    });

  } catch (error) {
    console.error('Verify user error:', error);
    res.status(500).json({
      error: 'User Verification Failed',
      message: 'Failed to verify user'
    });
  }
});

// GET /api/admin/products - Manage all products
router.get('/products', async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      spiceType, 
      qualityGrade,
      isActive,
      search,
      sellerId
    } = req.query;

    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Build where clause
    const where = {};

    if (spiceType) {
      where.spiceType = spiceType;
    }

    if (qualityGrade) {
      where.qualityGrade = qualityGrade;
    }

    if (isActive !== undefined) {
      where.isActive = isActive === 'true';
    }

    if (sellerId) {
      where.sellerId = parseInt(sellerId);
    }

    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } }
      ];
    }

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,
        skip,
        take: parseInt(limit),
        orderBy: { createdAt: 'desc' },
        include: {
          seller: {
            select: {
              id: true,
              name: true,
              email: true,
              sellerProfile: {
                select: {
                  farmName: true
                }
              }
            }
          },
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
    console.error('Get products error:', error);
    res.status(500).json({
      error: 'Products Fetch Failed',
      message: 'Failed to fetch products'
    });
  }
});

// PUT /api/admin/product/:id/toggle-status - Toggle product active status
router.put('/product/:id/toggle-status', [
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

    const product = await prisma.product.findUnique({
      where: { id: productId }
    });

    if (!product) {
      return res.status(404).json({
        error: 'Product Not Found',
        message: 'Product not found'
      });
    }

    const updatedProduct = await prisma.product.update({
      where: { id: productId },
      data: { isActive: !product.isActive },
      include: {
        seller: {
          select: {
            name: true,
            email: true
          }
        }
      }
    });

    res.json({
      message: `Product ${updatedProduct.isActive ? 'activated' : 'deactivated'} successfully`,
      product: updatedProduct
    });

  } catch (error) {
    console.error('Toggle product status error:', error);
    res.status(500).json({
      error: 'Product Status Update Failed',
      message: 'Failed to update product status'
    });
  }
});

// GET /api/admin/transactions - Manage all transactions
router.get('/transactions', async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      status,
      paymentStatus,
      buyerId,
      search
    } = req.query;

    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Build where clause
    const where = {};

    if (status) {
      where.status = status;
    }

    if (paymentStatus) {
      where.paymentStatus = paymentStatus;
    }

    if (buyerId) {
      where.buyerId = parseInt(buyerId);
    }

    const [transactions, total] = await Promise.all([
      prisma.transaction.findMany({
        where,
        skip,
        take: parseInt(limit),
        orderBy: { createdAt: 'desc' },
        include: {
          buyer: {
            select: {
              id: true,
              name: true,
              email: true
            }
          },
          items: {
            include: {
              product: {
                select: {
                  name: true,
                  spiceType: true,
                  seller: {
                    select: {
                      name: true
                    }
                  }
                }
              }
            }
          }
        }
      }),
      prisma.transaction.count({ where })
    ]);

    res.json({
      transactions,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });

  } catch (error) {
    console.error('Get transactions error:', error);
    res.status(500).json({
      error: 'Transactions Fetch Failed',
      message: 'Failed to fetch transactions'
    });
  }
});

// PUT /api/admin/transaction/:id/status - Update transaction status
router.put('/transaction/:id/status', [
  param('id').isInt().withMessage('Invalid transaction ID'),
  body('status').isIn(['PENDING', 'PAID', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'REFUNDED'])
    .withMessage('Invalid status')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation Error',
        details: errors.array()
      });
    }

    const transactionId = parseInt(req.params.id);
    const { status, trackingNumber } = req.body;

    const transaction = await prisma.transaction.findUnique({
      where: { id: transactionId }
    });

    if (!transaction) {
      return res.status(404).json({
        error: 'Transaction Not Found',
        message: 'Transaction not found'
      });
    }

    const updateData = { status };
    if (trackingNumber) {
      updateData.trackingNumber = trackingNumber;
    }

    const updatedTransaction = await prisma.transaction.update({
      where: { id: transactionId },
      data: updateData,
      include: {
        buyer: {
          select: {
            name: true,
            email: true
          }
        }
      }
    });

    res.json({
      message: 'Transaction status updated successfully',
      transaction: updatedTransaction
    });

  } catch (error) {
    console.error('Update transaction status error:', error);
    res.status(500).json({
      error: 'Transaction Status Update Failed',
      message: 'Failed to update transaction status'
    });
  }
});

// GET /api/admin/reports/sales - Sales analytics
router.get('/reports/sales', async (req, res) => {
  try {
    const { period = '30', startDate, endDate } = req.query;

    let dateFilter = {};
    
    if (startDate && endDate) {
      dateFilter = {
        createdAt: {
          gte: new Date(startDate),
          lte: new Date(endDate)
        }
      };
    } else {
      const days = parseInt(period);
      dateFilter = {
        createdAt: {
          gte: new Date(Date.now() - days * 24 * 60 * 60 * 1000)
        }
      };
    }

    // Sales by date
    const salesByDate = await prisma.transaction.groupBy({
      by: ['createdAt'],
      where: {
        status: 'DELIVERED',
        ...dateFilter
      },
      _sum: {
        totalAmount: true
      },
      _count: {
        id: true
      }
    });

    // Sales by spice type
    const salesBySpice = await prisma.transactionItem.groupBy({
      by: ['productId'],
      where: {
        transaction: {
          status: 'DELIVERED',
          ...dateFilter
        }
      },
      _sum: {
        quantity: true,
        totalPrice: true
      }
    });

    // Get product details for spice type aggregation
    const spiceTypeData = new Map();
    for (const item of salesBySpice) {
      const product = await prisma.product.findUnique({
        where: { id: item.productId },
        select: { spiceType: true }
      });
      
      if (product) {
        const existing = spiceTypeData.get(product.spiceType) || { quantity: 0, revenue: 0 };
        spiceTypeData.set(product.spiceType, {
          quantity: existing.quantity + item._sum.quantity,
          revenue: existing.revenue + parseFloat(item._sum.totalPrice)
        });
      }
    }

    const salesBySpiceType = Array.from(spiceTypeData.entries()).map(([spiceType, data]) => ({
      spiceType,
      ...data
    }));

    // Top sellers
    const topSellers = await prisma.user.findMany({
      where: {
        role: 'SELLER',
        products: {
          some: {
            transactionItems: {
              some: {
                transaction: {
                  status: 'DELIVERED',
                  ...dateFilter
                }
              }
            }
          }
        }
      },
      include: {
        sellerProfile: {
          select: {
            farmName: true,
            totalSales: true
          }
        },
        products: {
          include: {
            transactionItems: {
              where: {
                transaction: {
                  status: 'DELIVERED',
                  ...dateFilter
                }
              },
              select: {
                totalPrice: true
              }
            }
          }
        }
      },
      take: 10
    });

    const topSellersData = topSellers.map(seller => {
      const totalRevenue = seller.products.reduce((sum, product) => {
        return sum + product.transactionItems.reduce((productSum, item) => {
          return productSum + parseFloat(item.totalPrice);
        }, 0);
      }, 0);

      return {
        id: seller.id,
        name: seller.name,
        farmName: seller.sellerProfile?.farmName,
        totalRevenue
      };
    }).sort((a, b) => b.totalRevenue - a.totalRevenue);

    res.json({
      period: {
        days: parseInt(period),
        startDate: startDate || new Date(Date.now() - parseInt(period) * 24 * 60 * 60 * 1000).toISOString(),
        endDate: endDate || new Date().toISOString()
      },
      salesByDate,
      salesBySpiceType,
      topSellers: topSellersData
    });

  } catch (error) {
    console.error('Sales report error:', error);
    res.status(500).json({
      error: 'Sales Report Failed',
      message: 'Failed to generate sales report'
    });
  }
});

module.exports = router;