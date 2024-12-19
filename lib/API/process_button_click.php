<?php
header('Content-Type: application/json');

$host = 'localhost';
$dbname = 'attendancesystem';
$username = 'root';
$password = 'root123';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database connection failed.']);
    exit();
}

$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['uuid'], $data['button_id'])) {
    echo json_encode(['success' => false, 'message' => 'Invalid request data.']);
    exit();
}

$uuid = $data['uuid'];
$buttonId = $data['button_id'];

try {
    // Fetch the student's class ID
    $stmt = $pdo->prepare("SELECT class_id FROM students WHERE uuid = :uuid");
    $stmt->execute(['uuid' => $uuid]);
    $student = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$student) {
        echo json_encode(['success' => false, 'message' => 'Student not found.']);
        exit();
    }

    $class_id = $student['class_id'];

    // Fetch the class name using the class ID
    $stmt = $pdo->prepare("SELECT class_name FROM classes WHERE id = :class_id");
    $stmt->execute(['class_id' => $class_id]);
    $class = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$class) {
        echo json_encode(['success' => false, 'message' => 'Class not found.']);
        exit();
    }

    $class_name = $class['class_name'];

    // Fetch the subject details
    $stmt = $pdo->prepare("
        SELECT subject_name, subject_code, lec_type
        FROM subjects
        WHERE FIND_IN_SET(subject_code, 
            (SELECT subject_codes FROM classes WHERE id = :class_id)
        ) 
        LIMIT 1 OFFSET :offset
    ");
    $stmt->bindParam(':class_id', $class_id);
    $stmt->bindValue(':offset', $buttonId - 1, PDO::PARAM_INT);
    $stmt->execute();

    $subject = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$subject) {
        echo json_encode(['success' => false, 'message' => 'No subject found for the button ID.']);
        exit();
    }

    // Include class_name and lec_type in the response
    $subject['class_name'] = $class_name;
    $subject['lec_type'] = $subject['lec_type']; // Ensure lec_type is included

    echo json_encode(['success' => true, 'subject' => $subject]);

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Query failed: ' . $e->getMessage()]);
}
?>
