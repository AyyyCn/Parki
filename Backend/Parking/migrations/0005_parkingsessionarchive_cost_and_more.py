# Generated by Django 5.0.4 on 2024-06-03 12:26

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('Parking', '0004_alter_parking_price_per_hour'),
    ]

    operations = [
        migrations.AddField(
            model_name='parkingsessionarchive',
            name='cost',
            field=models.FloatField(null=True),
        ),
        migrations.AddField(
            model_name='parkingsessionarchive',
            name='parking',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, related_name='archives', to='Parking.parking'),
        ),
    ]
