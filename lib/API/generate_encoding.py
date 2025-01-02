import sys
import face_recognition
import json

image_path = sys.argv[1]


try:
    # Load image and generate encoding
    image = face_recognition.load_image_file(image_path)
    encodings = face_recognition.face_encodings(image)

    if len(encodings) > 0:
        # Return encoding as JSON
        print(json.dumps(encodings[0].tolist()))
    else:
        print("NO_FACE_DETECTED")
except Exception as e:
    print(f"ERROR: {str(e)}")
