from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils import timezone
from datetime import timedelta
from django.contrib.auth.models import BaseUserManager
from phonenumber_field.modelfields import PhoneNumberField


class CustomUserManager(BaseUserManager):
    def create_user(self, phone_number, password=None, **extra_fields):
        if not phone_number:
            raise ValueError("phone number is required")

        if 'email' in extra_fields:
            extra_fields['email'] = self.normalize_email(extra_fields['email'])

        # Create a new user instance
        user = self.model(phone_number=phone_number, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)

        return user

    def create_superuser(self, phone_number, password=None, **extra_fields):
        # Set default values for superuser fields
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)

        # Create a superuser using create_user method
        return self.create_user(phone_number, password, **extra_fields)


class CustomUser(AbstractUser):
    id = models.AutoField(primary_key=True)

    first_name = models.CharField(max_length=100, default=None, null=True)
    last_name = models.CharField(max_length=100, default=None, null=True)
    phone_number = PhoneNumberField(unique=True)
    address = models.CharField(max_length=100, default=None, null=True)
    city = models.CharField(max_length=100, default=None, null=True)
    state = models.CharField(max_length=100, default=None, null=True)
    country = models.CharField(max_length=100, default=None, null=True)
    updated_at = models.DateTimeField(auto_now=True)
    subscription = models.IntegerField(default=None, null=True)
    credit = models.IntegerField(default=None, null=True)
    username = None

    USERNAME_FIELD = 'phone_number'
    objects = CustomUserManager()
    def __str__(self):
        return (str(self.first_name) +str(self.last_name) )


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
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    license_plate = models.CharField(max_length=20, unique=True)

    def __str__(self):
        return self.license_plate


class ParkingSession(models.Model):
    parking = models.ForeignKey(Parking, on_delete=models.CASCADE)
    license_plate = models.CharField(max_length=20)
    entry_time = models.DateTimeField(auto_now_add=True)
    paid = models.BooleanField(default=False)
    pay_time = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return self.license_plate

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
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    parking = models.ForeignKey(Parking, on_delete=models.CASCADE)
    start_time = models.DateTimeField()
    duration_hours = models.IntegerField()
    paid = models.BooleanField(default=False)

    def is_active(self):
        """Check if the reservation is currently active."""
        now = timezone.now()
        end_time = self.start_time + timedelta(hours=self.duration_hours)
        return now >= self.start_time and now <= end_time


class ParkingSessionArchive(models.Model):
    # Assuming these fields mirror those in ParkingSession
    license_plate = models.CharField(max_length=20)
    entry_time = models.DateTimeField()
    exit_time = models.DateTimeField()

    pay_time = models.DateTimeField(null=True, blank=True)
    # Additional fields for archiving
    archived_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Archived session for {self.license_plate}"
