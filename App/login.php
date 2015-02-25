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
        // $dbuser   = "root";
        // $dbpass   = "1234";
        // $dbname   = "hollyhotel";
        // $dsn      = "mysql:host=127.0.0.1;dbname=$dbname";
        // $db = new PDO($dsn, $dbuser, $dbpass);
        include('ajax/ajax_config.php');
        try {
            $stmt = $db->prepare("SELECT userID, username, password FROM users WHERE username = :username AND password = :password");
            $stmt->bindParam(':username', $username, PDO::PARAM_STR);
            $stmt->bindParam(':password', $password, PDO::PARAM_STR, 40);
            $stmt->execute();
            $result = $stmt->fetch();
            $userID = $result['userID'];
            if(!$userID){
                $error_message = "login failed";
            } else {
                $_SESSION['user_id'] = $userID;
                $_SESSION['user_name'] = $result['username'];
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
    <link href="../css/login.css" rel="stylesheet">
</head>
<body>

<div id="align">
<div id="login-form">
<div class="col-xs-12 form-group">
 <h1>Holly Hotel Login</h1>
 </div>
    <form action="login.php" method="post" class="clearfix">
    <div class="col-xs-12 form-group">
        <?php if(isset($error_message)) {echo('<p class="error">' . $error_message . '</p>');} ?>
    </div>
    <div class="col-xs-12 form-group">
        <input class="form-control" type="text" id="username" name="username" placeholder="Username" required/>
        <?php if(isset($uError)) { echo('<p class="error">' . $uError . '</p>'); }?>

    </div>
    <div class="col-xs-12 form-group">
        <input class="form-control" type="password" id="password" name="password" placeholder="Password" required/>
        <?php if(isset($pError)) {echo('<p class="error">' . $pError . '</p>');} ?>
    </div>

    <div class="col-xs-12 form-group">
        <input class="btn btn-primary pull-right" type="submit" value="Login" />
    </div>    

    </form>
</div>
</div>


<!-- All of our JavaScript files -->
<script src="../js/jquery/jquery.js"></script>
<script src="../js/login.js"></script>
</body>
</html>