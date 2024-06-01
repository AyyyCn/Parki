import os
import django
from math import floor
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'myproject.settings')
django.setup()
from Parking.Services.UserServices import *


from Parking.Services.ParkingServices import *
from django.shortcuts import get_object_or_404
from Parking.Services.ParkingServices import ParkingSession, ParkingSessionArchive
from Parking.models import CustomUser, UserCar
from Parking.Services.UserServices import *



def get_user_by_id(user_id):
    """
    Retrieve a user by their ID.
    """
    return get_object_or_404(CustomUser, id=user_id)

start_parking_session("123Soleil", 1)

"""result = exit_parking_session("123Soleil", 1)
print(get_all_license_plates(get_user_by_id(4)))
print(get_credit(get_user_by_id(4)))
print(result)
print(get_cost_by_plate("123Soleil", 1))
print(pay(get_user_by_id(4), "123Soleil", 1))

start_parking_session("audia7", 1)

start_parking_session("audia5", 1)
start_parking_session("audia3", 1)

result = exit_parking_session("237TUN23", 1)
print(result)
readln = input()
result = pay("237TUN23", 1)
print(result)
readln = input() 
result = exit_parking_session("237TUN23", 1)
print(result)"""



"""from django.shortcuts import get_object_or_404
from Parking.Services.ParkingServices import ParkingSession, ParkingSessionArchive, CustomUser, UserCar
from django.utils import timezone
import os
import django
from math import floor
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'myproject.settings')
django.setup()
"""