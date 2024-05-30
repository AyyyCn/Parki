from django.views import View
from Parking.models import Parking
from ..parkingSerializers import ParkingSerializer
from django.http import JsonResponse

class ParkingList (View):
    def get(self, request):
        parkings= Parking.objects.all()
        serializer = ParkingSerializer(parkings, many= True)
        return JsonResponse(serializer.data)
