<?php
include("connect.php");
$conn = dbconnection();

$class_id = $_GET['class_id'] ?? null;

if ($class_id) {
    $sql = "SELECT s.id, s.subject_name FROM subjects s
            JOIN classes c ON FIND_IN_SET(s.subject_code, c.subject_codes)
            WHERE c.id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $class_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $subjectnames = [];
    while ($row = $result->fetch_assoc()) {
        $subjectnames[] = $row;
    }

    echo json_encode(['success' => true, 'subjectnames' => $subjectnames]);
} else {
    echo json_encode(['success' => false, 'message' => 'Class ID missing']);
}

$conn->close();
?>
