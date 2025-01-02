<?php
include("connect.php");
$conn = dbconnection();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $uuid = $_POST['uuid'];
    $face_image = $_POST['face_image'];
    
    // Save image temporarily
    $temp_path ='C:/Users/swapn/Videos/attendancesysBluetoothOnly/Flutter_Attendance/lib/API/registered_faces/'.uniqid().'.jpg';
    file_put_contents($temp_path, base64_decode($face_image));
    
    // Call Python script to generate face encoding
    $command = escapeshellcmd("python3 generate_encoding.py $temp_path");
    $encoding = shell_exec($command);
    unlink($temp_path); // Delete temporary file
    
    if ($encoding) {
        $sql = "UPDATE students SET face_data = ? WHERE uuid = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ss", $encoding, $uuid);
    
        if ($stmt->execute()) {
            echo "Face registered successfully!";
        } else {
            echo "Error: " . $conn->error;
        }
    
        $stmt->close();
    } else {
        echo "Error: Failed to generate face encoding.";
    }
    
    $conn->close();
}
?>