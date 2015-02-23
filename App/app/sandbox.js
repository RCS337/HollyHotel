angular.module('ProtoApp')
    .controller('SandboxController', function ($scope, $http, $timeout, $routeParams) {
        $scope.guestID = 3;
        $http.post('../ajax/searchGuests.php', $scope.guestID) .success(function(res) {
                console.log(res)
            })
    });