# views.py

from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from ..models import UserCar, ParkingSession, ParkingReservation
from ..parkingSerializers import ParkingSessionSerializer, ParkingReservationSerializer, UserCarSerializer

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

class ParkingSessionAPIView(BaseAPIView):
    model = ParkingSession
    serializer_class = ParkingSessionSerializer

class ParkingReservationAPIView(BaseAPIView):
    model = ParkingReservation
    serializer_class = ParkingReservationSerializer
