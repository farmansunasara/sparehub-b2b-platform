from django.contrib import admin
from .models import Analytics

@admin.register(Analytics)
class AnalyticsAdmin(admin.ModelAdmin):
    list_display = ('user', 'start_date', 'end_date', 'created_at')
    search_fields = ('user__username',)
    ordering = ('-created_at',)
