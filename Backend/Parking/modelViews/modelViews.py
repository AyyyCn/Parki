# views.py

from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from ..models import UserCar, ParkingSession, ParkingReservation
from ..Serializers.parkingSerializers import ParkingSessionSerializer, ParkingReservationSerializer, UserCarSerializer
from rest_framework.permissions import IsAuthenticated

class BaseAPIView(APIView):
    model = None
    serializer_class = None

    def get(self, request):
        instances = self.model.objects.all()
        serializer = self.serializer_class(instances, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk):
        try:
            instance = self.model.objects.get(id=pk)
        except self.model.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        serializer = self.serializer_class(instance, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def patch(self, request, pk):
        try:
            instance = self.model.objects.get(id=pk)
        except self.model.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        serializer = self.serializer_class(instance, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        try:
            instance = self.model.objects.get(id=pk)
        except self.model.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        instance.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

class UserCarAPIView(BaseAPIView):
    model = UserCar
    serializer_class = UserCarSerializer

class ParkingSessionAPIView(APIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ParkingSessionSerializer

    def get(self, request):
        # Get the authenticated user
        user = request.user
        
        # Fetch the license plates for the authenticated user
        license_plates = UserCar.objects.filter(user=user).values_list('license_plate', flat=True)
        
        # Filter ParkingSession objects with these license plates
        parking_sessions = ParkingSession.objects.filter(license_plate__in=license_plates)
        
        # Serialize the results
        serializer = ParkingSessionSerializer(parking_sessions, many=True)
        
        return Response(serializer.data)
    
class ParkingReservationAPIView(BaseAPIView):
    model = ParkingReservation
    serializer_class = ParkingReservationSerializer
