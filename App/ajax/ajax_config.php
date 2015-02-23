<?php
    $dbuser   = "root";
    $dbpass   = "1234";
    $dsn      = "mysql:host=127.0.0.1;dbname=hollyhotel";
    $db = new PDO($dsn, $dbuser, $dbpass);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
?>