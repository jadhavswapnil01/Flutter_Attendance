import face_recognition
import numpy as np
# import os
from celery import Celery
import logging

app = Celery('tasks')
app = Celery(
    'celery_tasks',
    broker='redis://localhost:6379/0',  # Redis as broker
    backend='redis://localhost:6379/0',  # Redis for result storage
)
app.conf.update(
    
    include=['celery_tasks.tasks'],
    task_serializer='json',
    result_serializer='json',
    accept_content=['json'],
    timezone='UTC',
    enable_utc=True,
)


@app.task(bind=True)
def generate_encoding(self, image_path):
    logging.info(f"Received image path: {image_path}")
    try:
        image = face_recognition.load_image_file(image_path)
        encodings = face_recognition.face_encodings(image)
        
        if len(encodings) > 0:
            return {"success": True, "encoding": encodings[0].tolist()}
        return {"success": False, "error": "NO_FACE_DETECTED"}
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.task(bind=True)
def compare_faces(self, image_path1, image_path2):
    try:
        image1 = face_recognition.load_image_file(image_path1)
        image2 = face_recognition.load_image_file(image_path2)
        encodings1 = face_recognition.face_encodings(image1)
        encodings2 = face_recognition.face_encodings(image2)
        
        if len(encodings1) == 0 or len(encodings2) == 0:
            return {"match": False, "error": "No_Face_Detected_In_One_Or_Both_Images"}
        
        
        if len(encodings1) > 0 and len(encodings2) > 0:
            distance = np.linalg.norm(encodings1[0] - encodings2[0])
            return {"match": True if distance < 0.6 else False}
        return {"match": False, "error": "FACE_NOT_DETECTED"}
    except Exception as e:
        return {"match": False, "error": str(e)}
