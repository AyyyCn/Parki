
from django.shortcuts import render
from django.shortcuts import render, redirect, get_object_or_404
from .models import Parking, ParkingSessionArchive
from django.contrib.auth import logout

from .views.Userviews import logout_view, homepage_view
from .forms import ParkingOwnerRegisterForm

import matplotlib
matplotlib.use('Agg')  # Use the Agg backend

from django.shortcuts import get_object_or_404, render
import matplotlib.pyplot as plt
import tempfile
import os
from .models import Parking, ParkingOwner


from io import StringIO
import numpy as np


from django.shortcuts import render
from django.http import JsonResponse
import matplotlib.pyplot as plt
from io import StringIO
import numpy as np
from .models import Parking

def plot_parking_costs(parkings):
    parking_names = [parking.name for parking in parkings]
    total_costs = [sum(session.cost for session in parking.archives.all()) for parking in parkings]

    fig = plt.figure(figsize=(10, 6))
    plt.bar(parking_names, total_costs)
    plt.xlabel('Parking Name')
    plt.ylabel('Total Revenue ($)')
    plt.title('Total Revenue from Each Parking')

    imgdata = StringIO()
    fig.savefig(imgdata, format='svg')
    imgdata.seek(0)

    data = imgdata.getvalue()
    plt.close()  # Close the figure to avoid memory leaks
    return data

def your_view(request):
    parkings = Parking.objects.all()
    return render(request, 'your_template.html', {'parkings': parkings})

def generate_chart(request):
    parkings = Parking.objects.all()
    chart_svg = plot_parking_costs(parkings)
    return JsonResponse({'image_url': 'data:image/svg+xml;base64,' + chart_svg.encode('base64').decode()})


def parking_owner_register(request):
    
    form = ParkingOwnerRegisterForm()
    return render(request, 'parking_owner_register.html')


def parking_archive_sessions(request, pk):
    parking = get_object_or_404(Parking, pk=pk)
    parking_archive_sessions = ParkingSessionArchive.objects.filter(parking=parking)
    total_cost = sum(session.cost for session in parking_archive_sessions)
    return render(request, 'parking_archive_sessions.html', {'parking': parking, 'sessions': parking_archive_sessions, 'total_cost': total_cost})

def Log_out(request):
    logout(request)
    return render(request, "base.html")



def add_parking_PO(request, id):
    if request.method == 'POST':
        form_data = request.POST
        parking = Parking(
                    name=form_data['name'],
                    owner=get_object_or_404(ParkingOwner, pk =id),
                    address=form_data['address'],
                    total_spots=form_data['total_spots'],
                    available_spots=form_data['total_spots'],
                    price_per_hour=form_data['price_per_hour'],
                )
        parking.save()
        return redirect (homepage_view,instance_id=id)

    