from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
from ...models import ParkingOwner, Parking, ParkingSessionArchive
import random

class Command(BaseCommand):
    help = 'Create parkings for a given phone number'

    def add_arguments(self, parser):
        parser.add_argument('phone_number', type=str, help='Phone number of the parking owner')
        parser.add_argument('parking_count', type=int, help='Number of parkings to create')

    def handle(self, *args, **kwargs):
        phone_number = kwargs['phone_number']
        parking_count = kwargs['parking_count']

        try:
            owner = ParkingOwner.objects.get(phone_number=phone_number)
        except ParkingOwner.DoesNotExist:
            self.stdout.write(self.style.ERROR(f"ParkingOwner with phone number {phone_number} does not exist"))
            return

        parkings = []
        for i in range(parking_count):
            parking_name = f'Parking {i+1}'
            parking_address = f'Address {i+1}'
           
            latitude = 0.0  # Set latitude to appropriate value
            longitude = 0.0  # Set longitude to appropriate value
            total_spots = 50  # Set total_spots to appropriate value
            available_spots = total_spots  # Set available_spots to appropriate value
            price_per_hour = 10.0  # Set price_per_hour to appropriate value

            parking = Parking(
                name=parking_name,
                owner=owner,
                address=parking_address,
                latitude=latitude,
                longitude=longitude,
                total_spots=total_spots,
                available_spots=available_spots,
                price_per_hour=price_per_hour,
            )
            parking.save()  
            for _ in range(random.randint(1, 6)):  
                entry_time = timezone.now() - timedelta(days=random.randint(1, 7))  
                exit_time = entry_time + timedelta(hours=random.randint(1, 24))  
                pay_time = exit_time + timedelta(hours=random.randint(1, 24))  
                parking_archive = ParkingSessionArchive(
                    parking=parking,
                    license_plate=f'ABC123',  
                    entry_time=entry_time,  
                    exit_time=exit_time,  
                    cost=random.randint(50, 200),  
                    pay_time=pay_time,  
                )
                parking_archive.save()

        self.stdout.write(self.style.SUCCESS(f"Successfully created {parking_count} parkings with random count of archives per parking for {owner}"))
