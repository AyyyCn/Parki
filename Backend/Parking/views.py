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
from .forms import RegisterForm, LoginForm
from .Services.UserServices import get_checkinhour  # Adjust the import path as needed
from django.contrib.auth import login, authenticate, logout
from django.shortcuts import render, redirect
from django import forms
import logging

from .UserSerializers import PublicUserInfoSerializer, ChangePasswordSerializer, SelfUserInfoSerializer
from .UserSerializers import PhoneNumberSerializer


from .models import CustomUser
from rest_framework.decorators import api_view, permission_classes


def check_in_hour(request, license_plate):
    check_in_hour = get_checkinhour(license_plate)
    if isinstance(check_in_hour, str):
        # Handling the error case
        return JsonResponse({"error": check_in_hour}, status=404)
    return JsonResponse({"check_in_hour": check_in_hour})


def homepage(request):
    
    return HttpResponse("this is the homepage ( au    cas où)")


def registerpage(request):
    title = "register"
    return render(request, "register.html", {"title": title})


def loginpage(request):
    title = "login"
    return render(request, "login.html", {'title': title})





def register_view(request):
    if request.method == 'GET':
        form = RegisterForm()
        

        return render(request, 'register.html', {'form': form})

    if request.method == 'POST':
        form = RegisterForm(request.POST)
        
        if form.is_valid():

            user = form.save(commit=False)
            user.save()
            

            return redirect('homepage')
        else:
            
            return render(request, 'register.html', {"form": form, })




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












