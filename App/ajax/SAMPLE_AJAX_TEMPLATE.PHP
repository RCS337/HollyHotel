<?php
/* =====================================================================
 * TEMPLATE FOR BUILDING QUERIES, IT SHOULD CONTAIN EVERYTHING
 * NEEDED TO BUILD JUST ABOUT ANY QUERIES
 *
 *
 ====================================================================== */

    // Everything is inside the try block to handle exceptions
    try {

        // STEP 1: Require database connection config file, includes database object $db
        require('ajax_config.php');

        // STEP 2: IF data is being passed TO this script, get it and decode it
        $data = file_get_contents("php://input"); // get the parameters passed by javascript to this file
        $input = json_decode($data); // decodes from a Javascript Object to a PHP Object
            // * Data will be passed in JSON format: {id: 1234, firstname: "John", lastname: "Smith"}

        // STEP 3: Construct query - any query can be put in here, line breaks, etc OK
        $query = $db->prepare("SELECT id, firstname, middleinit, lastname FROM customers");

        // STEP 3a: IF using supplied data from step 2, the query will have a data placeholder
        $query = $db->prepare("SELECT id, firstname, middleinit, lastname FROM customers WHERE id = :id");

        // STEP 3b: IF using supplied data, bind value from step 2 to placeholder in step 3
        // Can bind as many values as necessary
        $query->bindParam(':id', $input->id, PDO::PARAM_STR);
            // * last argument checks data, can be PDO::PARAM_BOOL, PDO::PARAM_NULL, PDO::PARAM_INT, PDO::PARAM_STR (string used for everything not bool, int, or null)
            // * DOES NOT change the data type in the database, just runs a check to guard against malacious injection and escapes malacious code

        // STEP 4: Execute query
        $query->execute();

        // STEP 5a: IF returning data SET, loop over results and put each row in an array
            //  ('fetchAll' has built in pointer that will keep fetching)
        $response = array();
        foreach ($query->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $response[] = $row;
        }
        // STEP 5b: IF returning single result ('fetch' will only return first result)
        $response = $query->fetch(PDO::FETCH_ASSOC);

        // STEP 6: JSON-encode the response so Javascript can read it
        $json_response = json_encode( $response );

        // STEP 7: Return the response to Angular
        echo $json_response;

        // STEP 8: Null (close) database object
        $db = null;

    // Catch and echo any exceptions that occure
    } catch ( PDOException $e ){
        echo $e -> getMessage();
    }
?>