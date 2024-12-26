<?php
header("Content-Type: application/json");

include("connect.php");
$conn = dbconnection();

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]));
}

$email = $_POST['email'] ?? null;
$uuid = $_POST['uuid'] ?? null;

if (!$email || !$uuid) {
    echo json_encode(["success" => false, "message" => "Email and UUID are required."]);
    exit;
}

$sql = "UPDATE teachers SET uuid = ? WHERE email = ?";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(["success" => false, "message" => "SQL preparation failed: " . $conn->error]);
    exit;
}

$stmt->bind_param("ss", $uuid, $email);
$result = $stmt->execute();

if ($result) {
    echo json_encode(["success" => true, "message" => "UUID updated successfully."]);
} else {
    echo json_encode(["success" => false, "message" => "Update failed: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
