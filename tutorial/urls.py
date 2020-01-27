from django.contrib import admin
from django.urls import path, include
from rest_framework import routers
from core.api.viewsets import ClientViewSet

router = routers.DefaultRouter()
router.register(r'clients', ClientViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('admin/', admin.site.urls),
]
