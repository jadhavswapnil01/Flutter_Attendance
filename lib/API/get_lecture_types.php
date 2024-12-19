<?php
include("connect.php");
$conn = dbconnection();

$subject_id = $_GET['subject_id'] ?? null;

if ($subject_id) {
    $sql = "SELECT lec_type FROM subjects WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $subject_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($row = $result->fetch_assoc()) {
        echo json_encode(['success' => true, 'lec_types' => $row['lec_type']]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Subject not found']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Subject ID missing']);
}

$conn->close();
?>
