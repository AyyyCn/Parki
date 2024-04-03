import json

from django.contrib.auth.password_validation import validate_password
from phonenumber_field.serializerfields import PhoneNumberField
from rest_framework import serializers


from .models import CustomUser

class PublicUserInfoSerializer(serializers.ModelSerializer):

    class Meta:
        model = CustomUser
        fields = ['last_name', 'phone_number', 'phone', 'address', 'city', 'state', 'country']

class ChangePasswordSerializer(serializers.Serializer):

    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)

    def validate_new_password(self, value):
        validate_password(value)
        return value

from rest_framework import serializers
from .models import CustomUser
from phonenumber_field.serializerfields import PhoneNumberField

class FormattedPhoneNumberField(serializers.RelatedField):
    def to_representation(self, value):
        # Format the phone number here as desired
        return f"{value.country_code}-{value.national_number}"

from rest_framework import serializers
from phonenumber_field.serializerfields import PhoneNumberField

class PhoneNumberSerializer(serializers.Serializer):
    number = PhoneNumberField()

    def serialize_phone_number(self, phone_number_str):
        serializer = PhoneNumberSerializer(data={"number": phone_number_str})
        if serializer.is_valid():
            validated_data = dict(serializer.validated_data)  # Convert OrderedDict to dict
            phone_obj = validated_data['number']
            serialized_phone = {
                'country_code': phone_obj.country_code,
                'national_number': phone_obj.national_number,
                'extension': phone_obj.extension,
            }
            return serialized_phone
        else:
            return "Error: Invalid phone number"


class SelfUserInfoSerializer(serializers.ModelSerializer):
    phone_number=PhoneNumberSerializer()

    class Meta:
        model = CustomUser
        fields = ['last_name', 'first_name', 'email', 'phone_number', 'address', 'city', 'state', 'country']
