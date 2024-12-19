<?php
// teacher_register.php

include("connect.php"); // Include database connection
$conn = dbconnection();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Retrieve data from the POST request
    $teacher_id = $_POST['teacher_id'];
    $email = $_POST['email'];
    $username = $_POST['username'];
    $password = $_POST['password'];

    // Input validation
    if (empty($teacher_id) || empty($email) || empty($username) || empty($password)) {
        echo json_encode(["status" => "error", "message" => "All fields are required"]);
        exit();
    }

    // Check if the teacher already exists
    $checkQuery = "SELECT * FROM teachers WHERE teacher_id = ? OR email = ?";
    $stmt = $conn->prepare($checkQuery);
    $stmt->bind_param("ss", $teacher_id, $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "Teacher ID or Email already exists"]);
        exit();
    }

    // Hash the password
    $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

    // Insert into the database
    $insertQuery = "INSERT INTO teachers (teacher_id, email, username, password) VALUES (?, ?, ?, ?)";
    $stmt = $conn->prepare($insertQuery);
    $stmt->bind_param("ssss", $teacher_id, $email, $username, $hashedPassword);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Teacher registered successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to register teacher"]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
?>
