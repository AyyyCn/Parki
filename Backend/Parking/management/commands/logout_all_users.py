from django.core.management.base import BaseCommand
from django.contrib.sessions.models import Session

class Command(BaseCommand):
    help = 'Logs out all users by clearing the session table'

    def handle(self, *args, **kwargs):
        # Delete all sessions
        Session.objects.all().delete()
        
        # Print confirmation message
        self.stdout.write(self.style.SUCCESS('Successfully logged out all users'))
