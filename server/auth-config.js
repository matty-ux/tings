// Auth0 Configuration
const defaultBaseURL = 'https://tings-production.up.railway.app';

// Ensure we always have a proper base URL
let baseURL = process.env.BASE_URL || defaultBaseURL;
if (!baseURL.startsWith('http')) {
  baseURL = defaultBaseURL;
}

// Ensure callback URL is properly formatted
let callbackURL = process.env.AUTH0_CALLBACK_URL;
if (!callbackURL) {
  callbackURL = `${baseURL}/callback`;
} else if (!callbackURL.startsWith('http')) {
  callbackURL = `${baseURL}/callback`;
}

export const auth0Config = {
  domain: process.env.AUTH0_DOMAIN,
  clientID: process.env.AUTH0_CLIENT_ID,
  clientSecret: process.env.AUTH0_CLIENT_SECRET,
  callbackURL: callbackURL,
  baseURL: baseURL,
  sessionSecret: process.env.SESSION_SECRET || 'your-session-secret-change-in-production'
};

// Validate Auth0 configuration
export function validateAuth0Config() {
  const required = ['AUTH0_DOMAIN', 'AUTH0_CLIENT_ID', 'AUTH0_CLIENT_SECRET'];
  const missing = required.filter(key => !process.env[key]);
  
  if (missing.length > 0) {
    console.warn(`⚠️ Auth0 configuration incomplete. Missing: ${missing.join(', ')}`);
    console.log('💡 Auth0 authentication will be disabled. Set environment variables to enable.');
    return false;
  }
  
  console.log('✅ Auth0 configuration validated');
  console.log('🔗 Callback URL:', auth0Config.callbackURL);
  console.log('🏠 Base URL:', auth0Config.baseURL);
  console.log('🌐 Auth0 Domain:', auth0Config.domain);
  console.log('🆔 Client ID:', auth0Config.clientID);
  
  // Validate domain format
  if (!auth0Config.domain.includes('.auth0.com')) {
    console.error('❌ Auth0 domain format appears incorrect:', auth0Config.domain);
    console.log('💡 Expected format: your-tenant.auth0.com or your-tenant.region.auth0.com');
  }
  
  return true;
}

// Auth0 Strategy configuration
export const auth0StrategyConfig = {
  domain: auth0Config.domain,
  clientID: auth0Config.clientID,
  clientSecret: auth0Config.clientSecret,
  callbackURL: auth0Config.callbackURL,
  scope: 'openid email profile'
};
