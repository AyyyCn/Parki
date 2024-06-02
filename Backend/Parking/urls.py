from django.urls import path
from rest_framework.routers import DefaultRouter
from .views.parkingViews import ParkingAPIView
from .import _views as view
from .views.Userviews import PublicUserInfoViewSet, UpdatePassword, SelfUserInfoViewSet,license_plate,Payment
from .views import Userviews
from .modelViews.modelViews import UserCarAPIView,ParkingReservationAPIView,ParkingSessionAPIView
from .views.parkingViews import RecommendParking, StartSession,EndSession

UserRouter= DefaultRouter()
UserRouter.register('touchInfo', PublicUserInfoViewSet, basename='info')

urlpatterns = [
    path('', view.homepage, name = 'homepage'),
    path('check_in_hour/<str:license_plate>/', view.check_in_hour, name='check_in_hour'),
    path('register', view.register_view, name= 'signup'),
    path('login', view.login_view, name= 'loginpage'),
    path('loginAPI', Userviews.login_viewJSON, name= 'loginpageAPI'),
    path('registerAPI', Userviews.register_viewJSON, name= 'signupAPI'),

    path('logoutAPI', Userviews.logout_view, name='f'),

    # URL pattern for retrieving/updating a specific user by primary key
    path('user/<int:pk>/', PublicUserInfoViewSet.as_view({'get': 'retrieve', 'put': 'update'}), name='user-detail'),

    # URL pattern for retrieving/updating the authenticated user (no primary key provided)
    path('self/', SelfUserInfoViewSet.as_view({'get': 'retrieve', 'put': 'update'}), name='user-self'),
    path('updatepassword', UpdatePassword.as_view() , name="updatepwd"),

    path('parking', ParkingAPIView.as_view(), name="parking_api"),
    path('parking/<int:pk>/', ParkingAPIView.as_view(), name="parking_detail_api"),
    path('usercar/', UserCarAPIView.as_view(), name='usercar_api'),
    path('usercar/<int:pk>/', UserCarAPIView.as_view(), name='usercar_detail_api'),
    path('parkingreservation/', ParkingReservationAPIView.as_view(), name='parkingreservation_api'),
    path('parkingreservation/<int:pk>/', ParkingReservationAPIView.as_view(), name='parkingreservation_detail_api'),
    path('parkingsession/', ParkingSessionAPIView.as_view(), name='parkingsession_api'),
    path('parkingsession/<int:pk>/', ParkingSessionAPIView.as_view(), name='parkingsession_detail_api'),
    path('closest' , RecommendParking.as_view(), name = 'closest Parking'), 
    path('StartSession', StartSession.as_view(), name='StartSession'), #this is the endpoint for uploading images from camera to be changed
    path('EndSession', EndSession.as_view(), name='EndSession'), #this is the endpoint for uploading images from camera to be changed
    path ('license_plate', license_plate.as_view(), name='license_plate'),
    path ('pay', Payment.as_view(), name='pay')
]