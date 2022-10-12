from django.db import models

# Create your models here.
class File(models.Model):
  file = models.FileField(blank=False, null=False)
  filename = models.CharField(max_length=30, default="")
  title = models.CharField(max_length=30, default="")
  timestamp = models.DateTimeField(auto_now_add=True)