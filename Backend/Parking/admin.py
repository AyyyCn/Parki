from django.contrib import admin
from .models import User, UserCar, Parking, ParkingSession, ParkingReservation

# Register your models here.
admin.site.register(User)
admin.site.register(Parking)
admin.site.register(UserCar)
admin.site.register(ParkingSession)
admin.site.register(ParkingReservation)