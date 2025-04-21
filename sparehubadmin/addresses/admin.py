from django.contrib import admin
from .models import Address

@admin.register(Address)
class AddressAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'city', 'state', 'country', 'type', 'is_default')
    list_filter = ('type', 'city', 'state', 'country')
    search_fields = ('name', 'user__username', 'city', 'state', 'country')
    ordering = ('user', 'name')
