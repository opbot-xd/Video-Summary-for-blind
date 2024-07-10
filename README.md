# INTRODUCTION
The app has a very simple one page UI to ensure simplicity for blind people.  
The frontend has explicit voice audio instructions at every step to ensure convinience, so that blind people can easily record videos.    
The process used for caption generation is as follows:  
1. First audio and video are seperated for processing.  
2. Key frame extraction is done using opencv by converting frames to luv format, smoothening them and selecting the frames which have the maximum difference from the ones around them.  
3. An image captioning model by Salesforce is used for captioning each image.  
4. Whisper is used for audio transcription.  
5. Gemini is used for combining the data produced from captioning and transcription.  
The frontend utilizes bloc state management to ensure a smooth user experience.  
For faster processing celery and redis have been used so that backend processing can be asynchronous.  
The summary returned by Gemini is read using text-to-speech for the blind person.  
![WhatsApp Image 2024-07-10 at 22 59 58_4aea107f](https://github.com/MS-githubaccnt/Video-Summary-for-blind/assets/152601846/f24cdf06-2152-4663-b85f-903baae1cc56)

# SETUP
## Backend setup:
1. cd ./backend/video_summary_backend   
2. Make a virtual environment and install all dependencies mention in the requirement.txt   
3. Make a redis instance on port 6379    
4. Check the working with redis-cli ping command    
5. To open the celery worker use the command: celery -A video_summary_backend worker --pool=solo -l info   
6. To setup database: run python manage.py makemigrations  
7. run python manage.py migrate  
8. run python manage.py runserver 0.0.0.0:8000  
9. To setup the keys in the .env refer to the sample.envv  

## Frontend setup:
1. To ensure the latest version run:flutter upgrade (optional)  
2. use flutter pub get  
3. use flutter run  
