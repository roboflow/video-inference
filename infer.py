import cv2
import requests
import base64
import json 
import numpy as np
import random
import os

#####CONFIGURATION######
video_file = "IN_VIDEO_PATH"
video_file_out = "OUT_VIDEO_PATH"
api_key = "YOUR_API_KEY"
version = "YOUR_VERSION"
model = "YOUR_MODEL"
#url = "http://localhost:9001/" - #use this for local deployments
url = "http://detect.roboflow.com/"
confidence = 0.2
overlap = 0.5
#frame_limit = 500


###CAPTURE VIDEO###
cap = cv2.VideoCapture(video_file)
fps = cap.get(cv2.CAP_PROP_FPS)
width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
print("VIDEO FPS: ", fps, "VIDEO WIDTH: ",  width, "VIDEO HEIGHT: ", height)
fourcc = cv2.VideoWriter_fourcc(*'MP4V')
out = cv2.VideoWriter(video_file_out, fourcc, fps, (width,height))   

def plot_one_box(x, img, color=None, label=None, line_thickness=None):
    # Plots one bounding box on image img
    tl = line_thickness or round(0.002 * (img.shape[0] + img.shape[1]) / 2) + 1  # line/font thickness
    #color = color or [random.randint(0, 255) for _ in range(3)]
    c1, c2 = (int(x[0]), int(x[1])), (int(x[2]), int(x[3]))
    cv2.rectangle(img, c1, c2, color, thickness=tl, lineType=cv2.LINE_AA)
    if label:
        tf = max(tl - 1, 1)  # font thickness
        t_size = cv2.getTextSize(label, 0, fontScale=tl / 3, thickness=tf)[0]
        c2 = c1[0] + t_size[0], c1[1] - t_size[1] - 3
        cv2.rectangle(img, c1, c2, color, -1, cv2.LINE_AA)  # filled
        cv2.putText(img, label, (c1[0], c1[1] - 2), 0, tl / 3, [225, 255, 255], thickness=tf, lineType=cv2.LINE_AA)

frame_num = 0
ret = True 
while ret:
#while frame_num < frame_limit:
    frame_num += 1
    print(f"Processing Frame {frame_num}")
    #cv2.readframe() --> read frame from stream splitter
    ret, frame = cap.read()
    retval, buffer = cv2.imencode('.jpg', frame)
    img_str = base64.b64encode(buffer)
    img_str = img_str.decode("ascii")

    upload_url = "".join([
        url,
        model,
        "/",
        version,
        "?api_key=",
        api_key,
        "&confidence=",
        str(confidence),
        "&overlap=",
        str(overlap)
    ])

    # POST to the API
    r = requests.post(upload_url, data=img_str, headers={
        "Content-Type": "application/x-www-form-urlencoded"
    })

    json = r.json()

    predictions = json["predictions"]
    print("PREDICTIONS: ", predictions)
    
    formatted_predictions = []
    classes = []

    for pred in predictions:

        formatted_pred = [pred["x"], pred["y"], pred["x"], pred["y"], pred["confidence"]]

        # convert to top-left x/y from center
        formatted_pred[0] = int(formatted_pred[0]  - pred["width"]/2)
        formatted_pred[1] = int(formatted_pred[1]  - pred["height"]/2)
        formatted_pred[2] = int(formatted_pred[2]  + pred["width"]/2)
        formatted_pred[3] = int(formatted_pred[3]  + pred["height"]/2)

        formatted_predictions.append(formatted_pred)
        classes.append(pred["class"])
        color = np.random.randint(0, 255, size=(3, ))
        plot_one_box(formatted_pred, frame, label=pred["class"])

    out.write(frame)

cap.release()        
out.release()

