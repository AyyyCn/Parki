from django.utils import timezone
from ..models import ParkingSession, ParkingSessionArchive
from ..models import CustomUser, UserCar
def get_checkinhour(license_plate):
    """
    Calculate the check in hour.
    """
    try:
        # Find the latest parking session for this license plate that hasn't been paid yet
        parking_session = ParkingSession.objects.filter(
            license_plate=license_plate
        ).latest('entry_time')
        return parking_session.entry_time
    except ParkingSession.DoesNotExist:
        # No unpaid parking session found for this license plate
        return "No unpaid parking session found for this license plate. Please contact support."
def pay(license_plate,parking_id):
    """
    Process payment for a parking session. Marks the session as paid if found.
    """
    try:
        # Find the latest parking session for this license plate that hasn't been paid yet
        parking_session = ParkingSession.objects.filter(
            license_plate=license_plate,
            parking_id=parking_id,
            paid=False  # Filters sessions that haven't been marked as paid
        ).latest('entry_time')

        # Mark the session as paid
        parking_session.paid = True
        parking_session.pay_time = timezone.now()
        parking_session.save()
        return "Payment successful. Thank you! Please leave within 15 minutes."
    except ParkingSession.DoesNotExist:
        # No unpaid parking session found for this license plate
        return "No unpaid parking session found for this license plate. Please contact support."

def get_all_license_plates(user):
    """
    Retrieve all license plates associated with a user.
    """
    return [car.license_plate for car in user.cars.all()]


def add_license_plate(user, license_plate):
    """
    Add a new license plate for the user if it doesn't exist.
    """
    if not UserCar.objects.filter(user=user, license_plate=license_plate).exists():
        UserCar.objects.create(user=user, license_plate=license_plate)
        return f"License plate {license_plate} added successfully."
    else:
        return f"License plate {license_plate} already exists for this user."