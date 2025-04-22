from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Product, Category, Subcategory, Brand, Car
from .serializers import (
    ProductSerializer, CategorySerializer, SubcategorySerializer,
    BrandSerializer, CarSerializer
)
from users.models import User
from django.db.models import Q

class IsManufacturer(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'manufacturer'

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated, IsManufacturer]

    def get_queryset(self):
        return Product.objects.filter(manufacturer=self.request.user)

    def perform_create(self, serializer):
        serializer.save(manufacturer=self.request.user)

    def perform_update(self, serializer):
        serializer.save(manufacturer=self.request.user)

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

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def cars(self, request):
        cars = Car.objects.all()
        serializer = CarSerializer(cars, many=True)
        return Response(serializer.data)  # Returns a list of cars