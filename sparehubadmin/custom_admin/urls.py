from django.urls import path
from . import views

app_name = 'custom_admin'

urlpatterns = [
    path('', views.dashboard, name='dashboard'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    
    # User URLs
    path('users/', views.user_list, name='users'),
    path('users/create/', views.user_create, name='user_create'),
    path('users/<int:pk>/', views.user_detail, name='user_detail'),
    path('users/<int:pk>/edit/', views.user_edit, name='user_edit'),
    path('users/<int:pk>/toggle-status/', views.user_toggle_status, name='user_toggle_status'),
    path('users/<int:pk>/delete/', views.user_delete, name='user_delete'),
    
    # Product URLs
    path('products/', views.product_list, name='products'),
    path('products/create/', views.product_create, name='product_create'),
    path('products/<int:pk>/', views.product_detail, name='product_detail'),
    path('products/<int:pk>/edit/', views.product_edit, name='product_edit'),
    path('products/<int:pk>/delete/', views.product_delete, name='product_delete'),
    path('products/<int:pk>/toggle-status/', views.product_toggle_status, name='product_toggle_status'),
    path('products/<int:pk>/toggle-featured/', views.product_toggle_featured, name='product_toggle_featured'),
    path('products/<int:pk>/upload-image/', views.product_image_upload, name='product_image_upload'),
    path('products/<int:pk>/delete-image/<int:image_id>/', views.product_image_delete, name='product_image_delete'),
    path('products/<int:pk>/set-primary-image/<int:image_id>/', views.product_image_set_primary, name='product_image_set_primary'),
    
    # Order URLs
    path('orders/', views.order_list, name='orders'),
    path('orders/<int:pk>/', views.order_detail, name='order_detail'),
    path('orders/<int:pk>/print/', views.order_print, name='order_print'),
    path('orders/<int:pk>/status/', views.order_update_status, name='order_update_status'),
    path('orders/<int:pk>/cancel/', views.order_cancel, name='order_cancel'),
    path('orders/export/', views.export_orders, name='order_export'),
    
    # Analytics URLs
    path('analytics/', views.analytics, name='analytics'),
    
    # Settings URLs
    path('settings/', views.settings, name='settings'),
    path('settings/test-email/', views.test_email_settings, name='test_email_settings'),
    path('settings/test-payment/', views.test_payment_settings, name='test_payment_settings'),
    
    # Category URLs
    path('categories/', views.category_list, name='categories'),
    path('categories/<int:pk>/', views.category_detail, name='category_detail'),
    path('categories/create/', views.category_create, name='category_create'),
    path('categories/<int:pk>/edit/', views.category_edit, name='category_edit'),
    path('categories/<int:pk>/delete/', views.category_delete, name='category_delete'),
    
    # Subcategory URLs
    path('subcategories/', views.subcategory_list, name='subcategories'),
    path('subcategories/<int:pk>/', views.subcategory_detail, name='subcategory_detail'),
    path('subcategories/create/', views.subcategory_create, name='subcategory_create'),
    path('subcategories/<int:pk>/edit/', views.subcategory_edit, name='subcategory_edit'),
    path('subcategories/<int:pk>/delete/', views.subcategory_delete, name='subcategory_delete'),

    # Brand URLs
    path('brands/', views.brand_list, name='brands'),
    path('brands/<int:pk>/', views.brand_detail, name='brand_detail'),
    path('brands/create/', views.brand_create, name='brand_create'),
    path('brands/<int:pk>/edit/', views.brand_edit, name='brand_edit'),
    path('brands/<int:pk>/delete/', views.brand_delete, name='brand_delete'),
    
    # Subcategory URL
    path('subcategories/<int:category_id>/', views.subcategory_list, name='subcategory_list'),
]