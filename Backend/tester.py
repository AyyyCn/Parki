import os
import django
from math import floor
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'myproject.settings')
django.setup()
from Parking.Services.UserServices import *
timeStayed = timezone.now()-get_checkinhour("audia5")
#show time stayed in minutes
print(floor( timeStayed.total_seconds()/60) , " Minutes")

from Parking.Services.ParkingServices import *
start_parking_session("ABC123", 1)

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
print(result)