<?php
include("connect.php");
$conn = dbconnection();

// Get POST data
$classroom_id = $_POST['classroom_id'];
$uuid = $_POST['uuid']; // The UUID to get the student ID

if (!$classroom_id || !$uuid) {
    echo json_encode(['status' => 'error', 'message' => 'Missing required parameters.']);
    exit();
}

try {
    // Fetch the student ID from the students table using the provided uuid
    $queryStudent = "SELECT id FROM students WHERE uuid = ?";
    $stmtStudent = $conn->prepare($queryStudent);
    $stmtStudent->bind_param("s", $uuid);
    $stmtStudent->execute();
    $resultStudent = $stmtStudent->get_result();
    
    if ($resultStudent->num_rows === 0) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid UUID.']);
        exit();
    }
    
    // Get the student ID
    $student = $resultStudent->fetch_assoc();
    $student_id = $student['id'];

    // Fetch the `created_at` timestamp for the specified classroom_id
    $queryClassroom = "SELECT created_at FROM classrooms WHERE classroom_id = ?";
    $stmtClassroom = $conn->prepare($queryClassroom);
    $stmtClassroom->bind_param("i", $classroom_id);
    $stmtClassroom->execute();
    $resultClassroom = $stmtClassroom->get_result();
    
    if ($resultClassroom->num_rows === 0) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid classroom ID.']);
        exit();
    }
    
    $classroom = $resultClassroom->fetch_assoc();
    $created_at = $classroom['created_at'];

    // Update the attendance table
    $queryAttendance = "
        UPDATE attendance
        SET attendies_id_comma_sep = 
            CASE 
                WHEN attendies_id_comma_sep IS NULL OR attendies_id_comma_sep = '' 
                THEN ?
                ELSE CONCAT(attendies_id_comma_sep, ',', ?)
            END
        WHERE classroom_id = ? 
          AND created_at = ? 
          AND (attendies_id_comma_sep IS NULL OR FIND_IN_SET(?, attendies_id_comma_sep) = 0)
    ";

    $stmtAttendance = $conn->prepare($queryAttendance);
    $stmtAttendance->bind_param("iiisi", $student_id, $student_id, $classroom_id, $created_at, $student_id);
    $stmtAttendance->execute();

    if ($stmtAttendance->affected_rows > 0) {
        echo json_encode(['status' => 'success', 'message' => 'Attendance marked successfully.']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Attendance already marked or no matching row found.']);
    }

} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'An error occurred: ' . $e->getMessage()]);
}
?>
