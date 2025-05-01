from django import forms
from .models import Manufacturer, Shop
from django.core.validators import URLValidator
from django.core.exceptions import ValidationError

class ManufacturerProfileForm(forms.ModelForm):
    class Meta:
        model = Manufacturer
        fields = [
            'company_name', 'contact_name', 'phone', 'gst', 'address',
            'city', 'state', 'country', 'website', 'product_categories',
            'logo', 'license', 'terms_accepted'
        ]
        widgets = {
            'address': forms.Textarea(attrs={'rows': 4}),
            'product_categories': forms.Textarea(attrs={'rows': 2}),
            'terms_accepted': forms.CheckboxInput(),
            'logo': forms.URLInput(attrs={'placeholder': 'https://example.com/logo.png'}),
        }

    def clean_logo(self):
        logo = self.cleaned_data.get('logo')
        if logo:
            validator = URLValidator()
            try:
                validator(logo)
                # Optional: Check if URL points to an image
                if not logo.lower().endswith(('.png', '.jpg', '.jpeg')):
                    raise forms.ValidationError("Logo URL must point to a PNG or JPG image.")
            except ValidationError:
                raise forms.ValidationError("Invalid URL format.")
        return logo

class ShopProfileForm(forms.ModelForm):
    class Meta:
        model = Shop
        fields = [
            'shop_name', 'contact_name', 'phone', 'gst', 'address',
            'city', 'state', 'country', 'website', 'business_type',
            'logo', 'license', 'terms_accepted'
        ]
        widgets = {
            'address': forms.Textarea(attrs={'rows': 4}),
            'terms_accepted': forms.CheckboxInput(),
            'logo': forms.URLInput(attrs={'placeholder': 'https://example.com/logo.png'}),
        }

    def clean_logo(self):
        logo = self.cleaned_data.get('logo')
        if logo:
            validator = URLValidator()
            try:
                validator(logo)
                if not logo.lower().endswith(('.png', '.jpg', '.jpeg')):
                    raise forms.ValidationError("Logo URL must point to a PNG or JPG image.")
            except ValidationError:
                raise forms.ValidationError("Invalid URL format.")
        return logo