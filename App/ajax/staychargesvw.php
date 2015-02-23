<?php
// Require database connection config file, includes database object $db
try {
    require('ajax_config.php');
    // Construct query
    //$query="SELECT id, firstname, middleinit, lastname, streetaddress, city, state, zip, phone, dob FROM customers";
    $query="SELECT * FROM staychargesvw";
    // Execute query and place results into an associative array
    $response = array();
    foreach ( $db->query( $query ) as $row ) {
        $response[] = $row;
    }
    // JSON-encode the response
    $json_response = json_encode( $response );
    // Return the response to Angular
    echo $json_response;
    // Null (close) database object
    $db = null;
// Catch and echo any exceptions that occure
} catch ( PDOException $e ){
    echo $e -> getMessage();
}
?>