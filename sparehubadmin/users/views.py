from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import User, Manufacturer, Shop
from .serializers import UserSerializer, ManufacturerSerializer, ShopSerializer
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from django.contrib.auth.hashers import make_password
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from django.core.validators import URLValidator
from django.core.exceptions import ValidationError
import logging

logger = logging.getLogger(__name__)

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class ManufacturerRegisterView(APIView):
    permission_classes = [AllowAny]
    authentication_classes = []
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def post(self, request):
        data = request.data.copy()
        email = data.get('email')
        if not email:
            return Response({'error': 'Email is required'}, status=status.HTTP_400_BAD_REQUEST)

        password = data.get('password')
        if not password:
            return Response({'error': 'Password is required'}, status=status.HTTP_400_BAD_REQUEST)

        username = email

        user_data = {
            'email': email,
            'username': username,
            'role': 'manufacturer',
            'password': password,
        }
        user_serializer = UserSerializer(data=user_data)
        if user_serializer.is_valid():
            user = user_serializer.save()
        else:
            logger.error(f"User serializer errors: {user_serializer.errors}")
            return Response(user_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        logo_file = request.FILES.get('logo')
        license_file = request.FILES.get('license')

        logo_url = None
        license_url = None
        from django.core.files.storage import default_storage
        from django.core.files.base import ContentFile

        if logo_file:
            logo_path = default_storage.save(f'logos/{logo_file.name}', ContentFile(logo_file.read()))
            logo_url = request.build_absolute_uri(default_storage.url(logo_path))

        if license_file:
            license_path = default_storage.save(f'licenses/{license_file.name}', ContentFile(license_file.read()))
            license_url = request.build_absolute_uri(default_storage.url(license_path))

        website = data.get('website')
        if website in ['', None]:
            website = None
        else:
            validator = URLValidator()
            try:
                validator(website)
            except ValidationError:
                website = None

        manufacturer_data = {
            'user': user.id,
            'company_name': data.get('company_name'),
            'contact_name': data.get('contact_name'),
            'phone': data.get('phone_number'),
            'gst': data.get('gst_number'),
            'address': data.get('address'),
            'city': data.get('city'),
            'state': data.get('state'),
            'country': data.get('country'),
            'website': website,
            'product_categories': data.get('product_categories'),
            'logo': logo_url if logo_url else data.get('logo'),
            'license': license_url if license_url else data.get('license'),
            'terms_accepted': data.get('terms_accepted') == 'true' or data.get('terms_accepted') == True,
        }

        manufacturer_serializer = ManufacturerSerializer(data=manufacturer_data)
        if manufacturer_serializer.is_valid():
            manufacturer_serializer.save()
        else:
            logger.error(f"Manufacturer serializer errors: {manufacturer_serializer.errors}")
            user.delete()
            return Response(manufacturer_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        refresh = RefreshToken.for_user(user)
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'role': user.role,
            'user': user_serializer.data,
        }, status=status.HTTP_201_CREATED)

class ShopRegisterView(APIView):
    permission_classes = [AllowAny]
    authentication_classes = []
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def post(self, request):
        data = request.data.copy()
        email = data.get('email')
        if not email:
            return Response({'error': 'Email is required'}, status=status.HTTP_400_BAD_REQUEST)

        password = data.get('password')
        if not password:
            return Response({'error': 'Password is required'}, status=status.HTTP_400_BAD_REQUEST)

        username = email

        user_data = {
            'email': email,
            'username': username,
            'role': 'shop',
            'password': password,
        }
        user_serializer = UserSerializer(data=user_data)
        if user_serializer.is_valid():
            user = user_serializer.save()
        else:
            logger.error(f"User serializer errors: {user_serializer.errors}")
            return Response(user_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        logo_file = request.FILES.get('logo')
        license_file = request.FILES.get('license')

        logo_url = None
        license_url = None
        from django.core.files.storage import default_storage
        from django.core.files.base import ContentFile

        if logo_file:
            logo_path = default_storage.save(f'logos/{logo_file.name}', ContentFile(logo_file.read()))
            logo_url = request.build_absolute_uri(default_storage.url(logo_path))

        if license_file:
            license_path = default_storage.save(f'licenses/{license_file.name}', ContentFile(license_file.read()))
            license_url = request.build_absolute_uri(default_storage.url(license_path))

        website = data.get('website')
        if website in ['', None]:
            website = None
        else:
            validator = URLValidator()
            try:
                validator(website)
            except ValidationError:
                website = None

        shop_data = {
            'user': user.id,
            'shop_name': data.get('shop_name'),
            'contact_name': data.get('owner_name'),
            'phone': data.get('phone_number'),
            'gst': data.get('gst_number'),
            'address': data.get('address'),
            'city': data.get('city'),
            'state': data.get('state'),
            'country': data.get('country'),
            'website': website,
            'business_type': data.get('business_type'),
            'logo': logo_url if logo_url else data.get('logo'),
            'license': license_url if license_url else data.get('license'),
            'terms_accepted': data.get('terms_accepted') == 'true' or data.get('terms_accepted') == True,
        }

        shop_serializer = ShopSerializer(data=shop_data)
        if shop_serializer.is_valid():
            shop_serializer.save()
        else:
            logger.error(f"Shop serializer errors: {shop_serializer.errors}")
            user.delete()
            return Response(shop_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        refresh = RefreshToken.for_user(user)
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'role': user.role,
            'user': user_serializer.data,
        }, status=status.HTTP_201_CREATED)

class LoginView(APIView):
    permission_classes = [AllowAny]
    authentication_classes = []

    def post(self, request):
        logger.debug(f'Login request data: {request.data}')
        username = request.data.get('username')
        password = request.data.get('password')

        logger.debug(f'Login attempt for username: {username}')
        if not username or not password:
            logger.debug('Username or password missing')
            return Response({'error': 'Username and password are required'}, status=status.HTTP_400_BAD_REQUEST)

        user = authenticate(request, username=username, password=password)
        logger.debug(f'Authenticated user: {user}')
        if user is not None:
            logger.debug(f'User {username} authenticated successfully')
            refresh = RefreshToken.for_user(user)
            user_serializer = UserSerializer(user)

            # Include manufacturer or shop profile data
            profile_data = {}
            if user.role == 'manufacturer':
                try:
                    manufacturer = Manufacturer.objects.get(user=user)
                    manufacturer_serializer = ManufacturerSerializer(manufacturer)
                    profile_data = manufacturer_serializer.data
                except Manufacturer.DoesNotExist:
                    logger.error(f"Manufacturer profile not found for user {user.email}")
                    profile_data = {}
            elif user.role == 'shop':
                try:
                    shop = Shop.objects.get(user=user)
                    shop_serializer = ShopSerializer(shop)
                    profile_data = shop_serializer.data
                except Shop.DoesNotExist:
                    logger.error(f"Shop profile not found for user {user.email}")
                    profile_data = {}

            # Combine user and profile data
            response_data = {
                'id': user_serializer.data['id'],
                'username': user_serializer.data['username'],
                'email': user_serializer.data['email'],
                'role': user_serializer.data['role'],
                'is_active': user_serializer.data['is_active'],
                'is_staff': user_serializer.data['is_staff'],
                'created_at': user_serializer.data['created_at'],
                'updated_at': user_serializer.data['updated_at'],
            }

            if user.role == 'manufacturer':
                response_data.update({
                    'companyName': profile_data.get('company_name', ''),
                    'phone': profile_data.get('phone', ''),
                    'gst': profile_data.get('gst', ''),
                    'address': profile_data.get('address', ''),
                    'logo': profile_data.get('logo', ''),
                    'license': profile_data.get('license', ''),
                })
            elif user.role == 'shop':
                response_data.update({
                    'shopName': profile_data.get('shop_name', ''),
                    'phone': profile_data.get('phone', ''),
                    'gst': profile_data.get('gst', ''),
                    'address': profile_data.get('address', ''),
                    'logo': profile_data.get('logo', ''),
                    'license': profile_data.get('license', ''),
                })

            return Response({
                'access': str(refresh.access_token),
                'refresh': str(refresh),
                'role': user.role,
                'user': response_data,
            })
        else:
            logger.debug(f'Authentication failed for user {username}')
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        user_serializer = UserSerializer(user)
        
        profile_data = {}
        if user.role == 'manufacturer':
            try:
                manufacturer = Manufacturer.objects.get(user=user)
                manufacturer_serializer = ManufacturerSerializer(manufacturer)
                profile_data = manufacturer_serializer.data
            except Manufacturer.DoesNotExist:
                logger.error(f"Manufacturer profile not found for user {user.email}")
                profile_data = {}
        elif user.role == 'shop':
            try:
                shop = Shop.objects.get(user=user)
                shop_serializer = ShopSerializer(shop)
                profile_data = shop_serializer.data
            except Shop.DoesNotExist:
                logger.error(f"Shop profile not found for user {user.email}")
                profile_data = {}

        response_data = {
            'id': user_serializer.data['id'],
            'username': user_serializer.data['username'],
            'email': user_serializer.data['email'],
            'role': user_serializer.data['role'],
            'is_active': user_serializer.data['is_active'],
            'is_staff': user_serializer.data['is_staff'],
            'created_at': user_serializer.data['created_at'],
            'updated_at': user_serializer.data['updated_at'],
        }
        
        if user.role == 'manufacturer':
            response_data.update({
                'companyName': profile_data.get('company_name', ''),
                'phone': profile_data.get('phone', ''),
                'gst': profile_data.get('gst', ''),
                'address': profile_data.get('address', ''),
                'logo': profile_data.get('logo', ''),
                'license': profile_data.get('license', ''),
            })
        elif user.role == 'shop':
            response_data.update({
                'shopName': profile_data.get('shop_name', ''),
                'phone': profile_data.get('phone', ''),
                'gst': profile_data.get('gst', ''),
                'address': profile_data.get('address', ''),
                'logo': profile_data.get('logo', ''),
                'license': profile_data.get('license', ''),
            })

        return Response(response_data)

    def put(self, request):
        user = request.user
        data = request.data.copy()

        user_serializer = UserSerializer(user, data=data, partial=True)
        if user_serializer.is_valid():
            user_serializer.save()
        else:
            logger.error(f"User serializer errors: {user_serializer.errors}")
            return Response(user_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        if user.role == 'manufacturer':
            try:
                manufacturer = Manufacturer.objects.get(user=user)
                manufacturer_data = {
                    'company_name': data.get('companyName', manufacturer.company_name),
                    'phone': data.get('phone', manufacturer.phone),
                    'gst': data.get('gst', manufacturer.gst),
                    'address': data.get('address', manufacturer.address),
                    'logo': data.get('logo', manufacturer.logo),
                    'license': data.get('license', manufacturer.license),
                    'contact_name': data.get('contact_name', manufacturer.contact_name),
                    'city': data.get('city', manufacturer.city),
                    'state': data.get('state', manufacturer.state),
                    'country': data.get('country', manufacturer.country),
                    'website': data.get('website', manufacturer.website),
                    'product_categories': data.get('product_categories', manufacturer.product_categories),
                    'terms_accepted': data.get('terms_accepted', manufacturer.terms_accepted),
                }
                manufacturer_serializer = ManufacturerSerializer(manufacturer, data=manufacturer_data, partial=True)
                if manufacturer_serializer.is_valid():
                    manufacturer_serializer.save()
                else:
                    logger.error(f"Manufacturer serializer errors: {manufacturer_serializer.errors}")
                    return Response(manufacturer_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            except Manufacturer.DoesNotExist:
                logger.error(f"Manufacturer profile not found for user {user.email}")
                return Response({'error': 'Manufacturer profile not found'}, status=status.HTTP_404_NOT_FOUND)
        elif user.role == 'shop':
            try:
                shop = Shop.objects.get(user=user)
                shop_data = {
                    'shop_name': data.get('shopName', shop.shop_name),
                    'phone': data.get('phone', shop.phone),
                    'gst': data.get('gst', shop.gst),
                    'address': data.get('address', shop.address),
                    'logo': data.get('logo', shop.logo),
                    'license': data.get('license', shop.license),
                    'contact_name': data.get('contact_name', shop.contact_name),
                    'city': data.get('city', shop.city),
                    'state': data.get('state', shop.state),
                    'country': data.get('country', shop.country),
                    'website': data.get('website', shop.website),
                    'business_type': data.get('business_type', shop.business_type),
                    'terms_accepted': data.get('terms_accepted', shop.terms_accepted),
                }
                shop_serializer = ShopSerializer(shop, data=shop_data, partial=True)
                if shop_serializer.is_valid():
                    shop_serializer.save()
                else:
                    logger.error(f"Shop serializer errors: {shop_serializer.errors}")
                    return Response(shop_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            except Shop.DoesNotExist:
                logger.error(f"Shop profile not found for user {user.email}")
                return Response({'error': 'Shop profile not found'}, status=status.HTTP_404_NOT_FOUND)

        return self.get(request)