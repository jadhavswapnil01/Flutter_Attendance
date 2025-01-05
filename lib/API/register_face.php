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
    $command = escapeshellcmd("celery -A celery_tasks.tasks call generate_encoding --args='[\"$temp_path\"]'");
    $task_id = trim(shell_exec($command));

    // Poll Celery for task status
    $status_command = escapeshellcmd("celery -A celery_tasks.tasks result $task_id");
    $result = null;

    do {
        sleep(2); // Wait before checking status
        $status_output = shell_exec($status_command);
        $result = json_decode($status_output, true);
    } while ($result === null || !isset($result['state']) || $result['state'] !== "SUCCESS");

    // Handle Celery task result
    if (isset($result['result']['success']) && $result['result']['success'] === false) {
        if ($result['result']['error'] === "NO_FACE_DETECTED") {
            echo json_encode(["success" => false, "message" => "No face detected in the image."]);
        } else {
            echo json_encode(["success" => false, "message" => $result['result']['error']]);
        }
    } elseif (isset($result['result']['success']) && $result['result']['success'] === true) {
        $sql = "UPDATE students SET face_image = ? WHERE uuid = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ss", $temp_path, $uuid);
        $success = $stmt->execute();
        $stmt->close();

        echo json_encode(["success" => $success, "message" => $success ? "Face registered successfully!" : "Database error."]);
    } else {
        echo json_encode(["success" => false, "message" => "Unexpected error occurred."]);
    }

    // Cleanup
    unlink($temp_path);
    $conn->close();
}
?>
