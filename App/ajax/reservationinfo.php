<?php
// Require database connection config file, includes database object $db
try {
    require('ajax_config.php');
    // Construct query
    $query="SELECT ReservationID, ParentResID, BillToID, BillToFirstName, BillToLastName, GuestID, GuestFirstName, GuestLastName, EventID, EventName, HostID, HostFirstName, HostLastName, RoomType, RoomTypeName, StartDate, EndDate, Rate, Deposit, RoomID, Smoking, ConvertedToStay, Features, Feature_Description FROM reservationinfovw";
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