const midtransClient = require('midtrans-client');

class MidtransService {
  constructor() {
    // Initialize Midtrans Snap
    this.snap = new midtransClient.Snap({
      isProduction: process.env.NODE_ENV === 'production',
      serverKey: process.env.MIDTRANS_SERVER_KEY,
      clientKey: process.env.MIDTRANS_CLIENT_KEY
    });

    // Initialize Midtrans Core API
    this.coreApi = new midtransClient.CoreApi({
      isProduction: process.env.NODE_ENV === 'production',
      serverKey: process.env.MIDTRANS_SERVER_KEY,
      clientKey: process.env.MIDTRANS_CLIENT_KEY
    });
  }

  /**
   * Create payment token for Snap
   * @param {Object} paymentData - Payment data
   */
  async createPaymentToken(paymentData) {
    try {
      const {
        orderId,
        amount,
        customerDetails,
        itemDetails,
        shippingAddress
      } = paymentData;

      const parameter = {
        transaction_details: {
          order_id: orderId,
          gross_amount: Math.round(amount)
        },
        customer_details: {
          first_name: customerDetails.firstName,
          last_name: customerDetails.lastName || '',
          email: customerDetails.email,
          phone: customerDetails.phone,
          billing_address: {
            first_name: customerDetails.firstName,
            last_name: customerDetails.lastName || '',
            email: customerDetails.email,
            phone: customerDetails.phone,
            address: shippingAddress?.address || '',
            city: shippingAddress?.city || '',
            postal_code: shippingAddress?.postalCode || '',
            country_code: 'IDN'
          },
          shipping_address: shippingAddress ? {
            first_name: customerDetails.firstName,
            last_name: customerDetails.lastName || '',
            email: customerDetails.email,
            phone: customerDetails.phone,
            address: shippingAddress.address,
            city: shippingAddress.city,
            postal_code: shippingAddress.postalCode,
            country_code: 'IDN'
          } : undefined
        },
        item_details: itemDetails.map(item => ({
          id: item.id.toString(),
          price: Math.round(item.price),
          quantity: item.quantity,
          name: item.name.substring(0, 50), // Midtrans has character limit
          category: 'Spices',
          merchant_name: 'Spice Farmers Connect'
        })),
        enabled_payments: [
          'gopay', 'shopeepay', 'dana', 'linkaja', 'ovo',
          'bca_va', 'bni_va', 'bri_va', 'mandiri_va', 'permata_va',
          'credit_card', 'bca_klikbca', 'bca_klikpay', 'bri_epay',
          'echannel', 'mandiri_clickpay', 'mandiri_ecash',
          'cimb_clicks', 'danamon_online', 'qris'
        ],
        callbacks: {
          finish: `${process.env.FRONTEND_URL}/payment/success`,
          error: `${process.env.FRONTEND_URL}/payment/error`,
          pending: `${process.env.FRONTEND_URL}/payment/pending`
        },
        expiry: {
          start_time: new Date().toISOString().replace(/\.\d{3}Z$/, ' +0700'),
          unit: 'hours',
          duration: 24
        },
        custom_field1: 'spice_ecommerce',
        custom_field2: process.env.NODE_ENV || 'development',
        custom_field3: new Date().toISOString()
      };

      const transaction = await this.snap.createTransaction(parameter);
      
      return {
        token: transaction.token,
        redirectUrl: transaction.redirect_url,
        orderId: orderId
      };
    } catch (error) {
      console.error('Midtrans create payment token error:', error);
      throw new Error(`Payment token creation failed: ${error.message}`);
    }
  }

  /**
   * Check payment status
   * @param {string} orderId - Order ID
   */
  async checkPaymentStatus(orderId) {
    try {
      const statusResponse = await this.coreApi.transaction.status(orderId);
      
      return {
        orderId: statusResponse.order_id,
        transactionStatus: statusResponse.transaction_status,
        fraudStatus: statusResponse.fraud_status,
        paymentType: statusResponse.payment_type,
        grossAmount: parseFloat(statusResponse.gross_amount),
        transactionTime: statusResponse.transaction_time,
        statusCode: statusResponse.status_code,
        statusMessage: statusResponse.status_message,
        signatureKey: statusResponse.signature_key,
        merchantId: statusResponse.merchant_id
      };
    } catch (error) {
      console.error('Midtrans check payment status error:', error);
      throw new Error(`Payment status check failed: ${error.message}`);
    }
  }

  /**
   * Handle Midtrans notification webhook
   * @param {Object} notification - Midtrans notification data
   */
  async handleNotification(notification) {
    try {
      const statusResponse = await this.coreApi.transaction.notification(notification);
      
      const {
        order_id,
        transaction_status,
        fraud_status,
        payment_type,
        gross_amount
      } = statusResponse;

      let paymentStatus = 'PENDING';
      let transactionStatus = 'PENDING';

      // Determine payment status based on Midtrans response
      if (transaction_status === 'capture') {
        if (fraud_status === 'challenge') {
          paymentStatus = 'PENDING';
        } else if (fraud_status === 'accept') {
          paymentStatus = 'SUCCESS';
          transactionStatus = 'PAID';
        }
      } else if (transaction_status === 'settlement') {
        paymentStatus = 'SUCCESS';
        transactionStatus = 'PAID';
      } else if (transaction_status === 'cancel' || 
                 transaction_status === 'deny' || 
                 transaction_status === 'expire') {
        paymentStatus = 'FAILED';
        transactionStatus = 'CANCELLED';
      } else if (transaction_status === 'pending') {
        paymentStatus = 'PENDING';
        transactionStatus = 'PENDING';
      } else if (transaction_status === 'refund') {
        paymentStatus = 'SUCCESS';
        transactionStatus = 'REFUNDED';
      }

      return {
        orderId: order_id,
        paymentStatus,
        transactionStatus,
        paymentType: payment_type,
        grossAmount: parseFloat(gross_amount),
        midtransResponse: statusResponse
      };
    } catch (error) {
      console.error('Midtrans handle notification error:', error);
      throw new Error(`Notification handling failed: ${error.message}`);
    }
  }

  /**
   * Cancel transaction
   * @param {string} orderId - Order ID
   */
  async cancelTransaction(orderId) {
    try {
      const cancelResponse = await this.coreApi.transaction.cancel(orderId);
      
      return {
        orderId: cancelResponse.order_id,
        transactionStatus: cancelResponse.transaction_status,
        statusCode: cancelResponse.status_code,
        statusMessage: cancelResponse.status_message
      };
    } catch (error) {
      console.error('Midtrans cancel transaction error:', error);
      throw new Error(`Transaction cancellation failed: ${error.message}`);
    }
  }

  /**
   * Approve transaction (for challenge fraud status)
   * @param {string} orderId - Order ID
   */
  async approveTransaction(orderId) {
    try {
      const approveResponse = await this.coreApi.transaction.approve(orderId);
      
      return {
        orderId: approveResponse.order_id,
        transactionStatus: approveResponse.transaction_status,
        statusCode: approveResponse.status_code,
        statusMessage: approveResponse.status_message
      };
    } catch (error) {
      console.error('Midtrans approve transaction error:', error);
      throw new Error(`Transaction approval failed: ${error.message}`);
    }
  }

  /**
   * Refund transaction
   * @param {string} orderId - Order ID
   * @param {number} amount - Refund amount (optional, full refund if not specified)
   * @param {string} reason - Refund reason
   */
  async refundTransaction(orderId, amount = null, reason = 'Customer request') {
    try {
      const parameter = {
        refund_key: `refund-${orderId}-${Date.now()}`,
        amount: amount ? Math.round(amount) : undefined,
        reason: reason
      };

      const refundResponse = await this.coreApi.transaction.refund(orderId, parameter);
      
      return {
        orderId: refundResponse.order_id,
        refundKey: refundResponse.refund_key,
        refundAmount: parseFloat(refundResponse.refund_amount),
        transactionStatus: refundResponse.transaction_status,
        statusCode: refundResponse.status_code,
        statusMessage: refundResponse.status_message
      };
    } catch (error) {
      console.error('Midtrans refund transaction error:', error);
      throw new Error(`Transaction refund failed: ${error.message}`);
    }
  }

  /**
   * Get payment methods
   */
  getPaymentMethods() {
    return {
      eWallets: [
        { code: 'gopay', name: 'GoPay', icon: 'gopay.png' },
        { code: 'shopeepay', name: 'ShopeePay', icon: 'shopeepay.png' },
        { code: 'dana', name: 'DANA', icon: 'dana.png' },
        { code: 'linkaja', name: 'LinkAja', icon: 'linkaja.png' },
        { code: 'ovo', name: 'OVO', icon: 'ovo.png' }
      ],
      virtualAccounts: [
        { code: 'bca_va', name: 'BCA Virtual Account', icon: 'bca.png' },
        { code: 'bni_va', name: 'BNI Virtual Account', icon: 'bni.png' },
        { code: 'bri_va', name: 'BRI Virtual Account', icon: 'bri.png' },
        { code: 'mandiri_va', name: 'Mandiri Virtual Account', icon: 'mandiri.png' },
        { code: 'permata_va', name: 'Permata Virtual Account', icon: 'permata.png' }
      ],
      creditCards: [
        { code: 'credit_card', name: 'Credit/Debit Card', icon: 'card.png' }
      ],
      others: [
        { code: 'qris', name: 'QRIS', icon: 'qris.png' },
        { code: 'indomaret', name: 'Indomaret', icon: 'indomaret.png' },
        { code: 'alfamart', name: 'Alfamart', icon: 'alfamart.png' }
      ]
    };
  }

  /**
   * Validate Midtrans signature
   * @param {Object} notification - Midtrans notification
   * @param {string} signatureKey - Signature key from notification
   */
  validateSignature(notification, signatureKey) {
    const crypto = require('crypto');
    const serverKey = process.env.MIDTRANS_SERVER_KEY;
    
    const {
      order_id,
      status_code,
      gross_amount
    } = notification;
    
    const input = `${order_id}${status_code}${gross_amount}${serverKey}`;
    const hash = crypto.createHash('sha512').update(input).digest('hex');
    
    return hash === signatureKey;
  }
}

module.exports = new MidtransService();