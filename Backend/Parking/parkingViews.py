from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Parking
from .parkingSerializers import ParkingSerializer

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
