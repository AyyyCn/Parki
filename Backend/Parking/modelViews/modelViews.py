# views.py

from datetime import timedelta
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from ..Serializers.ParkingOwnerSerializer import ParkingOwnerSerializer
from ..models import ParkingOwner, UserCar, ParkingSession, ParkingReservation
from ..Serializers.parkingSerializers import ParkingSessionSerializer, ParkingReservationSerializer, UserCarSerializer
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone

class BaseAPIView(APIView):
    model = None
    serializer_class = None

    def get(self, request, pk=None):
        if (pk):
            try:
                instance = self.model.objects.get(id=pk)
            except self.model.DoesNotExist:
                return Response(status=status.HTTP_404_NOT_FOUND)
            serializer = self.serializer_class(instance)
            return Response(serializer.data)
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
        
        # Get the timeframe parameter from the request query parameters
        timeframe = request.GET.get('timeframe', None)
        
        # Define the start date based on the timeframe
        if timeframe == 'Today':
            start_date = timezone.now().date()
        elif timeframe == 'LastWeek':
            start_date = timezone.now().date() - timedelta(days=7)
        elif timeframe == 'LastMonth':
            start_date = timezone.now().date() - timedelta(days=30)
        elif timeframe == 'LastYear':
            start_date = timezone.now().date() - timedelta(days=365)
        else:
            # Handle invalid or missing timeframe parameter
            return Response({'error': 'Invalid or missing timeframe parameter'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Filter ParkingSession objects with these license plates and start date
        parking_sessions = ParkingSession.objects.filter(license_plate__in=license_plates, entry_time__date__gte=start_date)
        
        # Serialize the results
        serializer = ParkingSessionSerializer(parking_sessions, many=True)
        
        return Response(serializer.data)


    
class ParkingReservationAPIView(BaseAPIView):
    model = ParkingReservation
    serializer_class = ParkingReservationSerializer

class ParkingOwnerAPIView(BaseAPIView):
    model = ParkingOwner
    serializer_class= ParkingOwnerSerializer