import sys
import face_recognition
import numpy as np

# Define paths
captured_image_path = sys.argv[2]
cap_image2 = sys.argv[1]

# Load images
image1 = face_recognition.load_image_file(captured_image_path)
image2 = face_recognition.load_image_file(cap_image2)

# Get face encodings
encodings1 = face_recognition.face_encodings(image1)
encodings2 = face_recognition.face_encodings(image2)

# Ensure faces are detected in both images
if len(encodings1) > 0 and len(encodings2) > 0:
    captured_encoding = encodings1[0]
    encoding2 = encodings2[0]
    
    if len(encodings1) == 0 or len(encodings2) == 0:
        print("False")
        sys.exit(0)
    
    # Calculate distance between encodings
    distance = np.linalg.norm(captured_encoding - encoding2)
    print("True" if distance < 0.6 else "False")
else:
    print("False")
