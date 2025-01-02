<?php
// header('Content-Type: application/json');

include("connect.php");
$conn = dbconnection(); // Include your database connection file
error_reporting(E_ERROR | E_PARSE);


if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $uuid = $_POST['uuid'];
    $face_image = $_POST['face_image'];

    // Fetch stored face encoding
    $sql = "SELECT face_image FROM students WHERE uuid = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $uuid);
    $stmt->execute();
    $stmt->bind_result($stored_path);
    $stmt->fetch();

    if ($stored_path) {
        // Save captured image temporarily
        $temp_path = 'C:/Users/swapn/Videos/attendancesysBluetoothOnly/Flutter_Attendance/lib/API/registered_faces/' . uniqid() . '.jpg';
        if (file_put_contents($temp_path, base64_decode($face_image)) === false) {
            echo json_encode(["match" => false, "message" => "Failed to save temporary image."]);
            exit;
        }

        // Escape paths properly for Python script
        $escaped_temp_path = escapeshellarg($temp_path);
        $escaped_stored_path = escapeshellarg($stored_path);

        // Call Python script to compare encodings
        $command = "python compare_encodings.py $escaped_temp_path $escaped_stored_path";
        $match = trim(shell_exec($command)); // Use trim to remove trailing whitespace
        unlink($temp_path);

        echo json_encode(['match' => $match === "True"]);
    } else {
        echo json_encode(["match" => false, "message" => "No face data found for the provided UUID."]);
    }
    unlink($temp_path);
    $stmt->close();
    $conn->close();
}
?>

