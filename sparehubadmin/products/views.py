from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Product, Category, Subcategory, Brand
from .serializers import (
    ProductSerializer, CategorySerializer, SubcategorySerializer,
    BrandSerializer
)
from users.models import User
from django.db.models import Q

class IsManufacturer(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'manufacturer'

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if self.request.user.role == 'manufacturer':
            return Product.objects.filter(manufacturer=self.request.user)
        return Product.objects.filter(is_active=True)

    def perform_create(self, serializer):
        if self.request.user.role != 'manufacturer':
            raise PermissionError("Only manufacturers can create products")
        
        try:
            serializer.save(manufacturer=self.request.user)
        except Exception as e:
            logger.error(f"Error creating product: {str(e)}")
            raise serializers.ValidationError(f"Failed to create product: {str(e)}")

    def perform_update(self, serializer):
        if self.request.user.role != 'manufacturer':
            raise PermissionError("Only manufacturers can update products")
            
        product = self.get_object()
        if product.manufacturer != self.request.user:
            raise PermissionError("You can only update your own products")
            
        try:
            serializer.save(manufacturer=self.request.user)
        except Exception as e:
            logger.error(f"Error updating product: {str(e)}")
            raise serializers.ValidationError(f"Failed to update product: {str(e)}")

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def categories(self, request):
        categories = Category.objects.filter(is_active=True)
        serializer = CategorySerializer(categories, many=True)
        return Response(serializer.data)  # Returns a list of categories

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def subcategories(self, request):
        category_id = request.query_params.get('category_id')
        subcategories = Subcategory.objects.filter(is_active=True)
        if category_id:
            subcategories = subcategories.filter(category_id=category_id)
        serializer = SubcategorySerializer(subcategories, many=True)
        return Response(serializer.data)  # Returns a list of subcategories

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def brands(self, request):
        brands = Brand.objects.filter(is_active=True)
        serializer = BrandSerializer(brands, many=True)
        return Response(serializer.data)  # Returns a list of brands

    