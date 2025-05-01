from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib.auth import authenticate, login, logout as auth_logout
from django.db.models import Count, Sum, Avg, Q
from django.db.models.functions import TruncDate
from django.contrib import messages
from django.http import JsonResponse, HttpResponse
from users.models import User, Manufacturer, Shop
from products.models import Product, Category, Brand, ProductImage, Subcategory
from orders.models import Order, OrderStatus, OrderStatusUpdate
from settings.models import Setting
from products.forms import ProductForm, CategoryForm, SubcategoryForm, BrandForm
from django.core.paginator import Paginator
from django.contrib.auth.forms import UserCreationForm
from django import forms
from django.utils import timezone
import json
import smtplib
from email.mime.text import MIMEText
from datetime import datetime, timedelta
import csv

# Form for user creation
class CustomUserCreationForm(UserCreationForm):
    role = forms.ChoiceField(
        choices=[
            ('admin', 'Admin'),
            ('manufacturer', 'Manufacturer'),
            ('shop', 'Shop'),
        ],
        required=True,
        label="Role"
    )
    # Manufacturer fields
    company_name = forms.CharField(max_length=255, required=False, label="Company Name")
    manufacturer_contact_name = forms.CharField(max_length=255, required=False, label="Contact Name")
    manufacturer_phone = forms.CharField(max_length=20, required=False, label="Phone")
    manufacturer_gst = forms.CharField(max_length=50, required=False, label="GST Number")
    manufacturer_address = forms.CharField(widget=forms.Textarea, required=False, label="Address")
    manufacturer_city = forms.CharField(max_length=100, required=False, label="City")
    manufacturer_state = forms.CharField(max_length=100, required=False, label="State")
    manufacturer_country = forms.CharField(max_length=100, required=False, label="Country")
    manufacturer_logo = forms.URLField(required=False, label="Logo URL")
    # Shop fields
    shop_name = forms.CharField(max_length=255, required=False, label="Shop Name")
    shop_contact_name = forms.CharField(max_length=255, required=False, label="Contact Name")
    shop_phone = forms.CharField(max_length=20, required=False, label="Phone")
    shop_gst = forms.CharField(max_length=50, required=False, label="GST Number")
    shop_address = forms.CharField(widget=forms.Textarea, required=False, label="Address")
    shop_city = forms.CharField(max_length=100, required=False, label="City")
    shop_state = forms.CharField(max_length=100, required=False, label="State")
    shop_country = forms.CharField(max_length=100, required=False, label="Country")
    shop_logo = forms.URLField(required=False, label="Logo URL")

    class Meta:
        model = User
        fields = ['username', 'email', 'password1', 'password2', 'role']

    def clean(self):
        cleaned_data = super().clean()
        role = cleaned_data.get('role')
        if role == 'manufacturer':
            required_fields = ['company_name', 'manufacturer_contact_name', 'manufacturer_phone', 'manufacturer_address', 'manufacturer_city', 'manufacturer_state', 'manufacturer_country']
            for field in required_fields:
                if not cleaned_data.get(field):
                    self.add_error(field, 'This field is required for manufacturers.')
        elif role == 'shop':
            required_fields = ['shop_name', 'shop_contact_name', 'shop_phone', 'shop_address', 'shop_city', 'shop_state', 'shop_country']
            for field in required_fields:
                if not cleaned_data.get(field):
                    self.add_error(field, 'This field is required for shops.')
        return cleaned_data

    def save(self, commit=True):
        user = super().save(commit=False)
        user.role = self.cleaned_data['role']
        if commit:
            user.save()
            if user.role == 'manufacturer':
                Manufacturer.objects.create(
                    user=user,
                    company_name=self.cleaned_data['company_name'],
                    contact_name=self.cleaned_data['manufacturer_contact_name'],
                    phone=self.cleaned_data['manufacturer_phone'],
                    gst=self.cleaned_data['manufacturer_gst'],
                    address=self.cleaned_data['manufacturer_address'],
                    city=self.cleaned_data['manufacturer_city'],
                    state=self.cleaned_data['manufacturer_state'],
                    country=self.cleaned_data['manufacturer_country'],
                    logo=self.cleaned_data['manufacturer_logo'],
                )
            elif user.role == 'shop':
                Shop.objects.create(
                    user=user,
                    shop_name=self.cleaned_data['shop_name'],
                    contact_name=self.cleaned_data['shop_contact_name'],
                    phone=self.cleaned_data['shop_phone'],
                    gst=self.cleaned_data['shop_gst'],
                    address=self.cleaned_data['shop_address'],
                    city=self.cleaned_data['shop_city'],
                    state=self.cleaned_data['shop_state'],
                    country=self.cleaned_data['shop_country'],
                    logo=self.cleaned_data['shop_logo'],
                )
        return user

# Form for user editing
class UserEditForm(forms.ModelForm):
    role = forms.ChoiceField(
        choices=[
            ('admin', 'Admin'),
            ('manufacturer', 'Manufacturer'),
            ('shop', 'Shop'),
        ],
        required=True,
        label="Role"
    )
    # Manufacturer fields
    company_name = forms.CharField(max_length=255, required=False, label="Company Name")
    manufacturer_contact_name = forms.CharField(max_length=255, required=False, label="Contact Name")
    manufacturer_phone = forms.CharField(max_length=20, required=False, label="Phone")
    manufacturer_gst = forms.CharField(max_length=50, required=False, label="GST Number")
    manufacturer_address = forms.CharField(widget=forms.Textarea, required=False, label="Address")
    manufacturer_city = forms.CharField(max_length=100, required=False, label="City")
    manufacturer_state = forms.CharField(max_length=100, required=False, label="State")
    manufacturer_country = forms.CharField(max_length=100, required=False, label="Country")
    manufacturer_logo = forms.URLField(required=False, label="Logo URL")
    # Shop fields
    shop_name = forms.CharField(max_length=255, required=False, label="Shop Name")
    shop_contact_name = forms.CharField(max_length=255, required=False, label="Contact Name")
    shop_phone = forms.CharField(max_length=20, required=False, label="Phone")
    shop_gst = forms.CharField(max_length=50, required=False, label="GST Number")
    shop_address = forms.CharField(widget=forms.Textarea, required=False, label="Address")
    shop_city = forms.CharField(max_length=100, required=False, label="City")
    shop_state = forms.CharField(max_length=100, required=False, label="State")
    shop_country = forms.CharField(max_length=100, required=False, label="Country")
    shop_logo = forms.URLField(required=False, label="Logo URL")

    class Meta:
        model = User
        fields = ['username', 'email', 'role']

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if self.instance.role == 'manufacturer' and hasattr(self.instance, 'manufacturer_profile'):
            profile = self.instance.manufacturer_profile
            self.initial['company_name'] = profile.company_name
            self.initial['manufacturer_contact_name'] = profile.contact_name
            self.initial['manufacturer_phone'] = profile.phone
            self.initial['manufacturer_gst'] = profile.gst
            self.initial['manufacturer_address'] = profile.address
            self.initial['manufacturer_city'] = profile.city
            self.initial['manufacturer_state'] = profile.state
            self.initial['manufacturer_country'] = profile.country
            self.initial['manufacturer_logo'] = profile.logo
        elif self.instance.role == 'shop' and hasattr(self.instance, 'shop_profile'):
            profile = self.instance.shop_profile
            self.initial['shop_name'] = profile.shop_name
            self.initial['shop_contact_name'] = profile.contact_name
            self.initial['shop_phone'] = profile.phone
            self.initial['shop_gst'] = profile.gst
            self.initial['shop_address'] = profile.address
            self.initial['shop_city'] = profile.city
            self.initial['shop_state'] = profile.state
            self.initial['shop_country'] = profile.country
            self.initial['shop_logo'] = profile.logo

    def save(self, commit=True):
        user = super().save(commit=False)
        user.role = self.cleaned_data['role']
        if commit:
            user.save()
            if user.role == 'manufacturer':
                Manufacturer.objects.update_or_create(
                    user=user,
                    defaults={
                        'company_name': self.cleaned_data['company_name'],
                        'contact_name': self.cleaned_data['manufacturer_contact_name'],
                        'phone': self.cleaned_data['manufacturer_phone'],
                        'gst': self.cleaned_data['manufacturer_gst'],
                        'address': self.cleaned_data['manufacturer_address'],
                        'city': self.cleaned_data['manufacturer_city'],
                        'state': self.cleaned_data['manufacturer_state'],
                        'country': self.cleaned_data['manufacturer_country'],
                        'logo': self.cleaned_data['manufacturer_logo'],
                    }
                )
                Shop.objects.filter(user=user).delete()
            elif user.role == 'shop':
                Shop.objects.update_or_create(
                    user=user,
                    defaults={
                        'shop_name': self.cleaned_data['shop_name'],
                        'contact_name': self.cleaned_data['shop_contact_name'],
                        'phone': self.cleaned_data['shop_phone'],
                        'gst': self.cleaned_data['shop_gst'],
                        'address': self.cleaned_data['shop_address'],
                        'city': self.cleaned_data['shop_city'],
                        'state': self.cleaned_data['shop_state'],
                        'country': self.cleaned_data['shop_country'],
                        'logo': self.cleaned_data['shop_logo'],
                    }
                )
                Manufacturer.objects.filter(user=user).delete()
            else:
                Manufacturer.objects.filter(user=user).delete()
                Shop.objects.filter(user=user).delete()
        return user

# Authentication Views
def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        if user is not None and user.is_staff:
            login(request, user)
            return redirect('custom_admin:dashboard')
    return render(request, 'custom_admin/login.html')

@login_required
def logout_view(request):
    if request.method == 'POST':
        auth_logout(request)
        messages.success(request, 'You have been logged out successfully.')
        return redirect('custom_admin:login')
    return render(request, 'custom_admin/logout_confirm.html')

# Dashboard and Analytics Views
@login_required
def dashboard(request):
    total_users = User.objects.count()
    total_products = Product.objects.count()
    total_orders = Order.objects.count()
    revenue = Order.objects.filter(
        status='delivered'
    ).aggregate(
        total_revenue=Sum('total')
    )['total_revenue'] or 0
    recent_orders = Order.objects.select_related('user').order_by('-created_at')[:10]
    end_date = timezone.now()
    start_date = end_date - timedelta(days=6)
    daily_sales = Order.objects.filter(
        created_at__range=[start_date, end_date]
    ).annotate(
        date=TruncDate('created_at')
    ).values('date').annotate(
        total=Sum('total')
    ).order_by('date')
    sales_labels = [d['date'].strftime('%b %d') for d in daily_sales]
    sales_data = [float(d['total']) for d in daily_sales]
    completed_orders = Order.objects.filter(
        status__in=['delivered', 'shipped']
    )
    product_counts = {}
    for order in completed_orders:
        for item in order.items:
            product_id = item.get('product_id')
            quantity = item.get('quantity', 1)
            if product_id:
                if product_id in product_counts:
                    product_counts[product_id] += quantity
                else:
                    product_counts[product_id] = quantity
    top_product_ids = sorted(product_counts.items(), key=lambda x: x[1], reverse=True)[:5]
    top_products = []
    product_labels = []
    product_data = []
    for product_id, count in top_product_ids:
        try:
            product = Product.objects.get(id=product_id)
            top_products.append(product)
            product_labels.append(product.name)
            product_data.append(count)
        except Product.DoesNotExist:
            continue
    context = {
        'total_users': total_users,
        'total_products': total_products,
        'total_orders': total_orders,
        'revenue': revenue,
        'recent_orders': recent_orders,
        'sales_labels': json.dumps(sales_labels),
        'sales_data': json.dumps(sales_data),
        'product_labels': json.dumps(product_labels),
        'product_data': json.dumps(product_data),
    }
    return render(request, 'custom_admin/dashboard.html', context)

@login_required
def analytics(request):
    end_date = timezone.now()
    start_date = end_date - timedelta(days=30)
    sales_data = Order.objects.filter(
        created_at__range=[start_date, end_date],
        status__in=['delivered', 'shipped']
    ).annotate(
        date=TruncDate('created_at')
    ).values('date').annotate(
        total=Sum('total'),
        count=Count('id')
    ).order_by('date')
    date_range = [(start_date + timedelta(days=x)).date() for x in range(31)]
    sales_by_date = {item['date']: item for item in sales_data}
    filled_sales_data = []
    for date in date_range:
        if date in sales_by_date:
            filled_sales_data.append({
                'date': date,
                'total': float(sales_by_date[date]['total']),
                'count': sales_by_date[date]['count']
            })
        else:
            filled_sales_data.append({
                'date': date,
                'total': 0,
                'count': 0
            })
    completed_orders = Order.objects.filter(
        status__in=['delivered', 'shipped']
    )
    product_counts = {}
    product_revenue = {}
    for order in completed_orders:
        for item in order.items:
            product_id = item.get('product_id')
            quantity = item.get('quantity', 1)
            total = item.get('total', 0)
            if product_id:
                if product_id in product_counts:
                    product_counts[product_id] += quantity
                    product_revenue[product_id] += total
                else:
                    product_counts[product_id] = quantity
                    product_revenue[product_id] = total
    top_product_ids = sorted(product_counts.items(), key=lambda x: x[1], reverse=True)[:10]
    product_labels = []
    product_values = []
    for product_id, count in top_product_ids:
        try:
            product = Product.objects.get(id=product_id)
            product_labels.append(product.name)
            product_values.append(count)
        except Product.DoesNotExist:
            continue
    sales_labels = [item['date'].strftime('%b %d') for item in filled_sales_data]
    sales_values = [item['total'] for item in filled_sales_data]
    total_orders = Order.objects.count()
    total_revenue = Order.objects.filter(
        status__in=['delivered', 'shipped']
    ).aggregate(
        total=Sum('total')
    )['total'] or 0
    avg_order_value = Order.objects.filter(
        status__in=['delivered', 'shipped']
    ).aggregate(
        avg=Avg('total')
    )['avg'] or 0
    context = {
        'sales_labels': json.dumps(sales_labels),
        'sales_data': json.dumps(sales_values),
        'product_labels': json.dumps(product_labels),
        'product_data': json.dumps(product_values),
        'total_orders': total_orders,
        'total_revenue': total_revenue,
        'avg_order_value': avg_order_value,
        'start_date': start_date,
        'end_date': end_date,
    }
    return render(request, 'custom_admin/analytics.html', context)

# User Management Views
@login_required
def user_list(request):
    users = User.objects.all().prefetch_related('manufacturer_profile', 'shop_profile')
    search_query = request.GET.get('search', '')
    if search_query:
        users = users.filter(
            Q(username__icontains=search_query) |
            Q(email__icontains=search_query) |
            Q(manufacturer_profile__company_name__icontains=search_query) |
            Q(shop_profile__shop_name__icontains=search_query)
        )
    role_filter = request.GET.get('role', '')
    if role_filter:
        users = users.filter(role=role_filter)
    status_filter = request.GET.get('status', '')
    if status_filter == 'active':
        users = users.filter(is_active=True)
    elif status_filter == 'inactive':
        users = users.filter(is_active=False)
    users = users.order_by('-created_at')
    paginator = Paginator(users, 10)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    context = {
        'users': page_obj,
        'search_query': search_query,
        'role_filter': role_filter,
        'status_filter': status_filter,
        'page_obj': page_obj,
    }
    return render(request, 'custom_admin/user_list.html', context)

@login_required
def user_detail(request, pk):
    user = get_object_or_404(User, pk=pk)
    activities = [
        {'type': 'account_created', 'description': 'Account created', 'timestamp': user.created_at},
        {'type': 'profile_updated', 'description': 'Profile updated', 'timestamp': user.updated_at},
        {'type': 'status_changed', 'description': f'Status changed to {"Active" if user.is_active else "Inactive"}', 'timestamp': user.updated_at},
    ]
    context = {
        'user': user,
        'activities': activities,
    }
    return render(request, 'custom_admin/user_detail.html', context)

@login_required
def user_toggle_status(request, pk):
    user = get_object_or_404(User, pk=pk)
    user.is_active = not user.is_active
    user.save()
    status = 'activated' if user.is_active else 'deactivated'
    messages.success(request, f'User {status} successfully.')
    return redirect('custom_admin:user_detail', pk=pk)

@login_required
def user_delete(request, pk):
    user = get_object_or_404(User, pk=pk)
    if request.method == 'POST':
        user.delete()
        messages.success(request, 'User deleted successfully.')
        return redirect('custom_admin:users')
    return render(request, 'custom_admin/user_confirm_delete.html', {'user': user})

@login_required
def user_create(request):
    if request.method == 'POST':
        form = CustomUserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            messages.success(request, f'User {user.username} created successfully.')
            return redirect('custom_admin:users')
    else:
        form = CustomUserCreationForm()
    context = {
        'form': form,
        'action': 'Create',
    }
    return render(request, 'custom_admin/user_form.html', context)

@login_required
def user_edit(request, pk):
    user = get_object_or_404(User, pk=pk)
    if request.method == 'POST':
        form = UserEditForm(request.POST, instance=user)
        if form.is_valid():
            user = form.save()
            messages.success(request, f'User {user.username} updated successfully.')
            return redirect('custom_admin:user_detail', pk=pk)
    else:
        form = UserEditForm(instance=user)
    context = {
        'form': form,
        'action': 'Edit',
        'user': user,
    }
    return render(request, 'custom_admin/user_form.html', context)

# Product Management Views
@login_required
def product_list(request):
    products = Product.objects.select_related(
        'category', 'subcategory', 'brand', 'manufacturer'
    ).prefetch_related('images').order_by('-created_at')
    categories = Category.objects.filter(is_active=True)
    brands = Brand.objects.filter(is_active=True)
    paginator = Paginator(products, 10)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    context = {
        'products': page_obj,
        'categories': categories,
        'brands': brands,
    }
    return render(request, 'custom_admin/product_list.html', context)

@login_required
def product_detail(request, pk):
    product = get_object_or_404(
        Product.objects.select_related(
            'category', 'subcategory', 'brand', 'manufacturer'
        ).prefetch_related('images'),
        pk=pk
    )
    context = {
        'product': product,
    }
    return render(request, 'custom_admin/product_detail.html', context)

@login_required
def product_create(request):
    if request.method == 'POST':
        form = ProductForm(request.POST, request.FILES)
        if form.is_valid():
            product = form.save()
            images = request.FILES.getlist('images')
            for image in images:
                if image.size > 2 * 1024 * 1024:
                    messages.error(request, 'Image file size must be under 2MB.')
                    return render(request, 'custom_admin/product_form.html', {
                        'form': form,
                        'categories': Category.objects.filter(is_active=True),
                        'brands': Brand.objects.filter(is_active=True),
                        'manufacturers': User.objects.filter(role='manufacturer', is_active=True),
                    })
                if not image.name.lower().endswith(('.png', '.jpg', '.jpeg')):
                    messages.error(request, 'Images must be PNG or JPG files.')
                    return render(request, 'custom_admin/product_form.html', {
                        'form': form,
                        'categories': Category.objects.filter(is_active=True),
                        'brands': Brand.objects.filter(is_active=True),
                        'manufacturers': User.objects.filter(role='manufacturer', is_active=True),
                    })
                ProductImage.objects.create(
                    product=product,
                    image=image,
                    is_primary=not product.images.exists()
                )
            messages.success(request, f'Product {product.name} created successfully.')
            return redirect('custom_admin:products')
        else:
            messages.error(request, 'Please correct the errors below.')
    else:
        form = ProductForm()
    categories = Category.objects.filter(is_active=True)
    brands = Brand.objects.filter(is_active=True)
    manufacturers = User.objects.filter(role='manufacturer', is_active=True)
    context = {
        'form': form,
        'categories': categories,
        'brands': brands,
        'manufacturers': manufacturers,
    }
    return render(request, 'custom_admin/product_form.html', context)

@login_required
def product_edit(request, pk):
    product = get_object_or_404(Product, pk=pk)
    if request.method == 'POST':
        form = ProductForm(request.POST, request.FILES, instance=product)
        if form.is_valid():
            product = form.save()
            images = request.FILES.getlist('images')
            for image in images:
                if image.size > 2 * 1024 * 1024:
                    messages.error(request, 'Image file size must be under 2MB.')
                    return render(request, 'custom_admin/product_form.html', {
                        'form': form,
                        'product': product,
                        'categories': Category.objects.filter(is_active=True),
                        'brands': Brand.objects.filter(is_active=True),
                        'manufacturers': User.objects.filter(role='manufacturer', is_active=True),
                    })
                if not image.name.lower().endswith(('.png', '.jpg', '.jpeg')):
                    messages.error(request, 'Images must be PNG or JPG files.')
                    return render(request, 'custom_admin/product_form.html', {
                        'form': form,
                        'product': product,
                        'categories': Category.objects.filter(is_active=True),
                        'brands': Brand.objects.filter(is_active=True),
                        'manufacturers': User.objects.filter(role='manufacturer', is_active=True),
                    })
                ProductImage.objects.create(
                    product=product,
                    image=image,
                    is_primary=not product.images.exists()
                )
            messages.success(request, f'Product {product.name} updated successfully.')
            return redirect('custom_admin:product_detail', pk=pk)
        else:
            messages.error(request, 'Please correct the errors below.')
    else:
        form = ProductForm(instance=product)
    categories = Category.objects.filter(is_active=True)
    brands = Brand.objects.filter(is_active=True)
    manufacturers = User.objects.filter(role='manufacturer', is_active=True)
    context = {
        'form': form,
        'product': product,
        'categories': categories,
        'brands': brands,
        'manufacturers': manufacturers,
    }
    return render(request, 'custom_admin/product_form.html', context)

@login_required
def product_delete(request, pk):
    product = get_object_or_404(Product, pk=pk)
    if request.method == 'POST':
        product.delete()
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
            return JsonResponse({'success': True, 'message': 'Product deleted successfully.'})
        messages.success(request, 'Product deleted successfully.')
        return redirect('custom_admin:products')
    return render(request, 'custom_admin/product_confirm_delete.html', {'product': product})

@login_required
def product_toggle_status(request, pk):
    product = get_object_or_404(Product, pk=pk)
    product.is_active = not product.is_active
    product.save()
    status = 'activated' if product.is_active else 'deactivated'
    messages.success(request, f'Product {status} successfully.')
    return redirect('custom_admin:product_detail', pk=pk)

@login_required
def product_toggle_featured(request, pk):
    product = get_object_or_404(Product, pk=pk)
    product.is_featured = not product.is_featured
    product.save()
    status = 'marked as featured' if product.is_featured else 'removed from featured'
    messages.success(request, f'Product {status} successfully.')
    return redirect('custom_admin:product_detail', pk=pk)

@login_required
def product_image_upload(request, pk):
    product = get_object_or_404(Product, pk=pk)
    if request.method == 'POST' and request.FILES.get('image'):
        image = request.FILES['image']
        if image.size > 2 * 1024 * 1024:
            return JsonResponse({'success': False, 'error': 'Image file size must be under 2MB.'}, status=400)
        if not image.name.lower().endswith(('.png', '.jpg', '.jpeg')):
            return JsonResponse({'success': False, 'error': 'Image must be a PNG or JPG file.'}, status=400)
        image_obj = ProductImage.objects.create(
            product=product,
            image=image,
            is_primary=not product.images.exists()
        )
        return JsonResponse({
            'success': True,
            'image_id': image_obj.id,
            'image_url': image_obj.image.url
        })
    return JsonResponse({'success': False, 'error': 'No image provided.'}, status=400)

@login_required
def product_image_delete(request, pk, image_id):
    image = get_object_or_404(ProductImage, pk=image_id, product_id=pk)
    image.delete()
    return JsonResponse({'success': True})

@login_required
def product_image_set_primary(request, pk, image_id):
    product = get_object_or_404(Product, pk=pk)
    image = get_object_or_404(ProductImage, pk=image_id, product=product)
    product.images.update(is_primary=False)
    image.is_primary = True
    image.save()
    return JsonResponse({'success': True})

# Category Management Views
@login_required
def category_list(request):
    categories = Category.objects.all().order_by('-created_at')
    search_query = request.GET.get('search', '')
    if search_query:
        categories = categories.filter(name__icontains=search_query)
    status_filter = request.GET.get('status', '')
    if status_filter == 'active':
        categories = categories.filter(is_active=True)
    elif status_filter == 'inactive':
        categories = categories.filter(is_active=False)
    paginator = Paginator(categories, 10)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    context = {
        'categories': page_obj,
        'search_query': search_query,
        'status_filter': status_filter,
    }
    return render(request, 'custom_admin/category_list.html', context)

@login_required
def category_detail(request, pk):
    category = get_object_or_404(Category, pk=pk)
    context = {
        'category': category,
    }
    return render(request, 'custom_admin/category_detail.html', context)

@login_required
def category_create(request):
    if request.method == 'POST':
        form = CategoryForm(request.POST, request.FILES)
        if form.is_valid():
            category = form.save()
            messages.success(request, f'Category {category.name} created successfully.')
            return redirect('custom_admin:categories')
        else:
            messages.error(request, 'Please correct the errors below.')
    else:
        form = CategoryForm()
    context = {
        'form': form,
        'action': 'Create',
    }
    return render(request, 'custom_admin/category_form.html', context)

@login_required
def category_edit(request, pk):
    category = get_object_or_404(Category, pk=pk)
    if request.method == 'POST':
        form = CategoryForm(request.POST, request.FILES, instance=category)
        if form.is_valid():
            category = form.save()
            messages.success(request, f'Category {category.name} updated successfully.')
            return redirect('custom_admin:category_detail', pk=pk)
        else:
            messages.error(request, 'Please correct the errors below.')
    else:
        form = CategoryForm(instance=category)
    context = {
        'form': form,
        'category': category,
        'action': 'Edit',
    }
    return render(request, 'custom_admin/category_form.html', context)

@login_required
def category_delete(request, pk):
    category = get_object_or_404(Category, pk=pk)
    if request.method == 'POST':
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
            try:
                category.delete()
                return JsonResponse({'success': True, 'message': 'Category deleted successfully.'})
            except Exception as e:
                return JsonResponse({'success': False, 'message': str(e)}, status=400)
        category.delete()
        messages.success(request, 'Category deleted successfully.')
        return redirect('custom_admin:categories')
    return render(request, 'custom_admin/category_confirm_delete.html', {'category': category})

# Subcategory Management Views
@login_required
def subcategory_list(request):
    subcategories = Subcategory.objects.select_related('category').order_by('-created_at')
    search_query = request.GET.get('search', '')
    if search_query:
        subcategories = subcategories.filter(
            Q(name__icontains=search_query) | Q(category__name__icontains=search_query)
        )
    status_filter = request.GET.get('status', '')
    if status_filter == 'active':
        subcategories = subcategories.filter(is_active=True)
    elif status_filter == 'inactive':
        subcategories = subcategories.filter(is_active=False)
    category_filter = request.GET.get('category', '')
    if category_filter:
        subcategories = subcategories.filter(category__id=category_filter)
    categories = Category.objects.filter(is_active=True)
    paginator = Paginator(subcategories, 10)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    context = {
        'subcategories': page_obj,
        'categories': categories,
        'search_query': search_query,
        'status_filter': status_filter,
        'category_filter': category_filter,
    }
    return render(request, 'custom_admin/subcategory_list.html', context)

@login_required
def subcategory_detail(request, pk):
    subcategory = get_object_or_404(Subcategory.objects.select_related('category'), pk=pk)
    context = {
        'subcategory': subcategory,
    }
    return render(request, 'custom_admin/subcategory_detail.html', context)

@login_required
def subcategory_create(request):
    if request.method == 'POST':
        form = SubcategoryForm(request.POST, request.FILES)
        if form.is_valid():
            subcategory = form.save()
            messages.success(request, f'Subcategory {subcategory.name} created successfully.')
            return redirect('custom_admin:subcategories')
        else:
            messages.error(request, 'Please correct the errors below.')
    else:
        form = SubcategoryForm()
    context = {
        'form': form,
        'action': 'Create',
    }
    return render(request, 'custom_admin/subcategory_form.html', context)

@login_required
def subcategory_edit(request, pk):
    subcategory = get_object_or_404(Subcategory, pk=pk)
    if request.method == 'POST':
        form = SubcategoryForm(request.POST, request.FILES, instance=subcategory)
        if form.is_valid():
            subcategory = form.save()
            messages.success(request, f'Subcategory {subcategory.name} updated successfully.')
            return redirect('custom_admin:subcategory_detail', pk=pk)
        else:
            messages.error(request, 'Please correct the errors below.')
    else:
        form = SubcategoryForm(instance=subcategory)
    context = {
        'form': form,
        'subcategory': subcategory,
        'action': 'Edit',
    }
    return render(request, 'custom_admin/subcategory_form.html', context)

@login_required
def subcategory_delete(request, pk):
    subcategory = get_object_or_404(Subcategory, pk=pk)
    if request.method == 'POST':
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
            try:
                subcategory.delete()
                return JsonResponse({'success': True, 'message': 'Subcategory deleted successfully.'})
            except Exception as e:
                return JsonResponse({'success': False, 'message': str(e)}, status=400)
        subcategory.delete()
        messages.success(request, 'Subcategory deleted successfully.')
        return redirect('custom_admin:subcategories')
    return render(request, 'custom_admin/subcategory_confirm_delete.html', {'subcategory': subcategory})

@login_required
def subcategory_list_json(request, category_id):
    subcategories = Subcategory.objects.filter(category_id=category_id, is_active=True).values('id', 'name')
    return JsonResponse(list(subcategories), safe=False)

# Brand Management Views
@login_required
def brand_list(request):
    brands = Brand.objects.all().order_by('-created_at')
    search_query = request.GET.get('search', '')
    if search_query:
        brands = brands.filter(name__icontains=search_query)
    status_filter = request.GET.get('status', '')
    if status_filter == 'active':
        brands = brands.filter(is_active=True)
    elif status_filter == 'inactive':
        brands = brands.filter(is_active=False)
    paginator = Paginator(brands, 10)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    context = {
        'brands': page_obj,
        'search_query': search_query,
        'status_filter': status_filter,
    }
    return render(request, 'custom_admin/brand_list.html', context)

@login_required
def brand_detail(request, pk):
    brand = get_object_or_404(Brand, pk=pk)
    context = {
        'brand': brand,
    }
    return render(request, 'custom_admin/brand_detail.html', context)

@login_required
def brand_create(request):
    if request.method == 'POST':
        form = BrandForm(request.POST, request.FILES)
        if form.is_valid():
            brand = form.save()
            messages.success(request, f'Brand {brand.name} created successfully.')
            return redirect('custom_admin:brands')
        else:
            messages.error(request, 'Please correct the errors below.')
    else:
        form = BrandForm()
    context = {
        'form': form,
        'action': 'Create',
    }
    return render(request, 'custom_admin/brand_form.html', context)

@login_required
def brand_edit(request, pk):
    brand = get_object_or_404(Brand, pk=pk)
    if request.method == 'POST':
        form = BrandForm(request.POST, request.FILES, instance=brand)
        if form.is_valid():
            brand = form.save()
            messages.success(request, f'Brand {brand.name} updated successfully.')
            return redirect('custom_admin:brand_detail', pk=pk)
        else:
            messages.error(request, 'Please correct the errors below.')
    else:
        form = BrandForm(instance=brand)
    context = {
        'form': form,
        'brand': brand,
        'action': 'Edit',
    }
    return render(request, 'custom_admin/brand_form.html', context)

@login_required
def brand_delete(request, pk):
    brand = get_object_or_404(Brand, pk=pk)
    if request.method == 'POST':
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
            try:
                brand.delete()
                return JsonResponse({'success': True, 'message': 'Brand deleted successfully.'})
            except Exception as e:
                return JsonResponse({'success': False, 'message': str(e)}, status=400)
        brand.delete()
        messages.success(request, 'Brand deleted successfully.')
        return redirect('custom_admin:brands')
    return render(request, 'custom_admin/brand_confirm_delete.html', {'brand': brand})

# Order Management Views
@login_required
def order_list(request):
    orders = Order.objects.select_related(
        'user', 'payment', 'shipping_address'
    ).order_by('-created_at')
    paginator = Paginator(orders, 10)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    context = {
        'orders': page_obj,
    }
    return render(request, 'custom_admin/order_list.html', context)

@login_required
def order_detail(request, pk):
    order = get_object_or_404(
        Order.objects.select_related(
            'user', 'payment', 'shipping_address', 'billing_address'
        ).prefetch_related('status_updates'),
        pk=pk
    )
    context = {
        'order': order,
    }
    return render(request, 'custom_admin/order_detail.html', context)

@login_required
def order_update_status(request, pk):
    if request.method == 'POST':
        order = get_object_or_404(Order, pk=pk)
        data = json.loads(request.body)
        status = data.get('status')
        if status in OrderStatus.values:
            status_update = OrderStatusUpdate.objects.create(
                status=status,
                comment=f"Status updated to {status} by {request.user.username}"
            )
            order.status = status
            order.status_updates.add(status_update)
            order.save()
            messages.success(request, f'Order status updated to {status}')
            return JsonResponse({'success': True})
        return JsonResponse({'success': False, 'error': 'Invalid status'}, status=400)
    return JsonResponse({'success': False, 'error': 'Invalid request method'}, status=405)

@login_required
def order_cancel(request, pk):
    if request.method == 'POST':
        order = get_object_or_404(Order, pk=pk)
        if order.status == 'pending':
            status_update = OrderStatusUpdate.objects.create(
                status='cancelled',
                comment=f"Order cancelled by {request.user.username}"
            )
            order.status = 'cancelled'
            order.status_updates.add(status_update)
            order.save()
            messages.success(request, 'Order cancelled successfully')
            return JsonResponse({'success': True})
        return JsonResponse(
            {'success': False, 'error': 'Only pending orders can be cancelled'}, 
            status=400
        )
    return JsonResponse({'success': False, 'error': 'Invalid request method'}, status=405)

@login_required
def order_print(request, pk):
    order = get_object_or_404(
        Order.objects.select_related(
            'user', 'payment', 'shipping_address', 'billing_address'
        ),
        pk=pk
    )
    settings_data = {}
    try:
        setting = Setting.objects.get(user=request.user, key='site_settings')
        settings_data = setting.value
    except Setting.DoesNotExist:
        pass
    context = {
        'order': order,
        'print_mode': True,
        'settings': settings_data
    }
    return render(request, 'custom_admin/order_print.html', context)

@login_required
def export_orders(request):
    search_query = request.GET.get('search', '')
    status_filter = request.GET.get('status', '')
    payment_status_filter = request.GET.get('payment_status', '')
    start_date = request.GET.get('start_date', '')
    end_date = request.GET.get('end_date', '')
    orders = Order.objects.select_related('user', 'payment').order_by('-created_at')
    if search_query:
        orders = orders.filter(
            Q(id__icontains=search_query) |
            Q(user__username__icontains=search_query) |
            Q(shop_name__icontains=search_query)
        )
    if status_filter:
        orders = orders.filter(status=status_filter)
    if payment_status_filter:
        orders = orders.filter(payment__status=payment_status_filter)
    if start_date:
        orders = orders.filter(created_at__gte=start_date)
    if end_date:
        orders = orders.filter(created_at__lte=end_date)
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="orders_export.csv"'
    writer = csv.writer(response)
    writer.writerow([
        'Order ID',
        'Customer',
        'Shop Name',
        'Status',
        'Payment Status',
        'Payment Method',
        'Total',
        'Subtotal',
        'Tax',
        'Shipping Cost',
        'Created At',
        'Item Count'
    ])
    for order in orders:
        writer.writerow([
            order.id,
            order.user.username,
            order.shop_name or '',
            order.status.title(),
            order.payment.status.title(),
            order.payment.method.upper(),
            order.total,
            order.subtotal,
            order.tax,
            order.shipping_cost,
            order.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            len(order.items)
        ])
    return response

# Settings Views
@login_required
def settings(request):
    if request.method == 'POST':
        form_type = request.POST.get('form_type')
        if form_type == 'site_settings':
            site_settings = {
                'site_name': request.POST.get('site_name'),
                'contact_email': request.POST.get('contact_email'),
                'support_phone': request.POST.get('support_phone'),
                'currency': request.POST.get('currency'),
                'address': request.POST.get('address'),
            }
            Setting.objects.update_or_create(
                user=request.user,
                key='site_settings',
                defaults={'value': site_settings}
            )
            messages.success(request, 'Site settings updated successfully')
        elif form_type == 'email_settings':
            email_settings = {
                'smtp_host': request.POST.get('smtp_host'),
                'smtp_port': request.POST.get('smtp_port'),
                'smtp_username': request.POST.get('smtp_username'),
                'smtp_password': request.POST.get('smtp_password'),
                'smtp_use_tls': bool(request.POST.get('smtp_use_tls')),
            }
            Setting.objects.update_or_create(
                user=request.user,
                key='email_settings',
                defaults={'value': email_settings}
            )
            messages.success(request, 'Email settings updated successfully')
        elif form_type == 'payment_settings':
            payment_settings = {
                'payment_gateway': request.POST.get('payment_gateway'),
                'payment_api_key': request.POST.get('payment_api_key'),
                'payment_api_secret': request.POST.get('payment_api_secret'),
                'payment_webhook_secret': request.POST.get('payment_webhook_secret'),
                'payment_test_mode': bool(request.POST.get('payment_test_mode')),
            }
            Setting.objects.update_or_create(
                user=request.user,
                key='payment_settings',
                defaults={'value': payment_settings}
            )
            messages.success(request, 'Payment settings updated successfully')
    settings_data = {}
    for key in ['site_settings', 'email_settings', 'payment_settings']:
        try:
            setting = Setting.objects.get(user=request.user, key=key)
            settings_data.update(setting.value)
        except Setting.DoesNotExist:
            pass
    return render(request, 'custom_admin/settings.html', {'settings': settings_data})

@login_required
def test_email_settings(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            smtp = smtplib.SMTP(data['smtp_host'], int(data['smtp_port']))
            if data['smtp_use_tls']:
                smtp.starttls()
            smtp.login(data['smtp_username'], data['smtp_password'])
            msg = MIMEText('This is a test email from SpareHub Admin')
            msg['Subject'] = 'Test Email'
            msg['From'] = data['smtp_username']
            msg['To'] = request.user.email
            smtp.send_message(msg)
            smtp.quit()
            return JsonResponse({'success': True})
        except Exception as e:
            return JsonResponse({'success': False, 'error': str(e)})
    return JsonResponse({'success': False, 'error': 'Invalid request method'})

@login_required
def test_payment_settings(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            gateway = data['payment_gateway']
            if gateway == 'razorpay':
                import razorpay
                client = razorpay.Client(
                    auth=(data['payment_api_key'], data['payment_api_secret'])
                )
                client.payment.all()
            elif gateway == 'stripe':
                import stripe
                stripe.api_key = data['payment_api_secret']
                stripe.PaymentIntent.list(limit=1)
            elif gateway == 'paypal':
                pass
            return JsonResponse({'success': True})
        except Exception as e:
            return JsonResponse({'success': False, 'error': str(e)})
    return JsonResponse({'success': False, 'error': 'Invalid request method'})