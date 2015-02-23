<?php
/* =====================================================================
 * closes out the old room, and creates a maintenance ticket for cleaning
 * creates new stay, using the old rate unless a new rate is specified
 * moves balance of original stay to new stay
 ====================================================================== */
    try {
        //connect to db
        require('ajax_config.php');
        // get data
        $data = file_get_contents("php://input");
        $input = json_decode($data);
        // prepare query
        $query = $db->prepare("call reassignroomsp(:OldStayID, :NewRoomID, :NewRate)");
        $query->bindParam(':OldStayID', $input->OldStayID, PDO::PARAM_INT);
        $query->bindParam(':NewRoomID', $input->NewRoomID, PDO::PARAM_INT);       
        $query->bindParam(':NewRate', $input->NewRate, PDO::PARAM_STR);
       // execute query
        $query->execute();
        // null (close) database object
        $db = null;
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
?>