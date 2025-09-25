// Auth0 Configuration
export const auth0Config = {
  domain: process.env.AUTH0_DOMAIN,
  clientID: process.env.AUTH0_CLIENT_ID,
  clientSecret: process.env.AUTH0_CLIENT_SECRET,
  callbackURL: process.env.AUTH0_CALLBACK_URL || `${process.env.BASE_URL || 'https://tings-production.up.railway.app'}/callback`,
  baseURL: process.env.BASE_URL || 'https://tings-production.up.railway.app',
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
