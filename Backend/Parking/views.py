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

from .Services.UserServices import get_checkinhour  # Adjust the import path as needed
from django.contrib.auth import login, authenticate, logout
from django.shortcuts import render, redirect, get_object_or_404
from django import forms
import logging

from .UserSerializers import PublicUserInfoSerializer, ChangePasswordSerializer, SelfUserInfoSerializer
from .UserSerializers import PhoneNumberSerializer

logger = logging.getLogger(__name__)
from .models import CustomUser
from rest_framework.decorators import api_view, permission_classes


def check_in_hour(request, license_plate):
    check_in_hour = get_checkinhour(license_plate)
    if isinstance(check_in_hour, str):
        # Handling the error case
        return JsonResponse({"error": check_in_hour}, status=404)
    return JsonResponse({"check_in_hour": check_in_hour})


def homepage(request):
    logger.debug("dqondqn")
    return HttpResponse("this is the homepage ( au    cas où)")


def registerpage(request):
    title = "register"
    return render(request, "register.html", {"title": title})


def loginpage(request):
    title = "login"
    return render(request, "login.html", {'title': title})


from .forms import RegisterForm, LoginForm


def register_view(request):
    if request.method == 'GET':
        form = RegisterForm()
        logger.debug("debug MAAAAAAAAAAAAAAAAAN")

        return render(request, 'register.html', {'form': form})

    if request.method == 'POST':
        form = RegisterForm(request.POST)
        logger.debug("randooooooooooooooooooooooooo")
        if form.is_valid():

            user = form.save(commit=False)
            user.save()
            all_users = CustomUser.objects.all()
            for usa in all_users:
                logger.info(f"User '{usa.id}' created successfully.")

            return redirect('homepage')
        else:
            logger.debug("hihiiiiiiiiiiiiiiiiiiiiiiii")
            return render(request, 'register.html', {"form": form, })


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


from django.middleware.csrf import get_token

from django.http import JsonResponse


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
            print("dddddddddddddddddddddddd")
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
                return response
            else:
                return JsonResponse({'error': 'Invalid phone number or password'}, status=400)
        else:
            return JsonResponse(form.errors, status=400)


def login_view(request):
    if request.method == 'POST':
        form = AuthenticationForm(request, request.POST)
        if form.is_valid():
            phonenumber = form.cleaned_data.get('phone_number')
            password = form.cleaned_data.get('password')
            user = authenticate(phone_number=phonenumber, password=password)
            if user is not None:
                login(request, user)
                return redirect('homepage')
            else:

                return render(request, 'login.html', {'form': form, 'error': 'Invalid phone number or password.'})
    else:
        form = AuthenticationForm()
    return render(request, 'login.html', {'form': form})



@api_view(['POST'])
def logout_view(request):
    # Invalidate the user's session or authentication token yay
    logout(request)
    return Response({'message': 'Logout successful'}, status=200)


from rest_framework import viewsets
from .models import CustomUser


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


class UpdatePassword(APIView):
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


from django.contrib.auth import logout
from django.http import JsonResponse


@api_view(['PUT'])
def logout_all_users(request):
    # Iterate over all active sessions and log out users
    for session_key in list(request.session.keys()):
        session = request.session[session_key]
        if '_auth_user_id' in session:
            del request.session[session_key]

    return JsonResponse({'message': 'All users logged out successfully'}, status=200)


@api_view(['GET'])
def Test(request):
    data = {}
    for us in CustomUser.objects.all():
        data[us.id] = us.is_authenticated
    return Response(data)
