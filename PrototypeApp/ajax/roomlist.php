<?php
// Require database connection config file, includes database object $db
try {
    require('ajax_config.php');
    // Construct query
    $query = $db->prepare(
        "SELECT a.id, a.bedCount, a.bedType, a.smoking, a.wing, b.pool, b.parking, b.handicap
            FROM room a
                JOIN wing b on a.wing=b.title
    ");
    // Execute query and place results into an associative array
    $query->execute();
    $response = array();
    foreach ($query->fetchAll(PDO::FETCH_ASSOC) as $row) {
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