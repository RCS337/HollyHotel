<?php
/* =====================================================================
 * inserts a stay record
 * BillToID is required
 * If passing from a reservation only reservationid, billtoid and roomnumber are required
 ====================================================================== */
    try {
        //connect to db
        require('ajax_config.php');
        // get data
        $data = file_get_contents("php://input");
        $input = json_decode($data);
        // prepare query
        $query = $db->prepare("call insertstaysp(:BillToID, :GuestID, :ReservationID, :EventID, :RoomID, :RoomType :AnticipatedCheckOut, :Rate, :Deposit)");
       $query->bindParam(':BillToID', $input->BillToID, PDO::PARAM_INT);
        $query->bindParam(':GuestID', $input->GuestID, PDO::PARAM_INT);
        $query->bindParam(':ReservationID', $input->ReservationID, PDO::PARAM_INT);
        $query->bindParam(':EventID', $input->EventID, PDO::PARAM_INT);
        $query->bindParam(':RoomID', $input->RoomID, PDO::PARAM_INT);
        $query->bindParam(':RoomType', $input->RoomType, PDO::PARAM_INT);
        $query->bindParam(':AnticipatedCheckOut', $input->AnticipatedCheckOut, PDO::PARAM_STR);
        $query->bindParam(':Rate', $input->Rate, PDO::PARAM_STR);
        $query->bindParam(':Deposit', $input->Deposit, PDO::PARAM_STR);
       // execute query
        $query->execute();
        // null (close) database object
        $lastID = $db->lastInsertId();
        echo($lastID);
        $db = null;
        return $lastID;
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
?>