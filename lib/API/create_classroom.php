<?php
include("connect.php");
$conn = dbconnection();

$email = $_POST['email'] ?? null;
$class_name = $_POST['class_name'] ?? null;
$subject_code = $_POST['subject_code'] ?? null;
$subject_name = $_POST['subject_name'] ?? null;
$lec_type = $_POST['lec_type'] ?? null;
$latitude = $_POST['latitude'] ?? null;
$longitude = $_POST['longitude'] ?? null;
$classroom_number = $_POST['classroom_number'] ?? null;
error_log("Class Name: $class_name, Subject Code: $subject_code, Subject Name: $subject_name, Lecture Type: $lec_type");


if ($email && $class_name && $subject_code && $subject_name && $lec_type && $latitude && $longitude && $classroom_number) {
    $sql = "UPDATE classrooms 
            SET classroom_number = ?, 
                teacher_email = ?, 
                teacher_latitude = ?, 
                teacher_longitude = ?, 
                online_attendance_status = 'inactive'
            WHERE TRIM(class_name) = TRIM(?) AND 
                  TRIM(subject_code) = TRIM(?) AND 
                  TRIM(subject_name) = TRIM(?) AND
                  TRIM(lecture_type) = TRIM(?)";

error_log("SQL Query: $sql");

                  
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssddssss", $classroom_number, $email, $latitude, $longitude, $class_name, $subject_code, $subject_name, $lec_type);

    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(['success' => true, 'message' => 'Classroom updated successfully']);
        } else {
            echo json_encode(['success' => false, 'message' => 'No matching classroom found to update']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update classroom']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Missing required fields']);
}

$conn->close();
?>
