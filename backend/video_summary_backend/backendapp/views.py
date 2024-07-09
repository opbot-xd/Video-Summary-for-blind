# summarizer/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Video
from .serializers import VideoSerializer
from .tasks import process_video

class VideoUploadView(APIView):
    def post(self, request):
        serializer = VideoSerializer(data=request.data)
        if serializer.is_valid():
            video = serializer.save()
            process_video.delay(video.id, video.video_file.path)
            return Response({'video_id': video.id, 'status': 'Processing'}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class VideoStatusView(APIView):
    def get(self, request, video_id):
        try:
            video = Video.objects.get(id=video_id)
            return Response({'video_id': video.id, 'summary': video.summary, 'status': 'Completed' if video.summary else 'Processing'}, status=status.HTTP_200_OK)
        except Video.DoesNotExist:
            return Response({'error': 'Video not found'}, status=status.HTTP_404_NOT_FOUND)
