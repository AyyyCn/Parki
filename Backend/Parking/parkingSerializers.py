from rest_framework import serializers
from .models import Parking

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
    