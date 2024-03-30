from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers


from .models import CustomUser

class PublicUserInfoSerializer(serializers.ModelSerializer):
    username = serializers.CharField(required=False)
    class Meta:
        model = CustomUser
        fields = ['username', 'email', 'phone', 'address', 'city', 'state', 'country']

class ChangePasswordSerializer(serializers.Serializer):

    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)

    def validate_new_password(self, value):
        validate_password(value)
        return value

class SelfUserInfoSerializer(serializers.ModelSerializer):
    username = serializers.CharField(required=False)
    class Meta:
        model = CustomUser
        fields = ['username', 'email', 'phone', 'address', 'city', 'state', 'country']