from django.apps import AppConfig

class CustomAdminConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'custom_admin'
    verbose_name = 'SpareHub Admin'

    def ready(self):
        # Import signals or perform any app initialization here
        pass
