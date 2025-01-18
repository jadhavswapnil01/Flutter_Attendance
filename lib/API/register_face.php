<?php

include("connect.php");
$conn = dbconnection();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $uuid = $_POST['uuid'];
    $face_image = $_POST['face_image'];
    
    // Save image temporarily
    $temp_path ='C:/Users/swapn/Videos/attendancesysBluetoothOnly/Flutter_Attendance/lib/API/registered_faces/'.uniqid().'.jpg';
    if (file_put_contents($temp_path, base64_decode($face_image)) === false) {
        echo json_encode(["success" => false, "message" => "Failed to save image."]);
        exit;
    }
    // file_put_contents($temp_path, base64_decode($face_image));
    
    // Call Python script to generate face encoding
    $command = escapeshellcmd("python generate_encoding.py $temp_path");
    $output = shell_exec($command);

    header('Content-Type: application/json'); // Ensure the response is JSON
    if (trim($output) == "NO_FACE_DETECTED") {
        echo json_encode(["success" => false, "message" => "No face detected in the image."]);
        unlink($temp_path); // Delete temporary file
    } elseif (strpos($output, "ERROR") === 0) {
        echo json_encode(["success" => false, "message" => "Error processing image: " . $output]);
        unlink($temp_path);
    } else {
        // Store encoding in database
        // $face_encoding = $output;
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

    // Cleanup
    // unlink($temp_path);
    $conn->close();
} else {
    header('Content-Type: application/json'); // Ensure the response is JSON
    echo json_encode(["success" => false, "message" => "Invalid request."]);
    $conn->close();
}
