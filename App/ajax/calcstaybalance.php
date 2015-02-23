<?php
/* =====================================================================
 * USED TO CLOSE OUT BALANCES ON ROOMS, SETS PAID DATE TO TODAY ON ALL TRANSACTIONS
 * MOCK DATA BEING PASSED: {CustomerID: "John", LastName: "Smith", dob: 1980-03-23}
 ====================================================================== */
    try {
        //connect to db
        require('ajax_config.php');
        // get data
        $data = file_get_contents("php://input");
        $input = json_decode($data);
        // prepare query
        $query = $db->prepare("call calcstaybalancesp(:StayID, :CustomerID)");
        $query->bindParam(':StayID', $input->StayID, PDO::PARAM_INT);
        $query->bindParam(':CustomerID', $input->CustomerID, PDO::PARAM_INT);
       // execute query
        $query->execute();
        // null (close) database object
        $db = null;
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
?>