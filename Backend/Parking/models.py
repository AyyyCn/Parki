from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta

class User (models.Model) :
    name = models.CharField(max_length=100)
    email = models.EmailField(max_length=100)
    pwd = models.CharField(max_length=100)
    phone = models.CharField(max_length=10)
    address = models.CharField(max_length=100)
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    country = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    susbcription = models.IntegerField()
    credit = models.IntegerField()
    def __str__(self):
        return self.name


class Parking(models.Model):
    name = models.CharField(max_length=255)
    address = models.CharField(max_length=255)
    latitude = models.FloatField()
    longitude = models.FloatField()
    total_spots = models.IntegerField()
    available_spots = models.IntegerField()
    price_per_hour = models.DecimalField(max_digits=6, decimal_places=2)

    def __str__(self):
        return self.name
    def update_availability(self, increment=True):
        """Increment or decrement the available spots."""
        self.available_spots += 1 if increment else -1
        self.save()

class UserCar(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    license_plate = models.CharField(max_length=20, unique=True)

    def __str__(self):
        return self.license_plate

class ParkingSession(models.Model):
    parking = models.ForeignKey(Parking, on_delete=models.CASCADE)
    license_plate = models.CharField(max_length=20)
    entry_time = models.DateTimeField(auto_now_add=True)
    paid = models.BooleanField(default=False)
    pay_time = models.DateTimeField(null=True, blank=True)


    def calculate_duration(self):
        """Calculate the total duration of the parking session in hours."""
        if self.exit_time:
            return (self.exit_time - self.entry_time).total_seconds() / 3600.0
        return 0

    def calculate_cost(self):
        """Calculate the cost of the parking session."""
        duration = self.calculate_duration()
        return duration * self.parking.price_per_hour

class ParkingReservation(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    parking = models.ForeignKey(Parking, on_delete=models.CASCADE)
    start_time = models.DateTimeField()
    duration_hours = models.IntegerField()
    paid = models.BooleanField(default=False)

    def is_active(self):
        """Check if the reservation is currently active."""
        now = timezone.now()
        end_time = self.start_time + timedelta(hours=self.duration_hours)
        return now >= self.start_time and now <= end_time
