<?php
    try {
        // connect to db
        require('ajax_config.php');
        // get data
        $data = file_get_contents("php://input");
        $input = json_decode($data);

        // // If last name is NOT black, add 'like syntax'
        // if ($input->FirstName){
        //     echo("First Set");
        //     $FirstName = $input->FirstName . "%";
        // } else {
        //     $FirstName = "%%";
        // }
        // // If last name is NOT black, add 'like syntax'
        // if ($input->LastName){
        //     echo("Second Set");
        //     $LastName = $input->LastName . "%";
        // } else {
        //     $LastName = "%%";
        // }

        if (isset($input->FirstName) && isset($input->LastName)){
            // if both are set, but blank return
            if($input->FirstName == "" && $input->LastName == ""){
                exit;
            } else {
                $FirstName = ($input->FirstName == "" ? "%%" : $input->FirstName . "%");
                $LastName = ($input->LastName == "" ? "%%" : $input->LastName . "%");
            }
        } elseif (isset($input->FirstName)) {
            if($input->FirstName == ""){
                exit;
            } else {
                $FirstName = $input->FirstName . "%";
                $LastName = "%%";
            }
        } elseif (isset($input->LastName)) {
            if($input->LastName == ""){
                exit;
            } else {
                $LastName = $input->LastName . "%";
                $FirstName = "%%";
            }
        } else {
            exit;
        }

        // prepare query
        $query = $db->prepare("SELECT CustomerID, FirstName, LastName FROM CUSTOMER WHERE FirstName LIKE :FirstName AND LastName LIKE :LastName ORDER BY LastName");
        $query->bindValue(':FirstName', $FirstName, PDO::PARAM_STR);
        $query->bindValue(':LastName', $LastName, PDO::PARAM_STR);
        // execute query
        $query->execute();
        // put results into an array of rows
        $response = array();
        foreach ($query->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $response[] = $row;
        }
        // JSON-encode the response so Javascript can read it
        $json_response = json_encode( $response );
        // return the response to Angular
        echo $json_response;
        // null (close) database object
        $db = null;
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
?>