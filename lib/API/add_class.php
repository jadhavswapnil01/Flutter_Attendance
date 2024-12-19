<?php

header('Content-Type: application/json');
// Database connection
include("connect.php");
$conn = dbconnection();

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]));
}

// Input from POST request
$className = $_POST['class_name'] ?? null;
$subjectsInput = $_POST['subjects'] ?? null; // Expect (subject_code,subject_name,{lec_types}),...
error_log("Received class_name: $className");
error_log("Received subjects: $subjectsInput");

if (!$className || !$subjectsInput) {
    echo json_encode(["success" => false, "message" => "Invalid input"]);
    exit;
}

// Start processing
$subjectEntries = explode('),(', trim($subjectsInput, "()"));
$subjectCodes = []; // To collect subject codes for insertion into classes table

$conn->begin_transaction(); // Begin a transaction
try {
    // Insert into classes table
    $stmtClass = $conn->prepare("INSERT INTO classes (class_name, subject_codes) VALUES (?, ?)");
    $stmtClass->bind_param("ss", $className, $subjectsInput);

    if (!$stmtClass->execute()) {
        throw new Exception("Error inserting class: " . $stmtClass->error);
    }
    $stmtClass->close();

    // Insert into subjects table
    $stmtSubject = $conn->prepare("INSERT INTO subjects (subject_code, subject_name, lec_type) VALUES (?, ?, ?)");
    $stmtClassroom = $conn->prepare("INSERT INTO classrooms (class_name, subject_code, subject_name, lecture_type) VALUES (?, ?, ?, ?)");

    foreach ($subjectEntries as $entry) {
        // Parsing input (subject_code,subject_name,{lec_types})
        preg_match('/^([a-zA-Z0-9]+),([^,]+),\{([^}]+)\}$/', $entry, $matches);
        error_log("Processing subject entry: $entry");
        if (count($matches) !== 4) {
            error_log("Invalid format for subject: $entry");
            throw new Exception("Invalid subject input format.");
        }

        $subjectCode = $matches[1];
        $subjectName = $matches[2];
        $lecTypes = explode(",", $matches[3]); // Array of lecture types

        // Insert subject into subjects table
        $stmtSubject->bind_param("sss", $subjectCode, $subjectName, $matches[3]);
        if (!$stmtSubject->execute()) {
            error_log("Error inserting subject: " . $stmtSubject->error);
            throw new Exception("Error inserting subject: " . $stmtSubject->error);
        }

        $subjectCodes[] = $subjectCode; // Collect subject codes

        // Insert combinations into classrooms table
        foreach ($lecTypes as $lecType) {
            $stmtClassroom->bind_param("ssss", $className, $subjectCode, $subjectName, $lecType);
            if (!$stmtClassroom->execute()) {
                throw new Exception("Error inserting into classrooms: " . $stmtClassroom->error);
            }
        }
    }

    $stmtSubject->close();
    $stmtClassroom->close();

    // Update classes table with subject codes (comma-separated)
    $subjectCodesStr = implode(",", $subjectCodes);
    $stmtUpdate = $conn->prepare("UPDATE classes SET subject_codes = ? WHERE class_name = ?");
    $stmtUpdate->bind_param("ss", $subjectCodesStr, $className);

    if (!$stmtUpdate->execute()) {
        throw new Exception("Error updating classes table: " . $stmtUpdate->error);
    }

    $stmtUpdate->close();

    // Commit transaction
    $conn->commit();
    echo json_encode(["success" => true, "message" => "Class, subjects, and classrooms added successfully"]);

} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}

$conn->close();
?>
