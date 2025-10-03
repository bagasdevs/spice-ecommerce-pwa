const { GoogleGenerativeAI } = require('@google/generative-ai');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

class AIService {
  constructor() {
    this.model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
  }

  /**
   * Predict next-day price using Gemini AI
   * @param {string} spiceType - Type of spice (e.g., 'JAHE', 'KUNYIT')
   * @param {string} qualityGrade - Quality grade ('A_PREMIUM', 'B_STANDARD', 'C_ECONOMY')
   * @param {Array} historicalData - Array of historical price data
   * @returns {Object} Prediction result
   */
  async predictPrice(spiceType, qualityGrade, historicalData) {
    try {
      if (!historicalData || historicalData.length < 3) {
        throw new Error('Insufficient historical data for prediction');
      }

      // Prepare historical data for AI analysis
      const priceData = historicalData.map(item => ({
        date: item.createdAt,
        price: parseFloat(item.price),
        source: item.source,
        region: item.region || 'Unknown'
      }));

      // Calculate basic statistics
      const prices = priceData.map(item => item.price);
      const avgPrice = prices.reduce((sum, price) => sum + price, 0) / prices.length;
      const minPrice = Math.min(...prices);
      const maxPrice = Math.max(...prices);
      
      // Recent price trend (last 7 days)
      const recentPrices = priceData.slice(-7);
      const recentAvg = recentPrices.reduce((sum, item) => sum + item.price, 0) / recentPrices.length;

      // Create prompt for Gemini
      const prompt = `
Anda adalah seorang ahli prediksi harga komoditas rempah-rempah Indonesia. Analisis data historis berikut dan berikan prediksi harga untuk besok.

Data Rempah:
- Jenis: ${this.translateSpiceType(spiceType)}
- Kualitas: ${this.translateQualityGrade(qualityGrade)}

Data Historis Harga (Rp/kg):
${priceData.map(item => `${item.date}: Rp ${item.price.toLocaleString('id-ID')} (${item.source})`).join('\n')}

Statistik:
- Harga rata-rata: Rp ${avgPrice.toLocaleString('id-ID')}
- Harga minimum: Rp ${minPrice.toLocaleString('id-ID')}
- Harga maksimum: Rp ${maxPrice.toLocaleString('id-ID')}
- Rata-rata 7 hari terakhir: Rp ${recentAvg.toLocaleString('id-ID')}

Tugas Anda:
1. Analisis tren harga berdasarkan data historis
2. Pertimbangkan faktor musiman, permintaan pasar, dan kualitas produk
3. Berikan prediksi harga untuk besok dengan confidence score (0-1)
4. Berikan rekomendasi: "JUAL_SEKARANG" jika prediksi < rata-rata, "TUNDA_JUAL" jika prediksi > rata-rata
5. Berikan alasan singkat untuk rekomendasi

Format respons JSON:
{
  "predicted_price": [harga prediksi dalam rupiah],
  "confidence": [skor kepercayaan 0-1],
  "recommendation": "[JUAL_SEKARANG atau TUNDA_JUAL]",
  "reasoning": "[penjelasan singkat dalam bahasa Indonesia]"
}
`;

      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();

      // Parse JSON response from Gemini
      let aiResponse;
      try {
        // Extract JSON from response
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          aiResponse = JSON.parse(jsonMatch[0]);
        } else {
          throw new Error('No JSON found in AI response');
        }
      } catch (parseError) {
        console.error('Failed to parse AI response:', text);
        // Fallback to simple analysis
        aiResponse = this.fallbackPrediction(avgPrice, recentAvg, prices);
      }

      // Validate and sanitize AI response
      const predictedPrice = Math.max(0, parseFloat(aiResponse.predicted_price) || avgPrice);
      const confidence = Math.min(1, Math.max(0, parseFloat(aiResponse.confidence) || 0.5));
      const recommendation = ['JUAL_SEKARANG', 'TUNDA_JUAL'].includes(aiResponse.recommendation) 
        ? aiResponse.recommendation 
        : (predictedPrice < avgPrice ? 'JUAL_SEKARANG' : 'TUNDA_JUAL');

      // Save prediction to database
      await prisma.aIPricePrediction.create({
        data: {
          spiceType,
          quality: qualityGrade,
          currentPrice: avgPrice,
          predictedPrice,
          confidence,
          recommendation,
          reasoning: aiResponse.reasoning || 'Prediksi berdasarkan analisis tren historis',
          validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000) // Valid for 24 hours
        }
      });

      return {
        currentStats: {
          avgPrice,
          minPrice,
          maxPrice,
          recentAvg
        },
        prediction: {
          predictedPrice,
          confidence,
          recommendation,
          reasoning: aiResponse.reasoning || 'Prediksi berdasarkan analisis tren historis'
        },
        success: true
      };

    } catch (error) {
      console.error('AI Price prediction error:', error);
      
      // Fallback to simple statistical prediction
      if (historicalData && historicalData.length > 0) {
        return this.fallbackPrediction(historicalData);
      }
      
      throw new Error('Failed to generate price prediction');
    }
  }

  /**
   * Fallback prediction using simple statistical analysis
   */
  fallbackPrediction(historicalDataOrAvg, recentAvg = null, allPrices = null) {
    try {
      let avgPrice, minPrice, maxPrice, trend;
      
      if (Array.isArray(historicalDataOrAvg)) {
        const prices = historicalDataOrAvg.map(item => parseFloat(item.price));
        avgPrice = prices.reduce((sum, price) => sum + price, 0) / prices.length;
        minPrice = Math.min(...prices);
        maxPrice = Math.max(...prices);
        
        // Simple trend analysis
        const recent = prices.slice(-3);
        const older = prices.slice(-6, -3);
        const recentAvgCalc = recent.reduce((sum, price) => sum + price, 0) / recent.length;
        const olderAvg = older.length > 0 ? older.reduce((sum, price) => sum + price, 0) / older.length : recentAvgCalc;
        trend = recentAvgCalc > olderAvg ? 'up' : 'down';
      } else {
        avgPrice = historicalDataOrAvg;
        minPrice = avgPrice * 0.8;
        maxPrice = avgPrice * 1.2;
        trend = recentAvg && allPrices ? (recentAvg > avgPrice ? 'up' : 'down') : 'stable';
      }

      // Simple prediction logic
      const trendFactor = trend === 'up' ? 1.02 : (trend === 'down' ? 0.98 : 1.0);
      const predictedPrice = avgPrice * trendFactor;
      
      const recommendation = predictedPrice < avgPrice ? 'JUAL_SEKARANG' : 'TUNDA_JUAL';
      
      return {
        currentStats: {
          avgPrice,
          minPrice,
          maxPrice,
          recentAvg: recentAvg || avgPrice
        },
        prediction: {
          predictedPrice,
          confidence: 0.6,
          recommendation,
          reasoning: `Prediksi berdasarkan analisis statistik sederhana. Tren harga ${trend === 'up' ? 'naik' : trend === 'down' ? 'turun' : 'stabil'}.`
        },
        success: true
      };
    } catch (error) {
      console.error('Fallback prediction error:', error);
      throw new Error('Failed to generate fallback prediction');
    }
  }

  /**
   * Translate spice type to Indonesian
   */
  translateSpiceType(spiceType) {
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

  /**
   * Translate quality grade to Indonesian
   */
  translateQualityGrade(grade) {
    const translations = {
      'A_PREMIUM': 'Grade A (Premium)',
      'B_STANDARD': 'Grade B (Standard)',
      'C_ECONOMY': 'Grade C (Ekonomi)'
    };
    return translations[grade] || grade;
  }

  /**
   * Get latest price prediction from database
   */
  async getLatestPrediction(spiceType, qualityGrade) {
    try {
      const prediction = await prisma.aIPricePrediction.findFirst({
        where: {
          spiceType,
          quality: qualityGrade,
          validUntil: {
            gt: new Date()
          }
        },
        orderBy: {
          createdAt: 'desc'
        }
      });

      return prediction;
    } catch (error) {
      console.error('Get latest prediction error:', error);
      return null;
    }
  }
}

module.exports = new AIService();