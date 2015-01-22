angular.module('ProtoApp')
    .controller('DashboardCtrl', function ($scope) {
        $scope.title = "DashBoard Control";
        $scope.message = "Dashboard Message";
    })
    .controller('GuestsCtrl', function ($scope, $http, $timeout) {
        $scope.title = "Guests";
        $http.get('http://protoapp.dev/ajax/getGuests.php').success(function(data) {
            $scope.list = data;
            $scope.entryLimit = 10; //max no of items to display in a page
            $scope.filteredItems = $scope.list.length; //Initially for no filter
            $scope.totalItems = $scope.list.length;
        });
        $scope.setPage = function(pageNo) {
            $scope.currentPage = pageNo;
        };
        $scope.filter = function() {
            $timeout(function() {
            $scope.filteredItems = $scope.filtered.length;
            }, 10);
        };
        $scope.sort_by = function(predicate) {
            $scope.predicate = predicate;
            $scope.reverse = !$scope.reverse;
        };
        $scope.currentPage = 1;
        $scope.maxSize = 10;
        $scope.bigTotalItems = 12;
        $scope.bigCurrentPage = 1;

    })
    .controller('RoomsCtrl', function ($scope) {
        $scope.title = "Rooms";
        $scope.message = "Rooms Message";
    });
