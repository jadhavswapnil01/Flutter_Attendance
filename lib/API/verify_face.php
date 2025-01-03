<?php

include("connect.php");
$conn = dbconnection();

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
        $temp_path = 'C:/Users/swapn/Videos/attendancesysBluetoothOnly/Flutter_Attendance/lib/API/registered_faces/'.uniqid().'.jpg';
        if (file_put_contents($temp_path, base64_decode($face_image)) === false) {
            echo json_encode(["match" => false, "message" => "Failed to save temporary image."]);
            exit;
        }

        // Submit task to Celery for face comparison
        $escaped_temp_path = escapeshellarg($temp_path);
        $escaped_stored_path = escapeshellarg($stored_path);

        $command = "celery -A celery_app compare_encodings.delay('$escaped_temp_path', '$escaped_stored_path')";
        $match = trim(shell_exec($command));

        unlink($temp_path);

        echo json_encode(['match' => $match === "True"]);
    } else {
        echo json_encode(["match" => false, "message" => "No face data found for the provided UUID."]);
    }
    $stmt->close();
    $conn->close();
}
?>
