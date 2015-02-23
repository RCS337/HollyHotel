angular.module('ProtoApp')
    .controller('SandboxController', function ($scope, $http, $timeout, $routeParams) {
        
        $scope.guestID = 3;
        $scope.StartRange = "2015-02-12";
        $scope.EndRange = "2015-02-24";

        // $http.post('../ajax/getReservations.php', {StartRange: $scope.StartRange, EndRange: $scope.EndRange}).success(function(res) {
        //         console.log(res)
        //     })
    console.log($scope.StartRange);
        $http.post('../ajax/getReservations.php', { StartRange: $scope.StartRange, EndRange: $scope.EndRange }).success(function(res) {
            console.log(res)
        });
    });