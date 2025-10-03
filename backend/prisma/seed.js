const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding...');

  try {
    // 1. Create Categories
    console.log('📂 Creating categories...');
    const spicesCategory = await prisma.category.upsert({
      where: { slug: 'rempah-rempah' },
      update: {},
      create: {
        name: 'Rempah-rempah',
        slug: 'rempah-rempah',
        description: 'Berbagai jenis rempah tradisional Indonesia',
        isActive: true,
        sortOrder: 1,
      },
    });

    const herbsCategory = await prisma.category.upsert({
      where: { slug: 'herbal' },
      update: {},
      create: {
        name: 'Tanaman Herbal',
        slug: 'herbal',
        description: 'Tanaman herbal dan obat tradisional',
        isActive: true,
        sortOrder: 2,
      },
    });

    // 2. Create Spice Types
    console.log('🌶️ Creating spice types...');
    const spiceTypes = [
      {
        name: 'Lada Hitam',
        slug: 'lada-hitam',
        categoryId: spicesCategory.id,
        description: 'Lada hitam berkualitas tinggi dari Indonesia',
        properties: {
          harvestSeason: ['Juni', 'Juli', 'Agustus'],
          shelfLife: '24 bulan',
          storage: 'Tempat kering dan sejuk'
        }
      },
      {
        name: 'Lada Putih',
        slug: 'lada-putih',
        categoryId: spicesCategory.id,
        description: 'Lada putih premium dengan rasa yang khas',
        properties: {
          harvestSeason: ['Juni', 'Juli', 'Agustus'],
          shelfLife: '24 bulan',
          storage: 'Tempat kering dan sejuk'
        }
      },
      {
        name: 'Kayu Manis',
        slug: 'kayu-manis',
        categoryId: spicesCategory.id,
        description: 'Kayu manis asli dengan aroma yang harum',
        properties: {
          harvestSeason: ['September', 'Oktober', 'November'],
          shelfLife: '36 bulan',
          storage: 'Tempat kering dan tertutup rapat'
        }
      },
      {
        name: 'Cengkeh',
        slug: 'cengkeh',
        categoryId: spicesCategory.id,
        description: 'Cengkeh berkualitas ekspor',
        properties: {
          harvestSeason: ['Oktober', 'November', 'Desember'],
          shelfLife: '24 bulan',
          storage: 'Tempat kering dan sejuk'
        }
      },
      {
        name: 'Pala',
        slug: 'pala',
        categoryId: spicesCategory.id,
        description: 'Pala asli Maluku dengan kualitas terbaik',
        properties: {
          harvestSeason: ['Juli', 'Agustus', 'September'],
          shelfLife: '36 bulan',
          storage: 'Tempat kering dan tertutup rapat'
        }
      },
      {
        name: 'Jahe',
        slug: 'jahe',
        categoryId: herbsCategory.id,
        description: 'Jahe segar dan jahe kering berkualitas',
        properties: {
          harvestSeason: ['April', 'Mei', 'Juni'],
          shelfLife: '12 bulan',
          storage: 'Tempat sejuk dan kering'
        }
      }
    ];

    const createdSpiceTypes = [];
    for (const spiceType of spiceTypes) {
      const created = await prisma.spiceType.upsert({
        where: { slug: spiceType.slug },
        update: {},
        create: spiceType,
      });
      createdSpiceTypes.push(created);
    }

    // 3. Create Users
    console.log('👥 Creating users...');
    const hashedPassword = await bcrypt.hash('password123', 12);

    // Admin User
    const admin = await prisma.user.upsert({
      where: { email: 'admin@spice.com' },
      update: {},
      create: {
        name: 'Admin Spice',
        email: 'admin@spice.com',
        password: hashedPassword,
        phone: '08123456789',
        role: 'ADMIN',
        isActive: true,
        isVerified: true,
        profile: {
          create: {
            bio: 'System Administrator untuk platform Spice Ecommerce',
            city: 'Jakarta',
            province: 'DKI Jakarta',
          },
        },
        adminProfile: {
          create: {
            permissions: {
              users: ['read', 'write', 'delete'],
              products: ['read', 'write', 'delete'],
              orders: ['read', 'write', 'delete'],
              categories: ['read', 'write', 'delete']
            },
            department: 'IT & Operations',
          },
        },
      },
    });

    // Seller Users
    const sellers = [
      {
        name: 'Budi Santoso',
        email: 'budi@petanirempah.com',
        phone: '08234567890',
        city: 'Lampung',
        province: 'Lampung',
        shopName: 'Rempah Lampung Asli',
        shopDescription: 'Petani rempah generasi ketiga yang menyediakan lada berkualitas ekspor langsung dari kebun.',
      },
      {
        name: 'Sari Wijaya',
        email: 'sari@rempahmaluku.com',
        phone: '08345678901',
        city: 'Ambon',
        province: 'Maluku',
        shopName: 'Pala Maluku Premium',
        shopDescription: 'Spesialis pala asli Maluku dengan kualitas terbaik dan bersertifikat organik.',
      },
      {
        name: 'Ahmad Subagyo',
        email: 'ahmad@cayennecianjur.com',
        phone: '08456789012',
        city: 'Cianjur',
        province: 'Jawa Barat',
        shopName: 'Kayu Manis Cianjur',
        shopDescription: 'Produsen kayu manis dan jahe berkualitas dari pegunungan Cianjur.',
      }
    ];

    const createdSellers = [];
    for (const sellerData of sellers) {
      const seller = await prisma.user.upsert({
        where: { email: sellerData.email },
        update: {},
        create: {
          name: sellerData.name,
          email: sellerData.email,
          password: hashedPassword,
          phone: sellerData.phone,
          role: 'SELLER',
          isActive: true,
          isVerified: true,
          profile: {
            create: {
              bio: `Petani rempah berpengalaman dari ${sellerData.city}`,
              city: sellerData.city,
              province: sellerData.province,
            },
          },
          sellerProfile: {
            create: {
              shopName: sellerData.shopName,
              shopDescription: sellerData.shopDescription,
              isVerified: true,
              rating: 4.8,
              totalSales: Math.floor(Math.random() * 500) + 100,
            },
          },
        },
      });
      createdSellers.push(seller);
    }

    // Buyer Users
    const buyers = [
      {
        name: 'Dewi Kusuma',
        email: 'dewi@buyer.com',
        phone: '08567890123',
        city: 'Jakarta',
        province: 'DKI Jakarta',
      },
      {
        name: 'Rian Pratama',
        email: 'rian@buyer.com',
        phone: '08678901234',
        city: 'Surabaya',
        province: 'Jawa Timur',
      }
    ];

    for (const buyerData of buyers) {
      await prisma.user.upsert({
        where: { email: buyerData.email },
        update: {},
        create: {
          name: buyerData.name,
          email: buyerData.email,
          password: hashedPassword,
          phone: buyerData.phone,
          role: 'BUYER',
          isActive: true,
          isVerified: true,
          profile: {
            create: {
              bio: `Pencinta masakan tradisional dari ${buyerData.city}`,
              city: buyerData.city,
              province: buyerData.province,
            },
          },
        },
      });
    }

    // 4. Create Products
    console.log('🛒 Creating products...');
    const products = [
      {
        sellerId: createdSellers[0].id, // Budi - Lada Lampung
        categoryId: spicesCategory.id,
        spiceTypeId: createdSpiceTypes[0].id, // Lada Hitam
        name: 'Lada Hitam Premium Lampung',
        slug: 'lada-hitam-premium-lampung',
        description: 'Lada hitam premium langsung dari kebun di Lampung. Dipetik pada waktu yang tepat dan dikeringkan dengan metode tradisional untuk mempertahankan aroma dan rasa yang khas. Cocok untuk berbagai masakan Indonesia dan internasional.',
        shortDescription: 'Lada hitam premium berkualitas ekspor dari Lampung',
        price: 85000,
        originalPrice: 95000,
        discount: 10.53,
        stock: 250,
        weight: 1.0,
        origin: 'Lampung Timur, Lampung',
        isOrganic: true,
        quality: 'PREMIUM',
        moisture: 12.5,
        purity: 98.0,
        specifications: {
          size: '4-5mm',
          color: 'Hitam kecoklatan',
          aroma: 'Kuat dan harum',
          texture: 'Kering dan berkerut'
        },
        tags: ['lada', 'hitam', 'premium', 'lampung', 'organik', 'ekspor'],
        status: 'PUBLISHED',
        isActive: true,
        isFeatured: true,
      },
      {
        sellerId: createdSellers[0].id, // Budi - Lada Lampung
        categoryId: spicesCategory.id,
        spiceTypeId: createdSpiceTypes[1].id, // Lada Putih
        name: 'Lada Putih Grade A Lampung',
        slug: 'lada-putih-grade-a-lampung',
        description: 'Lada putih grade A dengan proses pengupasan yang sempurna. Memiliki rasa yang lebih halus dibanding lada hitam dengan aroma yang khas. Sangat cocok untuk masakan berkuah dan hidangan yang membutuhkan rasa pedas tanpa mengubah warna masakan.',
        shortDescription: 'Lada putih grade A dengan rasa halus dan aroma khas',
        price: 120000,
        stock: 180,
        weight: 1.0,
        origin: 'Lampung Selatan, Lampung',
        isOrganic: true,
        quality: 'PREMIUM',
        moisture: 11.0,
        purity: 99.0,
        specifications: {
          size: '3-4mm',
          color: 'Putih kekuningan',
          aroma: 'Halus dan tajam',
          texture: 'Halus dan bulat'
        },
        tags: ['lada', 'putih', 'grade-a', 'lampung', 'organik'],
        status: 'PUBLISHED',
        isActive: true,
      },
      {
        sellerId: createdSellers[1].id, // Sari - Pala Maluku
        categoryId: spicesCategory.id,
        spiceTypeId: createdSpiceTypes[4].id, // Pala
        name: 'Pala Asli Maluku Utuh',
        slug: 'pala-asli-maluku-utuh',
        description: 'Pala asli Maluku dalam bentuk utuh dengan kualitas terbaik. Dipetik dari pohon pala tua yang berusia puluhan tahun. Memiliki aroma yang sangat harum dan rasa yang kuat. Cocok untuk berbagai masakan tradisional dan modern.',
        shortDescription: 'Pala asli Maluku utuh dengan aroma harum khas',
        price: 180000,
        originalPrice: 200000,
        discount: 10.0,
        stock: 120,
        weight: 0.5,
        origin: 'Banda, Maluku',
        isOrganic: true,
        quality: 'PREMIUM',
        moisture: 8.0,
        purity: 99.5,
        specifications: {
          size: '2-3cm',
          color: 'Coklat kehitaman',
          aroma: 'Sangat harum',
          texture: 'Keras dan berminyak'
        },
        tags: ['pala', 'maluku', 'utuh', 'premium', 'organik', 'banda'],
        status: 'PUBLISHED',
        isActive: true,
        isFeatured: true,
      },
      {
        sellerId: createdSellers[2].id, // Ahmad - Kayu Manis
        categoryId: spicesCategory.id,
        spiceTypeId: createdSpiceTypes[2].id, // Kayu Manis
        name: 'Kayu Manis Cianjur Batang',
        slug: 'kayu-manis-cianjur-batang',
        description: 'Kayu manis berkualitas tinggi dari daerah pegunungan Cianjur. Dipanen dari pohon cassia yang tumbuh di ketinggian optimal. Memiliki rasa manis alami dan aroma yang khas. Sangat cocok untuk minuman hangat, kue, dan masakan tradisional.',
        shortDescription: 'Kayu manis batang dari Cianjur dengan aroma harum',
        price: 65000,
        stock: 300,
        weight: 0.5,
        origin: 'Cianjur, Jawa Barat',
        isOrganic: false,
        quality: 'STANDARD',
        moisture: 10.0,
        purity: 95.0,
        specifications: {
          length: '8-12cm',
          thickness: '2-4mm',
          color: 'Coklat muda',
          aroma: 'Manis dan harum'
        },
        tags: ['kayu-manis', 'cianjur', 'batang', 'cassia', 'tradisional'],
        status: 'PUBLISHED',
        isActive: true,
      },
      {
        sellerId: createdSellers[2].id, // Ahmad - Jahe
        categoryId: herbsCategory.id,
        spiceTypeId: createdSpiceTypes[5].id, // Jahe
        name: 'Jahe Merah Kering Premium',
        slug: 'jahe-merah-kering-premium',
        description: 'Jahe merah kering premium yang telah melalui proses pengeringan dengan teknologi modern. Mempertahankan kandungan gingerol dan zat aktif lainnya. Cocok untuk membuat minuman herbal, jamu tradisional, dan sebagai bumbu masakan.',
        shortDescription: 'Jahe merah kering dengan khasiat tinggi',
        price: 45000,
        stock: 200,
        weight: 0.5,
        origin: 'Cianjur, Jawa Barat',
        isOrganic: true,
        quality: 'PREMIUM',
        moisture: 8.5,
        purity: 96.0,
        specifications: {
          type: 'Jahe merah',
          form: 'Irisan kering',
          color: 'Merah kecoklatan',
          aroma: 'Pedas dan hangat'
        },
        tags: ['jahe', 'merah', 'kering', 'herbal', 'premium', 'organik'],
        status: 'PUBLISHED',
        isActive: true,
      }
    ];

    const createdProducts = [];
    for (const productData of products) {
      // Calculate harvest and expiry dates
      const harvestDate = new Date();
      harvestDate.setMonth(harvestDate.getMonth() - Math.floor(Math.random() * 6)); // 0-6 months ago

      const expiryDate = new Date(harvestDate);
      expiryDate.setMonth(expiryDate.getMonth() + 24); // 2 years shelf life

      const product = await prisma.product.create({
        data: {
          ...productData,
          harvestDate,
          expiryDate,
          views: Math.floor(Math.random() * 1000) + 50,
          salesCount: Math.floor(Math.random() * 100) + 10,
          rating: 4.0 + Math.random() * 1.0, // 4.0 - 5.0
          reviewCount: Math.floor(Math.random() * 20) + 5,
          publishedAt: new Date(),
        },
      });
      createdProducts.push(product);
    }

    // 5. Create Product Images
    console.log('🖼️ Creating product images...');
    const imageUrls = [
      'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=500', // Peppercorns
      'https://images.unsplash.com/photo-1609501676725-7186f34dd905?w=500', // White pepper
      'https://images.unsplash.com/photo-1638228942888-ec2250ad9154?w=500', // Nutmeg
      'https://images.unsplash.com/photo-1599909533260-0a0e1c03b8bb?w=500', // Cinnamon
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500', // Ginger
    ];

    for (let i = 0; i < createdProducts.length; i++) {
      await prisma.productImage.create({
        data: {
          productId: createdProducts[i].id,
          url: imageUrls[i] || imageUrls[0],
          alt: `${createdProducts[i].name} - Gambar Utama`,
          sortOrder: 0,
          isPrimary: true,
        },
      });
    }

    // 6. Create Sample Reviews
    console.log('⭐ Creating sample reviews...');
    const reviewTexts = [
      {
        title: 'Kualitas Sangat Baik',
        comment: 'Produk sangat berkualitas, aroma khas dan segar. Packing rapi dan pengiriman cepat. Akan order lagi.',
        rating: 5
      },
      {
        title: 'Recommended!',
        comment: 'Kualitas sesuai ekspektasi, harga reasonable. Cocok untuk masakan sehari-hari.',
        rating: 4
      },
      {
        title: 'Puas dengan kualitasnya',
        comment: 'Produk asli dan berkualitas tinggi. Seller responsif dan pengiriman cepat.',
        rating: 5
      },
      {
        title: 'Good Quality',
        comment: 'Sesuai deskripsi, kualitas bagus untuk harga segini. Recommended seller.',
        rating: 4
      }
    ];

    // Get buyer users for reviews
    const existingBuyers = await prisma.user.findMany({
      where: { role: 'BUYER' }
    });

    for (const product of createdProducts) {
      const numReviews = Math.floor(Math.random() * 3) + 2; // 2-4 reviews per product

      for (let i = 0; i < numReviews; i++) {
        const reviewer = existingBuyers[Math.floor(Math.random() * existingBuyers.length)];
        const review = reviewTexts[Math.floor(Math.random() * reviewTexts.length)];

        try {
          await prisma.review.create({
            data: {
              userId: reviewer.id,
              productId: product.id,
              rating: review.rating,
              title: review.title,
              comment: review.comment,
              isVerified: Math.random() > 0.3, // 70% verified purchases
              isActive: true,
            },
          });
        } catch (error) {
          // Skip if review already exists (unique constraint)
          if (!error.message.includes('Unique constraint')) {
            console.log('Review creation error:', error.message);
          }
        }
      }
    }

    // 7. Create Price Insights
    console.log('💰 Creating price insights...');
    const priceInsights = [
      {
        spiceType: 'Lada Hitam',
        quality: 'Premium',
        origin: 'Lampung',
        isOrganic: true,
        minPrice: 75000,
        maxPrice: 95000,
        avgPrice: 85000,
        confidence: 0.92,
        factors: {
          seasonality: 'high',
          demand: 'stable',
          supply: 'normal',
          quality: 'premium'
        },
        marketTrend: 'STABLE'
      },
      {
        spiceType: 'Pala',
        quality: 'Premium',
        origin: 'Maluku',
        isOrganic: true,
        minPrice: 160000,
        maxPrice: 200000,
        avgPrice: 180000,
        confidence: 0.88,
        factors: {
          seasonality: 'medium',
          demand: 'high',
          supply: 'limited',
          quality: 'premium'
        },
        marketTrend: 'UP'
      }
    ];

    for (const insight of priceInsights) {
      await prisma.priceInsight.create({
        data: insight,
      });
    }

    console.log('✅ Database seeding completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`- Categories: ${await prisma.category.count()}`);
    console.log(`- Spice Types: ${await prisma.spiceType.count()}`);
    console.log(`- Users: ${await prisma.user.count()}`);
    console.log(`- Products: ${await prisma.product.count()}`);
    console.log(`- Reviews: ${await prisma.review.count()}`);
    console.log(`- Price Insights: ${await prisma.priceInsight.count()}`);

    console.log('\n🔐 Login Credentials:');
    console.log('Admin: admin@spice.com / password123');
    console.log('Seller 1: budi@petanirempah.com / password123');
    console.log('Seller 2: sari@rempahmaluku.com / password123');
    console.log('Seller 3: ahmad@cayennecianjur.com / password123');
    console.log('Buyer 1: dewi@buyer.com / password123');
    console.log('Buyer 2: rian@buyer.com / password123');

  } catch (error) {
    console.error('❌ Error during seeding:', error);
    throw error;
  }
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
