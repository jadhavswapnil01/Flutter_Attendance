<?php
header('Content-Type: application/json');

// Database connection
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

// Get the raw POST data
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['uuid'])) {
    echo json_encode(['success' => false, 'message' => 'UUID not provided.']);
    exit();
}

$uuid = $data['uuid'];

try {
    // Step 1: Fetch student's class_id using uuid
    $stmt = $pdo->prepare("SELECT class_id FROM students WHERE uuid = :uuid");
    $stmt->execute(['uuid' => $uuid]);
    $student = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$student) {
        echo json_encode(['success' => false, 'message' => 'Student not found.']);
        exit();
    }

    $class_id = $student['class_id'];

    // Step 2: Fetch subject codes for the class
    $stmt = $pdo->prepare("SELECT subject_codes FROM classes WHERE id = :class_id");
    $stmt->execute(['class_id' => $class_id]);
    $class = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$class) {
        echo json_encode(['success' => false, 'message' => 'Class not found.']);
        exit();
    }

    $subject_codes = explode(',', $class['subject_codes']);

    // Step 3: Fetch subject details for the subject codes
    $placeholders = implode(',', array_fill(0, count($subject_codes), '?'));
    $stmt = $pdo->prepare("SELECT subject_name, lec_type FROM subjects WHERE subject_code IN ($placeholders)");
    $stmt->execute($subject_codes);
    $subjects = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!$subjects) {
        echo json_encode(['success' => false, 'message' => 'No subjects found.']);
        exit();
    }

    // Step 4: Format the response
    $formattedSubjects = [];
    foreach ($subjects as $subject) {
        $lectureTypes = explode(',', $subject['lec_type']);
        $formattedSubjects[] = [
            'subject_name' => $subject['subject_name'],
            'lec_type' => $lectureTypes
        ];
    }

    echo json_encode(['success' => true, 'subjects' => $formattedSubjects]);

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Query failed: ' . $e->getMessage()]);
}
