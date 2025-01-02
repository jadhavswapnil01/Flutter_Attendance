import sys
import face_recognition

image_path = sys.argv[1]
# print(image_path)

# Load image and generate encoding
image = face_recognition.load_image_file(image_path)
encodings = face_recognition.face_encodings(image)

if len(encodings) > 0:
    print(encodings[0].tolist())
else:
    print("")
