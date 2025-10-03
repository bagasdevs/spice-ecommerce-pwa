const express = require('express');
const { body, validationResult, param } = require('express-validator');
const { PrismaClient } = require('@prisma/client');
const { authenticateToken, requireBuyer } = require('../middleware/auth');
const midtransService = require('../services/midtransService');
const shippingService = require('../services/shippingService');

const router = express.Router();
const prisma = new PrismaClient();

// Apply authentication to all buyer routes
router.use(authenticateToken);
router.use(requireBuyer);

// GET /api/buyer/products - List all available products
router.get('/products', async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 12, 
      search, 
      spiceType, 
      qualityGrade, 
      minPrice, 
      maxPrice,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;

    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Build where clause
    const where = {
      isActive: true,
      stockQuantity: {
        gt: 0
      }
    };

    if (search) {
      where.OR = [
        {
          name: {
            contains: search,
            mode: 'insensitive'
          }
        },
        {
          description: {
            contains: search,
            mode: 'insensitive'
          }
        }
      ];
    }

    if (spiceType) {
      where.spiceType = spiceType;
    }

    if (qualityGrade) {
      where.qualityGrade = qualityGrade;
    }

    if (minPrice || maxPrice) {
      where.unitPrice = {};
      if (minPrice) where.unitPrice.gte = parseFloat(minPrice);
      if (maxPrice) where.unitPrice.lte = parseFloat(maxPrice);
    }

    // Validate sort parameters
    const validSortFields = ['createdAt', 'unitPrice', 'name', 'stockQuantity'];
    const validSortOrders = ['asc', 'desc'];
    
    const orderBy = {};
    orderBy[validSortFields.includes(sortBy) ? sortBy : 'createdAt'] = 
      validSortOrders.includes(sortOrder) ? sortOrder : 'desc';

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,
        skip,
        take: parseInt(limit),
        orderBy,
        include: {
          seller: {
            select: {
              id: true,
              name: true,
              city: true,
              sellerProfile: {
                select: {
                  farmName: true,
                  averageRating: true,
                  totalReviews: true
                }
              }
            }
          },
          _count: {
            select: {
              reviews: true
            }
          },
          reviews: {
            take: 1,
            orderBy: {
              createdAt: 'desc'
            },
            select: {
              rating: true
            }
          }
        }
      }),
      prisma.product.count({ where })
    ]);

    // Calculate average rating for each product
    const productsWithRating = products.map(product => {
      const averageRating = product.reviews.length > 0 
        ? product.reviews.reduce((sum, review) => sum + review.rating, 0) / product.reviews.length
        : 0;
      
      return {
        ...product,
        averageRating,
        reviewCount: product._count.reviews
      };
    });

    res.json({
      products: productsWithRating,
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

// GET /api/buyer/product/:id - Get product details
router.get('/product/:id', [
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

    const product = await prisma.product.findFirst({
      where: {
        id: productId,
        isActive: true
      },
      include: {
        seller: {
          select: {
            id: true,
            name: true,
            city: true,
            province: true,
            sellerProfile: {
              select: {
                farmName: true,
                farmLocation: true,
                averageRating: true,
                totalReviews: true,
                totalSales: true
              }
            }
          }
        },
        reviews: {
          include: {
            buyer: {
              select: {
                name: true
              }
            }
          },
          orderBy: {
            createdAt: 'desc'
          },
          take: 10
        },
        _count: {
          select: {
            reviews: true,
            transactionItems: true
          }
        }
      }
    });

    if (!product) {
      return res.status(404).json({
        error: 'Product Not Found',
        message: 'Product not found or not available'
      });
    }

    // Get similar products
    const similarProducts = await prisma.product.findMany({
      where: {
        spiceType: product.spiceType,
        id: {
          not: productId
        },
        isActive: true,
        stockQuantity: {
          gt: 0
        }
      },
      include: {
        seller: {
          select: {
            name: true,
            city: true
          }
        }
      },
      take: 4,
      orderBy: {
        createdAt: 'desc'
      }
    });

    // Calculate average rating
    const averageRating = product.reviews.length > 0 
      ? product.reviews.reduce((sum, review) => sum + review.rating, 0) / product.reviews.length
      : 0;

    res.json({
      product: {
        ...product,
        averageRating
      },
      similarProducts
    });

  } catch (error) {
    console.error('Get product details error:', error);
    res.status(500).json({
      error: 'Product Details Fetch Failed',
      message: 'Failed to fetch product details'
    });
  }
});

// POST /api/buyer/calculate-shipping - Calculate shipping cost
router.post('/calculate-shipping', [
  body('items').isArray().withMessage('Items must be an array'),
  body('items.*.productId').isInt().withMessage('Product ID must be an integer'),
  body('items.*.quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
  body('destinationCity').notEmpty().withMessage('Destination city is required'),
  body('destinationProvince').notEmpty().withMessage('Destination province is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation Error',
        details: errors.array()
      });
    }

    const { items, destinationCity, destinationProvince } = req.body;

    // Validate products and calculate total weight
    let totalWeight = 0;
    let totalAmount = 0;
    const orderItems = [];

    for (const item of items) {
      const product = await prisma.product.findFirst({
        where: {
          id: item.productId,
          isActive: true,
          stockQuantity: {
            gte: item.quantity
          }
        },
        include: {
          seller: {
            select: {
              city: true,
              province: true
            }
          }
        }
      });

      if (!product) {
        return res.status(400).json({
          error: 'Invalid Product',
          message: `Product ${item.productId} not available or insufficient stock`
        });
      }

      if (item.quantity < product.minOrderQty) {
        return res.status(400).json({
          error: 'Invalid Quantity',
          message: `Minimum order quantity for ${product.name} is ${product.minOrderQty}`
        });
      }

      const itemWeight = item.quantity; // Assuming 1 unit = 1 kg for simplicity
      const itemTotal = parseFloat(product.unitPrice) * item.quantity;

      totalWeight += itemWeight;
      totalAmount += itemTotal;

      orderItems.push({
        productId: product.id,
        name: product.name,
        quantity: item.quantity,
        unitPrice: parseFloat(product.unitPrice),
        totalPrice: itemTotal,
        weight: itemWeight,
        seller: product.seller
      });
    }

    // Calculate shipping costs using RajaOngkir
    const shippingOptions = await shippingService.calculateShipping({
      origin: orderItems[0].seller.city, // Use first seller's city as origin
      destination: destinationCity,
      weight: Math.ceil(totalWeight * 1000), // Convert to grams
      courier: ['jne', 'tiki', 'pos']
    });

    res.json({
      orderSummary: {
        items: orderItems,
        totalWeight,
        totalAmount,
        itemCount: items.length
      },
      shippingOptions
    });

  } catch (error) {
    console.error('Calculate shipping error:', error);
    res.status(500).json({
      error: 'Shipping Calculation Failed',
      message: 'Failed to calculate shipping cost'
    });
  }
});

// POST /api/buyer/checkout - Create order and payment
router.post('/checkout', [
  body('items').isArray().withMessage('Items must be an array'),
  body('items.*.productId').isInt().withMessage('Product ID must be an integer'),
  body('items.*.quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
  body('shippingAddress').notEmpty().withMessage('Shipping address is required'),
  body('shippingCity').notEmpty().withMessage('Shipping city is required'), 
  body('shippingProvince').notEmpty().withMessage('Shipping province is required'),
  body('shippingPostal').notEmpty().withMessage('Shipping postal code is required'),
  body('courierService').notEmpty().withMessage('Courier service is required'),
  body('shippingCost').isFloat({ min: 0 }).withMessage('Shipping cost must be a positive number')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation Error',
        details: errors.array()
      });
    }

    const buyerId = req.user.id;
    const {
      items,
      shippingAddress,
      shippingCity,
      shippingProvince,
      shippingPostal,
      courierService,
      shippingCost,
      notes
    } = req.body;

    // Validate products and calculate totals
    let totalAmount = 0;
    let totalWeight = 0;
    const orderItems = [];

    for (const item of items) {
      const product = await prisma.product.findFirst({
        where: {
          id: item.productId,
          isActive: true,
          stockQuantity: {
            gte: item.quantity
          }
        }
      });

      if (!product) {
        return res.status(400).json({
          error: 'Invalid Product',
          message: `Product ${item.productId} not available or insufficient stock`
        });
      }

      const itemTotal = parseFloat(product.unitPrice) * item.quantity;
      totalAmount += itemTotal;
      totalWeight += item.quantity; // Assuming 1 unit = 1 kg

      orderItems.push({
        productId: product.id,
        quantity: item.quantity,
        unitPrice: parseFloat(product.unitPrice),
        totalPrice: itemTotal
      });
    }

    const finalAmount = totalAmount + parseFloat(shippingCost);

    // Create transaction in database
    const transaction = await prisma.transaction.create({
      data: {
        buyerId,
        totalAmount: finalAmount,
        shippingCost: parseFloat(shippingCost),
        totalWeight,
        shippingAddress,
        shippingCity,
        shippingProvince,
        shippingPostal,
        courierService,
        notes,
        items: {
          create: orderItems
        }
      },
      include: {
        items: {
          include: {
            product: true
          }
        },
        buyer: true
      }
    });

    // Create Midtrans payment token
    const paymentToken = await midtransService.createPaymentToken({
      orderId: `ORDER-${transaction.id}-${Date.now()}`,
      amount: finalAmount,
      customerDetails: {
        firstName: req.user.name || 'Customer',
        email: req.user.email,
        phone: req.user.phone || '08123456789'
      },
      itemDetails: orderItems.map(item => ({
        id: item.productId,
        price: item.unitPrice,
        quantity: item.quantity,
        name: transaction.items.find(ti => ti.productId === item.productId)?.product.name || 'Product'
      })).concat([
        {
          id: 'SHIPPING',
          price: parseFloat(shippingCost),
          quantity: 1,
          name: `Shipping - ${courierService}`
        }
      ])
    });

    // Update transaction with payment token
    await prisma.transaction.update({
      where: { id: transaction.id },
      data: {
        paymentToken: paymentToken.token
      }
    });

    res.status(201).json({
      message: 'Order created successfully',
      transaction: {
        id: transaction.id,
        totalAmount: finalAmount,
        shippingCost: parseFloat(shippingCost),
        status: transaction.status,
        paymentToken: paymentToken.token,
        paymentUrl: paymentToken.redirectUrl
      }
    });

  } catch (error) {
    console.error('Checkout error:', error);
    res.status(500).json({
      error: 'Checkout Failed',
      message: 'Failed to create order'
    });
  }
});

// GET /api/buyer/orders - Get buyer's orders
router.get('/orders', async (req, res) => {
  try {
    const buyerId = req.user.id;
    const { page = 1, limit = 10, status } = req.query;

    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const where = {
      buyerId
    };

    if (status) {
      where.status = status;
    }

    const [transactions, total] = await Promise.all([
      prisma.transaction.findMany({
        where,
        skip,
        take: parseInt(limit),
        orderBy: {
          createdAt: 'desc'
        },
        include: {
          items: {
            include: {
              product: {
                select: {
                  name: true,
                  spiceType: true,
                  images: true
                }
              }
            }
          }
        }
      }),
      prisma.transaction.count({ where })
    ]);

    res.json({
      orders: transactions,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });

  } catch (error) {
    console.error('Get orders error:', error);
    res.status(500).json({
      error: 'Orders Fetch Failed',
      message: 'Failed to fetch orders'
    });
  }
});

// GET /api/buyer/order/:id - Get order details
router.get('/order/:id', [
  param('id').isInt().withMessage('Invalid order ID')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation Error',
        details: errors.array()
      });
    }

    const orderId = parseInt(req.params.id);
    const buyerId = req.user.id;

    const transaction = await prisma.transaction.findFirst({
      where: {
        id: orderId,
        buyerId
      },
      include: {
        items: {
          include: {
            product: {
              include: {
                seller: {
                  select: {
                    name: true,
                    phone: true,
                    sellerProfile: {
                      select: {
                        farmName: true
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    });

    if (!transaction) {
      return res.status(404).json({
        error: 'Order Not Found',
        message: 'Order not found'
      });
    }

    res.json({
      order: transaction
    });

  } catch (error) {
    console.error('Get order details error:', error);
    res.status(500).json({
      error: 'Order Details Fetch Failed',
      message: 'Failed to fetch order details'
    });
  }
});

module.exports = router;