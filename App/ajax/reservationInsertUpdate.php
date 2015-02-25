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
        // $query = $db->prepare("call insupstdreservationsp(:ReservationID, :ParentResID, :BillToID, :GuestID, :EventID, :RoomType, :StartDate,
        //     :EndDate, :Rate, :Deposit, :RoomID, :Smoking, :Features)");
        $query = $db->prepare("INSERT INTO reservation (ParentResID, BillToID, GuestID, EventID, RoomType, StartDate, EndDate, Rate, Deposit, RoomID, Smoking)
                                                VALUES (:ParentResID, :BillToID, :GuestID, :EventID, :RoomType, :StartDate, :EndDate, :Rate, :Deposit, :RoomID, :Smoking)");
        // $query->bindValue(':ReservationID', $input->ReservationID, PDO::PARAM_INT);
        $query->bindValue(':ParentResID', $input->ParentResID, PDO::PARAM_INT);
        $query->bindValue(':BillToID', $input->BillToID, PDO::PARAM_INT);
        $query->bindValue(':GuestID', $input->GuestID, PDO::PARAM_INT);
        $query->bindValue(':EventID', $input->EventID, PDO::PARAM_INT);
        $query->bindValue(':RoomType', $input->RoomType, PDO::PARAM_INT);
        $query->bindValue(':StartDate', $input->StartDate, PDO::PARAM_STR);
        $query->bindValue(':EndDate', $input->EndDate, PDO::PARAM_STR);
        $query->bindValue(':Rate', $input->Rate, PDO::PARAM_STR);
        $query->bindValue(':Deposit', $input->Deposit, PDO::PARAM_STR);
        $query->bindValue(':RoomID', $input->RoomID, PDO::PARAM_INT);
        $query->bindValue(':Smoking', $input->Smoking, PDO::PARAM_INT);
        // $query->bindValue(':Features', $input->Features, PDO::PARAM_STR);
       // execute query
        $query->execute();
        // Return ID of just inserted reservation
        $lastID = $db->lastInsertId();
        echo($lastID);
        $db = null;
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
?>