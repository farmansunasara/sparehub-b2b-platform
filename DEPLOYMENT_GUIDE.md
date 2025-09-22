# SpareHub B2B Platform - Render Deployment Guide

## 🚀 Quick Deployment Steps

### 1. Prepare Your Repository

1. **Push your code to GitHub** (if not already done)
2. **Ensure all files are committed**:
   ```bash
   git add .
   git commit -m "Prepare for Render deployment"
   git push origin main
   ```

### 2. Create Render Account & Services

1. **Sign up at [render.com](https://render.com)**
2. **Connect your GitHub account**
3. **Create a new Web Service**:
   - Connect your GitHub repository
   - Choose "Web Service"
   - Select your repository

### 3. Configure Web Service

#### **Basic Settings**
- **Name**: `sparehub-backend`
- **Environment**: `Python 3`
- **Region**: Choose closest to your users
- **Branch**: `main` (or your default branch)

#### **Build & Deploy Settings**
- **Build Command**: 
  ```bash
  pip install -r requirements.txt && python manage.py migrate && python manage.py collectstatic --noinput
  ```
- **Start Command**: 
  ```bash
  gunicorn sparehubadmin.wsgi:application
  ```

#### **Environment Variables**
Add these environment variables in Render dashboard:

```
DEBUG=False
SECRET_KEY=your-very-secure-secret-key-here
ALLOWED_HOSTS=sparehub-backend.onrender.com
CORS_ALLOWED_ORIGINS=https://sparehub-backend.onrender.com
STATIC_URL=/static/
STATIC_ROOT=/opt/render/project/src/staticfiles
MEDIA_URL=/media/
MEDIA_ROOT=/opt/render/project/src/media
```

### 4. Create PostgreSQL Database

1. **Create a new PostgreSQL service** in Render
2. **Name**: `sparehub-db`
3. **Plan**: Free tier (or paid for production)
4. **Copy the database URL** from the service dashboard

### 5. Update Environment Variables

Add the database URL to your web service:
```
DATABASE_URL=postgresql://user:password@host:port/database
```

### 6. Deploy

1. **Click "Deploy"** in Render dashboard
2. **Monitor the build logs** for any errors
3. **Wait for deployment to complete** (5-10 minutes)

### 7. Create Admin User

After successful deployment, create an admin user:

1. **Go to your deployed URL**: `https://sparehub-backend.onrender.com`
2. **Access Django admin**: `https://sparehub-backend.onrender.com/django-admin/`
3. **Create superuser** (you may need to use Render's shell):
   ```bash
   python manage.py createsuperuser
   ```

## 🔧 Configuration Files Created

### `requirements.txt`
Contains all Python dependencies needed for production.

### `render.yaml`
Configuration file for Render services (optional, can use dashboard instead).

### `Procfile`
Specifies the command to run the web server.

### `build.sh`
Build script for deployment (optional).

### `runtime.txt`
Specifies Python version.

### `env.example`
Template for environment variables.

## 📱 Flutter App Configuration

After backend deployment, update your Flutter app:

1. **Update API base URL** in `lib/services/api_service.dart`:
   ```dart
   static const String _baseUrl = 'https://sparehub-backend.onrender.com/api';
   ```

2. **Test the connection** with your deployed backend.

## 🔍 Troubleshooting

### Common Issues

1. **Build Failures**:
   - Check Python version compatibility
   - Verify all dependencies in requirements.txt
   - Check build logs for specific errors

2. **Database Connection Issues**:
   - Verify DATABASE_URL is correctly set
   - Ensure PostgreSQL service is running
   - Check database credentials

3. **Static Files Not Loading**:
   - Verify STATIC_ROOT and STATIC_URL settings
   - Check if collectstatic ran successfully
   - Ensure WhiteNoise is properly configured

4. **CORS Issues**:
   - Update CORS_ALLOWED_ORIGINS with your frontend domain
   - Check if CORS middleware is properly configured

### Debugging Steps

1. **Check Render logs** in the dashboard
2. **Test API endpoints** using Postman or curl
3. **Verify environment variables** are set correctly
4. **Check database connectivity** using Django shell

## 🚀 Production Considerations

### Security
- Use strong SECRET_KEY
- Set DEBUG=False
- Configure proper CORS origins
- Use HTTPS (Render provides this automatically)

### Performance
- Consider upgrading to paid plan for better performance
- Use CDN for static files (optional)
- Monitor database performance

### Monitoring
- Set up logging and monitoring
- Monitor error rates and response times
- Set up alerts for critical issues

## 📞 Support

If you encounter issues:
1. Check Render documentation
2. Review Django deployment guides
3. Check the logs in Render dashboard
4. Verify all environment variables are set correctly

## 🎉 Success!

Once deployed, your SpareHub B2B platform will be available at:
- **Backend API**: `https://sparehub-backend.onrender.com/api/`
- **Admin Panel**: `https://sparehub-backend.onrender.com/admin/`
- **Custom Admin**: `https://sparehub-backend.onrender.com/admin/`

Update your Flutter app to use the new backend URL and you're ready to go!
