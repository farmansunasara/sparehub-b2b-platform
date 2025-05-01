from django import template
import os

register = template.Library()

@register.filter
def basename(value):
    if value:
        return os.path.basename(value)
    return ''