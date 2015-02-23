<?php
    $dbuser   = "root";
    $dbpass   = "root";
    $dsn      = "mysql:host=127.0.0.1;dbname=hollyhotel";
    $db = new PDO($dsn, $dbuser, $dbpass);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
?>