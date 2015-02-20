<?php
/* =====================================================================
 * TEMPLATE FOR BUILDING INSERT / UPDATE QUERIES
 * MOCK DATA BEING PASSED: {FirstName: "John", LastName: "Smith", dob: 1980-03-23}
 ====================================================================== */
    try {
        //connect to db
        require('ajax_config.php');
        // get data
        $data = file_get_contents("php://input");
        $input = json_decode($data);
        // prepare query
        $query = $db->prepare("call insupstdcustomersp(:CustomerID, :FirstName, :LastName, :ContactInfoConfidential, :BillToAddress1, :BillToAddress2
            :BillToAddress3, :BillToAddress4, :BillToCity, :BillToState, :BillToZip, :BillToCountry, :BillToPhonenum)");
       //if CustomerID is null, it will insert a new record, otherwise it will update the record
       $query->bindParam(':CustomerID', $input->CustomerID, PDO::PARAM_INT);
        $query->bindParam(':FirstName', $input->FirstName, PDO::PARAM_STR);
        $query->bindParam(':LastName', $input->LastName, PDO::PARAM_STR);
        $query->bindParam(':ContactInfoConfidential', $input->ContactInfoConfidential, PDO::PARAM_BOOL);
        $query->bindParam(':BillToAddress1', $input->BillToAddress1, PDO::PARAM_STR);
        $query->bindParam(':BillToAddress2', $input->BillToAddress2, PDO::PARAM_STR);
        $query->bindParam(':BillToAddress3', $input->BillToAddress3, PDO::PARAM_STR);
        $query->bindParam(':BillToAddress4', $input->BillToAddress4 PDO::PARAM_STR);
        $query->bindParam(':BillToCity', $input->BillToCity PDO::PARAM_STR);
        $query->bindParam(':BillToState', $input->BillToState PDO::PARAM_STR);
        $query->bindParam(':BillToZip', $input->BillToZip PDO::PARAM_STR);
        $query->bindParam(':BillToCountry', $input->BillToCountry PDO::PARAM_STR);
        $query->bindParam(':BillToPhonenum', $input->BillToPhonenum PDO::PARAM_STR);
       // execute query
        $query->execute();
        // null (close) database object
        $db = null;
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
?>