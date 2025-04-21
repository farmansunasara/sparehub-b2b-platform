from django.db import models
from django.db.models import JSONField
from users.models import User

class OrderStatus(models.TextChoices):
    PENDING = 'pending'
    CONFIRMED = 'confirmed'
    PROCESSING = 'processing'
    SHIPPED = 'shipped'
    DELIVERED = 'delivered'
    CANCELLED = 'cancelled'
    RETURNED = 'returned'

class PaymentStatus(models.TextChoices):
    PENDING = 'pending'
    PROCESSING = 'processing'
    COMPLETED = 'completed'
    FAILED = 'failed'
    REFUNDED = 'refunded'

class PaymentMethod(models.TextChoices):
    COD = 'cod'
    CARD = 'card'
    UPI = 'upi'
    NET_BANKING = 'netBanking'
    WALLET = 'wallet'

class OrderAddress(models.Model):
    name = models.CharField(max_length=255)
    phone = models.CharField(max_length=20)
    address_line1 = models.TextField()
    address_line2 = models.TextField(blank=True, null=True)
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    pincode = models.CharField(max_length=20)
    country = models.CharField(max_length=100)
    is_default = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.name} - {self.city}"

class OrderPayment(models.Model):
    method = models.CharField(max_length=20, choices=PaymentMethod.choices)
    status = models.CharField(max_length=20, choices=PaymentStatus.choices)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    transaction_id = models.CharField(max_length=255, blank=True, null=True)
    timestamp = models.DateTimeField(auto_now_add=True)
    metadata = JSONField(blank=True, null=True)

    def __str__(self):
        return f"{self.method} - {self.status} - {self.amount}"

class OrderStatusUpdate(models.Model):
    status = models.CharField(max_length=20, choices=OrderStatus.choices)
    comment = models.TextField(blank=True, null=True)
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.status} at {self.timestamp}"

class Order(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    shop_name = models.CharField(max_length=255)
    items = JSONField()  # Store list of items as JSON
    shipping_address = models.ForeignKey(OrderAddress, related_name='shipping_orders', on_delete=models.CASCADE)
    billing_address = models.ForeignKey(OrderAddress, related_name='billing_orders', on_delete=models.CASCADE, blank=True, null=True)
    payment = models.OneToOneField(OrderPayment, on_delete=models.CASCADE)
    status = models.CharField(max_length=20, choices=OrderStatus.choices)
    subtotal = models.DecimalField(max_digits=10, decimal_places=2)
    tax = models.DecimalField(max_digits=10, decimal_places=2)
    shipping_cost = models.DecimalField(max_digits=10, decimal_places=2)
    total = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    status_updates = models.ManyToManyField(OrderStatusUpdate, blank=True)
    metadata = JSONField(blank=True, null=True)

    def __str__(self):
        return f"Order {self.id} by {self.user}"
