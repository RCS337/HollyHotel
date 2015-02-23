angular.module('ProtoApp')
	.controller('CheckInController', function ($rootScope, $scope, $http, $timeout, $routeParams, GuestListFactory) {
       
        $scope.init = function () {
            // Get Guest List
            $scope.today = $rootScope.today;
            $scope.reservation = {reservationID: 23, reservationStartDate: "2015-02-12"};
            $scope.availableRooms = [{roomNumber: 2201, Beds: "2 Queen", Capacity: 4, Smoking: "Non", Floor: 3, Wing: "North", Building: "Savanah", Features: "Outdoor Pool, Handicap Access"}, {roomNumber: 2201, Beds: "2 Queen", Capacity: 4, Smoking: "Non", Floor: 3, Wing: "North", Building: "Savanah", Features: "Outdoor Pool, Handicap Access"}];
            // $scope.filteredItems = $scope.availableRooms.length;
            // $scope.totalItems = $scope.availableRooms.length;

            // Check for guest details
            // if($routeParams.guestID) {
            //     $scope.guest = $routeParams.guestID;
            //     $scope.getGuestDetails();
            // }
            // // Check for reservation
            // if($routeParams.reservationID){
            // 	if($routeParams.reservationID == 0){
            // 		$scope.reservation = null;
            // 	} else {
            // 		$scope.reservation = $routeParams.reservationID;
            // 		$scope.getReservationDetails();
            // 	}
            // }
            // Check for room

            // Set default max number of entries to show per page
            $scope.entryLimit = 5;
            // Set max number of pages to show in pagination
            $scope.maxSize = 10;
            // Set default current page for pagination
            $scope.currentPage = 1;
            
            console.log($scope.reservation);

        };

        $scope.getReservations = function(){
            $http.post('../ajax/getReservations.php', { StartRange: $scope.today, EndRange: $scope.today }).success(function(res) {
                // $scope.guestDetails = res;
                console.log("Got Reservations");
                console.log(res);
            })
        };
        $scope.getGuestDetails = function(){
            $http.post('../ajax/guestDetails.php', { CustomerID: $scope.guest }).success(function(res) {
                $scope.guestDetails = res;
            })
        };
        $scope.getReservationDetails = function(){
            $http.post('../ajax/reservationDetails.php', { CustomerID: $scope.guest }).success(function(res) {
                $scope.guestDetails = res;
            })
        };
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