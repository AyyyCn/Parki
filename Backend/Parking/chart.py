from django.http import JsonResponse
from django.shortcuts import get_object_or_404
import matplotlib.pyplot as plt
from io import StringIO
from .models import ParkingOwner

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
    instance = get_object_or_404(ParkingOwner, id=id)
    parkings = instance.parkings.all()
    print(parkings)
    parking_data = []

    for parking in parkings:
        total_cost = sum(session.cost for session in parking.archives.all())
        parking_data.append((parking, total_cost))

    image_data = generate_matplotlib_image(parking_data)

    return JsonResponse({'graph': image_data})

def generate_matplotlib_image2(sorted_dates, revenue):
    fig = plt.figure(figsize=(10, 6))
    plt.plot(sorted_dates, revenue)
    plt.xlabel('Date')
    plt.ylabel('Revenue ($)')
    plt.title('Daily Revenue')

    imgdata = StringIO()
    fig.savefig(imgdata, format='svg')
    imgdata.seek(0)

    data = imgdata.getvalue()
    plt.close()  # Close the figure to avoid memory leaks
    return data

def your_view2(request, id):
    
    instance = get_object_or_404(ParkingOwner, id=id)
    parkings = instance.parkings.all()
    print(parkings)
    revenue_by_date = {}

    for parking in parkings:
        sessions = parking.archives.all()
        for session in sessions:
            date = session.entry_time.date()  # Extract date from entry time
            revenue_by_date[date] = revenue_by_date.get(date, 0) + session.cost

    sorted_dates = sorted(revenue_by_date.keys())
    revenue = [revenue_by_date[date] for date in sorted_dates]

    image_data = generate_matplotlib_image2(sorted_dates, revenue)

    return JsonResponse({'graph': image_data})