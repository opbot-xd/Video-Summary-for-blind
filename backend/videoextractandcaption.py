import cv2 as cv
import numpy as np
from scipy.signal import argrelextrema
import requests
from PIL import Image
from transformers import BlipProcessor, BlipForConditionalGeneration

    # Setting local maxima criteria
USE_LOCAL_MAXIMA = True
    # Lenght of sliding window taking difference
len_window = 20
    # Chunk size of Images to be processed at a time in memory
max_frames_in_chunk = 500
    # Type of smoothening window from 'flat', 'hanning', 'hamming', 'bartlett', 'blackman' flat window will produce a moving average smoothing.
window_type = "hanning"

def process_frame(frame,prev_frame,frame_diffs,frames):
    luv=cv.cvtColor(frame,cv.COLOR_BGR2LUV)
    curr_frame=luv
    #take a look at case where prev_frame is none that is first frame in chunk
    if curr_frame is not None and prev_frame is not None:
        #returns an array after finding the abs difference of l,u,v value of each pixel in a n image and subtracting both arrays
        diff=cv.absdiff(curr_frame,prev_frame)
        frame_diff=np.sum(diff)
    else:
        frame_diff=None
    if frame_diff is not None:
        frame_diffs.append(frame_diff)
        frames.append(frame)
    del prev_frame
    prev_frame=curr_frame
    return prev_frame,curr_frame

def smooth(x,window_len):
    if x.size<window_len:
        return x
    s = np.r_[2 * x[0] - x[window_len:1:-1], x, 2 * x[-1] - x[-1:-window_len:-1]]
    w=np.hanning(window_len)
    #is a cos based function used for smmotthing signals
    #will devide by sum for noramlise and convolve it which is just mathematical func to apply smoothening
    y=np.convolve(w/w.sum(),s,mode='same')
    return y[window_len-1:-window_len+1]

def frames_in_local_max(frames,frame_diffs):
     extracted_key=[]
     diff_array=np.array(frame_diffs)
     sm_diff_array=smooth(diff_array,len_window)
     # asarray cuz it returns a tuple and to get the first and only array in the new array we use [0]
     #agrelextrema np.greter finds local maxiams and retruns their indices
     frame_indexes = np.asarray(argrelextrema(sm_diff_array, np.greater))[0]
     for i in frame_indexes:
        #confirm shoudnt this be +1
        extracted_key.append(frames[i-1])
     del frames[:]
     del sm_diff_array
     del diff_array
     del frame_diffs[:]
     return extracted_key

def extract_candi_frames(videopath):
    #extracted_candi_frames=[]
    cap=cv.VideoCapture(videopath)
    if not cap.isOpened():
        print("kyu")
        return
    else:
        ret,frame=cap.read()
        i=1
        chunk_no=0
        while ret:
            curr_frame=None
            prev_frame=None
            frame_diffs=[]
            frames=[]
            for _ in range(0,max_frames_in_chunk):
                if ret:
                    prev_frame,curr_frame=process_frame(frame,prev_frame,frame_diffs,frames)
                    i=i+1
                    #i can be used for keeping frame count i may use it for timestamps later 
                    ret,frame=cap.read()
                    #while in a chunk keeps updting to next frame
                else:
                    #if is last chunk and has no more frames in said chunk
                    cap.release()
                    break
            chunk_no=chunk_no + 1
            yield frames,frame_diffs
        cap.release()    

def finalcandi(videopath):
    extracted_candi_frames=[]
    frame_generator=extract_candi_frames(videopath)
    for frames,frame_diffs in frame_generator:
        candi_chunk=[]
        candi_chunk=frames_in_local_max(frames,frame_diffs)
        extracted_candi_frames.extend(candi_chunk)
        return extracted_candi_frames
videopath=""
arr=finalcandi(videopath)
#image captioning
#pretrained model from hugging face
#too much processing power required to train own model also dl knowledge too complex :(
#cpu pytorch
processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-large")
model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-large")
for img in arr:
   img1=cv.cvtColor(img,cv.COLOR_BGR2RGB)
   img2=Image.fromarray(img1)
   #img.convert("RGB")
   img2.show()
   inputs=processor(img2,return_tensors='pt')
   out=model.generate(**inputs)
   print(processor.decode(out[0], skip_special_tokens=True))
