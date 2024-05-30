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
        name_exists = request.query_params.get('name', None)
        if name_exists:
            pkings = parkings.filter(name=name_exists)
            serializer = ParkingSerializer(pkings, many=True)
            return Response(serializer.data)
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

import math

def calculate_haversine_distance(lat1, lon1, lat2, lon2):
    
    lat1 = math.radians(float(lat1))
    lon1 = math.radians(float(lon1))
    lat2 = math.radians(float(lat2))
    lon2 = math.radians(float(lon2))

    
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = math.sin(dlat / 2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    
    
    radius = 6371.0
    
    
    distance = radius * c
    return distance




class RecommandParking(View):
    def get(self, request):
        try:
            body = json.loads(request.body)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)

        
        if 'longitude' not in body or 'latitude' not in body:
            return JsonResponse({'error': 'Missing required attributes: longitude, latitude'}, status=400)

        
        user_longitude = body.get('longitude')
        user_latitude = body.get('latitude')

        
        parkings = Parking.objects.all()

        distances = []

        for pking in parkings:
            distance = calculate_haversine_distance(user_latitude, user_longitude, pking.latitude,  pking.longitude)
            distances.append(({
                'parking_id': pking.id,
                'parking_name': pking.name,
                'longitude': pking.longitude,
                'latitude': pking.latitude
            }, distance))
        distances.sort(key=lambda x: x[1] )

        if 'number' in body and int(body.get('number')) >1:
            n= int(body.get('number'))
            return JsonResponse(distances[:int(n)], safe= False)

        return JsonResponse(distances[0], safe=False)
