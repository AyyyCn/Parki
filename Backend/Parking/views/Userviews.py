from django.contrib.auth.forms import AuthenticationForm, PasswordChangeForm
from django.contrib.sessions.models import Session
from django.http import JsonResponse, HttpResponse
from django.utils import timezone
from rest_framework import authentication, exceptions, status
from rest_framework.generics import UpdateAPIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from django.views.decorators.csrf import csrf_exempt
from rest_framework.views import APIView
from ..forms import RegisterForm, LoginForm
from django.contrib.auth import login, authenticate, logout
from django import forms
import logging
from rest_framework import viewsets
from ..Serializers.UserSerializers import PublicUserInfoSerializer, ChangePasswordSerializer, SelfUserInfoSerializer, PhoneNumberSerializer
from ..Serializers.LicencePlateSerializer import LicensePlateSerializer
from ..models import CustomUser
from rest_framework.decorators import api_view, permission_classes
from django.middleware.csrf import get_token
from django.http import JsonResponse
from ..models import UserCar
@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def register_viewJSON(request):
    if request.method == 'POST':
        form = RegisterForm(data=request.data)
        if form.is_valid():
            user = form.save(commit=False)
            user.save()
            return JsonResponse({'message': 'User created successfully'}, status=201)
        else:
            print(form.errors)
            return JsonResponse({'error': form.errors}, status=500)



@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def login_viewJSON(request):
    if request.user.is_authenticated:
        return JsonResponse({'message': 'User is already authenticated'}, status=400)

    if request.method == 'POST':
        form = LoginForm(data=request.data)
        print(form.is_valid())
        if form.is_valid():
            phone_number = form.cleaned_data.get('phone_number')
            password = form.cleaned_data.get('password')
            user = authenticate(request, phone_number=phone_number, password=password)
            if user is not None:
                login(request, user)
                # Retrieve CSRF token
                csrf_token = get_token(request)
                # Include CSRF token in response headers
                response = JsonResponse({'message': 'Login successful'}, status=200)
                response["X-CSRFToken"] = csrf_token
                print(response)
                return response
                
            else:
                return JsonResponse({'error': 'Invalid phone number or password'}, status=400)
        else:
            print(form.errors)
            return JsonResponse(form.errors, status=400)

@api_view(['POST'])
def logout_view(request):
    # Invalidate the user's session or authentication token yay
    logout(request)
    return Response({'message': 'Logout successful'}, status=200)

class SelfUserInfoViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated]

    def retrieve(self, request):

        user = request.user

        # Get the list of requested fields from query parameters
        fields = request.query_params.getlist('field')
        if fields:
            data = {}

            for field in fields:

                if field in SelfUserInfoSerializer.Meta.fields:
                    if field == "phone_number":
                        pn = PhoneNumberSerializer()
                        phonenum = pn.to_representation(getattr(user, "phone_number", None))
                        data["phone_number"] = phonenum
                    else:
                        data[field] = getattr(user, field, None)
                else:
                    return Response({'error': f'Field "{field}" is not valid'}, status=status.HTTP_400_BAD_REQUEST)
            return Response(data, status=status.HTTP_200_OK)
        else:
            # Return all public information if no specific fields are requested
            serializer = SelfUserInfoSerializer(user)
            return Response(serializer.data, status=status.HTTP_200_OK)

    def update(self, request, *args, **kwargs):
        try:
            partial = kwargs.pop('partial', True)
            instance = request.user
            serializer = SelfUserInfoSerializer(instance, data=request.data, partial=partial)
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as e:
            # Handle the exception and return an appropriate error response
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class PublicUserInfoViewSet(viewsets.ViewSet):

    def retrieve(self, request, pk=None):
        # Retrieve the user instance based on the provided primary key (pk)
        user = CustomUser.objects.filter(id=pk).first()

        if user:
            # Get the list of requested fields from query parameters
            fields = request.query_params.getlist('field')
            if fields:
                data = {}

                for field in fields:
                    # Check if the requested field is valid
                    if field in PublicUserInfoSerializer.Meta.fields:
                        if field == 'phone_number':
                            pn = PhoneNumberSerializer()
                            phonenum = pn.to_representation(getattr(user, "phone_number", None))
                            data["phone_number"]=phonenum
                        else:
                            data[field] = getattr(user, field, None)
                    else:
                        return Response({'error': f'Field "{field}" is not valid'}, status=status.HTTP_400_BAD_REQUEST)
                return Response(data, status=status.HTTP_200_OK)
            else:
                # Return all public information if no specific fields are requested
                serializer = PublicUserInfoSerializer(user)
                return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            # Return 404 if the user with the provided pk is not found
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

    def update(self, request, pk=None, *args, **kwargs):

        user = CustomUser.objects.filter(id=pk).first()
        try:
            instance = user
            partial = kwargs.pop('partial', True)
            serializer = PublicUserInfoSerializer(instance, data=request.data, partial=partial)
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as e:
            # Handle the exception and return an appropriate error response
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class   UpdatePassword(APIView):
    permission_classes = [IsAuthenticated]

    def get_object(self, queryset=None):
        return self.request.user

    def put(self, request, *args, **kwargs):
        self.object = self.get_object()
        serializer = ChangePasswordSerializer(data=request.data)
        if serializer.is_valid():
            # Check old password
            old_password = serializer.data.get("old_password")
            if not self.object.check_password(old_password):
                return Response({"old_password": ["Wrong password."]},
                                status=status.HTTP_400_BAD_REQUEST)
            # set_password also hashes the password that the user will get
            self.object.set_password(serializer.data.get("new_password"))
            self.object.save()
            return Response(status=status.HTTP_204_NO_CONTENT)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_license_plate_view(request):
    """
    Endpoint to add a license plate for the authenticated user.
    """
    user = request.user
    serializer = LicensePlateSerializer(data=request.data)
    if serializer.is_valid():
        license_plate = serializer.validated_data['license_plate']
        if not UserCar.objects.filter(user=user, license_plate=license_plate).exists():
            UserCar.objects.create(user=user, license_plate=license_plate)
            return Response({'message': 'License plate added successfully'}, status=status.HTTP_201_CREATED)
        else:
            return Response({'error': 'License plate already exists'}, status=status.HTTP_400_BAD_REQUEST)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)