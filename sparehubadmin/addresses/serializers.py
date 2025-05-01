from rest_framework import serializers
from .models import Address

class AddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = Address
        fields = [
            'id', 'name', 'phone', 'address_line1', 'address_line2', 'city',
            'state', 'pincode', 'country', 'type', 'is_default', 'metadata',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['user', 'created_at', 'updated_at']

    def validate(self, data):
        print(f"Received data: {data}")  # Debug log to inspect incoming payload
        # NEW: Ensure address_line1 is present
        if 'address_line1' not in data or not data['address_line1']:
            print("Validation error: address_line1 is missing or empty")
            raise serializers.ValidationError({
                'address_line1': 'This field is required.'
            })
        return data

    def validate_address_line1(self, value):
        # NEW: Enforce minimum length
        if len(value.strip()) < 3:
            print(f"Validation error: address_line1 '{value}' is too short")
            raise serializers.ValidationError("Address must be at least 3 characters long.")
        return value

    def create(self, validated_data):
        request = self.context.get('request')
        if request and hasattr(request, 'user') and request.user.is_authenticated:
            validated_data['user'] = request.user
        return super().create(validated_data)