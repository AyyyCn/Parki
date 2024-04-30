from django.contrib.auth import get_user_model
from django.contrib.auth.backends import BaseBackend
from .models import CustomUser

class PhoneNumberBackend(BaseBackend):
    def authenticate(self, request, phone_number=None, password=None):
        UserModel = get_user_model()
        try:
            user = CustomUser.objects.get(phone_number=phone_number)
            if user.check_password(password):
                return user
        except CustomUser.DoesNotExist:
            pass
        return None

    def get_user(self, user_id):
        UserModel = get_user_model()
        try:
            return UserModel.objects.get(id=user_id)
        except UserModel.DoesNotExist:
            return None
