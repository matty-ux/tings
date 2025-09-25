# Auth0 Authentication Setup for Vend GB Admin Portal

This guide will walk you through setting up Auth0 authentication for your Vend GB admin portal.

## 🚀 Quick Start

The Auth0 integration is already implemented in your codebase. You just need to:

1. **Create an Auth0 account and application**
2. **Configure environment variables on Railway**
3. **Test the authentication flow**

## 📋 Step 1: Create Auth0 Account & Application

### 1.1 Create Auth0 Account
1. Go to [Auth0](https://auth0.com) and sign up for a free account
2. Complete the account setup process

### 1.2 Create Application
1. In your Auth0 Dashboard, go to **Applications** → **Applications**
2. Click **Create Application**
3. Choose **Regular Web Applications**
4. Click **Create**

### 1.3 Configure Application Settings
1. **Application Name**: `Vend GB Admin Portal`
2. **Allowed Callback URLs**: 
   ```
   https://tings-production.up.railway.app/callback
   ```
3. **Allowed Logout URLs**:
   ```
   https://tings-production.up.railway.app
   ```
4. **Allowed Web Origins**:
   ```
   https://tings-production.up.railway.app
   ```

### 1.4 Get Your Auth0 Credentials
1. Go to **Applications** → **Your App** → **Settings**
2. Copy these values:
   - **Domain** (e.g., `your-tenant.auth0.com`)
   - **Client ID**
   - **Client Secret**

## 🔧 Step 2: Configure Railway Environment Variables

### 2.1 Add Environment Variables
Go to your Railway dashboard and add these environment variables:

```bash
AUTH0_DOMAIN=your-tenant.auth0.com
AUTH0_CLIENT_ID=your-client-id
AUTH0_CLIENT_SECRET=your-client-secret
AUTH0_CALLBACK_URL=https://tings-production.up.railway.app/callback
BASE_URL=https://tings-production.up.railway.app
SESSION_SECRET=your-very-secure-random-session-secret-here
```

### 2.2 Generate Session Secret
For the `SESSION_SECRET`, use a secure random string:
```bash
# Generate a secure session secret
openssl rand -base64 32
```

## 🧪 Step 3: Test Authentication

### 3.1 Deploy Changes
Railway will automatically deploy your changes when you push to GitHub.

### 3.2 Test the Flow
1. **Visit**: `https://tings-production.up.railway.app/admin`
2. **You should be redirected to**: `/login`
3. **Click "Login with Auth0"**
4. **Complete Auth0 login**
5. **You should be redirected back to**: `/admin`
6. **Verify**: You can see your user info in the sidebar

## 🔐 How It Works

### Authentication Flow
1. **User visits `/admin`** → Redirected to `/login` if not authenticated
2. **User clicks login** → Redirected to Auth0 login page
3. **User completes login** → Auth0 redirects to `/callback`
4. **Server validates token** → Creates session and redirects to `/admin`
5. **User can access admin** → All API calls include session authentication

### Protected Routes
- **Admin Web Interface**: `/admin` (requires authentication)
- **Admin API Routes**: `/api/admin/*` (requires authentication)
- **Public Routes**: `/api/products`, `/api/orders`, `/health` (no authentication required)

### Session Management
- **Sessions**: Stored server-side with secure cookies
- **Duration**: 24 hours (configurable)
- **Security**: Secure cookies in production, CSRF protection

## 🛠️ Customization Options

### Add User Management
You can extend the system to:
- Store user profiles in your database
- Add role-based access control
- Track user activity and audit logs

### Customize Login Page
Edit `server/public/login.html` to:
- Match your brand colors
- Add custom messaging
- Include additional information

### Add User Roles
Modify `auth-middleware.js` to:
- Check user roles from Auth0
- Restrict access based on permissions
- Add admin-only features

## 🚨 Security Notes

### Production Checklist
- ✅ Use HTTPS (Railway provides this)
- ✅ Set secure session cookies
- ✅ Use strong session secrets
- ✅ Configure Auth0 callbacks correctly
- ✅ Enable Auth0 security features

### Auth0 Security Features
- **Multi-Factor Authentication**: Enable in Auth0 dashboard
- **Brute Force Protection**: Built into Auth0
- **Anomaly Detection**: Enable in Auth0 dashboard
- **Password Policy**: Configure in Auth0 dashboard

## 🐛 Troubleshooting

### Common Issues

#### 1. "Auth0 configuration incomplete"
- **Cause**: Missing environment variables
- **Fix**: Check all required Auth0 environment variables are set

#### 2. "Callback URL mismatch"
- **Cause**: Auth0 callback URL doesn't match configuration
- **Fix**: Update Auth0 application settings with correct callback URL

#### 3. "Session not persisting"
- **Cause**: Session configuration issues
- **Fix**: Check SESSION_SECRET is set and cookies are working

#### 4. "Redirect loop"
- **Cause**: Authentication middleware issues
- **Fix**: Check requireAuthWeb middleware is working correctly

### Debug Mode
To enable debug logging, add to your environment variables:
```bash
DEBUG=passport:*
```

## 📞 Support

If you encounter issues:
1. Check the server logs in Railway dashboard
2. Verify Auth0 application configuration
3. Test with Auth0's test users
4. Check browser console for JavaScript errors

---

**🎉 Congratulations!** Your admin portal is now secured with Auth0 authentication!
