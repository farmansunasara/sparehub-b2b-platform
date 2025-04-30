import logging
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.pagination import PageNumberPagination
from .models import Product, Category, Subcategory, Brand
from .serializers import (
    ProductSerializer, CategorySerializer, SubcategorySerializer,
    BrandSerializer
)
from users.models import User
from django.db.models import Q

# Set up logging
logger = logging.getLogger(__name__)

class IsManufacturer(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'manufacturer'

class StandardResultsSetPagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = StandardResultsSetPagination

    def get_queryset(self):
        try:
            queryset = Product.objects.all()
            if self.request.user.role == 'manufacturer':
                logger.info(f"Fetching products for manufacturer: {self.request.user.id}")
                queryset = queryset.filter(manufacturer=self.request.user)
            else:
                logger.info(f"Fetching products for shop user: {self.request.user.id}")
                queryset = queryset.filter(is_active=True, is_approved=True)

            category_id = self.request.query_params.get('category_id')
            subcategory_id = self.request.query_params.get('subcategory_id')
            brand_id = self.request.query_params.get('brand_id')
            min_price = self.request.query_params.get('min_price')
            max_price = self.request.query_params.get('max_price')
            stock_status = self.request.query_params.get('stock_status')
            search_query = self.request.query_params.get('search')

            if category_id:
                queryset = queryset.filter(category_id=category_id)
            if subcategory_id:
                queryset = queryset.filter(subcategory_id=subcategory_id)
            if brand_id:
                queryset = queryset.filter(brand_id=brand_id)
            if min_price:
                try:
                    queryset = queryset.filter(price__gte=float(min_price))
                except ValueError:
                    logger.warning(f"Invalid min_price: {min_price}")
            if max_price:
                try:
                    queryset = queryset.filter(price__lte=float(max_price))
                except ValueError:
                    logger.warning(f"Invalid max_price: {max_price}")
            if stock_status:
                if stock_status == 'in_stock':
                    queryset = queryset.filter(stock_quantity__gt=10)
                elif stock_status == 'low_stock':
                    queryset = queryset.filter(stock_quantity__lte=10, stock_quantity__gt=0)
                elif stock_status == 'out_of_stock':
                    queryset = queryset.filter(stock_quantity=0)
            if search_query:
                queryset = queryset.filter(
                    Q(name__icontains=search_query) | Q(sku__icontains=search_query)
                )

            return queryset
        except Exception as e:
            logger.error(f"Error in get_queryset: {str(e)}")
            raise

    def perform_create(self, serializer):
        if self.request.user.role != 'manufacturer':
            logger.warning(f"Non-manufacturer {self.request.user.id} attempted to create product")
            raise PermissionError("Only manufacturers can create products")
        
        try:
            serializer.save(manufacturer=self.request.user)
            logger.info(f"Product created by manufacturer: {self.request.user.id}")
        except Exception as e:
            logger.error(f"Error creating product: {str(e)}")
            raise serializers.ValidationError(f"Failed to create product: {str(e)}")

    def perform_update(self, serializer):
        if self.request.user.role != 'manufacturer':
            logger.warning(f"Non-manufacturer {self.request.user.id} attempted to update product")
            raise PermissionError("Only manufacturers can update products")
            
        product = self.get_object()
        if product.manufacturer != self.request.user:
            logger.warning(f"Manufacturer {self.request.user.id} attempted to update another manufacturer's product")
            raise PermissionError("You can only update your own products")
            
        try:
            serializer.save(manufacturer=self.request.user)
            logger.info(f"Product updated by manufacturer: {self.request.user.id}")
        except Exception as e:
            logger.error(f"Error updating product: {str(e)}")
            raise serializers.ValidationError(f"Failed to update product: {str(e)}")

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def categories(self, request):
        try:
            categories = Category.objects.filter(is_active=True)
            serializer = CategorySerializer(categories, many=True, context={'request': request})
            logger.info(f"Fetched {len(categories)} categories")
            return Response(serializer.data)
        except Exception as e:
            logger.error(f"Error fetching categories: {str(e)}")
            return Response({"detail": "Failed to fetch categories"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def subcategories(self, request):
        try:
            category_id = request.query_params.get('category_id')
            subcategories = Subcategory.objects.filter(is_active=True)
            if category_id:
                subcategories = subcategories.filter(category_id=category_id)
            serializer = SubcategorySerializer(subcategories, many=True, context={'request': request})
            logger.info(f"Fetched {len(subcategories)} subcategories")
            return Response(serializer.data)
        except Exception as e:
            logger.error(f"Error fetching subcategories: {str(e)}")
            return Response({"detail": "Failed to fetch subcategories"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def brands(self, request):
        try:
            brands = Brand.objects.filter(is_active=True)
            serializer = BrandSerializer(brands, many=True, context={'request': request})
            logger.info(f"Fetched {len(brands)} brands")
            return Response(serializer.data)
        except Exception as e:
            logger.error(f"Error fetching brands: {str(e)}")
            return Response({"detail": "Failed to fetch brands"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def featured(self, request):
        try:
            featured_products = Product.objects.filter(
                is_active=True, is_approved=True, is_featured=True
            )[:10]
            serializer = ProductSerializer(featured_products, many=True, context={'request': request})
            logger.info(f"Fetched {len(featured_products)} featured products")
            return Response(serializer.data)
        except Exception as e:
            logger.error(f"Error fetching featured products: {str(e)}")
            return Response({"detail": "Failed to fetch featured products"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)