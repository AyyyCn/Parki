# parking/services.py
from django.utils import timezone
from ..models import ParkingSession, ParkingSessionArchive

def start_parking_session(license_plate, parking_id):
    """Start a new parking session for the given license plate and parking spot."""
    
    existing_session = ParkingSession.objects.filter(
        license_plate=license_plate,
        paid=False,
        parking_id=parking_id
    ).first()

    if existing_session:
        # An active session already exists; handle as needed
        return existing_session

    # No active session found, start a new one
    new_session = ParkingSession.objects.create(
        license_plate=license_plate,
        parking_id=parking_id,
        entry_time=timezone.now(),
        paid=False  # Assume unpaid at start
    )
    #send to front signal session started
    return "Welcome! Your parking session has started. Please pay before exiting."

def exit_parking_session(license_plate,parking_id):
    """
    Process exiting for cars. Finds the active parking session for the given license plate.
    If the session is paid, marks it as exited. Otherwise, indicates payment is needed.
    """
    try:
        # Attempt to find the latest parking session for this license plate that hasn't been exited yet
        parking_session = ParkingSession.objects.filter(
            license_plate=license_plate,
            parking_id=parking_id  # Filters sessions that haven't been marked as exited
        ).latest('entry_time')

        if parking_session.paid :
            # If the session is paid, mark it as exited
            grace_period_end = parking_session.pay_time + timezone.timedelta(minutes=1)
            if timezone.now() > grace_period_end:
                # If the current time is past the grace period, extra payment is required.
                return "You stayed extra and need to pay extra."

            archive_and_delete_session(parking_session)
            #send to front signal session ended
            return "Gate opened. Thank you for your visit!"
        
        else:
            # If the session is not paid, inform the user/payment required
            return "Payment required. Please pay to exit."

    except ParkingSession.DoesNotExist:
        # No active parking session found for this license plate
        return "No active parking session found for this license plate. Please contact support."
    
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
