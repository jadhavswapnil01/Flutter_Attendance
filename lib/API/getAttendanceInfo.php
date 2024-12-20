<?php
header('Content-Type: application/json');
// Database connection
include("connect.php");
$conn = dbconnection();

$response = array();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $uuid = $_POST['uuid'];
    $className = $_POST['class_name'];
    $subjectCode = $_POST['subject_code'];
    $lectureType = $_POST['lecture_type'];

    try {
        // Step 1: Fetch student_id using UUID
        $stmt = $conn->prepare("SELECT id FROM students WHERE uuid = ?");
        $stmt->bind_param("s", $uuid);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows == 0) {
            throw new Exception("Student not found.");
        }

        $student = $result->fetch_assoc();
        $studentId = $student['id'];

        // Step 2: Fetch classroom_id using class details
        $stmt = $conn->prepare("SELECT classroom_id, online_attendance_status FROM classrooms WHERE class_name = ? AND subject_code = ? AND lecture_type = ?");
        $stmt->bind_param("sss", $className, $subjectCode, $lectureType);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows == 0) {
            throw new Exception("Classroom not found.");
        }

        $classroom = $result->fetch_assoc();
        $classroomId = $classroom['classroom_id'];
        $attendanceStatus = $classroom['online_attendance_status'];

        // Step 3: Fetch attendance details for the classroom
        $stmt = $conn->prepare("SELECT DATE(ended_at) AS date, attendies_id_comma_sep FROM attendance WHERE classroom_id = ?");
        $stmt->bind_param("i", $classroomId);
        $stmt->execute();
        $result = $stmt->get_result();

        $attendanceData = array();

        while ($attendance = $result->fetch_assoc()) {
            $attendanceDate = $attendance['date'];
            $attendies = explode(',', $attendance['attendies_id_comma_sep']);
            
            // Check if student is present
            $status = in_array($studentId, $attendies) ? 'P' : 'A';
            
            $attendanceData[] = array(
                'date' => $attendanceDate,
                'status' => $status
            );
        }

        $response['success'] = true;
        $response['id'] = $studentId;
        $response['classroom_id'] = $classroomId;
        $response['online_attendance_status'] = $attendanceStatus;
        $response['attendance'] = $attendanceData;

    } catch (Exception $e) {
        $response['success'] = false;
        $response['message'] = $e->getMessage();
    }
} else {
    $response['success'] = false;
    $response['message'] = "Invalid request method.";
}

echo json_encode($response);
?>
