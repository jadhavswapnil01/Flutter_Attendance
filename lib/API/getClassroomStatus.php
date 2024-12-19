<?php
include 'connect.php';
$conn = dbconnection();

$class_name = $_POST['class_name'];
$subject_code = $_POST['subject_code'];
$lecture_type = $_POST['lecture_type'];

$query = "SELECT classroom_id, online_attendance_status 
          FROM classrooms 
          WHERE class_name = ? AND subject_code = ? AND lecture_type = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param('sss', $class_name, $subject_code, $lecture_type);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    echo json_encode($result->fetch_assoc());
} else {
    echo json_encode(['error' => 'Classroom not found']);
}
?>
