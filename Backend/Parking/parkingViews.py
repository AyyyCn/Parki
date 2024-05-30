from django.http import JsonResponse
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Parking
from .parkingSerializers import ParkingSerializer
from django.views import View
import json
class ParkingAPIView(APIView):
    def get(self, request):
        parkings = Parking.objects.all()
        serializer = ParkingSerializer(parkings, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = ParkingSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk):
        try:
            parking = Parking.objects.get(id=pk)
        except Parking.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        serializer = ParkingSerializer(parking, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def patch(self, request, pk):
        try:
            parking = Parking.objects.get(id=pk)
        except Parking.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        serializer = ParkingSerializer(parking, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        try:
            parking = Parking.objects.get(id=pk)
        except Parking.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        parking.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

def CalculateDistance(l1,v1, l2, v2):
    
    return pow((l1 -l2),2) + pow((v1 - v2),2)



class RecommandParking(View):
    def get(self, request):
        body=json.loads(request.body)
        print (body.longtitude)
        if 'longitude' not in body or 'latitude' not in body:
            return JsonResponse({'error': 'Missing required attributes: longitude, latitude'}, status=400)
        parkings = Parking.objects.all()
        l=[]
        
        
        print(body)
        for pking in parkings:
            distance = CalculateDistance(body.l, body.v, pking.longitude, pking.latitude)
            l.append(distance)
        return JsonResponse(l)
