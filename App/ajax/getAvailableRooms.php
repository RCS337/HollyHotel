<?php
    try {

        // connect to db
        require('ajax_config.php');
        // get data
        $data = file_get_contents("php://input");
        $input = json_decode($data);
        // prepare query
        $query = $db->prepare("CALL getavailableroomssp(:pstartdate, :penddate, :proomtype, :psmoking, :prequirements)");
        $query->bindParam(':pstartdate', $input->pstartdate, PDO::PARAM_STR);
        $query->bindParam(':penddate', $input->penddate, PDO::PARAM_STR);
        $query->bindParam(':proomtype', $input->proomtype, PDO::PARAM_INT);
        $query->bindParam(':psmoking', $input->psmoking, PDO::PARAM_INT);
        //if null or blank it will return all rooms, otherwise it will try to match the type of room asked for
        $query->bindParam(':prequirements', $input->prequirements, PDO::PARAM_STR);
        // execute query
        $query->execute();
        $response = $query->fetch(PDO::FETCH_ASSOC);
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