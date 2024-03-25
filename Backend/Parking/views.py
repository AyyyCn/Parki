from django.http import JsonResponse, HttpResponse
from .Services.UserServices import get_checkinhour  # Adjust the import path as needed
from django.contrib.auth import login
from django.shortcuts import render, redirect
from django import forms




def check_in_hour(request, license_plate):
    check_in_hour = get_checkinhour(license_plate)
    if isinstance(check_in_hour, str):
        # Handling the error case
        return JsonResponse({"error": check_in_hour}, status=404)
    return JsonResponse({"check_in_hour": check_in_hour})

def homepage(request):
    return HttpResponse("this is the homepage ( au    cas où)")

def registerpage(request):
    title= "register"
    return render(request, "register.html", {"title" : title})

def loginpage(request):
    title= "login"
    return render(request, "login.html", {'title' : title})



from .forms import RegisterForm

def register_view(request):
    print("ririri")
    if request.method == 'GET':
        form = RegisterForm()
        print(form)
        print(" random")
        return render(request, 'register.html', {'form': form})

    if request.method == 'POST':
        form = RegisterForm(request.POST)
        print(form)
        if form.is_valid():

            user = form.save(commit=False)
            user.username = user.username.lower()
            user.save()

            login(request, user)
            print(form)
            return redirect('homepage')
        else:
            return render(request, 'register.html', {'form': form})
