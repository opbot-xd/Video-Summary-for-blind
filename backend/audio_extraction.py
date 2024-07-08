import whisper_timestamped as whisper
import json

# Load audio and model
audio = whisper.load_audio('audio.mp3')
model = whisper.load_model("base")

# Specify the language you want to transcribe
# Use "auto" for automatic detection if the model supports it
language = "en"  # or specify a language code like "en", "es", "fr", etc.

# Transcribe the audio
result = whisper.transcribe(model, audio, language=language)

# Function to format timestamp in SRT style
def format_timestamp(seconds):
    milliseconds = int((seconds - int(seconds)) * 1000)
    return f"{int(seconds // 3600):02}:{int((seconds % 3600) // 60):02}:{int(seconds % 60):02},{milliseconds:03}"

# Open a file to write the captions
with open("captions.srt", "w", encoding="utf-8") as f:
    for i, segment in enumerate(result['segments']):
        start, end = segment['start'], segment['end']
        f.write(f"{i + 1}\n")
        f.write(f"{format_timestamp(start)} --> {format_timestamp(end)}\n")
        f.write(f"{segment['text'].strip()}\n\n")

# Print the output to terminal as well
for i, segment in enumerate(result['segments']):
    start, end = segment['start'], segment['end']
    print(f"{i + 1}")
    print(f"{format_timestamp(start)} --> {format_timestamp(end)}")
    print(segment['text'].strip())
    print()
