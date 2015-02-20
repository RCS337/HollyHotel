<?php
/* =====================================================================
 * TEMPLATE FOR BUILDING INSERT / UPDATE QUERIES
 * MOCK DATA BEING PASSED: {firstname: "", lastname: "Smith", dob: 1980-03-23}
 ====================================================================== */
    try {
        //connect to db
        require('ajax_config.php');
        // get data
        $data = file_get_contents("php://input");
        $input = json_decode($data);
        // prepare query
        $query = $db->prepare("INSERT INTO customers (firstname, lastname, dob) VALUES (:firstname, :lastname, :dob)");
        $query->bindParam(':id', $input->firstname, PDO::PARAM_STR);
        $query->bindParam(':id', $input->lastname, PDO::PARAM_STR);
        $query->bindParam(':id', $input->dob, PDO::PARAM_STR);
        // execute query
        $query->execute();
        // null (close) database object
        $db = null;
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
?>