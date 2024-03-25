from django.urls import path
from . import views

urlpatterns = [
    path('', views.homepage, name = 'homepage'),
    path('api/check_in_hour/<str:license_plate>/', views.check_in_hour, name='check_in_hour'),
    path('register', views.registerpage, name= 'registerpage'),
    path('login', views.loginpage, name= 'loginpage')
]
