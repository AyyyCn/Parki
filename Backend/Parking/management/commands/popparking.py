# parking_management/management/commands/populate_parking.py
from django.core.management.base import BaseCommand
from ...models import Parking


class Command(BaseCommand):
    help = 'Populate the database with parking objects'

    def handle(self, *args, **options):
        parking_data = [
            {'name': 'Parking A', 'address': '123 Main Street', 'latitude': 40.7128, 'longitude': -74.0060, 'total_spots': 50, 'available_spots': 50, 'price_per_hour': 8.00},
            {'name': 'Parking B', 'address': '456 Elm Street', 'latitude': 34.0522, 'longitude': -118.2437, 'total_spots': 100, 'available_spots': 75, 'price_per_hour': 10.00},
            {'name': 'Parking C', 'address': '789 Oak Street', 'latitude': 41.8781, 'longitude': -87.6298, 'total_spots': 75, 'available_spots': 60, 'price_per_hour': 6.50},
            {'name': 'Parking D', 'address': '101 Pine Street', 'latitude': 51.5074, 'longitude': -0.1278, 'total_spots': 80, 'available_spots': 40, 'price_per_hour': 9.00},
            {'name': 'Parking E', 'address': '202 Cedar Street', 'latitude': 35.6895, 'longitude': 139.6917, 'total_spots': 120, 'available_spots': 100, 'price_per_hour': 7.00},
            {'name': 'Parking F', 'address': '303 Maple Street', 'latitude': 42.3601, 'longitude': -71.0589, 'total_spots': 60, 'available_spots': 55, 'price_per_hour': 8.50},
            # Add more parking data as needed
        ]

        for data in parking_data:
            Parking.objects.create(**data)

        self.stdout.write(self.style.SUCCESS('Parking objects created successfully'))
