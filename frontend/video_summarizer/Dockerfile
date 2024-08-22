# Use a Flutter image with Dart SDK 3.2.2
FROM ghcr.io/cirruslabs/flutter:3.13.0

# Set the working directory
WORKDIR /app

# Copy the Flutter project files
COPY . .

# Install Flutter dependencies
RUN flutter pub get

# Run the Flutter app
CMD ["flutter", "run", "-d", "web-server"]
