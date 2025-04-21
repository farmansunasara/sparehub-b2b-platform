from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import SettingsViewSet

router = DefaultRouter()
router.register(r'', SettingsViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
