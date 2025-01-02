import face_recognition

image_path = "C:/Users/swapn/Videos/attendancesysBluetoothOnly/Flutter_Attendance/lib/API/registered_faces/1000011519.jpg"
image = face_recognition.load_image_file(image_path)
face_locations = face_recognition.face_locations(image)
encodings = face_recognition.face_encodings(image)

if len(face_locations) == 0:
    print("No face detected in the test image.")
    
else:
    print("Face detected:", face_locations)
    print(encodings)
