from django.contrib import admin
from .models import Product

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'sku', 'manufacturer', 'price', 'stock_quantity', 'is_active')
    list_filter = ('manufacturer', 'is_active')
    search_fields = ('name', 'sku', 'description')
    ordering = ('name',)
