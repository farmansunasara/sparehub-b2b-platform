from rest_framework import serializers
from .models import Order, OrderAddress, OrderPayment, OrderStatusUpdate

class OrderAddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderAddress
        fields = '__all__'

class OrderPaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderPayment
        fields = '__all__'

class OrderStatusUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderStatusUpdate
        fields = '__all__'

class OrderSerializer(serializers.ModelSerializer):
    shipping_address = OrderAddressSerializer()
    billing_address = OrderAddressSerializer(required=False, allow_null=True)
    payment = OrderPaymentSerializer()
    status_updates = OrderStatusUpdateSerializer(many=True, required=False)

    class Meta:
        model = Order
        fields = [
            'id', 'user', 'shop_name', 'items', 'shipping_address', 'billing_address',
            'payment', 'status', 'subtotal', 'tax', 'shipping_cost', 'total',
            'created_at', 'updated_at', 'status_updates', 'metadata'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def create(self, validated_data):
        shipping_address_data = validated_data.pop('shipping_address')
        billing_address_data = validated_data.pop('billing_address', None)
        payment_data = validated_data.pop('payment')
        status_updates_data = validated_data.pop('status_updates', [])

        shipping_address = OrderAddress.objects.create(**shipping_address_data)
        billing_address = None
        if billing_address_data:
            billing_address = OrderAddress.objects.create(**billing_address_data)
        payment = OrderPayment.objects.create(**payment_data)

        order = Order.objects.create(
            shipping_address=shipping_address,
            billing_address=billing_address,
            payment=payment,
            **validated_data
        )

        for status_update_data in status_updates_data:
            status_update = OrderStatusUpdate.objects.create(**status_update_data)
            order.status_updates.add(status_update)

        return order

    def update(self, instance, validated_data):
        # Update nested serializers
        shipping_address_data = validated_data.pop('shipping_address', None)
        billing_address_data = validated_data.pop('billing_address', None)
        payment_data = validated_data.pop('payment', None)
        status_updates_data = validated_data.pop('status_updates', None)

        if shipping_address_data:
            for attr, value in shipping_address_data.items():
                setattr(instance.shipping_address, attr, value)
            instance.shipping_address.save()

        if billing_address_data:
            if instance.billing_address:
                for attr, value in billing_address_data.items():
                    setattr(instance.billing_address, attr, value)
                instance.billing_address.save()
            else:
                instance.billing_address = OrderAddress.objects.create(**billing_address_data)

        if payment_data:
            for attr, value in payment_data.items():
                setattr(instance.payment, attr, value)
            instance.payment.save()

        if status_updates_data is not None:
            instance.status_updates.clear()
            for status_update_data in status_updates_data:
                status_update = OrderStatusUpdate.objects.create(**status_update_data)
                instance.status_updates.add(status_update)

        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        return instance
