<?php

        $data = file_get_contents("php://input");
        $input = json_decode($data);
        echo("First: " . $input->first . "\n");
        echo("Second: " . $input->second . "\n");
        echo("Third: " . $input->third . "\n");

?>