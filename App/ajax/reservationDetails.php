<?php
   try {
        // connect to db
        require('ajax_config.php');
        // get data
        $data = file_get_contents("php://input");
        $input = json_decode($data);
        // prepare query
        $query = $db->prepare("SELECT ReservationID, ParentResID, BillToID, BillToFirstName, BillToLastName, BillToAddress1, BillToAddress2, BillToCity, BillToState, BillToZip, BillToCountry, BillToPhone,
            GuestID, GuestFirstName, GuestLastName, GuestAddress1, GuestAddress2, GuestCity, GuestState, GuestZip, GuestCountry, EventID, EventName, HostID, HostFirstName, HostLastName, RoomType, RoomTypeName, StartDate, EndDate, Rate, Deposit, RoomID, Smoking, ConvertedToStay, Features, Feature_Description FROM reservationinfovw WHERE ReservationID = :ReservationID");
        $query->bindValue(':ReservationID', $input->ReservationID, PDO::PARAM_INT);
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