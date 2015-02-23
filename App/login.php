<?php
session_set_cookie_params(0);
session_start();

// Check if user is already logged in
if(isset( $_SESSION['user_id'] )) {
    header( 'location: /index.php');
}
// Check that both username and password are set
if(isset($_REQUEST['username'], $_REQUEST['password'])) {
    // check that both are alphanumeric characters only
    if (ctype_alnum($_REQUEST['username']) != true) {
        $uError = "Username must be only letters and numbers";
        $error = true;
    }
    if (ctype_alnum($_REQUEST['password']) != true) {
        $pError = "Password must be only letters and numbers";
        $error = true;
    }
    // If we've reached here, there are no errors and we can check DB
    if(!isset($error)){
        $username = filter_var($_REQUEST['username'], FILTER_SANITIZE_STRING);
        $password = filter_var($_REQUEST['password'], FILTER_SANITIZE_STRING);
        // encrypt the password
        $password = sha1($password);
        // connect to user database
        $dbuser   = "root";
        $dbpass   = "1234";
        $dbname   = "hollyhotel";
        $dsn      = "mysql:host=127.0.0.1;dbname=$dbname";
        $db = new PDO($dsn, $dbuser, $dbpass);
        try {
            $stmt = $db->prepare("SELECT userID, username, password FROM users WHERE username = :username AND password = :password");
            $stmt->bindParam(':username', $username, PDO::PARAM_STR);
            $stmt->bindParam(':password', $password, PDO::PARAM_STR, 40);
            $stmt->execute();
            $userID = $stmt->fetchColumn();
            if(!$userID){
                $error_message = "login failed";
            } else {
                $_SESSION['user_id'] = $userID;
                header( 'location: /index.php');
            }
        } catch (Exception $e){
            $error_message = "We are unable to process your request at this time.";
        }
    } // end submission
}
 ?>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Holly Hotel Login</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="apple-touch-icon" href="apple-touch-icon.png">
    <!-- Place favicon.ico in the root directory -->
    <!-- Bootstrap Core CSS -->
    <link href="../css/bootstrap.css" rel="stylesheet">
    <link href="../css/font-awesome/css/font-awesome.css" rel="stylesheet">
    <link href="../css/protoapp.css" rel="stylesheet">
</head>
<body>

<div id="page-wrapper" class="container-fluid">
 <h1>Login</h1>
    <form action="login.php" method="post">

    <?php if(isset($error_message)) {echo $error_message;} ?>
    <label for="username">Username</label>
    <input type="text" id="username" name="username" value="" maxlength="20" placeholder="Username" required/>
    <?php if(isset($uError)) {echo $uError;} ?>

    <label for="password">Password</label>
    <input type="password" id="password" name="password" value="" maxlength="20" placeholder="Password" required/>
    <?php if(isset($pError)) {echo $pError;} ?>

    <input type="submit" value="Login" />

    </form>
</div>

<!-- All of our JavaScript files -->
<script src="../js/jquery/jquery.js"></script>
</body>
</html>