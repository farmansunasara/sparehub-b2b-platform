from django.contrib import admin
from .models import Order, OrderAddress, OrderPayment, OrderStatusUpdate

@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'shop_name', 'status', 'total', 'created_at')
    list_filter = ('status', 'created_at')
    search_fields = ('id', 'shop_name', 'user__username')
    ordering = ('-created_at',)

@admin.register(OrderAddress)
class OrderAddressAdmin(admin.ModelAdmin):
    list_display = ('name', 'city', 'state', 'country', 'is_default')
    search_fields = ('name', 'city', 'state', 'country')

@admin.register(OrderPayment)
class OrderPaymentAdmin(admin.ModelAdmin):
    list_display = ('method', 'status', 'amount', 'transaction_id', 'timestamp')
    list_filter = ('method', 'status')
    search_fields = ('transaction_id',)

@admin.register(OrderStatusUpdate)
class OrderStatusUpdateAdmin(admin.ModelAdmin):
    list_display = ('status', 'timestamp')
    list_filter = ('status',)
