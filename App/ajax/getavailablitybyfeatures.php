<?php
/* =====================================================================
 * Returns a summary of the rooms available for the specified date range
 ====================================================================== */
    try {

        // connect to db
        require('ajax_config.php');
        // get data
        $data = file_get_contents("php://input");
        $input = json_decode($data);
        // prepare query
        $query = $db->prepare("CALL GetAvailablityByFeaturesSp(:pstartdate, :penddate)");
        $query->bindParam(':pstartdate', $input->pstartdate, PDO::PARAM_STR);
        $query->bindParam(':penddate', $input->penddate, PDO::PARAM_STR);
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