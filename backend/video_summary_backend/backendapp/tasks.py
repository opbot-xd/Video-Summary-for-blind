# summarizer/tasks.py
from celery import shared_task
from .models import Video
from .summarizer import generate_summary
import os

@shared_task
def process_video(video_id, video_path):
    summary = generate_summary(video_path)
    video = Video.objects.get(id=video_id)
    video.summary = summary
    video.save()
    
    # Delete the video file after processing
    os.remove(video_path)
