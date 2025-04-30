from rest_framework import serializers
from .models import Product, Category, Subcategory, Brand, ProductImage
from users.models import User
import logging

# Set up logging
logger = logging.getLogger(__name__)

class CategorySerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()

    class Meta:
        model = Category
        fields = ['id', 'name', 'slug', 'image', 'is_active', 'created_at', 'updated_at']

    def get_image(self, obj):
        if obj.image:
            request = self.context.get('request')
            return request.build_absolute_uri(obj.image.url) if request else obj.image.url
        return None

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

class ProductImageSerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()

    class Meta:
        model = ProductImage
        fields = ['id', 'image', 'is_primary', 'created_at']

    def get_image(self, obj):
        if obj.image:
            request = self.context.get('request')
            return request.build_absolute_uri(obj.image.url) if request else obj.image.url
        return None

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
    
    # Explicitly define file fields
    technical_specification_pdf = serializers.FileField(required=False, allow_null=True)
    installation_guide_pdf = serializers.FileField(required=False, allow_null=True)

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
            'images'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'is_approved']

    def to_internal_value(self, data):
        # Log the incoming data for debugging
        logger.info(f"Received data in to_internal_value: {data}")

        # Convert string IDs to integers for multipart form data
        mutable_data = data.copy()
        for field in ['category_id', 'subcategory_id', 'brand_id', 'manufacturer']:
            if field in mutable_data and mutable_data[field]:
                try:
                    value = mutable_data[field]
                    if isinstance(value, list):
                        value = value[0]
                    mutable_data[field] = int(value)
                except (ValueError, TypeError) as e:
                    logger.error(f"Error converting {field} to integer: {value}, error: {str(e)}")
                    raise serializers.ValidationError({field: f'{field.replace("_id", "").title()} ID must be a valid integer.'})

        # Ensure numeric fields are properly converted
        for field in ['price', 'discount', 'weight', 'shipping_cost', 'stock_quantity', 'min_order_quantity', 'max_order_quantity']:
            if field in mutable_data and mutable_data[field]:
                try:
                    value = mutable_data[field]
                    if isinstance(value, list):
                        value = value[0]
                    mutable_data[field] = float(value)
                except (ValueError, TypeError) as e:
                    logger.error(f"Error converting {field} to float: {value}, error: {str(e)}")
                    raise serializers.ValidationError({field: f'{field.replace("_", " ").title()} must be a valid number.'})

        try:
            return super().to_internal_value(mutable_data)
        except Exception as e:
            logger.error(f"Error in to_internal_value: {str(e)}")
            raise serializers.ValidationError({'non_field_errors': [str(e)]})

    def validate(self, data):
        errors = {}
        
        try:
            logger.info('Validating product data: %s', data)
            
            manufacturer = data.get('manufacturer')
            if not manufacturer:
                errors['manufacturer'] = 'Manufacturer is required.'
            elif not hasattr(manufacturer, 'role') or manufacturer.role != 'manufacturer':
                errors['manufacturer'] = 'Invalid manufacturer or user is not a manufacturer.'
                logger.error('Invalid manufacturer role for user ID: %s', getattr(manufacturer, 'id', None))

            required_fields = {
                'name': 'Product name',
                'sku': 'SKU',
                'category': 'Category',
                'subcategory': 'Subcategory',
                'price': 'Price',
                'weight': 'Weight'
            }
            
            for field, label in required_fields.items():
                if field not in data or data[field] is None:
                    errors[field] = f'{label} is required.'
                    logger.error('Missing required field: %s', field)

            sku = data.get('sku')
            if sku:
                sku_query = Product.objects.filter(sku=sku)
                if self.instance:
                    sku_query = sku_query.exclude(id=self.instance.id)
                if sku_query.exists():
                    errors['sku'] = 'This SKU is already in use.'
                    logger.error('Duplicate SKU found: %s', sku)

            category = data.get('category')
            subcategory = data.get('subcategory')
            if category and subcategory:
                if subcategory.category_id != category.id:
                    errors['subcategory'] = 'Selected subcategory does not belong to the selected category.'
                    logger.error(
                        'Category mismatch - Category: %s, Subcategory: %s',
                        category.id,
                        subcategory.id
                    )

            numeric_fields = {
                'price': ('Price', 0),
                'weight': ('Weight', 0),
                'stock_quantity': ('Stock quantity', 0),
                'min_order_quantity': ('Minimum order quantity', 1),
            }

            for field, (label, min_value) in numeric_fields.items():
                value = data.get(field)
                if value is not None and float(value) < min_value:
                    errors[field] = f'{label} must be greater than or equal to {min_value}.'
                    logger.error('Invalid %s value: %s', field, value)

            max_order = data.get('max_order_quantity')
            min_order = data.get('min_order_quantity')
            if max_order is not None and min_order is not None:
                if max_order < min_order:
                    errors['max_order_quantity'] = 'Maximum order quantity must be greater than minimum order quantity.'
                    logger.error('Invalid order quantity range: min=%s, max=%s', min_order, max_order)

            if errors:
                logger.error(f"Validation errors: {errors}")
                raise serializers.ValidationError(errors)

            return data

        except Exception as e:
            logger.error('Unexpected error during product validation: %s', str(e))
            raise serializers.ValidationError({
                'non_field_errors': ['An unexpected error occurred while validating the product: %s' % str(e)]
            })

    def create(self, validated_data):
        from django.db import transaction
        
        try:
            with transaction.atomic():
                manufacturer = validated_data.pop('manufacturer')
                technical_pdf = validated_data.pop('technical_specification_pdf', None)
                installation_pdf = validated_data.pop('installation_guide_pdf', None)
                
                request_files = self.context.get('request').FILES
                images = request_files.getlist('images', [])
                technical_pdf = request_files.get('technical_specification_pdf', technical_pdf)
                installation_pdf = request_files.get('installation_guide_pdf', installation_pdf)

                for image in images:
                    if not image.content_type.startswith('image/'):
                        raise serializers.ValidationError({
                            'images': f'Invalid file type for {image.name}. Only images are allowed.'
                        })

                for pdf in [technical_pdf, installation_pdf]:
                    if pdf and not pdf.content_type == 'application/pdf':
                        raise serializers.ValidationError({
                            'pdf': f'Invalid file type for {pdf.name}. Only PDF files are allowed.'
                        })

                logger.info(
                    'Creating product: manufacturer=%s, sku=%s',
                    manufacturer.id,
                    validated_data.get('sku')
                )

                product = Product.objects.create(
                    manufacturer=manufacturer,
                    technical_specification_pdf=technical_pdf,
                    installation_guide_pdf=installation_pdf,
                    **validated_data
                )

                if images:
                    image_objects = []
                    for index, image in enumerate(images):
                        image_objects.append(
                            ProductImage(
                                product=product,
                                image=image,
                                is_primary=(index == 0)
                            )
                        )
                    ProductImage.objects.bulk_create(image_objects)

                logger.info(
                    'Product created successfully: id=%s, sku=%s',
                    product.id,
                    product.sku
                )

                return product

        except Exception as e:
            logger.error(
                'Failed to create product: %s\nData: %s',
                str(e),
                validated_data
            )
            raise serializers.ValidationError({
                'non_field_errors': [
                    'Failed to create product: %s' % str(e)
                ]
            })

    def update(self, instance, validated_data):
        from django.db import transaction
        
        try:
            with transaction.atomic():
                request_files = self.context.get('request').FILES
                images = request_files.getlist('images', [])
                technical_pdf = validated_data.pop('technical_specification_pdf', request_files.get('technical_specification_pdf', None))
                installation_pdf = validated_data.pop('installation_guide_pdf', request_files.get('installation_guide_pdf', None))

                for image in images:
                    if not image.content_type.startswith('image/'):
                        raise serializers.ValidationError({
                            'images': f'Invalid file type for {image.name}. Only images are allowed.'
                        })

                for pdf in [technical_pdf, installation_pdf]:
                    if pdf and not pdf.content_type == 'application/pdf':
                        raise serializers.ValidationError({
                            'pdf': f'Invalid file type for {pdf.name}. Only PDF files are allowed.'
                        })

                logger.info(
                    'Updating product: id=%s, sku=%s',
                    instance.id,
                    instance.sku
                )

                for attr, value in validated_data.items():
                    setattr(instance, attr, value)

                if technical_pdf:
                    instance.technical_specification_pdf = technical_pdf
                if installation_pdf:
                    instance.installation_guide_pdf = installation_pdf

                instance.save()

                if images:
                    instance.images.all().delete()
                    
                    image_objects = []
                    for index, image in enumerate(images):
                        image_objects.append(
                            ProductImage(
                                product=instance,
                                image=image,
                                is_primary=(index == 0)
                            )
                        )
                    ProductImage.objects.bulk_create(image_objects)

                logger.info(
                    'Product updated successfully: id=%s, sku=%s',
                    instance.id,
                    instance.sku
                )

                return instance

        except Exception as e:
            logger.error(
                'Failed to update product: %s\nProduct ID: %s\nData: %s',
                str(e),
                instance.id,
                validated_data
            )
            raise serializers.ValidationError({
                'non_field_errors': [
                    'Failed to update product: %s' % str(e)
                ]
            })