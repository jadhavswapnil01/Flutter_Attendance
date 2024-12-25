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
$email = isset($_POST['email']) ? trim($_POST['email']) : '';
$password = isset($_POST['password']) ? trim($_POST['password']) : '';

// Input validation
if (empty($email) || empty($password)) {
    echo json_encode(['success' => false, 'message' => 'Email and password are required.', 'uuid' => null]);
    exit();
}

// Query to fetch user password hash and UUID
$query = $conn->prepare("SELECT password, uuid FROM students WHERE college_email = ?");
$query->bind_param('s', $email);
$query->execute();
$result = $query->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();

    // Verify the hashed password
    if (password_verify($password, $row['password'])) {
        echo json_encode(['success' => true, 'message' => 'Login successful.', 'uuid' => $row['uuid']]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Incorrect password.', 'uuid' => $row['uuid']]);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Email not found.', 'uuid' => null]);
}

// Cleanup
$query->close();
$conn->close();
?>
