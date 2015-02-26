<?php
        $data = file_get_contents("php://input");
        $input = json_decode($data);
        $CustomerType = "c";
        $lastID;
        insertCustomer($input);
        // prepare query
function insertCustomer($input){
    $CustomerType = "c";
    try {
        require('ajax_config.php');
        $query = $db->prepare("INSERT INTO CUSTOMER (CustomerType, FirstName, LastName) VALUES (:CustomerType, :FirstName, :LastName)");
        $query->bindParam(':CustomerType', $CustomerType, PDO::PARAM_INT);
        $query->bindParam(':FirstName', $input->FirstName, PDO::PARAM_STR);
        $query->bindParam(':LastName', $input->LastName, PDO::PARAM_STR);
        $query->execute();
        // null (close) database object
        $lastID = $db->lastInsertId();
        echo($lastID);
        $db = null;
        insertPhone($lastID, $input);
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
}
function insertAddress($lastID, $input){
    try {
        require('ajax_config.php');
        $query = $db->prepare("INSERT INTO address (CustomerID, Address1, Address2, City, State, Zip, Country) VALUES (:CustomerID, :Address1, :Address2, :City, :State, :Zip, :Country)");
        $query->bindParam(':CustomerID', $lastID, PDO::PARAM_INT);
        $query->bindParam(':Address1', $input->address1, PDO::PARAM_STR);
        $query->bindParam(':Address2', $input->address2, PDO::PARAM_STR);
        $query->bindParam(':City', $input->city, PDO::PARAM_STR);
        $query->bindParam(':State', $input->state, PDO::PARAM_STR);
        $query->bindParam(':Zip', $input->zip, PDO::PARAM_STR);
        $query->bindParam(':Country', $input->Country, PDO::PARAM_STR);
        $query->execute();
        $db = null;
        insertCC($lastID, $input);
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
}

function insertPhone($lastID, $input){
    try {
        require('ajax_config.php');
        $query = $db->prepare("INSERT INTO phone (CustomerID, PhoneNum) VALUES (:CustomerID, :PhoneNum)");
        $query->bindParam(':CustomerID', $lastID, PDO::PARAM_INT);
        $query->bindParam(':PhoneNum', $input->phoneNum, PDO::PARAM_STR);
        $query->execute();
        $db = null;
        insertAddress($lastID, $input);
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
}

function insertCC($lastID, $input){
    try {
        require('ajax_config.php');
        $query = $db->prepare("INSERT INTO CC_INFO (CustomerID, NameOnCard, CCNumber, ExpMonth, ExpYear) VALUES (:CustomerID, :NameOnCard, :CCNumber, :ExpMonth, :ExpYear)");
        $query->bindParam(':CustomerID', $lastID, PDO::PARAM_INT);
        $query->bindParam(':NameOnCard', $input->nameOnCard, PDO::PARAM_STR);
        $query->bindParam(':CCNumber', $input->CCNumber, PDO::PARAM_STR);
        $query->bindParam(':ExpMonth', $input->ExpMonth, PDO::PARAM_STR);
        $query->bindParam(':ExpYear', $input->ExpYear, PDO::PARAM_STR);
        $query->execute();
        $db = null;
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
}

?>