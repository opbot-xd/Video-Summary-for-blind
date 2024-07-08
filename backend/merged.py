import cv2 as cv
import numpy as np
from scipy.signal import argrelextrema
from PIL import Image
from transformers import BlipProcessor, BlipForConditionalGeneration
import whisper_timestamped as whisper
import json
import moviepy.editor as mp
import os
import google.generativeai as genai
from dotenv import load_dotenv

# Setting local maxima criteria
USE_LOCAL_MAXIMA = True
# Length of sliding window taking difference
len_window = 20
# Chunk size of Images to be processed at a time in memory
max_frames_in_chunk = 500
# Type of smoothing window from 'flat', 'hanning', 'hamming', 'bartlett', 'blackman' flat window will produce a moving average smoothing.
window_type = "hanning"

def process_frame(frame, prev_frame, frame_diffs, frames):
    luv = cv.cvtColor(frame, cv.COLOR_BGR2LUV)
    curr_frame = luv
    if curr_frame is not None and prev_frame is not None:
        diff = cv.absdiff(curr_frame, prev_frame)
        frame_diff = np.sum(diff)
    else:
        frame_diff = None
    if frame_diff is not None:
        frame_diffs.append(frame_diff)
        frames.append(frame)
    del prev_frame
    prev_frame = curr_frame
    return prev_frame, curr_frame

def smooth(x, window_len):
    if x.size < window_len:
        return x
    s = np.r_[2 * x[0] - x[window_len:1:-1], x, 2 * x[-1] - x[-1:-window_len:-1]]
    w = np.hanning(window_len)
    y = np.convolve(w / w.sum(), s, mode='same')
    return y[window_len - 1:-window_len + 1]

def frames_in_local_max(frames, frame_diffs):
    extracted_key = []
    diff_array = np.array(frame_diffs)
    sm_diff_array = smooth(diff_array, len_window)
    frame_indexes = np.asarray(argrelextrema(sm_diff_array, np.greater))[0]
    for i in frame_indexes:
        extracted_key.append(frames[i - 1])
    del frames[:]
    del sm_diff_array
    del diff_array
    del frame_diffs[:]
    return extracted_key

def extract_candi_frames(videopath):
    cap = cv.VideoCapture(videopath)
    if not cap.isOpened():
        print("Could not open video.")
        return
    else:
        ret, frame = cap.read()
        i = 1
        chunk_no = 0
        while ret:
            curr_frame = None
            prev_frame = None
            frame_diffs = []
            frames = []
            for _ in range(0, max_frames_in_chunk):
                if ret:
                    prev_frame, curr_frame = process_frame(frame, prev_frame, frame_diffs, frames)
                    i += 1
                    ret, frame = cap.read()
                else:
                    cap.release()
                    break
            chunk_no += 1
            yield frames, frame_diffs
        cap.release()

def finalcandi(videopath):
    extracted_candi_frames = []
    frame_generator = extract_candi_frames(videopath)
    for frames, frame_diffs in frame_generator:
        candi_chunk = frames_in_local_max(frames, frame_diffs)
        extracted_candi_frames.extend(candi_chunk)
    return extracted_candi_frames

def extract_audio_from_video(videopath, audiopath):
    video = mp.VideoFileClip(videopath)
    video.audio.write_audiofile(audiopath)

videopath = "t.mp4"
audiopath = "audio.mp3"

# Extract candidate frames
arr = finalcandi(videopath)

# Image captioning
processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-large")
model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-large")

caption_visual = []
for img in arr:
    img1 = cv.cvtColor(img, cv.COLOR_BGR2RGB)
    img2 = Image.fromarray(img1)
    inputs = processor(img2, return_tensors='pt')
    out = model.generate(**inputs)
    caption = processor.decode(out[0], skip_special_tokens=True)
    caption_visual.append(caption)

print("Visual Captions:", caption_visual)

# Extract audio from video
extract_audio_from_video(videopath, audiopath)

# Load audio and model for transcription
audio = whisper.load_audio(audiopath)
model = whisper.load_model("base")

# Specify the language for transcription
language = "en"

# Transcribe the audio
result = whisper.transcribe(model, audio, language=language)

# Format timestamp in SRT style
def format_timestamp(seconds):
    milliseconds = int((seconds - int(seconds)) * 1000)
    return f"{int(seconds // 3600):02}:{int((seconds % 3600) // 60):02}:{int(seconds % 60):02},{milliseconds:03}"

caption_audio = []
with open("captions.srt", "w", encoding="utf-8") as f:
    for i, segment in enumerate(result['segments']):
        start, end = segment['start'], segment['end']
        f.write(f"{i + 1}\n")
        f.write(f"{format_timestamp(start)} --> {format_timestamp(end)}\n")
        f.write(f"{segment['text'].strip()}\n\n")
        caption_audio.append({
            "start": format_timestamp(start),
            "end": format_timestamp(end),
            "text": segment['text'].strip()
        })

print("Audio Captions:", caption_audio)
load_dotenv()

# Access your API key
api_key = os.environ.get('API_KEY')

# Check if API_KEY is set
if not api_key:
    print("Error: Please set the API_KEY environment variable.")
    exit(1)  # Exit the program with an error

# Configure genai with API key
genai.configure(api_key=api_key)

# Initialize the generative model
model = genai.GenerativeModel('gemini-1.5-flash')
visual_captions_text = "\n".join(caption_visual)

# Format the audio captions into a string
audio_captions_text = "\n".join([f"{caption['start']} - {caption['end']}: {caption['text']}" for caption in caption_audio])

# Construct the prompt
prompt = f"""
I am preparing a video summarizer for blind people so they can understand what is happening in the video. Here are the visual descriptions and audio transcriptions of the video. Please generate a summary of that combines both sources of information. Use the visual data first opinion and audio as secondary opinion as blind people can hear. I have also given audio timeline. Make sure that summary doesn't exceed 1000 words but can be less than it.
Visual Descriptions:
{visual_captions_text}

Audio Transcriptions:
{audio_captions_text}

Summary:
"""

# Generate the summary
response = model.generate_content(prompt)

# Print the summary
print(response.text)