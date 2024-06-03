import matplotlib
matplotlib.use('Agg')  # Use the Agg backend

from django.shortcuts import get_object_or_404, render
import matplotlib.pyplot as plt
import tempfile
import os
from .models import Parking, ParkingOwner


from io import StringIO
import numpy as np


def plot_parking_costs(parkings):
    parking_names = [parking.name for parking in parkings]
    total_costs = [sum(session.cost for session in parking.archives.all()) for parking in parkings]

    # Create bar chart
    plt.figure(figsize=(10, 6))
    plt.bar(parking_names, total_costs)
    plt.xlabel('Parking Name')
    plt.ylabel('Total Revenue ($)')
    plt.title('Total Revenue from Each Parking')

    # Save the chart as an image file
    temp_dir = tempfile.mkdtemp()
    image_path = os.path.join(temp_dir, 'parking_revenue_chart.png')
    plt.savefig(image_path)

    return image_path



def generate_matplotlib_image(parkings):
    parking_names = [parking.name for parking, _ in parkings]
    total_costs = [total_cost for _, total_cost in parkings]

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


def your_view(request, id):
    context = {}
    instance = get_object_or_404(ParkingOwner, id=id)
    parkings = instance.parkings.all()
    parking_data = []
    for parking in parkings:
        total_cost = sum(session.cost for session in parking.archives.all())
        parking_data.append((parking, total_cost))
    
    image_data = generate_matplotlib_image(parking_data)
    context['graph'] = image_data
    return render(request, 'your_template.html', context)