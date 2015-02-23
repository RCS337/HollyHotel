<?php
/* =====================================================================
 * inserts a log record for a maintenance ticket and closes the maintenance
*  ticket if specified to do so
 ====================================================================== */
    try {
        //connect to db
        require('ajax_config.php');
        // get data
        $data = file_get_contents("php://input");
        $input = json_decode($data);
        // prepare query
        $query = $db->prepare("call updatemaintticketsp(:MaintTicketID, :MaintenanceDate, :EmployeeID, :Notes, :CloseTicket)");
        $query->bindParam(':MaintTicketID', $input->MaintTicketID, PDO::PARAM_INT);
        $query->bindParam(':MaintenanceDate', $input->MaintenanceDate, PDO::PARAM_STR);       
        $query->bindParam(':EmployeeID', $input->EmployeeID, PDO::PARAM_INT);
        $query->bindParam(':Notes', $input->Notes, PDO::PARAM_STR);
        $query->bindParam(':CloseTicket', $input->CloseTicket, PDO::PARAM_INT);
       // execute query
        $query->execute();
        // null (close) database object
        $db = null;
    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
?>