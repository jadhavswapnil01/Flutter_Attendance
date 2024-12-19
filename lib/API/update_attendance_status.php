<?php
include("connect.php");
$conn = dbconnection();

$class_name = $_POST['class_name'] ?? null;
$subject_code = $_POST['subject_code'] ?? null;
$lec_type = $_POST['lec_type'] ?? null;
$new_status = $_POST['status'] ?? null; // 'active' or 'inactive'

if ($class_name && $subject_code && $lec_type && in_array($new_status, ['active', 'inactive'])) {
    // Update only the online_attendance_status and leave created_at as is
    $sql = "UPDATE classrooms 
            SET online_attendance_status = ?, created_at = created_at
            WHERE class_name = ? AND subject_code = ? AND lecture_type = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssss", $new_status, $class_name, $subject_code, $lec_type);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => "Attendance status updated to $new_status"]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update attendance status']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Missing or invalid parameters']);
}

$conn->close();
?>
