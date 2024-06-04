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
        parser.add_argument('archive_count', type=int, help='Number of archives per parking to create')

    def handle(self, *args, **kwargs):
        phone_number = kwargs['phone_number']
        parking_count = kwargs['parking_count']
        archive_count = kwargs['archive_count']

        try:
            owner = ParkingOwner.objects.get(phone_number=phone_number)
        except ParkingOwner.DoesNotExist:
            self.stdout.write(self.style.ERROR(f"ParkingOwner with phone number {phone_number} does not exist"))
            return

        parkings = []
        parking_archives = []
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
            parkings.append(parking)

            # Create corresponding parking archives
            for j in range(archive_count):
                parking_archive = ParkingSessionArchive(
                    parking=parking,
                    license_plate=f'ABC123',  # Set license plate to appropriate value
                    entry_time=timezone.now(),  # Set entry time to appropriate value
                    exit_time=timezone.now() + timedelta(hours=1),  # Set exit time to appropriate value
                    cost=random.randint(50, 200),  # Set cost to appropriate value
                    pay_time=timezone.now() + timedelta(hours=1),  # Set pay time to appropriate value
                )
                parking_archives.append(parking_archive)

        Parking.objects.bulk_create(parkings)
        ParkingSessionArchive.objects.bulk_create(parking_archives)
        
        self.stdout.write(self.style.SUCCESS(f"Successfully created {parking_count} parkings and {archive_count} archives per parking for {owner}"))
