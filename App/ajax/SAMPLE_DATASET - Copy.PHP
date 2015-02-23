<?php
/* =====================================================================
 * TEMPLATE FOR GETTING SET OF RESULTS, NO DATA PASSED
 *
 *
 ====================================================================== */

    // Everything is inside the try block to handle exceptions
    try {

        // connect to db
        require('ajax_config.php');
        // get data
        $data = file_get_contents("php://input");
        $input = json_decode($data);
        // prepare query
        $query = $db->prepare("SELECT id, firstname, middleinit, lastname FROM customers");
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