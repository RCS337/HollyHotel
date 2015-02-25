angular.module('ProtoApp')
    .controller('DashboardController', function ($rootScope, $scope, $http, $timeout, $routeParams, GuestListFactory) {
        $scope.init = function () {
            // Get Guest List
            $scope.today = $rootScope.today;
            $scope.entryLimit = 5;
            $scope.maxSize = 10;
            $scope.currentPage = 1;

        };
        $scope.getReservations = function(){
            $http.post('../ajax/getReservations.php', { StartRange: $scope.today, EndRange: $scope.today }).success(function(res) {
                // $scope.guestDetails = res;
                console.log("Got Reservations");
                console.log(res);
            })
        };
        $scope.addReservation = function(){
            console.log("add reservation");
            var CustomerID = $scope.guest.CustomerID == null ? $scope.createNewCustomer($scope.guest) : $scope.guest.CustomerID;
            var capacity   = $scope.reservation.capacity == null ? 1 : $scope.reservation.capacity;
            var cardName   = $scope.reservation.cardName;
            var cardNumber = $scope.reservation.cardNumber;
            var cardType   = $scope.reservation.cardType;
            var enddate    = $scope.reservation.enddate + " 11:00:00";
            var eventID    = $scope.reservation.eventID == null ? null : $scope.reservation.eventID;
            var roomtype   = $scope.reservation.roomtype == null ? 15 : $scope.reservation.roomtype;
            var smoking    = $scope.reservation.smoking == null ? 0 : $scope.reservation.smoking;
            var startdate  = $scope.reservation.startdate + " 16:00:00";
            $http.post('../ajax/reservationInsertUpdate.php', { ReservationID: null, ParentResID: null, BillToID: CustomerID, GuestID: CustomerID, EventID: eventID, RoomType: roomtype, StartDate: startdate, EndDate: enddate, Rate: null, Deposit: null, RoomID: null, Smoking: smoking, Features: null }).success(function(res) {
                console.log(res);
            })
        }
        $scope.updatePersonalInfo = function(){
            $scope.updateSuccess = true;
            console.log($scope.updateSuccess);
        }
        $scope.searchGuests = function () {
            console.log("searching");
            $http.post('../ajax/searchGuests.php', $scope.formData) .success(function(res) {
                $scope.searchResults = res;
                $scope.searchItems = $scope.searchResults.length;
                $scope.searchLimit = 3;
                $scope.entryLimit = 5;
            $scope.maxSize = 10;
            $scope.currentPage = 1;
            })
        };
        $scope.useGuest = function(customerID){
            $scope.customerID = customerID;
            $http.post('../ajax/guestDetails.php', {CustomerID: $scope.customerID}) .success(function(res) {
                $scope.guest = res;
                console.log($scope.guest);
            })
        }
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