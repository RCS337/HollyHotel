<?php
// Require database connection config file, includes database object $db
try {
    require('ajax_config.php');
            
    $data = file_get_contents("php://input");
    $input = json_decode($data);

    echo($input->StartRange . " " . $input->EndRange);
    // Construct query
    $query = $db->prepare("SELECT ReservationID, ParentResID, BillToID, BillToFirstName, BillToLastName, GuestID, GuestFirstName, GuestLastName, EventID, EventName, HostID, HostFirstName, HostLastName, RoomType, RoomTypeName, StartDate, EndDate, Rate, Deposit, Smoking, ConvertedToStay, Features, Feature_Description FROM reservationinfovw WHERE StartDate BETWEEN :StartRange AND :EndRange");
    
    $query->bindValue(':StartRange', $input->StartRange, PDO::PARAM_STR);
    $query->bindValue(':EndRange', $input->EndRange, PDO::PARAM_STR);

    $query->execute();

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
