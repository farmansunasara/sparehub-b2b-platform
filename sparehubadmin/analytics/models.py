from django.db import models
from django.db.models import JSONField
from users.models import User

class Analytics(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    data = JSONField()
    start_date = models.DateField()
    end_date = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Analytics for {self.user.username} from {self.start_date} to {self.end_date}"
