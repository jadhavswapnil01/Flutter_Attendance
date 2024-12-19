<?php
include("connect.php");
$conn = dbconnection();

header('Content-Type: application/json');

$subject_id = $_GET['subject_id'] ?? null;

if ($subject_id) {
    $sql = "SELECT subject_code FROM subjects WHERE id = ?";
    $stmt = $conn->prepare($sql);

    if ($stmt) {
        $stmt->bind_param("i", $subject_id);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($row = $result->fetch_assoc()) {
            // Output the subject_code in the response
            echo json_encode(['success' => true, 'subject_code' => $row['subject_code']]);
        } else {
            // No rows found
            echo json_encode(['success' => false, 'message' => 'Subject code not found']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Query preparation failed']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Subject ID missing']);
}

$conn->close();
?>
