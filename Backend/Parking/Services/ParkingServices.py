# parking/services.py
from django.utils import timezone
from ..models import ParkingSession, ParkingSessionArchive
from django.shortcuts import get_object_or_404
from ..models import Parking
def start_parking_session(license_plate, parking_id):
    """Start a new parking session for the given license plate and parking spot."""
    
    existing_session = ParkingSession.objects.filter(
        license_plate=license_plate,
        paid=False,
        parking_id=parking_id
    ).first()

    if existing_session:
        # An active session already exists; handle as needed
        return {"message": "Your Spot is waiting for you", "status": "session_already_active"}

    #check if there is a spot
    parking=get_object_or_404(Parking, id=parking_id)
    if parking.available_spots == 0:
        return {"message": "No available spots at the moment. Please try again later.", "status": "no_spots_available"}
    # No active session found, start a new one
    new_session = ParkingSession.objects.create(
        license_plate=license_plate,
        parking_id=parking_id,
        entry_time=timezone.now(),
        paid=False  # Assume unpaid at start
    )
    #send to front signal session started
    parking=get_object_or_404(Parking, id=parking_id)
    parking.update_availability(increment=False)
    return {"message": "Welcome!", "status": "session_started"}
def exit_parking_session(license_plate, parking_id):
    try:
        parking_session = ParkingSession.objects.filter(
            license_plate=license_plate,
            parking_id=parking_id
        ).latest('entry_time')

        if parking_session.paid or parking_session.parking.price_per_hour == 0 or parking_session.calculate_cost() == 0:
            if(parking_session.parking.price_per_hour != 0):
                grace_period_end = parking_session.pay_time + timezone.timedelta(minutes=15)
                if timezone.now() > grace_period_end:
                    return {"message": "You stayed extra and need to pay extra.", "status": "extra_payment_required"}
            parking=get_object_or_404(Parking, id=parking_id)
            parking.update_availability(increment=True)
            archive_and_delete_session(parking_session)
            return {"message": "Gate opened. Thank you for your visit!", "status": "exited_successfully"}
        
        else:
            return {"message": "Payment required. Please pay to exit.", "status": "payment_required"}
        
    except ParkingSession.DoesNotExist:
        return {"message": "No active parking session found for this license plate. Please contact support.", "status": "no_session_found"}

def archive_and_delete_session(parking_session):
    # Copy data to the archive model
    ParkingSessionArchive.objects.create(
        license_plate=parking_session.license_plate,
        entry_time=parking_session.entry_time,
        exit_time=timezone.now(),
        pay_time=parking_session.pay_time,
        # No need to set archived_at; it's auto-set to now
    )
    # Delete the original session
    parking_session.delete()

def open_gate(parking_id):
    """Opens the gate for the user to exit."""
    #send_signal_to_gate(parking_id)
    return "Gate opened. Thank you for your visit!"

def reservation_place(parking_id, licence_plate):
    parking = get_object_or_404(Parking, id=parking_id)
    if parking.available_spots > 0:
        parking.update_availability(increment=False)
        return start_parking_session(licence_plate, parking_id)
    else:
        return {"message": "No available spots at the moment. Please try again later.", "status": "no_spots_available"}
    