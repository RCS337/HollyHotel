<?php
// Begin the session
session_start();

// Unset all of the session variables.
session_unset();

// Destroy the session.
session_destroy();

// Redirect back to login.php
header('location: login.php')
?>