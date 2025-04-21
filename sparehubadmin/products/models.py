from django.db import models
from django.db.models import JSONField

class Product(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=255)
    description = models.TextField()
    sku = models.CharField(max_length=100, unique=True)
    model_number = models.CharField(max_length=100, blank=True, null=True)
    # brand = models.ForeignKey('brands.Brand', on_delete=models.SET_NULL, null=True, blank=True)
    # category = models.ForeignKey('categories.Category', on_delete=models.CASCADE)
    # subcategory = models.ForeignKey('categories.Subcategory', on_delete=models.CASCADE)
    manufacturer = models.ForeignKey('users.User', on_delete=models.CASCADE, limit_choices_to={'role': 'manufacturer'})
    compatible_cars = JSONField(blank=True, default=list)
    categories = JSONField(blank=True, default=list)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    discount = models.DecimalField(max_digits=5, decimal_places=2, default=0.0)
    stock_quantity = models.IntegerField()
    min_order_quantity = models.IntegerField(default=1)
    specifications = JSONField(blank=True, default=dict)
    technical_specification_pdf = models.URLField(blank=True, null=True)
    weight = models.FloatField()
    dimensions = models.CharField(max_length=255, blank=True, null=True)
    shipping_cost = models.DecimalField(max_digits=10, decimal_places=2, default=0.0)
    is_active = models.BooleanField(default=True)
    images = JSONField(blank=True, default=list)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name
