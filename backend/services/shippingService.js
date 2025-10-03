const axios = require('axios');

class ShippingService {
  constructor() {
    this.rajaOngkirApiKey = process.env.RAJAONGKIR_API_KEY;
    this.rajaOngkirBaseUrl = 'https://api.rajaongkir.com/starter';
    
    this.courierServices = {
      jne: {
        name: 'JNE',
        services: {
          'REG': 'Reguler',
          'OKE': 'OKE',
          'YES': 'YES'
        }
      },
      tiki: {
        name: 'TIKI',
        services: {
          'REG': 'Reguler',
          'ECO': 'Ekonomi',
          'ONS': 'Over Night Service'
        }
      },
      pos: {
        name: 'POS Indonesia',
        services: {
          'Paket Kilat Khusus': 'Paket Kilat Khusus',
          'Express Next Day': 'Express Next Day'
        }
      }
    };
  }

  /**
   * Get all provinces
   */
  async getProvinces() {
    try {
      const response = await axios.get(`${this.rajaOngkirBaseUrl}/province`, {
        headers: {
          'key': this.rajaOngkirApiKey
        }
      });

      if (response.data.rajaongkir.status.code === 200) {
        return response.data.rajaongkir.results.map(province => ({
          id: province.province_id,
          name: province.province
        }));
      } else {
        throw new Error('Failed to fetch provinces');
      }
    } catch (error) {
      console.error('Get provinces error:', error);
      // Return mock data if API fails
      return this.getMockProvinces();
    }
  }

  /**
   * Get cities by province
   * @param {string} provinceId - Province ID
   */
  async getCities(provinceId) {
    try {
      const response = await axios.get(`${this.rajaOngkirBaseUrl}/city`, {
        headers: {
          'key': this.rajaOngkirApiKey
        },
        params: {
          province: provinceId
        }
      });

      if (response.data.rajaongkir.status.code === 200) {
        return response.data.rajaongkir.results.map(city => ({
          id: city.city_id,
          name: city.city_name,
          type: city.type,
          postalCode: city.postal_code
        }));
      } else {
        throw new Error('Failed to fetch cities');
      }
    } catch (error) {
      console.error('Get cities error:', error);
      // Return mock data if API fails
      return this.getMockCities(provinceId);
    }
  }

  /**
   * Calculate shipping cost
   * @param {Object} shippingData - Shipping calculation data
   */
  async calculateShipping(shippingData) {
    try {
      const {
        origin,
        destination,
        weight,
        courier = ['jne', 'tiki', 'pos']
      } = shippingData;

      // Get origin and destination city IDs
      const originCityId = await this.getCityIdByName(origin);
      const destinationCityId = await this.getCityIdByName(destination);

      if (!originCityId || !destinationCityId) {
        return this.getMockShippingRates(origin, destination, weight, courier);
      }

      const shippingOptions = [];

      // Calculate for each courier
      for (const courierCode of courier) {
        try {
          const response = await axios.post(`${this.rajaOngkirBaseUrl}/cost`, {
            origin: originCityId,
            destination: destinationCityId,
            weight: weight,
            courier: courierCode
          }, {
            headers: {
              'key': this.rajaOngkirApiKey,
              'content-type': 'application/x-www-form-urlencoded'
            }
          });

          if (response.data.rajaongkir.status.code === 200) {
            const results = response.data.rajaongkir.results[0];
            if (results && results.costs) {
              results.costs.forEach(cost => {
                shippingOptions.push({
                  courier: courierCode.toUpperCase(),
                  courierName: this.courierServices[courierCode]?.name || courierCode.toUpperCase(),
                  service: cost.service,
                  serviceName: cost.description,
                  cost: cost.cost[0].value,
                  estimatedDays: cost.cost[0].etd,
                  note: cost.cost[0].note || ''
                });
              });
            }
          }
        } catch (courierError) {
          console.error(`Error calculating shipping for ${courierCode}:`, courierError);
          // Add mock data for this courier
          const mockRates = this.getMockCourierRates(courierCode, weight);
          shippingOptions.push(...mockRates);
        }
      }

      // If no real data, return mock data
      if (shippingOptions.length === 0) {
        return this.getMockShippingRates(origin, destination, weight, courier);
      }

      // Sort by cost
      return shippingOptions.sort((a, b) => a.cost - b.cost);
    } catch (error) {
      console.error('Calculate shipping error:', error);
      // Return mock data as fallback
      return this.getMockShippingRates(
        shippingData.origin, 
        shippingData.destination, 
        shippingData.weight, 
        shippingData.courier
      );
    }
  }

  /**
   * Get city ID by name (helper function)
   */
  async getCityIdByName(cityName) {
    try {
      // This would normally require getting all cities and searching
      // For demo purposes, return mock city IDs
      const cityMapping = {
        'Jakarta': '151',
        'Bandung': '23',
        'Surabaya': '444',
        'Medan': '151',
        'Makassar': '151',
        'Palembang': '151',
        'Semarang': '151',
        'Yogyakarta': '501'
      };

      return cityMapping[cityName] || '151'; // Default to Jakarta
    } catch (error) {
      console.error('Get city ID error:', error);
      return '151'; // Default to Jakarta
    }
  }

  /**
   * Track shipment
   * @param {string} courier - Courier code
   * @param {string} trackingNumber - Tracking number
   */
  async trackShipment(courier, trackingNumber) {
    try {
      // This would typically use specific courier APIs or a tracking service
      // For demo purposes, return mock tracking data
      return this.getMockTrackingData(courier, trackingNumber);
    } catch (error) {
      console.error('Track shipment error:', error);
      throw new Error('Failed to track shipment');
    }
  }

  /**
   * Mock provinces data
   */
  getMockProvinces() {
    return [
      { id: '1', name: 'Bali' },
      { id: '2', name: 'Bangka Belitung' },
      { id: '3', name: 'Banten' },
      { id: '4', name: 'Bengkulu' },
      { id: '5', name: 'DI Yogyakarta' },
      { id: '6', name: 'DKI Jakarta' },
      { id: '7', name: 'Gorontalo' },
      { id: '8', name: 'Jambi' },
      { id: '9', name: 'Jawa Barat' },
      { id: '10', name: 'Jawa Tengah' },
      { id: '11', name: 'Jawa Timur' },
      { id: '12', name: 'Kalimantan Barat' },
      { id: '13', name: 'Kalimantan Selatan' },
      { id: '14', name: 'Kalimantan Tengah' },
      { id: '15', name: 'Kalimantan Timur' },
      { id: '16', name: 'Kepulauan Riau' },
      { id: '17', name: 'Lampung' },
      { id: '18', name: 'Maluku' },
      { id: '19', name: 'Maluku Utara' },
      { id: '20', name: 'Nanggroe Aceh Darussalam (NAD)' },
      { id: '21', name: 'Nusa Tenggara Barat' },
      { id: '22', name: 'Nusa Tenggara Timur' },
      { id: '23', name: 'Papua' },
      { id: '24', name: 'Papua Barat' },
      { id: '25', name: 'Riau' },
      { id: '26', name: 'Sulawesi Barat' },
      { id: '27', name: 'Sulawesi Selatan' },
      { id: '28', name: 'Sulawesi Tengah' },
      { id: '29', name: 'Sulawesi Tenggara' },
      { id: '30', name: 'Sulawesi Utara' },
      { id: '31', name: 'Sumatera Barat' },
      { id: '32', name: 'Sumatera Selatan' },
      { id: '33', name: 'Sumatera Utara' }
    ];
  }

  /**
   * Mock cities data
   */
  getMockCities(provinceId) {
    const citiesByProvince = {
      '6': [ // DKI Jakarta
        { id: '151', name: 'Jakarta Barat', type: 'Kota', postalCode: '11220' },
        { id: '152', name: 'Jakarta Pusat', type: 'Kota', postalCode: '10540' },
        { id: '153', name: 'Jakarta Selatan', type: 'Kota', postalCode: '12560' },
        { id: '154', name: 'Jakarta Timur', type: 'Kota', postalCode: '13330' },
        { id: '155', name: 'Jakarta Utara', type: 'Kota', postalCode: '14240' }
      ],
      '9': [ // Jawa Barat
        { id: '23', name: 'Bandung', type: 'Kota', postalCode: '40115' },
        { id: '24', name: 'Bekasi', type: 'Kota', postalCode: '17121' },
        { id: '25', name: 'Bogor', type: 'Kota', postalCode: '16119' },
        { id: '26', name: 'Cirebon', type: 'Kota', postalCode: '45116' },
        { id: '27', name: 'Depok', type: 'Kota', postalCode: '16416' }
      ]
    };

    return citiesByProvince[provinceId] || [
      { id: '1', name: 'Default City', type: 'Kota', postalCode: '12345' }
    ];
  }

  /**
   * Mock shipping rates
   */
  getMockShippingRates(origin, destination, weight, couriers) {
    const baseRates = {
      jne: {
        'REG': { cost: 9000, etd: '2-3' },
        'OKE': { cost: 8000, etd: '3-4' },
        'YES': { cost: 15000, etd: '1-2' }
      },
      tiki: {
        'REG': { cost: 8500, etd: '2-3' },
        'ECO': { cost: 7500, etd: '4-5' },
        'ONS': { cost: 18000, etd: '1' }
      },
      pos: {
        'Paket Kilat Khusus': { cost: 8000, etd: '2-4' },
        'Express Next Day': { cost: 20000, etd: '1' }
      }
    };

    const shippingOptions = [];
    const weightInKg = Math.ceil(weight / 1000);

    couriers.forEach(courier => {
      const services = baseRates[courier];
      if (services) {
        Object.entries(services).forEach(([service, data]) => {
          shippingOptions.push({
            courier: courier.toUpperCase(),
            courierName: this.courierServices[courier]?.name || courier.toUpperCase(),
            service: service,
            serviceName: this.courierServices[courier]?.services[service] || service,
            cost: data.cost * weightInKg,
            estimatedDays: data.etd,
            note: `Estimasi ${data.etd} hari kerja`
          });
        });
      }
    });

    return shippingOptions.sort((a, b) => a.cost - b.cost);
  }

  /**
   * Mock courier rates for single courier
   */
  getMockCourierRates(courier, weight) {
    const rates = this.getMockShippingRates('Jakarta', 'Bandung', weight, [courier]);
    return rates;
  }

  /**
   * Mock tracking data
   */
  getMockTrackingData(courier, trackingNumber) {
    const statuses = [
      {
        date: '2024-01-15 09:00:00',
        status: 'Paket diterima di origin',
        location: 'Jakarta'
      },
      {
        date: '2024-01-15 14:30:00',
        status: 'Paket dalam perjalanan',
        location: 'Sorting Center Jakarta'
      },
      {
        date: '2024-01-16 08:15:00',
        status: 'Paket tiba di kota tujuan',
        location: 'Bandung'
      },
      {
        date: '2024-01-16 10:45:00',
        status: 'Paket sedang diantar',
        location: 'Courier Bandung'
      }
    ];

    return {
      trackingNumber,
      courier: courier.toUpperCase(),
      status: 'Sedang diantar',
      estimatedDelivery: '2024-01-16 17:00:00',
      history: statuses
    };
  }

  /**
   * Get supported courier services
   */
  getSupportedCouriers() {
    return Object.entries(this.courierServices).map(([code, data]) => ({
      code,
      name: data.name,
      services: Object.entries(data.services).map(([serviceCode, serviceName]) => ({
        code: serviceCode,
        name: serviceName
      }))
    }));
  }

  /**
   * Validate shipping address
   */
  validateShippingAddress(address) {
    const errors = [];

    if (!address.recipient) {
      errors.push('Nama penerima wajib diisi');
    }

    if (!address.phone || !/^(\+62|62|0)[0-9]{9,13}$/.test(address.phone)) {
      errors.push('Nomor telepon tidak valid');
    }

    if (!address.address || address.address.length < 10) {
      errors.push('Alamat lengkap minimal 10 karakter');
    }

    if (!address.city) {
      errors.push('Kota wajib dipilih');
    }

    if (!address.province) {
      errors.push('Provinsi wajib dipilih');
    }

    if (!address.postalCode || !/^[0-9]{5}$/.test(address.postalCode)) {
      errors.push('Kode pos harus 5 digit angka');
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }
}

module.exports = new ShippingService();