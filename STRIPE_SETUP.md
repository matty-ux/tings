# 🚀 Stripe Payment Integration Setup Guide

## ✅ What's Already Done
- Stripe SDK installed and configured
- Payment endpoints created in your server
- Test page created for payment testing
- Environment variable configuration ready

## 🔑 Step 1: Set Up Environment Variables

### On Railway (Production):
1. Go to your Railway dashboard: https://railway.app/dashboard
2. Open your "tings" project
3. Click on your service → "Variables" tab
4. Add these environment variables:

```
STRIPE_SECRET_KEY=sk_live_your_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_live_your_publishable_key_here
```

### Get Your Publishable Key:
1. Go to Stripe Dashboard: https://dashboard.stripe.com/
2. Click "Developers" → "API keys"
3. Copy your **Publishable key** (starts with `pk_live_`)

## 🧪 Step 2: Test the Integration

### Test Locally:
```bash
cd server
export STRIPE_SECRET_KEY="sk_live_your_secret_key_here"
export STRIPE_PUBLISHABLE_KEY="pk_live_your_publishable_key_here"
node test-stripe.js
```

### Test Payment Flow:
1. Start your server: `node server.js`
2. Visit: http://localhost:3001/payment-test.html
3. Use test card: `4242424242424242` (any expiry date, any CVC)

## 📱 Step 3: API Endpoints Available

### Payment Configuration
```
GET /api/payment/config
```
Returns Stripe publishable key and currency.

### Create Payment Intent
```
POST /api/payment/create-intent
{
  "orderId": "order_123",
  "amount": 15.74,
  "currency": "gbp"
}
```

### Confirm Payment
```
POST /api/payment/confirm
{
  "paymentIntentId": "pi_123",
  "orderId": "order_123"
}
```

### Webhook (Production)
```
POST /api/payment/webhook
```
Handles Stripe webhook events automatically.

## 💳 Step 4: Test Cards for Live Mode

Since you're using a live Stripe account, use real card details for testing:

### Real Test Cards:
- **Visa**: `4242424242424242`
- **Visa Debit**: `4000056655665556`
- **Mastercard**: `5555555555554444`
- **American Express**: `378282246310005`

Use any future expiry date and any 3-digit CVC.

## 🔧 Step 5: Integration with Your iOS App

### Add Stripe to iOS:
1. In Xcode, go to File → Add Package Dependencies
2. Add: `https://github.com/stripe/stripe-ios`
3. Import Stripe in your checkout view

### Example Swift Code:
```swift
import Stripe

class CheckoutView: UIViewController {
    func processPayment(orderId: String, amount: Double) {
        // Create payment intent
        let paymentData = [
            "orderId": orderId,
            "amount": amount,
            "currency": "gbp"
        ]
        
        // Call your server's /api/payment/create-intent
        // Then use Stripe iOS SDK to confirm payment
    }
}
```

## 🚨 Important Security Notes

1. **Never commit API keys** to version control
2. **Use environment variables** for all sensitive data
3. **Test with small amounts** first
4. **Monitor your Stripe dashboard** for transactions
5. **Set up webhooks** for production

## 📊 Step 6: Monitor Payments

1. **Stripe Dashboard**: https://dashboard.stripe.com/
2. **View transactions**: Payments → All transactions
3. **Check balance**: Dashboard shows your account balance
4. **Webhook logs**: Developers → Webhooks

## 🎯 Next Steps

1. **Set environment variables** on Railway
2. **Test payment flow** with test page
3. **Integrate with iOS app** using Stripe iOS SDK
4. **Set up webhooks** for production
5. **Test with real small amounts**

## 🆘 Troubleshooting

### Common Issues:
- **"Invalid API key"**: Check environment variable is set correctly
- **"Payment failed"**: Ensure you're using valid test card numbers
- **"Webhook failed"**: Check webhook endpoint URL in Stripe dashboard

### Get Help:
- Stripe Documentation: https://stripe.com/docs
- Stripe Support: https://support.stripe.com/

---

🎉 **Your Stripe integration is ready!** Start with small test amounts and gradually increase as you gain confidence.
