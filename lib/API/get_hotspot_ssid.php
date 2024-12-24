<?php
// Get SSID for a teacher based on their email
include("connect.php");
$conn = dbconnection();

$email = $_POST['email'];

// Query the database to get the SSID
$query = "SELECT ssid FROM teachers WHERE email = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
  $row = $result->fetch_assoc();
  echo json_encode(['success' => true, 'ssid' => $row['ssid']]);
} else {
  echo json_encode(['success' => false, 'ssid' => null]);
}

$stmt->close();
$conn->close();
?>
