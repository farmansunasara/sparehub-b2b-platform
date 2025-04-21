from rest_framework import serializers
from .models import Product

class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = [
            'id', 'name', 'description', 'sku', 'model_number', 'manufacturer',
            'compatible_cars', 'categories', 'price', 'discount', 'stock_quantity',
            'min_order_quantity', 'specifications', 'technical_specification_pdf',
            'weight', 'dimensions', 'shipping_cost', 'is_active', 'images',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
