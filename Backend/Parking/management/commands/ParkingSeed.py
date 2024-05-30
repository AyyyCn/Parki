# myapp/management/commands/seed_data.py

from django.core.management.base import BaseCommand
from faker import Faker
from Parking.models import Parking
import random

class Command(BaseCommand):
    help = 'Seed el database bel parking'

    def handle(self, *args, **kwargs):
        fake = Faker()
        total_parkings = 10  
        for _ in range(total_parkings):
            parking = Parking(
                name=fake.company(),
                address=fake.address(),
                latitude=fake.latitude(),
                longitude=fake.longitude(),
                total_spots=random.randint(50, 200),  
                available_spots=random.randint(10, 50), 
                price_per_hour=random.uniform(5.0, 20.0)  
            )
            parking.save()

        self.stdout.write(self.style.SUCCESS(f'tesna3 {total_parkings} parking'))
