import passport from 'passport';
import { Strategy as Auth0Strategy } from 'passport-auth0';
import session from 'express-session';
import { auth0Config, auth0StrategyConfig } from './auth-config.js';

// Session configuration
export const sessionConfig = {
  secret: auth0Config.sessionSecret,
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: process.env.NODE_ENV === 'production', // Use secure cookies in production
    maxAge: 24 * 60 * 60 * 1000 // 24 hours
  }
};

// Configure Passport
export function configurePassport() {
  console.log('🔧 Configuring Auth0 strategy with:');
  console.log('   Domain:', auth0StrategyConfig.domain);
  console.log('   Client ID:', auth0StrategyConfig.clientID);
  console.log('   Callback URL:', auth0StrategyConfig.callbackURL);
  
  // Auth0 Strategy
  const strategy = new Auth0Strategy(
    auth0StrategyConfig,
    (accessToken, refreshToken, extraParams, profile, done) => {
      // This function is called when user successfully logs in
      // You can save user info to database here if needed
      return done(null, profile);
    }
  );

  passport.use(strategy);

  // Serialize user for session
  passport.serializeUser((user, done) => {
    done(null, user);
  });

  // Deserialize user from session
  passport.deserializeUser((user, done) => {
    done(null, user);
  });
}

// Middleware to check if user is authenticated
export function requireAuth(req, res, next) {
  if (req.isAuthenticated()) {
    return next();
  } else {
    res.status(401).json({ error: 'Authentication required' });
  }
}

// Middleware to check if user is authenticated for web routes
export function requireAuthWeb(req, res, next) {
  console.log('🔍 requireAuthWeb check:');
  console.log('  - URL:', req.url);
  console.log('  - Is authenticated:', req.isAuthenticated());
  console.log('  - Session ID:', req.sessionID);
  console.log('  - User:', req.user ? 'Present' : 'Missing');
  
  if (req.isAuthenticated()) {
    console.log('✅ User authenticated, proceeding');
    return next();
  } else {
    console.log('❌ User not authenticated, redirecting to login');
    res.redirect('/login');
  }
}

// Middleware to add user info to requests
export function addUserInfo(req, res, next) {
  if (req.isAuthenticated()) {
    req.userInfo = {
      id: req.user.id,
      email: req.user.emails?.[0]?.value,
      name: req.user.displayName || req.user.name?.givenName + ' ' + req.user.name?.familyName,
      picture: req.user.picture
    };
  }
  next();
}

// Logout handler
export function logout(req, res) {
  req.logout((err) => {
    if (err) {
      console.error('Logout error:', err);
      return res.status(500).json({ error: 'Logout failed' });
    }
    
    // Redirect to Auth0 logout
    const logoutURL = `https://${auth0Config.domain}/v2/logout?` +
      `returnTo=${encodeURIComponent(auth0Config.baseURL)}&` +
      `client_id=${auth0Config.clientID}`;
    
    res.redirect(logoutURL);
  });
}
