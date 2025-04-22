from rest_framework import serializers
from .models import Product, Category, Subcategory, Brand, ProductImage
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



class ProductImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductImage
        fields = ['id', 'image', 'is_primary', 'created_at']



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

    def validate(self, data):
        """
        Validate product data with improved error handling
        """
        errors = {}
        
        try:
            # Log incoming data
            logger.info('Validating product data: %s', data)
            
            # Check manufacturer role first
            manufacturer = data.get('manufacturer')
            if not manufacturer:
                errors['manufacturer'] = 'Manufacturer is required.'
            elif not hasattr(manufacturer, 'role') or manufacturer.role != 'manufacturer':
                errors['manufacturer'] = 'Invalid manufacturer or user is not a manufacturer.'
                logger.error('Invalid manufacturer role for user ID: %s', getattr(manufacturer, 'id', None))

            # Validate required fields
            required_fields = {
                'name': 'Product name',
                'sku': 'SKU',
                'category_id': 'Category',
                'subcategory_id': 'Subcategory',
                'price': 'Price',
                'weight': 'Weight'
            }
            
            for field, label in required_fields.items():
                if field not in data or data[field] is None:
                    errors[field] = f'{label} is required.'
                    logger.error('Missing required field: %s', field)

            # Validate SKU uniqueness
            sku = data.get('sku')
            if sku:
                sku_query = Product.objects.filter(sku=sku)
                if self.instance:
                    sku_query = sku_query.exclude(id=self.instance.id)
                if sku_query.exists():
                    errors['sku'] = 'This SKU is already in use.'
                    logger.error('Duplicate SKU found: %s', sku)

            # Validate category and subcategory relationship
            category = data.get('category_id')
            subcategory = data.get('subcategory_id')
            if category and subcategory:
                if subcategory.category_id != category.id:
                    errors['subcategory_id'] = 'Selected subcategory does not belong to the selected category.'
                    logger.error(
                        'Category mismatch - Category: %s, Subcategory: %s',
                        category.id,
                        subcategory.id
                    )

            # Validate numeric fields
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

            # Validate max order quantity
            max_order = data.get('max_order_quantity')
            min_order = data.get('min_order_quantity')
            if max_order is not None and min_order is not None:
                if max_order < min_order:
                    errors['max_order_quantity'] = 'Maximum order quantity must be greater than minimum order quantity.'
                    logger.error('Invalid order quantity range: min=%s, max=%s', min_order, max_order)

            if errors:
                raise serializers.ValidationError(errors)

            return data

        except Exception as e:
            logger.error('Unexpected error during product validation: %s', str(e))
            raise serializers.ValidationError({
                'non_field_errors': ['An unexpected error occurred while validating the product.']
            })

    def create(self, validated_data):
        from django.db import transaction
        
        try:
            with transaction.atomic():
                # Extract data that needs special handling
                manufacturer = validated_data.pop('manufacturer')
                
                # Get files from request context
                request_files = self.context.get('request').FILES
                images = request_files.getlist('images', [])
                technical_pdf = request_files.get('technical_specification_pdf')
                installation_pdf = request_files.get('installation_guide_pdf')

                # Validate file types
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

                # Log the creation attempt
                logger.info(
                    'Creating product: manufacturer=%s, sku=%s',
                    manufacturer.id,
                    validated_data.get('sku')
                )

                # Create the product
                product = Product.objects.create(
                    manufacturer=manufacturer,
                    technical_specification_pdf=technical_pdf,
                    installation_guide_pdf=installation_pdf,
                    **validated_data
                )

              
                # Add images
                if images:
                    image_objects = []
                    for index, image in enumerate(images):
                        image_objects.append(
                            ProductImage(
                                product=product,
                                image=image,
                                is_primary=(index == 0)  # First image is primary
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
                    'Failed to create product. Please try again.'
                ]
            })

    def update(self, instance, validated_data):
        from django.db import transaction
        
        try:
            with transaction.atomic():
                # Extract data that needs special handling
                
                # Get files from request context
                request_files = self.context.get('request').FILES
                images = request_files.getlist('images', [])
                technical_pdf = request_files.get('technical_specification_pdf')
                installation_pdf = request_files.get('installation_guide_pdf')

                # Validate file types
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

                # Log the update attempt
                logger.info(
                    'Updating product: id=%s, sku=%s',
                    instance.id,
                    instance.sku
                )

                # Update product fields
                for attr, value in validated_data.items():
                    setattr(instance, attr, value)

                # Update PDFs if provided
                if technical_pdf:
                    instance.technical_specification_pdf = technical_pdf
                if installation_pdf:
                    instance.installation_guide_pdf = installation_pdf

                instance.save()

               
                # Update images if provided
                if images:
                    # Delete existing images
                    instance.images.all().delete()
                    
                    # Add new images
                    image_objects = []
                    for index, image in enumerate(images):
                        image_objects.append(
                            ProductImage(
                                product=instance,
                                image=image,
                                is_primary=(index == 0)  # First image is primary
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
                    'Failed to update product. Please try again.'
                ]
            })
