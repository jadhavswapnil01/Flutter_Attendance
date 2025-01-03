from celery import Celery
import face_recognition
import numpy as np
import json

app = Celery('attendance_system', broker='redis://localhost:6379/0')

@app.task
def generate_encoding(image_path):
    try:
        # Load image and generate encoding
        image = face_recognition.load_image_file(image_path)
        encodings = face_recognition.face_encodings(image)

        if len(encodings) > 0:
            return json.dumps(encodings[0].tolist())  # Return encoding as JSON
        else:
            return "NO_FACE_DETECTED"
    except Exception as e:
        return f"ERROR: {str(e)}"

@app.task
def compare_encodings(captured_image_path, registered_image_path):
    try:
        # Load images
        image1 = face_recognition.load_image_file(captured_image_path)
        image2 = face_recognition.load_image_file(registered_image_path)

        # Get face encodings
        encodings1 = face_recognition.face_encodings(image1)
        encodings2 = face_recognition.face_encodings(image2)

        if len(encodings1) > 0 and len(encodings2) > 0:
            captured_encoding = encodings1[0]
            encoding2 = encodings2[0]
            distance = np.linalg.norm(captured_encoding - encoding2)

            return "True" if distance < 0.6 else "False"
        else:
            return "False"
    except Exception as e:
        return f"ERROR: {str(e)}"
