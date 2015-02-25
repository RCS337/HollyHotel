<?php
    try {

        // connect to db
        require('ajax_config.php');
        // get data
        $data = file_get_contents("php://input");
        $input = json_decode($data);
        // prepare query
        $query = $db->prepare("CALL getavailableroomssp(:pstartdate, :penddate, :proomtype, :psmoking, :prequirements)");
        $query->bindValue(':pstartdate', $input->pstartdate, PDO::PARAM_STR);
        $query->bindValue(':penddate', $input->penddate, PDO::PARAM_STR);
        $query->bindValue(':proomtype', $input->proomtype, PDO::PARAM_INT);
        $query->bindValue(':psmoking', $input->psmoking, PDO::PARAM_INT);
        //if null or blank it will return all rooms, otherwise it will try to match the type of room asked for
        $query->bindValue(':prequirements', $input->prequirements, PDO::PARAM_STR);
        // execute query
        $query->execute();
        $response = array();
        $i = 0;
        foreach ($query->fetchAll(PDO::FETCH_ASSOC) as $row) {;
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