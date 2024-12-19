<?php
// Database connection
include("connect.php");
$conn = dbconnection();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];
    $prn = $_POST['prn'];
    $email = $_POST['email'];
    $uuid = $_POST['uuid']; // Capture UUID from request
    $class_id = $_POST['class_id']; // Capture class_id from request

    if (isset($_FILES['image'])) {
        $image = $_FILES['image'];
        $targetDir = "registered_faces/";
        $imagePath = $targetDir . basename($image['name']);
        move_uploaded_file($image['tmp_name'], $targetDir . $image['name']);
    }

    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

    $sql = "INSERT INTO `students` (`username`, `password`, `prn_number`, `college_email`, `class_id`, `uuid`, `face_image`) 
            VALUES ('$username', '$hashedPassword', '$prn', '$email', '$class_id', '$uuid', '$imagePath')";

    if ($conn->query($sql) === TRUE) {
        echo "Student registered successfully";
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }

    $conn->close();
}
?>
