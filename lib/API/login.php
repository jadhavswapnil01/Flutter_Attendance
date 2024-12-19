<?php
header('Content-Type: application/json');

// Database connection
include("connect.php");
$conn = dbconnection();

// Check connection
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Database connection failed.']);
    exit();
}

// Retrieve POST data
$username = isset($_POST['username']) ? trim($_POST['username']) : '';
$password = isset($_POST['password']) ? trim($_POST['password']) : '';
$uuid = isset($_POST['uuid']) ? trim($_POST['uuid']) : '';

// Input validation
if (empty($username) || empty($password) || empty($uuid)) {
    echo json_encode(['success' => false, 'message' => 'All fields are required.']);
    exit();
}

// Query to fetch user password hash and UUID
$query = $conn->prepare("SELECT password, uuid FROM students WHERE username = ?");
$query->bind_param('s', $username);
$query->execute();
$result = $query->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();

    // Verify the hashed password
    if (password_verify($password, $row['password'])) {
        // Verify UUID
        if ($row['uuid'] === $uuid) {
            echo json_encode(['success' => true, 'message' => 'Login successful.']);
        } else {
            echo json_encode(['success' => false, 'message' => 'UUID mismatch.']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Incorrect password.']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Username not found.']);
}

// Cleanup
$query->close();
$conn->close();
?>
