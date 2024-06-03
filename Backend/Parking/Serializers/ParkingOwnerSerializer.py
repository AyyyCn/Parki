from ..models import ParkingOwner
from rest_framework import serializers


class ParkingOwnerSerializer(serializers.ModelSerializer):
    class Meta:
        model = ParkingOwner
        fields = '__all__'