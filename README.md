## Backend setup:
cd ./backend/video_summary_backend
make venv and install all dependecies
make a redis instance on port 6379
check with redis-cli ping command
run celery -A video_summary_backend worker --pool=solo -l info for opening celery worker
run python manage.py makemigrations
run python manage.py migrate
run python manage.py runserver 0.0.0.0:8000
.env setup required in this directory refer sample.envv

## Frontend setup:
flutter upgrade (optional)
since running not running
flutter pub get
flutter run