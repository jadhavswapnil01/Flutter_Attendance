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
    // Set a common timestamp
    $common_created_at = date('Y-m-d H:i:s'); // Current timestamp in 'YYYY-MM-DD HH:MM:SS' format

    // Update classrooms table with common created_at timestamp
    $sql = "UPDATE classrooms 
            SET classroom_number = ?, 
                teacher_email = ?, 
                teacher_latitude = ?, 
                teacher_longitude = ?, 
                online_attendance_status = 'inactive',
                created_at = ?
            WHERE TRIM(class_name) = TRIM(?) AND 
                  TRIM(subject_code) = TRIM(?) AND 
                  TRIM(subject_name) = TRIM(?) AND
                  TRIM(lecture_type) = TRIM(?)";

    error_log("SQL Query: $sql");

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssddsssss", $classroom_number, $email, $latitude, $longitude, $common_created_at, $class_name, $subject_code, $subject_name, $lec_type);


    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            // Fetch the classroom_id for the updated classroom
            $classroom_id_query = "SELECT classroom_id FROM classrooms 
                                   WHERE TRIM(class_name) = TRIM(?) AND 
                                         TRIM(subject_code) = TRIM(?) AND 
                                         TRIM(subject_name) = TRIM(?) AND
                                         TRIM(lecture_type) = TRIM(?)";
            $classroom_stmt = $conn->prepare($classroom_id_query);
            $classroom_stmt->bind_param("ssss", $class_name, $subject_code, $subject_name, $lec_type);
            $classroom_stmt->execute();
            $classroom_result = $classroom_stmt->get_result();

            if ($classroom_row = $classroom_result->fetch_assoc()) {
                $classroom_id = $classroom_row['classroom_id'];

                // Insert into the attendance table with the same created_at timestamp
                $attendance_sql = "INSERT INTO attendance (classroom_id, class_name, subject_code, subject_name, lecture_type, created_at) 
                                   VALUES (?, ?, ?, ?, ?, ?)";
                $attendance_stmt = $conn->prepare($attendance_sql);
                $attendance_stmt->bind_param("isssss", $classroom_id, $class_name, $subject_code, $subject_name, $lec_type, $common_created_at);

                if ($attendance_stmt->execute()) {
                    echo json_encode(['success' => true, 'message' => 'Classroom updated and attendance record created successfully']);
                } else {
                    echo json_encode(['success' => false, 'message' => 'Classroom updated, but failed to create attendance record']);
                }
            } else {
                echo json_encode(['success' => false, 'message' => 'Classroom ID not found']);
            }
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
