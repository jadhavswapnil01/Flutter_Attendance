<?php
include("connect.php");
$conn = dbconnection();// Include your database connection file

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $uuid = $_POST['uuid'];
$face_image = $_POST['face_image'];

// Fetch stored face encoding
$sql = "SELECT face_data FROM students WHERE uuid = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $uuid);
$stmt->execute();
$stmt->bind_result($stored_encoding);
$stmt->fetch();

if ($stored_encoding) {
    // Save captured image temporarily
    $temp_path ='C:/Users/swapn/Videos/attendancesysBluetoothOnly/Flutter_Attendance/lib/API/registered_faces/'.uniqid().'.jpg';
    file_put_contents($temp_path, base64_decode($face_image));

    // Call Python script to compare encodings
    $command = escapeshellcmd("python3 compare_encodings.py $temp_path '$stored_encoding'");
    $match = shell_exec($command);
    unlink($temp_path);

    echo json_encode(['match' => $match == "True"]);
} else {
    echo "Error: No face data found.";
}

$stmt->close();
$conn->close();
}
?>
