from django.contrib import admin
from .models import Setting

@admin.register(Setting)
class SettingAdmin(admin.ModelAdmin):
    list_display = ('key', 'user', 'created_at')
    search_fields = ('key', 'user__username')
    ordering = ('user', 'key')
