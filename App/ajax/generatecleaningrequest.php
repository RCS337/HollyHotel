<?php
/* =====================================================================
 * Inserts maintenance ticket for cleaning based on roomid
 ====================================================================== */
    try {
        //connect to db
        require('ajax_config.php');
        // get data
        $data = file_get_contents("php://input");
        $input = json_decode($data);
        // prepare query
        $query = $db->prepare("call generatecleaningrequestsp(:RoomID)");
       $query->bindParam(':RoomID', $input->RoomID, PDO::PARAM_INT);
       // execute query
        $query->execute();
        // null (close) database object
        $db = null;
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
?>