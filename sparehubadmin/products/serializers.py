from rest_framework import serializers
from .models import Product, Category, Subcategory, Brand, Car, ProductImage, ProductCarCompatibility
from users.models import User
import logging

# Set up logging
logger = logging.getLogger(__name__)

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'slug', 'image', 'is_active', 'created_at', 'updated_at']

class SubcategorySerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(), source='category', write_only=True
    )

    class Meta:
        model = Subcategory
        fields = ['id', 'category', 'category_id', 'name', 'slug', 'image', 'is_active', 'created_at', 'updated_at']

class BrandSerializer(serializers.ModelSerializer):
    class Meta:
        model = Brand
        fields = ['id', 'name', 'logo', 'description', 'is_active', 'created_at', 'updated_at']

class CarSerializer(serializers.ModelSerializer):
    class Meta:
        model = Car
        fields = ['id', 'make', 'model', 'year', 'created_at']

class ProductImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductImage
        fields = ['id', 'image', 'is_primary', 'created_at']

class ProductCarCompatibilitySerializer(serializers.ModelSerializer):
    car = CarSerializer(read_only=True)
    car_id = serializers.PrimaryKeyRelatedField(
        queryset=Car.objects.all(), source='car', write_only=True
    )

    class Meta:
        model = ProductCarCompatibility
        fields = ['id', 'car', 'car_id', 'notes', 'created_at']

class ProductSerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(), source='category', write_only=True
    )
    subcategory = SubcategorySerializer(read_only=True)
    subcategory_id = serializers.PrimaryKeyRelatedField(
        queryset=Subcategory.objects.all(), source='subcategory', write_only=True
    )
    brand = BrandSerializer(read_only=True)
    brand_id = serializers.PrimaryKeyRelatedField(
        queryset=Brand.objects.all(), source='brand', write_only=True, required=False, allow_null=True
    )
    manufacturer = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.filter(role='manufacturer'), write_only=True
    )
    images = ProductImageSerializer(many=True, read_only=True)
    compatible_cars = ProductCarCompatibilitySerializer(many=True, read_only=True)
    compatible_car_ids = serializers.ListField(
        child=serializers.IntegerField(), write_only=True, required=False
    )
    price = serializers.DecimalField(max_digits=10, decimal_places=2, coerce_to_string=False)
    discount = serializers.DecimalField(max_digits=5, decimal_places=2, coerce_to_string=False)
    weight = serializers.DecimalField(max_digits=10, decimal_places=2, coerce_to_string=False)
    shipping_cost = serializers.DecimalField(max_digits=10, decimal_places=2, coerce_to_string=False)

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'description', 'sku', 'brand', 'brand_id', 'category', 'category_id',
            'subcategory', 'subcategory_id', 'manufacturer', 'price', 'discount', 'stock_quantity',
            'min_order_quantity', 'max_order_quantity', 'weight', 'dimensions', 'material', 'color',
            'technical_specification_pdf', 'installation_guide_pdf', 'shipping_cost', 'shipping_time',
            'origin_country', 'is_active', 'is_featured', 'is_approved', 'created_at', 'updated_at',
            'images', 'compatible_cars', 'compatible_car_ids'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'is_approved']

    def validate(self, data):
        """
        Log incoming data and files for debugging, and perform validation.
        """
        logger.info('Incoming Form Data: %s', data)
        logger.info('Incoming Files: %s', {
            'images': [file.name for file in self.context['request'].FILES.getlist('images', [])],
            'technical_specification_pdf': self.context['request'].FILES.get('technical_specification_pdf', None),
            'installation_guide_pdf': self.context['request'].FILES.get('installation_guide_pdf', None),
        })

        # Validate required fields
        errors = {}
        required_fields = ['name', 'sku', 'category_id', 'subcategory_id', 'manufacturer', 'price', 'weight']
        for field in required_fields:
            if field not in data or data[field] is None:
                errors[field] = f'{field} is required.'
                logger.error('Validation Error: %s is required.', field)

        # Validate SKU uniqueness
        sku = data.get('sku')
        if sku and Product.objects.filter(sku=sku).exclude(id=self.instance.id if self.instance else None).exists():
            errors['sku'] = 'This SKU is already in use.'
            logger.error('Validation Error: SKU %s is already in use.', sku)

        # Validate category and subcategory relationship
        category_id = data.get('category_id')
        subcategory_id = data.get('subcategory_id')
        if category_id and subcategory_id:
            try:
                subcategory = Subcategory.objects.get(id=subcategory_id.id)
                if subcategory.category_id != category_id.id:
                    errors['subcategory_id'] = 'Subcategory does not belong to the selected category.'
                    logger.error('Validation Error: Subcategory %s does not belong to category %s.', subcategory_id.id, category_id.id)
            except Subcategory.DoesNotExist:
                errors['subcategory_id'] = 'Invalid subcategory ID.'
                logger.error('Validation Error: Subcategory ID %s is invalid.', subcategory_id.id)

        # Validate manufacturer role
        manufacturer = data.get('manufacturer')
        if manufacturer and manufacturer.role != 'manufacturer':
            errors['manufacturer'] = 'User must have manufacturer role.'
            logger.error('Validation Error: User ID %s is not a manufacturer.', manufacturer.id)

        if errors:
            raise serializers.ValidationError(errors)

        return data

    def create(self, validated_data):
        compatible_car_ids = validated_data.pop('compatible_car_ids', [])
        manufacturer = validated_data.pop('manufacturer')
        images = self.context['request'].FILES.getlist('images', [])
        technical_pdf = self.context['request'].FILES.get('technical_specification_pdf', None)
        installation_pdf = self.context['request'].FILES.get('installation_guide_pdf', None)

        logger.info('Validated Data: %s', validated_data)
        logger.info('Images: %s', [image.name for image in images])
        logger.info('Technical PDF: %s', technical_pdf.name if technical_pdf else None)
        logger.info('Installation PDF: %s', installation_pdf.name if installation_pdf else None)

        # Create product
        product = Product.objects.create(
            **validated_data,
            manufacturer=manufacturer,
            technical_specification_pdf=technical_pdf,
            installation_guide_pdf=installation_pdf
        )

        # Handle compatible cars
        for car_id in compatible_car_ids:
            try:
                car = Car.objects.get(id=car_id)
                ProductCarCompatibility.objects.create(product=product, car=car)
            except Car.DoesNotExist:
                logger.warning('Car ID %s does not exist, skipping.', car_id)
                continue

        # Handle images
        for image in images:
            ProductImage.objects.create(
                product=product,
                image=image,
                is_primary=not ProductImage.objects.filter(product=product).exists()
            )

        return product

    def update(self, instance, validated_data):
        compatible_car_ids = validated_data.pop('compatible_car_ids', None)
        images = self.context['request'].FILES.getlist('images', [])
        technical_pdf = self.context['request'].FILES.get('technical_specification_pdf', None)
        installation_pdf = self.context['request'].FILES.get('installation_guide_pdf', None)

        logger.info('Validated Data: %s', validated_data)
        logger.info('Images: %s', [image.name for image in images])
        logger.info('Technical PDF: %s', technical_pdf.name if technical_pdf else None)
        logger.info('Installation PDF: %s', installation_pdf.name if installation_pdf else None)

        # Update product fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        if technical_pdf:
            instance.technical_specification_pdf = technical_pdf
        if installation_pdf:
            instance.installation_guide_pdf = installation_pdf
        instance.save()

        # Update compatible cars
        if compatible_car_ids is not None:
            instance.compatible_cars.all().delete()
            for car_id in compatible_car_ids:
                try:
                    car = Car.objects.get(id=car_id)
                    ProductCarCompatibility.objects.create(product=instance, car=car)
                except Car.DoesNotExist:
                    logger.warning('Car ID %s does not exist, skipping.', car_id)
                    continue

        # Update images
        if images:
            instance.images.all().delete()
            for image in images:
                ProductImage.objects.create(
                    product=instance,
                    image=image,
                    is_primary=not ProductImage.objects.filter(product=instance).exists()
                )

        return instance