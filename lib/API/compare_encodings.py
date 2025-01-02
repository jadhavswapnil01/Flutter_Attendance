import sys
import face_recognition
import numpy as np

captured_image_path = sys.argv[1]
stored_encoding = np.array(eval(sys.argv[2]))

# Load captured image and generate encoding
image = face_recognition.load_image_file(captured_image_path)
encodings = face_recognition.face_encodings(image)

if len(encodings) > 0:
    captured_encoding = encodings[0]
    distance = np.linalg.norm(captured_encoding - stored_encoding)
    print("True" if distance < 0.6 else "False")
else:
    print("False")
