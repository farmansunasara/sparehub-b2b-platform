from django import forms
from .models import Product, Category, Subcategory, Brand
from users.models import User

class ProductForm(forms.ModelForm):
    class Meta:
        model = Product
        fields = [
            'name', 'sku', 'brand', 'category', 'subcategory', 'manufacturer',
            'description', 'price', 'discount', 'stock_quantity',
            'min_order_quantity', 'max_order_quantity', 'shipping_cost',
            'weight', 'dimensions', 'material', 'color',
            'technical_specification_pdf', 'installation_guide_pdf',
            'is_active', 'is_featured'
        ]
        widgets = {
            'description': forms.Textarea(attrs={'rows': 4}),
            'is_active': forms.CheckboxInput(),
            'is_featured': forms.CheckboxInput(),
            'technical_specification_pdf': forms.FileInput(),
            'installation_guide_pdf': forms.FileInput(),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Filter active categories, subcategories, brands, and manufacturers
        self.fields['category'].queryset = Category.objects.filter(is_active=True)
        self.fields['subcategory'].queryset = Subcategory.objects.none()
        self.fields['brand'].queryset = Brand.objects.filter(is_active=True)
        self.fields['manufacturer'].queryset = User.objects.filter(role='manufacturer', is_active=True)
        self.fields['manufacturer'].required = True

        # Handle subcategory queryset based on category selection
        if 'category' in self.data:
            try:
                category_id = int(self.data.get('category'))
                self.fields['subcategory'].queryset = Subcategory.objects.filter(category_id=category_id, is_active=True)
            except (ValueError, TypeError):
                pass
        elif self.instance.pk and self.instance.category:
            self.fields['subcategory'].queryset = Subcategory.objects.filter(category=self.instance.category, is_active=True)

    def clean_sku(self):
        sku = self.cleaned_data.get('sku')
        instance = self.instance
        if Product.objects.exclude(pk=instance.pk if instance else None).filter(sku=sku).exists():
            raise forms.ValidationError("This SKU is already in use.")
        return sku

    def clean_technical_specification_pdf(self):
        pdf = self.cleaned_data.get('technical_specification_pdf')
        if pdf:
            if pdf.size > 5 * 1024 * 1024:  # 5MB limit
                raise forms.ValidationError("Technical specification PDF must be under 5MB.")
            if not pdf.name.lower().endswith('.pdf'):
                raise forms.ValidationError("Technical specification must be a PDF file.")
        return pdf

    def clean_installation_guide_pdf(self):
        pdf = self.cleaned_data.get('installation_guide_pdf')
        if pdf:
            if pdf.size > 5 * 1024 * 1024:  # 5MB limit
                raise forms.ValidationError("Installation guide PDF must be under 5MB.")
            if not pdf.name.lower().endswith('.pdf'):
                raise forms.ValidationError("Installation guide must be a PDF file.")
        return pdf

    def clean(self):
        cleaned_data = super().clean()
        price = cleaned_data.get('price')
        discount = cleaned_data.get('discount')
        stock_quantity = cleaned_data.get('stock_quantity')
        min_order_quantity = cleaned_data.get('min_order_quantity')
        max_order_quantity = cleaned_data.get('max_order_quantity')

        if price is not None and price < 0:
            self.add_error('price', 'Price cannot be negative.')
        if discount is not None and (discount < 0 or discount > 100):
            self.add_error('discount', 'Discount must be between 0 and 100.')
        if stock_quantity is not None and stock_quantity < 0:
            self.add_error('stock_quantity', 'Stock quantity cannot be negative.')
        if min_order_quantity is not None and min_order_quantity < 1:
            self.add_error('min_order_quantity', 'Minimum order quantity must be at least 1.')
        if max_order_quantity is not None and max_order_quantity < min_order_quantity:
            self.add_error('max_order_quantity', 'Maximum order quantity cannot be less than minimum order quantity.')
        return cleaned_data
    
    

class CategoryForm(forms.ModelForm):
    class Meta:
        model = Category
        fields = ['name', 'slug', 'image', 'is_active']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'mt-1 block w-full border border-gray-300 rounded-lg px-3 py-2'}),
            'slug': forms.TextInput(attrs={'class': 'mt-1 block w-full border border-gray-300 rounded-lg px-3 py-2'}),
            'image': forms.FileInput(attrs={'class': 'mt-1 block w-full border border-gray-300 rounded-lg px-3 py-2'}),
            'is_active': forms.CheckboxInput(attrs={'class': 'rounded border-gray-300 text-indigo-600'}),
        }

    def clean_slug(self):
        slug = self.cleaned_data['slug']
        if Category.objects.filter(slug=slug).exclude(pk=self.instance.pk).exists():
            raise forms.ValidationError("This slug is already in use.")
        return slug

class SubcategoryForm(forms.ModelForm):
    class Meta:
        model = Subcategory
        fields = ['category', 'name', 'slug', 'image', 'is_active']
        widgets = {
            'category': forms.Select(attrs={'class': 'mt-1 block w-full border border-gray-300 rounded-lg px-3 py-2'}),
            'name': forms.TextInput(attrs={'class': 'mt-1 block w-full border border-gray-300 rounded-lg px-3 py-2'}),
            'slug': forms.TextInput(attrs={'class': 'mt-1 block w-full border border-gray-300 rounded-lg px-3 py-2'}),
            'image': forms.FileInput(attrs={'class': 'mt-1 block w-full border border-gray-300 rounded-lg px-3 py-2'}),
            'is_active': forms.CheckboxInput(attrs={'class': 'rounded border-gray-300 text-indigo-600'}),
        }

    def clean(self):
        cleaned_data = super().clean()
        category = cleaned_data.get('category')
        name = cleaned_data.get('name')
        slug = cleaned_data.get('slug')
        if category and name:
            if Subcategory.objects.filter(category=category, name=name).exclude(pk=self.instance.pk).exists():
                raise forms.ValidationError("This subcategory name already exists for the selected category.")
        if slug and Subcategory.objects.filter(slug=slug).exclude(pk=self.instance.pk).exists():
            raise forms.ValidationError("This slug is already in use.")
        return cleaned_data

class BrandForm(forms.ModelForm):
    class Meta:
        model = Brand
        fields = ['name', 'logo', 'description', 'is_active']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'mt-1 block w-full border border-gray-300 rounded-lg px-3 py-2'}),
            'logo': forms.FileInput(attrs={'class': 'mt-1 block w-full border border-gray-300 rounded-lg px-3 py-2'}),
            'description': forms.Textarea(attrs={'class': 'mt-1 block w-full border border-gray-300 rounded-lg px-3 py-2', 'rows': 4}),
            'is_active': forms.CheckboxInput(attrs={'class': 'rounded border-gray-300 text-indigo-600'}),
        }

    def clean_name(self):
        name = self.cleaned_data['name']
        if Brand.objects.filter(name=name).exclude(pk=self.instance.pk).exists():
            raise forms.ValidationError("This brand name is already in use.")
        return name
    