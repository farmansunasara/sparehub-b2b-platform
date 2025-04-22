from django.contrib import admin
from django.utils.html import format_html
from .models import Product, Category, Subcategory, Brand, Car, ProductImage, ProductCarCompatibility, ProductVariant

@admin.register(ProductImage)
class ProductImageAdmin(admin.ModelAdmin):
    list_display = ['id', 'display_image', 'product', 'is_primary', 'created_at']
    list_filter = ['is_primary', 'created_at']
    search_fields = ['product__name']

    def display_image(self, obj):
        if obj.image:
            return format_html('<img src="{}" width="50" height="50" />', obj.image.url)
        return "No Image"
    display_image.short_description = 'Image'

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ['name', 'sku', 'brand', 'category', 'subcategory', 'price', 'stock_quantity', 'is_active', 'is_approved']
    list_filter = ['is_active', 'is_approved', 'category', 'subcategory', 'brand']
    search_fields = ['name', 'sku', 'description']

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'slug', 'is_active', 'created_at']
    prepopulated_fields = {'slug': ('name',)}
    search_fields = ['name']

@admin.register(Subcategory)
class SubcategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'category', 'slug', 'is_active', 'created_at']
    prepopulated_fields = {'slug': ('name',)}
    search_fields = ['name', 'category__name']

@admin.register(Brand)
class BrandAdmin(admin.ModelAdmin):
    list_display = ['name', 'is_active', 'created_at']
    search_fields = ['name']

@admin.register(Car)
class CarAdmin(admin.ModelAdmin):
    list_display = ['make', 'model', 'year', 'created_at']
    search_fields = ['make', 'model']

@admin.register(ProductCarCompatibility)
class ProductCarCompatibilityAdmin(admin.ModelAdmin):
    list_display = ['product', 'car', 'created_at']
    search_fields = ['product__name', 'car__make', 'car__model']

@admin.register(ProductVariant)
class ProductVariantAdmin(admin.ModelAdmin):
    list_display = ['product', 'name', 'sku', 'price_modifier', 'stock_quantity']
    search_fields = ['product__name', 'name', 'sku']