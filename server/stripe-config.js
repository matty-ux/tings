import Stripe from 'stripe';

// Initialize Stripe with your secret key
// IMPORTANT: Never commit API keys to version control!
// Set STRIPE_SECRET_KEY environment variable instead
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

if (!process.env.STRIPE_SECRET_KEY) {
  console.error('❌ STRIPE_SECRET_KEY environment variable is required for payments');
  console.log('💡 Set STRIPE_SECRET_KEY on Railway to enable payment functionality');
  // Don't exit - let server start without payments for now
}

export default stripe;

// Stripe configuration
export const stripeConfig = {
  // Currency for Vend GB (British Pounds)
  currency: 'gbp',
  
  // Payment methods to accept
  paymentMethods: ['card'],
  
  // Stripe publishable key (for frontend)
  publishableKey: process.env.STRIPE_PUBLISHABLE_KEY || 'pk_test_your_publishable_key_here',
  
  // Webhook endpoint secret (for production)
  webhookSecret: process.env.STRIPE_WEBHOOK_SECRET || null,
  
  // Success and cancel URLs
  successUrl: process.env.STRIPE_SUCCESS_URL || 'https://tings-production.up.railway.app/order-success',
  cancelUrl: process.env.STRIPE_CANCEL_URL || 'https://tings-production.up.railway.app/order-cancel'
};

// Helper function to convert price to pence (Stripe uses smallest currency unit)
export function priceToPence(price) {
  return Math.round(price * 100);
}

// Helper function to convert pence to price
export function penceToPrice(pence) {
  return pence / 100;
}
