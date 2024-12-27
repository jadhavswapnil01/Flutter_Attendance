<?php
header('Content-Type: application/json');
include("connect.php");
$conn = dbconnection();

$classroom_id = $_GET['classroom_id'] ?? null;

if (!$classroom_id) {
    echo json_encode(['success' => false, 'message' => 'Classroom ID is required.']);
    exit;
}

try {
    // Fetch teacher email based on classroom_id
    $query = $conn->prepare("SELECT teacher_email FROM classrooms WHERE classroom_id = ?");
    $query->bind_param("s", $classroom_id);
    $query->execute();
    $result = $query->get_result()->fetch_assoc();

    if (!$result) {
        echo json_encode(['success' => false, 'message' => 'Classroom not found.']);
        exit;
    }

    $teacher_email = $result['teacher_email'];

    // Fetch SSID based on teacher email
    $query = $conn->prepare("SELECT ssid FROM teachers WHERE email = ?");
    $query->bind_param("s", $teacher_email);
    $query->execute();
    $ssidResult = $query->get_result()->fetch_assoc();

    if (!$ssidResult) {
        echo json_encode(['success' => false, 'message' => 'SSID not found for the teacher.']);
        exit;
    }
     // Fetch uuidBluetooth based on teacher email
     $query = $conn->prepare("SELECT uuid FROM teachers WHERE email = ?");
     $query->bind_param("s", $teacher_email);
     $query->execute();
     $uuidResult = $query->get_result()->fetch_assoc();
 
     if (!$ssidResult) {
         echo json_encode(['success' => false, 'message' => 'SSID not found for the teacher.']);
         exit;
     }

    echo json_encode(['success' => true, 'ssid' => $ssidResult['ssid'],'uuidBluetooth' => $uuidResult['uuid']]);
} catch (mysqli_sql_exception $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
