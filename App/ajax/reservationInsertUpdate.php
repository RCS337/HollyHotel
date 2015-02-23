<?php
/* =====================================================================
 * inserts a reservation if ReservationID is null
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
        $query = $db->prepare("call insupstdreservationsp(:ReservationID, :ParentResID, :BillToID, :GuestID, :EventID, :RoomType, :StartDate, 
            :EndDate, :Rate, :Deposit, :RoomID, :Smoking, :Features)");
        $query->bindParam(':ReservationID', $input->ReservationID, PDO::PARAM_INT);
        $query->bindParam(':ParentResID', $input->ParentResID, PDO::PARAM_INT);       
        $query->bindParam(':BillToID', $input->BillToID, PDO::PARAM_INT);
        $query->bindParam(':GuestID', $input->GuestID, PDO::PARAM_INT);
        $query->bindParam(':EventID', $input->EventID, PDO::PARAM_INT);
        $query->bindParam(':RoomType', $input->RoomType, PDO::PARAM_INT);
        $query->bindParam(':StartDate', $input->StartDate, PDO::PARAM_STR);
        $query->bindParam(':EndDate', $input->EndDate, PDO::PARAM_STR);
        $query->bindParam(':Rate', $input->Rate PDO::PARAM_STR);
        $query->bindParam(':Deposit', $input->Deposit PDO::PARAM_STR);
        $query->bindParam(':RoomID', $input->RoomID, PDO::PARAM_INT);
        $query->bindParam(':Smoking', $input->Smoking, PDO::PARAM_INT);
        $query->bindParam(':Features', $input->Features PDO::PARAM_STR);
       // execute query
        $query->execute();
        // null (close) database object
        $db = null;
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
?>