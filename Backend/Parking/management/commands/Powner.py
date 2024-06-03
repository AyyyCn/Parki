# myapp/management/commands/seed_data.py

from django.core.management.base import BaseCommand
from faker import Faker
from Parking.models import ParkingOwner
import random

class Command(BaseCommand):
    help = 'Seed el database bel parkingowner'
    phones = phone_numbers = [
    "+15551234567",
    "+15552445678",
    "+15553756789",
    "+15554867890",
    "+15555078901",
    "+15556589012",
    "+15557390123",
    "+15558501234",
    "+15559612345",
    "+15550723456"
]

    def handle(self, *args, **kwargs):
        ParkingOwner.objects.all().delete()
        self.stdout.write(self.style.SUCCESS('Deleted all existing parking owners'))

        fake = Faker()
        total_parkings = 10  
        for i in range(total_parkings):
            parkingOwner = ParkingOwner(
                first_name=fake.company(),
                address=fake.address(),
                phone_number= self.phone_numbers[i]
            )
            

            parkingOwner.save()
            saved_owner = ParkingOwner.objects.get(phone_number=self.phone_numbers[i])
            print(f"Saved ParkingOwner: id={saved_owner.id}, first_name={saved_owner.first_name}, address={saved_owner.address}, phone_number={saved_owner.phone_number}")

        self.stdout.write(self.style.SUCCESS(f'tesna3 {total_parkings} parkingower'))
