from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserViewSet, ManufacturerRegisterView, ShopRegisterView, UserProfileView, LoginView

router = DefaultRouter()
router.register(r'', UserViewSet)

urlpatterns = [
    path('register-manufacturer/', ManufacturerRegisterView.as_view(), name='register-manufacturer'),
    path('register-shop/', ShopRegisterView.as_view(), name='register-shop'),
    path('profile/', UserProfileView.as_view(), name='user-profile'),
    path('login/', LoginView.as_view(), name="login"),
    path('', include(router.urls)),
]