const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { param, query, validationResult } = require('express-validator');

const router = express.Router();
const prisma = new PrismaClient();

// GET /api/products - Public endpoint to list all active products
router.get('/', async (req, res) => {
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
      sortOrder = 'desc',
      sellerId
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

    if (sellerId) {
      where.sellerId = parseInt(sellerId);
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
              province: true,
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
              reviews: true,
              transactionItems: true
            }
          }
        }
      }),
      prisma.product.count({ where })
    ]);

    // Calculate average rating for each product
    const productsWithStats = await Promise.all(
      products.map(async (product) => {
        const reviews = await prisma.review.findMany({
          where: { productId: product.id },
          select: { rating: true }
        });

        const averageRating = reviews.length > 0 
          ? reviews.reduce((sum, review) => sum + review.rating, 0) / reviews.length
          : 0;

        return {
          ...product,
          averageRating: Math.round(averageRating * 10) / 10, // Round to 1 decimal
          reviewCount: reviews.length,
          totalSold: product._count.transactionItems
        };
      })
    );

    res.json({
      products: productsWithStats,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      },
      filters: {
        spiceTypes: await getSpiceTypeOptions(),
        qualityGrades: ['A_PREMIUM', 'B_STANDARD', 'C_ECONOMY'],
        priceRange: await getPriceRange()
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

// GET /api/products/:id - Get single product details
router.get('/:id', [
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
            phone: true,
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
        priceHistories: {
          where: {
            createdAt: {
              gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) // Last 30 days
            }
          },
          orderBy: {
            createdAt: 'desc'
          },
          take: 50
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
            city: true,
            sellerProfile: {
              select: {
                farmName: true
              }
            }
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

    // Get market price data for comparison
    const marketPrices = await prisma.priceHistory.findMany({
      where: {
        spiceType: product.spiceType,
        quality: product.qualityGrade,
        createdAt: {
          gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) // Last 7 days
        }
      },
      orderBy: {
        createdAt: 'desc'
      },
      take: 20
    });

    const marketAverage = marketPrices.length > 0
      ? marketPrices.reduce((sum, price) => sum + parseFloat(price.price), 0) / marketPrices.length
      : null;

    res.json({
      product: {
        ...product,
        averageRating: Math.round(averageRating * 10) / 10,
        reviewCount: product.reviews.length,
        marketAverage: marketAverage ? Math.round(marketAverage) : null,
        priceComparison: marketAverage ? {
          currentPrice: parseFloat(product.unitPrice),
          marketAverage: Math.round(marketAverage),
          difference: parseFloat(product.unitPrice) - marketAverage,
          isAboveMarket: parseFloat(product.unitPrice) > marketAverage
        } : null
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

// GET /api/products/search/suggestions - Get search suggestions
router.get('/search/suggestions', [
  query('q').optional().isLength({ min: 1, max: 50 }).withMessage('Query must be 1-50 characters')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation Error',
        details: errors.array()
      });
    }

    const { q } = req.query;

    if (!q || q.length < 2) {
      return res.json({
        suggestions: [],
        popular: await getPopularSearchTerms()
      });
    }

    // Get product name suggestions
    const productSuggestions = await prisma.product.findMany({
      where: {
        isActive: true,
        OR: [
          {
            name: {
              contains: q,
              mode: 'insensitive'
            }
          },
          {
            description: {
              contains: q,
              mode: 'insensitive'
            }
          }
        ]
      },
      select: {
        name: true,
        spiceType: true
      },
      take: 10,
      distinct: ['name']
    });

    // Get seller suggestions
    const sellerSuggestions = await prisma.user.findMany({
      where: {
        role: 'SELLER',
        OR: [
          {
            name: {
              contains: q,
              mode: 'insensitive'
            }
          },
          {
            sellerProfile: {
              farmName: {
                contains: q,
                mode: 'insensitive'
              }
            }
          }
        ]
      },
      select: {
        name: true,
        sellerProfile: {
          select: {
            farmName: true
          }
        }
      },
      take: 5
    });

    const suggestions = [
      ...productSuggestions.map(p => ({
        type: 'product',
        text: p.name,
        spiceType: p.spiceType
      })),
      ...sellerSuggestions.map(s => ({
        type: 'seller',
        text: s.sellerProfile?.farmName || s.name
      }))
    ];

    res.json({
      query: q,
      suggestions: suggestions.slice(0, 8)
    });

  } catch (error) {
    console.error('Search suggestions error:', error);
    res.status(500).json({
      error: 'Search Suggestions Failed',
      message: 'Failed to fetch search suggestions'
    });
  }
});

// Helper functions
async function getSpiceTypeOptions() {
  try {
    const spiceTypes = await prisma.product.groupBy({
      by: ['spiceType'],
      where: {
        isActive: true,
        stockQuantity: {
          gt: 0
        }
      },
      _count: {
        spiceType: true
      },
      orderBy: {
        _count: {
          spiceType: 'desc'
        }
      }
    });

    return spiceTypes.map(item => ({
      value: item.spiceType,
      count: item._count.spiceType
    }));
  } catch (error) {
    console.error('Get spice type options error:', error);
    return [];
  }
}

async function getPriceRange() {
  try {
    const priceRange = await prisma.product.aggregate({
      where: {
        isActive: true,
        stockQuantity: {
          gt: 0
        }
      },
      _min: {
        unitPrice: true
      },
      _max: {
        unitPrice: true
      }
    });

    return {
      min: Math.floor(parseFloat(priceRange._min.unitPrice) || 0),
      max: Math.ceil(parseFloat(priceRange._max.unitPrice) || 100000)
    };
  } catch (error) {
    console.error('Get price range error:', error);
    return { min: 0, max: 100000 };
  }
}

async function getPopularSearchTerms() {
  try {
    // Get most common spice types as popular terms
    const popularSpices = await prisma.product.groupBy({
      by: ['spiceType'],
      where: {
        isActive: true
      },
      _count: {
        spiceType: true
      },
      orderBy: {
        _count: {
          spiceType: 'desc'
        }
      },
      take: 5
    });

    return popularSpices.map(item => ({
      text: translateSpiceType(item.spiceType),
      type: 'spice',
      value: item.spiceType
    }));
  } catch (error) {
    console.error('Get popular search terms error:', error);
    return [];
  }
}

function translateSpiceType(spiceType) {
  const translations = {
    'JAHE': 'Jahe',
    'KUNYIT': 'Kunyit',
    'LENGKUAS': 'Lengkuas',
    'KENCUR': 'Kencur',
    'TEMULAWAK': 'Temulawak',
    'SERAI': 'Serai',
    'DAUN_JERUK': 'Daun Jeruk',
    'CABE_RAWIT': 'Cabe Rawit',
    'KEMIRI': 'Kemiri',
    'PALA': 'Pala',
    'CENGKEH': 'Cengkeh',
    'KAYU_MANIS': 'Kayu Manis',
    'MERICA': 'Merica',
    'JINTAN': 'Jintan',
    'KETUMBAR': 'Ketumbar',
    'KAPULAGA': 'Kapulaga',
    'BUNGA_LAWANG': 'Bunga Lawang',
    'OTHER': 'Lainnya'
  };
  return translations[spiceType] || spiceType;
}

module.exports = router;