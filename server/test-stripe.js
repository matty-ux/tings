import stripe, { stripeConfig } from './stripe-config.js';

async function testStripeConnection() {
  try {
    console.log('🧪 Testing Stripe connection...');
    
    if (!process.env.STRIPE_SECRET_KEY) {
      console.error('❌ STRIPE_SECRET_KEY environment variable is required');
      console.log('💡 Set it with: export STRIPE_SECRET_KEY="sk_live_your_key_here"');
      return;
    }
    
    // Test 1: Verify API key works
    console.log('📊 Testing API key...');
    const balance = await stripe.balance.retrieve();
    console.log('✅ Stripe API key is valid!');
    console.log(`💰 Available balance: ${balance.available[0]?.amount / 100} ${balance.available[0]?.currency.toUpperCase()}`);
    
    // Test 2: Create a test payment intent
    console.log('\n💳 Testing payment intent creation...');
    const paymentIntent = await stripe.paymentIntents.create({
      amount: 2000, // £20.00 in pence
      currency: 'gbp',
      metadata: {
        test: 'true',
        orderId: 'test-order-123'
      },
      automatic_payment_methods: {
        enabled: true,
      },
    });
    
    console.log('✅ Payment intent created successfully!');
    console.log(`🆔 Payment Intent ID: ${paymentIntent.id}`);
    console.log(`🔑 Client Secret: ${paymentIntent.client_secret.substring(0, 20)}...`);
    
    // Test 3: Check configuration
    console.log('\n⚙️ Stripe Configuration:');
    console.log(`   Currency: ${stripeConfig.currency}`);
    console.log(`   Publishable Key: ${stripeConfig.publishableKey.substring(0, 20)}...`);
    
    console.log('\n🎉 All Stripe tests passed! Your integration is ready.');
    
  } catch (error) {
    console.error('❌ Stripe test failed:', error.message);
    
    if (error.type === 'StripeAuthenticationError') {
      console.log('\n💡 This usually means:');
      console.log('   1. Your API key is incorrect');
      console.log('   2. Your API key doesn\'t have the right permissions');
      console.log('   3. You\'re using a test key in live mode or vice versa');
    }
  }
}

testStripeConnection();
