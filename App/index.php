<?php
    session_start();
    if(!isset($_SESSION['user_id'])){
        header( 'location: /login.php');
    };
?>
<!doctype html>
<html ng-app="ProtoApp" lang="en">
<head>
    <!-- Required base tag for angular routing -->
    <base href="/"></base>
    <meta charset="utf-8">
    <title>{{ title }}</title>
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
{{ today }}

<div ng-controller="SandboxController"></div>
<?php include('navigation.php'); ?>

<div id="page-wrapper" class="container-fluid" ng-view></div>

<!-- All of our JavaScript files -->
<script src="../js/angular-core/angular.js"></script>
<script src="../js/angular-route/angular-route.js"></script>
<script src="../js/bootstrap/ui-bootstrap-tpls-0.12.0.js"></script>
<script src="../js/jquery/jquery.js"></script>
<script src="../js/protoapp.js"></script>
<script src="../app/app.js"></script>
<script src="../app/filters.js"></script>
<script src="../app/factories.js"></script>
<script src="../app/controllers.js"></script>
<script src="../app/controllerSandbox.js"></script>
<script src="../js/bootstrap/bootstrap.js"></script>
</body>
</html>