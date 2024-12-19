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

if (!isset($data['uuid'])) {
    echo json_encode(['success' => false, 'message' => 'UUID not provided.']);
    exit();
}

$uuid = $data['uuid'];

try {
    // Fetch student's class_id using uuid
    $stmt = $pdo->prepare("SELECT class_id FROM students WHERE uuid = :uuid");
    $stmt->execute(['uuid' => $uuid]);
    $student = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$student) {
        echo json_encode(['success' => false, 'message' => 'Student not found.']);
        exit();
    }

    $class_id = $student['class_id'];

    // Fetch subjects linked to the class
    $stmt = $pdo->prepare("SELECT subject_code, subject_name, lec_type FROM subjects 
                           WHERE FIND_IN_SET(subject_code, (SELECT subject_codes FROM classes WHERE id = :class_id))");
    $stmt->execute(['class_id' => $class_id]);
    $subjects = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!$subjects) {
        echo json_encode(['success' => false, 'message' => 'No subjects found.']);
        exit();
    }

    // Add button IDs
    $formattedSubjects = [];
    foreach ($subjects as $index => $subject) {
        $formattedSubjects[] = [
            'button_id' => $index + 1, // Example ID assignment
            'subject_name' => $subject['subject_name'],
            'subject_code' => $subject['subject_code'],
            'lec_type' => explode(',', $subject['lec_type']),
        ];
    }

    echo json_encode(['success' => true, 'subjects' => $formattedSubjects]);

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Query failed: ' . $e->getMessage()]);
}
?>
