<?php
function dbconnection(){
$servername = "localhost";
$username = "root";  // Replace with your DB username
$password = "root123";  // Replace with your DB password
$dbname = "AttendanceSystem";  // Replace with your DB name
$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
return $conn;
}

?>


