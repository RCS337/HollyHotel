angular.module('ProtoApp')
	.controller('GuestsController', function ($scope, $http, $timeout, $routeParams, GuestListFactory) {
        $scope.init = function () {
            // Get Guest List
            $scope.getAll();
            // Check for guest details
            if($routeParams.guestID) {
                $scope.guest = $routeParams.guestID;
                $scope.getDetails();
            }
            // Set default max number of entries to show per page
            $scope.entryLimit = 5;
            // Set max number of pages to show in pagination
            $scope.maxSize = 10;
            // Set default current page for pagination
            $scope.currentPage = 1;
        };
        $scope.getAll = function (){
            GuestListFactory.getAll().then(function(res) {
                // Success - Assign data to list
                $scope.list = GuestListFactory.guestList;
                // Set filtered items to default of all items
                $scope.filteredItems = $scope.list.length;
                // Set length of all items
                $scope.totalItems = $scope.list.length;
            }, function(err) {
                // error - log to console
                console.log(err);
            })
        };
        $scope.getDetails = function(){
            $http.post('../ajax/guestDetails.php', { CustomerID: $scope.guest }).success(function(res) {
                $scope.guestDetails = res;
            })
        };
        $scope.getSingle = function () {
            // $scope.guestID = $routeParams.guestID;
            // console.log($scope.guestID);
            GuestListFactory.getSingle($scope.guestID).then(function(res){
                // Success - Assign data to detail
                $scope.details = GuestListFactory.guestList;
            }, function(err){
                //error - log to console
                console.log(err);
            })
        }; // end getSingle
        $scope.searchGuests = function () {
            $http.post('../ajax/searchGuests.php', $scope.formData) .success(function(res) {
                $scope.searchResults = res;
                $scope.searchItems = $scope.searchResults.length;
                $scope.searchLimit = 8;
            })
        };
        // On filter, set filteredItems length after a 10 millisecond delay
        $scope.filter = function () {
            $timeout( function () {
                $scope.filteredItems = $scope.filtered.length;
            }, 10);
        };
        // Sort items
        $scope.sort = function(predicate) {
            $scope.predicate = predicate;
            $scope.reverse = !$scope.reverse;
        };
        $scope.setPage = function (pageNo) {
            $scope.currentPage = pageNo;
            console.log(pageNo);
        };
         // Run initializing function
        $scope.init();
    });