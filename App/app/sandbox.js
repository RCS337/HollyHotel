angular.module('ProtoApp')
    .controller('SandboxController', function ($scope, $http, $timeout, $routeParams) {
        
        $scope.guestID = 3;
        $scope.startDate = "2015-02-12";

        console.log("In the Sandbox");

        $http.post('../ajax/searchGuests.php', {customerID: $scope.guestID, startDate: $scope.startDate}).success(function(res) {
                console.log(res)
            })
    });