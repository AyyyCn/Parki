from rest_framework import serializers
from .models import Parking, UserCar, ParkingSession, ParkingReservation, ParkingSessionArchive


class ParkingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Parking
        fields = '__all__'
    def create(self, validated_data):
        # Custom logic for creating instances
        return Parking.objects.create(**validated_data)

    def update(self, instance, validated_data):
        instance = super().update(instance, validated_data)
        # Add any custom logic here if needed
        return instance


class UserCarSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserCar
        fields = '__all__'


class ParkingSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = ParkingSession
        fields = '__all__'


class ParkingReservationSerializer(serializers.ModelSerializer):
    class Meta:
        model = ParkingReservation
        fields = '__all__'


class ParkingSessionArchiveSerializer(serializers.ModelSerializer):
    class Meta:
        model = ParkingSessionArchive
        fields = '__all__'
