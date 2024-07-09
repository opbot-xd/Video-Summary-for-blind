# summarizer/models.py
from django.db import models

class Video(models.Model):
    video_file = models.FileField(upload_to='videos/')
    summary = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
