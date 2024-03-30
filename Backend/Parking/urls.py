from django.urls import path, include
from rest_framework.routers import DefaultRouter

from . import views
from .views import PublicUserInfoViewSet, UpdatePassword, SelfUserInfoViewSet

UserRouter= DefaultRouter()
UserRouter.register('touchInfo', PublicUserInfoViewSet, basename='info')

urlpatterns = [
    path('', views.homepage, name = 'homepage'),
    path('api/check_in_hour/<str:license_plate>/', views.check_in_hour, name='check_in_hour'),
    path('register', views.register_view, name= 'signup'),
    path('login', views.login_view, name= 'loginpage'),
    path('loginAPI', views.login_viewJSON, name= 'loginpageAPI'),
    path('registerAPI', views.register_viewJSON, name= 'signupAPI'),
    path('usersAPI', views.get_all_users, name='allusers'),

    path('logoutAPI', views.logout_view, name='f'),

    # URL pattern for retrieving/updating a specific user by primary key
    path('user/<int:pk>/', PublicUserInfoViewSet.as_view({'get': 'retrieve', 'put': 'update'}), name='user-detail'),

    # URL pattern for retrieving/updating the authenticated user (no primary key provided)
    path('self/', SelfUserInfoViewSet.as_view({'get': 'retrieve', 'put': 'update'}), name='user-self'),
    path('updatepassword', UpdatePassword.as_view() , name="updatepwd"),
    path('log', views.logout_all_users, name="ff"),
    path('tes', views.Test, name= "fff")

]
