from django.contrib.auth.forms import AuthenticationForm
from django.http import JsonResponse, HttpResponse
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.views.decorators.csrf import csrf_exempt
from .Services.UserServices import get_checkinhour  # Adjust the import path as needed
from django.contrib.auth import login, authenticate
from django.shortcuts import render, redirect
from django import forms
import logging
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
    title= "register"
    return render(request, "register.html", {"title" : title})

def loginpage(request):
    title= "login"
    return render(request, "login.html", {'title' : title})



from .forms import RegisterForm

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
            user.username = user.username.lower()
            user.save()
            all_users= CustomUser.objects.all()
            for usa in all_users:
                logger.info(f"User '{usa.id}' created successfully.")

            return redirect('homepage')
        else:
            logger.debug("hihiiiiiiiiiiiiiiiiiiiiiiii")
            return render(request, 'register.html', {"form": form, })

@api_view(['POST'])
@permission_classes([AllowAny])
def register_viewJSON(request):
    if request.method == 'POST':
        form = RegisterForm(data=request.data)
        if form.is_valid():
            user = form.save(commit=False)
            user.username = user.username.lower()
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
        form = AuthenticationForm(data=request.data)
        if form.is_valid():
            username = form.cleaned_data.get('username')
            password = form.cleaned_data.get('password')
            user = authenticate(username=username, password=password)
            if user is not None:
                login(request, user)
                return Response({'message': 'Login successful'}, status=200)
            else:
                return Response({'error': 'Invalid username or password'}, status=400)
        else:
            return Response(form.errors)


def login_view(request):
    if request.method == 'POST':
        form = AuthenticationForm(request, request.POST)
        if form.is_valid():
            username = form.cleaned_data.get('username')
            password = form.cleaned_data.get('password')
            user = authenticate(username=username, password=password)
            if user is not None:
                login(request, user)
                return redirect('homepage')
            else:

                return render(request, 'login.html', {'form': form, 'error': 'Invalid username or password.'})
    else:
        form = AuthenticationForm()
    return render(request, 'login.html', {'form': form})

@api_view(['GET'])
@permission_classes([AllowAny])
def get_all_users(request):
    all_users = CustomUser.objects.all()
    user_data = []
    for user in all_users:
        user_data.append({
            'id': user.id,
            'username': user.username,
            'email': user.email,
        })
    return JsonResponse({'users': user_data}, status=200)