from django.contrib import admin
from .models import ParkingOwner, UserCar, Parking, ParkingSession, ParkingReservation, CustomUser

# Register your models here.

admin.site.register(Parking)
admin.site.register(UserCar)
admin.site.register(ParkingSession)
admin.site.register(ParkingReservation)
admin.site.register(CustomUser)
admin.site.register(ParkingOwner)