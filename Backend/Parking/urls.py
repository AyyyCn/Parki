from django.urls import path
from . import views

urlpatterns = [
    path('', views.homepage, name = 'homepage'),
    path('api/check_in_hour/<str:license_plate>/', views.check_in_hour, name='check_in_hour'),
    path('register', views.register_view, name= 'signup'),
    path('login', views.login_view, name= 'loginpage'),
    path('loginAPI', views.login_viewJSON, name= 'loginpageAPI'),
    path('registerAPI', views.register_viewJSON, name= 'signupAPI'),
    path('usersAPI', views.get_all_users, name='allusers')
]
