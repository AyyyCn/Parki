from django import forms
from django.contrib.auth.forms import UserCreationForm

from .models import CustomUser




class RegisterForm(forms.ModelForm):
    class Meta:
        model = CustomUser
        fields= ('last_name', 'phone_number', 'password')
        widgets= {
            'password': forms.PasswordInput()
        }

    def save(self, commit=True):
        user= super().save(commit=False)
        user.set_password(self.cleaned_data['password'])
        if commit:
            user.save()
        return user

class LoginForm(forms.Form):
    phone_number = forms.CharField(max_length=20)
    password = forms.CharField(widget=forms.PasswordInput)
