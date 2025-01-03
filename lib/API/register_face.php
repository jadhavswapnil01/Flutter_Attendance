<?php

include("connect.php");
$conn = dbconnection();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $uuid = $_POST['uuid'];
    $face_image = $_POST['face_image'];

    // Save image temporarily
    $temp_path = 'C:/Users/swapn/Videos/attendancesysBluetoothOnly/Flutter_Attendance/lib/API/registered_faces/'.uniqid().'.jpg';
    if (file_put_contents($temp_path, base64_decode($face_image)) === false) {
        echo json_encode(["success" => false, "message" => "Failed to save image."]);
        exit;
    }

    // Submit task to Celery for encoding generation
    $command = "celery -A celery_app generate_encoding.delay('$temp_path')";
    $output = shell_exec($command);

    // You can handle the output here to check task success or failure.
    if (trim($output) == "NO_FACE_DETECTED") {
        echo json_encode(["success" => false, "message" => "No face detected in the image."]);
        unlink($temp_path); // Delete temporary file
    } else {
        // Store encoding in the database (or the path if you decide not to store the encoding directly)
        $sql = "UPDATE students SET face_image = ? WHERE uuid = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ss", $temp_path, $uuid);

        $success = $stmt->execute();
        $stmt->close();

        if ($success) {
            echo json_encode(["success" => true, "message" => "Face registered successfully!"]);
        } else {
            echo json_encode(["success" => false, "message" => "Error saving face encoding."]);
        }
    }

    $conn->close();
} else {
    header('Content-Type: application/json');
    echo json_encode(["success" => false, "message" => "Invalid request."]);
    $conn->close();
}
?>
