<?php
/* =====================================================================
 * inserts a payment for the stay/customerid, and calls
 * CalcStayBalanceSp which will close out the charges if nets to 0
 ====================================================================== */
    try {
        //connect to db
        require('ajax_config.php');
        // get data
        $data = file_get_contents("php://input");
        $input = json_decode($data);
        // prepare query
        $query = $db->prepare("call makepaymentsp(:StayID, :CustomerID, :Amount, :PaymentType)");
        $query->bindParam(':StayID', $input->StayID, PDO::PARAM_INT);
        $query->bindParam(':CustomerID', $input->CustomerID, PDO::PARAM_INT);       
        $query->bindParam(':Amount', $input->Amount, PDO::PARAM_STR);
        $query->bindParam(':PaymentType', $input->PaymentType, PDO::PARAM_INT);
       // execute query
        $query->execute();
        // null (close) database object
        $db = null;
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
?>