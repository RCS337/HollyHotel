<?php
/* =====================================================================
 * TEMPLATE FOR GETTING SINGLE RESULT, WHEN AN ID HAS BEEN PASSED IN
 * MOCK DATA BEING PASSED: {id: 1234}
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
        $query = $db->prepare("SELECT id, firstname, middleinit, lastname FROM customers WHERE id = :id");
        $query->bindParam(':id', $input->id, PDO::PARAM_STR);
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