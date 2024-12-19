<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Database connection
include("connect.php");
$conn = dbconnection();

// Check for POST method
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);

    // Check if UUID is provided
    if (!isset($input['uuid'])) {
        echo json_encode([
            "success" => false,
            "message" => "UUID is required."
        ]);
        exit;
    }

    $uuid = $input['uuid'];

    // Fetch class_id for the student
    $query = "SELECT class_id FROM students WHERE uuid = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("s", $uuid);
    $stmt->execute();
    $stmt->bind_result($class_id);
    $stmt->fetch();
    $stmt->close();

    if (!$class_id) {
        echo json_encode([
            "success" => false,
            "message" => "Class not found for the provided UUID."
        ]);
        exit;
    }

    // Fetch subject codes for the class
    $query = "SELECT subject_codes FROM classes WHERE id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $class_id);
    $stmt->execute();
    $stmt->bind_result($subject_codes);
    $stmt->fetch();
    $stmt->close();

    if ($subject_codes) {
        $subjects = explode(",", $subject_codes);
        echo json_encode([
            "success" => true,
            "subjects" => $subjects
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "No subjects found for the class."
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "message" => "Invalid request method."
    ]);
}
?>
