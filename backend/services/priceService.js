const axios = require('axios');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

class PriceService {
  constructor() {
    this.sources = {
      tokopedia: 'https://api.tokopedia.com', // Demo URL
      shopee: 'https://api.shopee.com', // Demo URL
      bukalapak: 'https://api.bukalapak.com' // Demo URL
    };
  }

  /**
   * Collect price data from various sources
   * @param {string} spiceType - Type of spice
   * @param {string} qualityGrade - Quality grade
   */
  async collectPriceData(spiceType, qualityGrade) {
    try {
      const pricePromises = [
        this.fetchFromTokopedia(spiceType, qualityGrade),
        this.fetchFromShopee(spiceType, qualityGrade),
        this.fetchFromBukalapak(spiceType, qualityGrade),
        this.fetchInternalPrices(spiceType, qualityGrade)
      ];

      const results = await Promise.allSettled(pricePromises);
      const collectedPrices = [];

      results.forEach((result, index) => {
        if (result.status === 'fulfilled' && result.value.length > 0) {
          collectedPrices.push(...result.value);
        }
      });

      // Clean and normalize data
      const cleanedPrices = this.cleanPriceData(collectedPrices);
      
      // Save to database
      if (cleanedPrices.length > 0) {
        await this.savePriceHistory(cleanedPrices, spiceType, qualityGrade);
      }

      return cleanedPrices;
    } catch (error) {
      console.error('Price collection error:', error);
      throw new Error('Failed to collect price data');
    }
  }

  /**
   * Fetch prices from Tokopedia (Demo implementation)
   */
  async fetchFromTokopedia(spiceType, qualityGrade) {
    try {
      // Demo implementation - in production, use actual Tokopedia API
      const searchQuery = this.translateSpiceForSearch(spiceType);
      
      // Simulate API call with mock data
      const mockPrices = this.generateMockPrices(spiceType, qualityGrade, 'tokopedia', 5);
      
      return mockPrices.map(price => ({
        ...price,
        source: 'tokopedia'
      }));
    } catch (error) {
      console.error('Tokopedia fetch error:', error);
      return [];
    }
  }

  /**
   * Fetch prices from Shopee (Demo implementation)
   */
  async fetchFromShopee(spiceType, qualityGrade) {
    try {
      // Demo implementation - in production, use actual Shopee API
      const mockPrices = this.generateMockPrices(spiceType, qualityGrade, 'shopee', 4);
      
      return mockPrices.map(price => ({
        ...price,
        source: 'shopee'
      }));
    } catch (error) {
      console.error('Shopee fetch error:', error);
      return [];
    }
  }

  /**
   * Fetch prices from Bukalapak (Demo implementation)
   */
  async fetchFromBukalapak(spiceType, qualityGrade) {
    try {
      // Demo implementation - in production, use actual Bukalapak API
      const mockPrices = this.generateMockPrices(spiceType, qualityGrade, 'bukalapak', 3);
      
      return mockPrices.map(price => ({
        ...price,
        source: 'bukalapak'
      }));
    } catch (error) {
      console.error('Bukalapak fetch error:', error);
      return [];
    }
  }

  /**
   * Fetch internal transaction prices
   */
  async fetchInternalPrices(spiceType, qualityGrade) {
    try {
      const internalPrices = await prisma.transactionItem.findMany({
        where: {
          product: {
            spiceType,
            qualityGrade
          },
          transaction: {
            status: 'DELIVERED',
            createdAt: {
              gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) // Last 30 days
            }
          }
        },
        include: {
          product: {
            select: {
              seller: {
                select: {
                  city: true,
                  province: true
                }
              }
            }
          }
        },
        take: 50,
        orderBy: {
          transaction: {
            createdAt: 'desc'
          }
        }
      });

      return internalPrices.map(item => ({
        price: parseFloat(item.unitPrice),
        region: item.product.seller.city || 'Unknown',
        date: item.transaction?.createdAt || new Date(),
        source: 'internal'
      }));
    } catch (error) {
      console.error('Internal prices fetch error:', error);
      return [];
    }
  }

  /**
   * Generate mock prices for demo purposes
   */
  generateMockPrices(spiceType, qualityGrade, source, count) {
    const basePrices = {
      'JAHE': { A_PREMIUM: 25000, B_STANDARD: 20000, C_ECONOMY: 15000 },
      'KUNYIT': { A_PREMIUM: 30000, B_STANDARD: 25000, C_ECONOMY: 20000 },
      'LENGKUAS': { A_PREMIUM: 22000, B_STANDARD: 18000, C_ECONOMY: 14000 },
      'KENCUR': { A_PREMIUM: 35000, B_STANDARD: 28000, C_ECONOMY: 22000 },
      'TEMULAWAK': { A_PREMIUM: 40000, B_STANDARD: 32000, C_ECONOMY: 25000 },
      'SERAI': { A_PREMIUM: 18000, B_STANDARD: 15000, C_ECONOMY: 12000 },
      'CABE_RAWIT': { A_PREMIUM: 45000, B_STANDARD: 38000, C_ECONOMY: 30000 },
      'PALA': { A_PREMIUM: 120000, B_STANDARD: 100000, C_ECONOMY: 80000 },
      'CENGKEH': { A_PREMIUM: 150000, B_STANDARD: 130000, C_ECONOMY: 110000 },
      'MERICA': { A_PREMIUM: 80000, B_STANDARD: 70000, C_ECONOMY: 60000 }
    };

    const basePrice = basePrices[spiceType]?.[qualityGrade] || 25000;
    const prices = [];

    for (let i = 0; i < count; i++) {
      // Add some variation (+/- 20%)
      const variation = (Math.random() - 0.5) * 0.4;
      const price = Math.round(basePrice * (1 + variation));
      
      prices.push({
        price,
        region: this.getRandomRegion(),
        date: new Date(Date.now() - Math.random() * 7 * 24 * 60 * 60 * 1000), // Random within last 7 days
        source
      });
    }

    return prices;
  }

  /**
   * Clean and normalize price data
   */
  cleanPriceData(priceData) {
    return priceData
      .filter(item => item.price && item.price > 0) // Remove null/zero prices
      .filter(item => item.price < 1000000) // Remove unrealistic prices
      .map(item => ({
        ...item,
        price: Math.round(item.price), // Round to whole numbers
        region: item.region || 'Unknown',
        date: item.date || new Date()
      }))
      .filter((item, index, self) => {
        // Remove duplicates based on price and source
        return index === self.findIndex(i => 
          i.price === item.price && 
          i.source === item.source && 
          i.region === item.region
        );
      });
  }

  /**
   * Save price history to database
   */
  async savePriceHistory(priceData, spiceType, qualityGrade) {
    try {
      const priceHistoryData = priceData.map(item => ({
        spiceType,
        quality: qualityGrade,
        price: item.price,
        source: item.source,
        region: item.region,
        createdAt: item.date
      }));

      await prisma.priceHistory.createMany({
        data: priceHistoryData,
        skipDuplicates: true
      });

      console.log(`Saved ${priceHistoryData.length} price records for ${spiceType} ${qualityGrade}`);
    } catch (error) {
      console.error('Save price history error:', error);
      throw new Error('Failed to save price history');
    }
  }

  /**
   * Get price statistics
   */
  async getPriceStatistics(spiceType, qualityGrade, days = 30) {
    try {
      const prices = await prisma.priceHistory.findMany({
        where: {
          spiceType,
          quality: qualityGrade,
          createdAt: {
            gte: new Date(Date.now() - days * 24 * 60 * 60 * 1000)
          }
        },
        orderBy: {
          createdAt: 'desc'
        }
      });

      if (prices.length === 0) {
        return null;
      }

      const priceValues = prices.map(p => parseFloat(p.price));
      const avgPrice = priceValues.reduce((sum, price) => sum + price, 0) / priceValues.length;
      const minPrice = Math.min(...priceValues);
      const maxPrice = Math.max(...priceValues);

      // Recent trend (last 7 days vs previous 7 days)
      const recentPrices = prices.filter(p => 
        new Date(p.createdAt) >= new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
      );
      const olderPrices = prices.filter(p => 
        new Date(p.createdAt) < new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) &&
        new Date(p.createdAt) >= new Date(Date.now() - 14 * 24 * 60 * 60 * 1000)
      );

      const recentAvg = recentPrices.length > 0 
        ? recentPrices.reduce((sum, p) => sum + parseFloat(p.price), 0) / recentPrices.length
        : avgPrice;
      const olderAvg = olderPrices.length > 0 
        ? olderPrices.reduce((sum, p) => sum + parseFloat(p.price), 0) / olderPrices.length
        : avgPrice;

      const trend = recentAvg > olderAvg ? 'up' : (recentAvg < olderAvg ? 'down' : 'stable');
      const trendPercentage = olderAvg !== 0 ? ((recentAvg - olderAvg) / olderAvg * 100) : 0;

      return {
        avgPrice: Math.round(avgPrice),
        minPrice,
        maxPrice,
        recentAvg: Math.round(recentAvg),
        trend,
        trendPercentage: Math.round(trendPercentage * 100) / 100,
        dataPoints: prices.length
      };
    } catch (error) {
      console.error('Get price statistics error:', error);
      return null;
    }
  }

  /**
   * Translate spice type for search
   */
  translateSpiceForSearch(spiceType) {
    const translations = {
      'JAHE': 'jahe ginger',
      'KUNYIT': 'kunyit turmeric',
      'LENGKUAS': 'lengkuas galangal',
      'KENCUR': 'kencur aromatic ginger',
      'TEMULAWAK': 'temulawak javanese ginger',
      'SERAI': 'serai lemongrass',
      'DAUN_JERUK': 'daun jeruk kaffir lime',
      'CABE_RAWIT': 'cabe rawit chili',
      'KEMIRI': 'kemiri candlenut',
      'PALA': 'pala nutmeg',
      'CENGKEH': 'cengkeh cloves',
      'KAYU_MANIS': 'kayu manis cinnamon',
      'MERICA': 'merica black pepper',
      'JINTAN': 'jintan cumin',
      'KETUMBAR': 'ketumbar coriander',
      'KAPULAGA': 'kapulaga cardamom',
      'BUNGA_LAWANG': 'bunga lawang star anise'
    };
    return translations[spiceType] || spiceType.toLowerCase();
  }

  /**
   * Get random Indonesian region for mock data
   */
  getRandomRegion() {
    const regions = [
      'Jakarta', 'Bandung', 'Surabaya', 'Medan', 'Makassar',
      'Palembang', 'Semarang', 'Tangerang', 'Depok', 'Bekasi',
      'Yogyakarta', 'Solo', 'Malang', 'Denpasar', 'Balikpapan'
    ];
    return regions[Math.floor(Math.random() * regions.length)];
  }
}

module.exports = new PriceService();