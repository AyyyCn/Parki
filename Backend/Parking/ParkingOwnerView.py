
from django.shortcuts import render
from django.shortcuts import render, get_object_or_404
from .models import Parking, ParkingSessionArchive

from .views.Userviews import logout_view
from .forms import ParkingOwnerRegisterForm
def parking_owner_register(request):
    
    form = ParkingOwnerRegisterForm()
    return render(request, 'parking_owner_register.html')


def parking_archive_sessions(request, pk):
    parking = get_object_or_404(Parking, pk=pk)
    parking_archive_sessions = ParkingSessionArchive.objects.filter(parking=parking)
    total_cost = sum(session.cost for session in parking_archive_sessions)
    return render(request, 'parking_archive_sessions.html', {'parking': parking, 'sessions': parking_archive_sessions, 'total_cost': total_cost})
