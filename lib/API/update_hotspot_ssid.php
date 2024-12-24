<?php
// Update the SSID for a teacher
include("connect.php");
$conn = dbconnection();

$email = $_POST['email'];
$ssid = $_POST['ssid'];

// Query the database to update the SSID
$query = "UPDATE teachers SET ssid = ? WHERE email = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("ss", $ssid, $email);
$result = $stmt->execute();

if ($result) {
  echo json_encode(['success' => true]);
} else {
  echo json_encode(['success' => false]);
}

$stmt->close();
$conn->close();
?>
