from django.http import JsonResponse
from .Services.UserServices import get_checkinhour  # Adjust the import path as needed

def check_in_hour(request, license_plate):
    check_in_hour = get_checkinhour(license_plate)
    if isinstance(check_in_hour, str):
        # Handling the error case
        return JsonResponse({"error": check_in_hour}, status=404)
    return JsonResponse({"check_in_hour": check_in_hour})
