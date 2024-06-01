from rest_framework import serializers
from ..models import UserCar

class LicensePlateSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserCar
        fields = ['license_plate']