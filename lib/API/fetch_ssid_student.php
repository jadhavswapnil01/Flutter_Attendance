<?php
include("connect.php");
$conn = dbconnection();

$classroom_id = $_GET['classroom_id'] ?? null;

if (!$classroom_id) {
    echo json_encode(['success' => false, 'message' => 'Classroom ID is required.']);
    exit;
}

try {
    // Fetch teacher email based on classroom_id
    $query = $db->prepare("SELECT teacher_email FROM classrooms WHERE classroom_id = ?");
    $query->execute([$classroom_id]);
    $result = $query->fetch(PDO::FETCH_ASSOC);

    if (!$result) {
        echo json_encode(['success' => false, 'message' => 'Classroom not found.']);
        exit;
    }

    $teacher_email = $result['teacher_email'];

    // Fetch SSID based on teacher email
    $query = $db->prepare("SELECT ssid FROM teachers WHERE email = ?");
    $query->execute([$teacher_email]);
    $ssidResult = $query->fetch(PDO::FETCH_ASSOC);

    if (!$ssidResult) {
        echo json_encode(['success' => false, 'message' => 'SSID not found for the teacher.']);
        exit;
    }

    echo json_encode(['success' => true, 'ssid' => $ssidResult['ssid']]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
