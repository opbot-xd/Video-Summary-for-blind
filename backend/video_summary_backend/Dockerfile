# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt /app/
RUN python -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install --no-cache-dir -r requirements.txt

# Copy the project code
COPY . /app/

# Expose the port for Django
EXPOSE 8000

# Run the Django development server
CMD ["/venv/bin/python", "manage.py", "runserver", "0.0.0.0:8000"]
