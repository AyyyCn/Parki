import json

from django.contrib.auth.password_validation import validate_password
from phonenumber_field.serializerfields import PhoneNumberField
from rest_framework import serializers


from .models import CustomUser

class PhoneNumberSerializer(serializers.Serializer):
    number = PhoneNumberField()

    def to_representation(self, instance):
        # Serialize phone number for reading
        return {
            'country_code': instance.country_code,
            'national_number': instance.national_number,
            'extension': instance.extension,
        }

    def create(self, validated_data):
        # Deserialize phone number for writing
        return validated_data['number']


class PublicUserInfoSerializer(serializers.ModelSerializer):
    phone_number = PhoneNumberSerializer()

    class Meta:
        model = CustomUser
        fields = ['last_name', 'first_name', 'email', 'phone_number', 'address', 'city', 'state', 'country']

    def create(self, validated_data):
        phone_number_data = validated_data.pop('phone_number')
        phone_number_instance = PhoneNumberSerializer().create(phone_number_data)
        user = CustomUser.objects.create(phone_number=phone_number_instance, **validated_data)
        return user

    def update(self, instance, validated_data):
        phone_number_data = validated_data.pop('phone_number', None)
        if phone_number_data:
            phone_number_instance = PhoneNumberSerializer().create(phone_number_data)
            instance.phone_number = phone_number_instance
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance


class ChangePasswordSerializer(serializers.Serializer):

    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)

    def validate_new_password(self, value):
        validate_password(value)
        return value

from rest_framework import serializers
from .models import CustomUser
from phonenumber_field.serializerfields import PhoneNumberField



from rest_framework import serializers
from phonenumber_field.serializerfields import PhoneNumberField


class SelfUserInfoSerializer(serializers.ModelSerializer):
    phone_number = PhoneNumberSerializer()

    class Meta:
        model = CustomUser
        fields = ['last_name', 'first_name', 'email', 'phone_number', 'address', 'city', 'state', 'country']

    def create(self, validated_data):
        phone_number_data = validated_data.pop('phone_number')
        phone_number_instance = PhoneNumberSerializer().create(phone_number_data)
        user = CustomUser.objects.create(phone_number=phone_number_instance, **validated_data)
        return user

    def update(self, instance, validated_data):
        phone_number_data = validated_data.pop('phone_number', None)
        if phone_number_data:
            phone_number_instance = PhoneNumberSerializer().create(phone_number_data)
            instance.phone_number = phone_number_instance
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance
