<?php
include("connect.php");
$conn = dbconnection();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $uuid = $_POST['uuid'];
    $face_image = $_POST['face_image'];

    $sql = "SELECT face_image FROM students WHERE uuid = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $uuid);
    $stmt->execute();
    $stmt->bind_result($stored_path);
    $stmt->fetch();

    if ($stored_path) {
        $temp_path = 'C:/Users/swapn/Videos/attendancesysBluetoothOnly/Flutter_Attendance/lib/API/registered_faces/'.uniqid().'.jpg';
        if (file_put_contents($temp_path, base64_decode($face_image)) === false) {
            echo json_encode(["match" => false, "message" => "Failed to save temporary image."]);
            exit;
        }

        $command = escapeshellcmd("celery -A celery_tasks.tasks call compare_faces --args='[\"$temp_path\", \"$stored_path\"]'");
        $task_id = shell_exec($command);

        // Poll Celery for task status
        $status_command = escapeshellcmd("celery -A celery_tasks.tasks result $task_id");
        do {
            sleep(2);
            $status_output = shell_exec($status_command);
        } while (strpos($status_output, '"state": "SUCCESS"') === false);
        unlink($temp_path);
        $result = json_decode($status_output, true);
        echo json_encode(["match" => $result['match'], "message" => $result['error'] ?? null]);
        
    } else {
        echo json_encode(["match" => false, "message" => "No face data found."]);
        
    }

    $stmt->close();
    $conn->close();
}
?>
