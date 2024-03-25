from django.urls import path
from . import views

urlpatterns = [
    path('api/check_in_hour/<str:license_plate>/', views.check_in_hour, name='check_in_hour'),
]
