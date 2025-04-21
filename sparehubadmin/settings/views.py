from rest_framework import viewsets
from .models import Setting
from .serializers import SettingsSerializer

class SettingsViewSet(viewsets.ModelViewSet):
    queryset = Setting.objects.all()
    serializer_class = SettingsSerializer
