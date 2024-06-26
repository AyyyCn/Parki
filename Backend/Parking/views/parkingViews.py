from django.http import Http404, JsonResponse
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from ..models import Parking
from ..Serializers.parkingSerializers import ParkingSerializer
from django.views import View
from ..Services.ParkingServices import start_parking_session, exit_parking_session
import os
from django.conf import settings
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
class ParkingAPIView(APIView):
    def get(self, request):
        parkings = Parking.objects.all()
        name_exists = request.query_params.get('name', None)
        id_exists = request.query_params.get('id', None) 
        if name_exists:
            pkings = parkings.filter(name__icontains=name_exists)  
            serializer = ParkingSerializer(pkings, many=True)
            return Response(serializer.data)
        elif id_exists:
            try:
                parking = Parking.objects.get(id=id_exists)
                serializer = ParkingSerializer(parking)
                return Response(serializer.data)
            except Parking.DoesNotExist:
                raise Http404
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




class RecommendParking(View):
    def get(self, request):
        try:
            longitude = request.GET.get('longitude')
            latitude = request.GET.get('latitude')
            if not longitude or not latitude:
                return JsonResponse({'error': 'Missing required attributes: longitude, latitude'}, status=400)
            user_longitude = float(longitude)
            user_latitude = float(latitude)
        except ValueError:
            return JsonResponse({'error': 'Invalid longitude or latitude values'}, status=400)

        parkings = Parking.objects.all()
        distances = []
        for pking in parkings:
            distance = calculate_haversine_distance(user_latitude, user_longitude, pking.latitude,  pking.longitude)
            distances.append(({
                'id': pking.id,
                'name': pking.name,
                'adress': pking.address,
                'latitude': pking.latitude,
                'longitude': pking.longitude,
                'totalSpots' : pking.total_spots,
                'availableSpots': pking.available_spots,
                'pricePerHour' : pking.price_per_hour
            }, distance))
        distances.sort(key=lambda x: x[1])
        
        number = request.GET.get('number')
        if number and int(number) > 1:
            n = int(number)
            return JsonResponse(distances[:n], safe=False)
        
        return JsonResponse(distances[0], safe=False)



class ImageUploadView(APIView):
    def post(self, request, *args, **kwargs):
        if 'image' not in request.FILES:
            return Response({'error': 'No image provided'}, status=status.HTTP_400_BAD_REQUEST)
        
        if 'parking_id' not in request.data:
            return Response({'error': 'No parking_id provided'}, status=status.HTTP_400_BAD_REQUEST)
        if 'mode' not in request.data:
            return Response({'error': 'No mode provided'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            parking_id = int(request.data['parking_id'])
        except ValueError:
            return Response({'error': 'Invalid parking_id provided'}, status=status.HTTP_400_BAD_REQUEST)
        
        image = request.FILES['image']
        
        # Process the image and parking_id here if needed
        # For demonstration, we will just return a success message.
        msg = start_parking_session("12ABC", parking_id)
        return Response({'message': 'Image received successfully!', 'parking_id': parking_id,'result': msg}, status=status.HTTP_200_OK)
class EndSession(APIView):
    def post(self, request, *args, **kwargs):
        if 'parking_id' not in request.data or 'license_plate' not in request.data:
            return Response({'error': 'Required data not provided'}, status=status.HTTP_400_BAD_REQUEST)

        parking_id = request.data.get('parking_id')
        license_plate = request.data.get('license_plate')
        if 'image' in request.FILES:
            image = request.FILES['image']
            
            # Define the directory where you want to save the images
            image_directory = os.path.join(settings.MEDIA_ROOT, 'parking_images')
            if not os.path.exists(image_directory):
                os.makedirs(image_directory)
            
            # Define the file path and save the image
            image_path = os.path.join(image_directory, image.name)
            with default_storage.open(image_path, 'wb+') as destination:
                for chunk in image.chunks():
                    destination.write(chunk)
            
            # Optional: Save the path to the image if needed
            image_url = default_storage.url(image_path)

        print("Received plate image")
        print("extracted license plate: ", license_plate)
        result = exit_parking_session(license_plate, parking_id)

        # Map the status to HTTP status codes
        status_map = {
            "exited_successfully": status.HTTP_200_OK,
            "payment_required": status.HTTP_402_PAYMENT_REQUIRED,
            "extra_payment_required": status.HTTP_402_PAYMENT_REQUIRED,
            "no_session_found": status.HTTP_404_NOT_FOUND
        }

        # Get the HTTP status from the map, default to 400 if not found
        http_status = status_map.get(result['status'], status.HTTP_400_BAD_REQUEST)

        return Response({'message': result['message'], 'parking_id': parking_id, 'status': result['status']}, status=http_status)

class StartSession(APIView):
    def post(self, request, *args, **kwargs):
        if 'parking_id' not in request.data or 'license_plate' not in request.data:
            return Response({'error': 'Required data not provided'}, status=status.HTTP_400_BAD_REQUEST)

        parking_id = request.data.get('parking_id')
        license_plate = request.data.get('license_plate')
        
        if 'image' in request.FILES:
            image = request.FILES['image']
            
            # Define the directory where you want to save the images
            image_directory = os.path.join(settings.MEDIA_ROOT, 'parking_images')
            if not os.path.exists(image_directory):
                os.makedirs(image_directory)
            
            # Define the file path and save the image
            image_path = os.path.join(image_directory, image.name)
            with default_storage.open(image_path, 'wb+') as destination:
                for chunk in image.chunks():
                    destination.write(chunk)
            
            # Optional: Save the path to the image if needed
            image_url = default_storage.url(image_path)

        print("Received plate image")
        print("extracted license plate: ", license_plate)
        result = start_parking_session(license_plate, parking_id)

        # Map the status to HTTP status codes
        status_map = {
            "session_already_active": status.HTTP_200_OK,
            "session_started": status.HTTP_200_OK,
            "no_spots_available": status.HTTP_403_FORBIDDEN,
        }

        # Get the HTTP status from the map, default to 400 if not found
        http_status = status_map.get(result['status'], status.HTTP_400_BAD_REQUEST)

        return Response({'message': result, 'parking_id': parking_id}, status=http_status)

class ReserveSpot(APIView):
    def post(self, request, *args, **kwargs):
        if 'parking_id' not in request.data or 'license_plate' not in request.data:
            return Response({'error': 'Required data not provided'}, status=status.HTTP_400_BAD_REQUEST)

        parking_id = request.data.get('parking_id')
        license_plate = request.data.get('license_plate')

        result = start_parking_session(license_plate, parking_id)

        # Map the status to HTTP status codes
        status_map = {
            "session_already_active": status.HTTP_200_OK,
            "session_started": status.HTTP_200_OK
        }

        # Get the HTTP status from the map, default to 400 if not found
        http_status = status_map.get(result['status'], status.HTTP_400_BAD_REQUEST)

        return Response({'message': result['message'], 'parking_id': parking_id, 'status': result['status']}, status=http_status )