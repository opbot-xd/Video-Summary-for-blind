import os
from celery import shared_task
from .models import Video
from .summarizer import generate_summary
import logging

logger = logging.getLogger(__name__)

@shared_task
def process_video(video_id, video_path):
    logger.info(f"Processing video: {video_id}")
    try:
        summary = generate_summary(video_path)
        logger.info(f"Generated summary: {summary}")
        video = Video.objects.get(id=video_id)
        video.summary = summary
        video.save()
        logger.info(f"Video {video_id} updated with summary")
        # Delete the video file after processing
        os.remove(video_path)
        logger.info(f"Deleted video file: {video_path}")
    except Exception as e:
        logger.error(f"Error processing video {video_id}: {e}")
        raise e
