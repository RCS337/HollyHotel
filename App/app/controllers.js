angular.module('ProtoApp')
    .controller('MainController', function ($rootScope, $scope, $route, $routeParams, $location) {
        $rootScope.title = $route.current.title;
        $rootScope.go = function ( path ) {
            $location.path( path );
        };
        $rootScope.getToday = function () {
            var tDate = new Date();
            var year = tDate.getFullYear().toString();
            var month = (tDate.getMonth()+1).toString();
            var day = tDate.getDate().toString();
            $rootScope.today = year + "-" + month + "-" + day;
        };
        $rootScope.getToday();
    })
    .controller('DashboardCtrl', function ($scope) {
        $scope.title = "DashBoard Control";
        $scope.message = "Dashboard Message";
    })
    .controller('GuestsController', function ($rootScope, $scope, $http, $timeout, $route, $routeParams, $location, $routeParams) {
        // Set page title
        $rootScope.title = $route.current.title;

        $scope.init = function () {
            // Check for guest details
            if($routeParams.guestID){
                $http.post('../ajax/guestDetails.php', { CustomerID: $routeParams.guestID }).success(function(res) {
                    $scope.guest = res;
                })
            }
            // Sample Data {customerID: "123", FirstName: "David", LastName: "Moore", contactInfoConfidential: 0, BillToAddress1: "123 RoadName Rd", BillToAddress2: null, BillToAddress3: null, BillToAddress4: null, BillToCity: "Madison" , BillToState: "WI", BillToZip: "53716", BillToCountry: "USA", BillToPhone: "6085556666"};
            $scope.billing = {billingID: "123", name: "David Moore", cardType: "Visa", BillToAddress1: "123 RoadName Rd", BillToAddress2: null, BillToAddress3: null, BillToAddress4: null, BillToCity: "Madison" , BillToState: "WI", BillToZip: "53716", BillToCountry: "USA"};

            // Set default max number of entries to show per page
            $scope.entryLimit = 10;
            // Set max number of pages to show in pagination
            $scope.maxSize = 10;
            // Set default current page for pagination
            $scope.currentPage = 1;
        };
        $scope.insertCustomer = function(){
            console.log($scope.guest);
                $http.post('../ajax/insertCustomer.php', $scope.guest ).success(function(res) {
                    console.log(res);
                })
        }
        $scope.insertCheckInCustomer = function(){
                $http.post('../ajax/insertCustomer.php', $scope.guest ).success(function(res) {
                    $scope.guestID = res;
                    var path = '/checkin/guest/' + $scope.guestID;
                    $location.path( path );
                })
        }
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

        // Set page number
        $scope.setPage = function (pageNo) {
            $scope.currentPage = pageNo;
            console.log(pageNo);
        };
         // Run initializing function
        $scope.init();
    })
    .controller('RoomsController', function ($scope, $http, $timeout, $routeParams, RoomsFactory) {
        $scope.init = function () {
            // Get Guest List
            $scope.getAll();
            // Set default max number of entries to show per page
            $scope.entryLimit = 10;
            // Set max number of pages to show in pagination
            $scope.maxSize = 10;
            // Set default current page for pagination
            $scope.currentPage = 1;
        };
        $scope.getAll = function (){
            RoomsFactory.getAll().then(function(res) {
                // Success - Assign data to list
                $scope.list = RoomsFactory.list;
                // Set filtered items to default of all items
                $scope.filteredItems = $scope.list.length;
                // Set length of all items
                $scope.totalItems = $scope.list.length;
            }, function(err) {
                // error - log to console
                console.log(err);
            })
        };
        // On filter, set filteredItems length after a 10 millisecond delay
        $scope.filter = function () {
            $timeout( function () {
                console.log($scope.filtered.length);
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
        $scope.init();
    })
    .controller('ReservationController', function ($rootScope, $scope, $http, $timeout, $routeParams) {
        $scope.init = function () {
            // $scope.getReservations();
            // Get Guest List
            $scope.today = $rootScope.today;
            $scope.entryLimit = 5;
            $scope.maxSize = 10;
            $scope.currentPage = 1;

        };
        $scope.getReservations = function(){
            var searchStart = $scope.reservationSearch.startDate + " 16:00:00";
            var searchEnd = $scope.reservationSearch.endDate + " 11:00:00";
            $http.post('../ajax/getReservations.php', { StartRange: searchStart, EndRange: searchEnd }).success(function(res) {
                $scope.reservations = res;
                $scope.reservationItems = $scope.reservations.length;
                $scope.searchLimit = 10;
                $scope.entryLimit = 5;
                $scope.maxSize = 10;
                $scope.currentPage = 1;
                // console.log(res);
            })
        };
        $scope.addReservation = function(){
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
                if(isNaN(res)){
                    $scope.submitReservationError = true;
                } else {
                    $scope.submitReservationSuccess = true;
                    $scope.reservation = null;
                    $scope.guest = null;
                    $scope.searchResults = null;
                }
            })
        }
        $scope.updatePersonalInfo = function(){
            $scope.updateSuccess = true;
            console.log($scope.updateSuccess);
        }
        $scope.searchGuests = function () {
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
    })
    .controller('MaintController', function ($scope, $http, $timeout, RoomsFactory) {
        $scope.init = function () {
            // Get List
            // $scope.getAll();
            // Set default max number of entries to show per page
            $scope.entryLimit = 10;
            // Set max number of pages to show in pagination
            $scope.maxSize = 10;
            // Set default current page for pagination
            $scope.currentPage = 1;
        };
        $scope.getAll = function (){
            RoomsFactory.getAll().then(function(res) {
                // Success - Assign data to list
                $scope.list = RoomsFactory.list;
                // Set filtered items to default of all items
                $scope.filteredItems = $scope.list.length;
                // Set length of all items
                $scope.totalItems = $scope.list.length;
            }, function(err) {
                // error - log to console
                console.log(err);
            })
        };
        $scope.getSingle = function () {
            // $scope.guestID = $routeParams.guestID;
            // console.log($scope.guestID);
            RoomsFactory.getSingle($scope.guestID).then(function(res){
                // Success - Assign data to detail
                $scope.details = RoomsFactory.list;
            }, function(err){
                //error - log to console
                console.log(err);
            })
        }; // end getSingle

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
    })
    .controller('CheckInController', function ($rootScope, $scope, $http, $timeout, $routeParams, $route, $location) {

        $scope.init = function () {
            $scope.getToday();
            if($routeParams.guestID){
                $scope.guestID = $routeParams.guestID;
                $scope.getGuestDetails($scope.guestID);
            } else if ($routeParams.reservationID){
                // do something else
                // $scope.getReservationDetails();
                var reservationID = $routeParams.reservationID;
                $scope.getReservationDetails(reservationID);
            } else {
                // do generic thing
                $scope.getTodaysReservations();
            }

        };
        $scope.go = function(path){
            console.log(path);
            $location.path( path );
        }
        $scope.getGuestDetails = function(guestID){

            $http.post('../ajax/guestDetails.php', { CustomerID: guestID }).success(function(res) {
                console.log(res);
                $scope.billingPartry = res;
                $scope.guest = res;
            })
        }
        $scope.getRoomList = function(){
            console.log("searching...");
            $scope.pstartdate = $scope.roomForm.pstartdate + " 16:00:00";
            $scope.penddate = $scope.roomForm.pstartdate + " 11:00:00";
            $scope.proomtype = $scope.roomForm.proomtype;
            $scope.psmoking = $scope.roomForm.psmoking;

            $http.post('../ajax/getAvailableRooms.php', { pstartdate: $scope.pstartdate, penddate: $scope.penddate, proomtype: $scope.proomtype, psmoking: $scope.psmoking, prequirements: null }).success(function(res) {
                $scope.roomList = res;
                console.log(res);
                $scope.filteredItems = $scope.roomList.length;
                $scope.searchLimit = 10;
                $scope.entryLimit = 5;
                $scope.maxSize = 10;
                $scope.currentPage = 1;
            })
        }
        $scope.getReservationDetails = function(resID){
            var ReservationID = resID;
            $http.post('../ajax/reservationDetails.php', { ReservationID: ReservationID }).success(function(res) {
                console.log(res);

                // var startDate = new Date($scope.resDetails.StartDate);
                // var date = startDate.getDate();
                // var month = startDate.getMonth();
                // var year = startDate.getFullYear();
                // $scope.resDetails.StartDate = startDate;
                // var EndDate = new Date($scope.resDetails.EndDate);
                // var date = EndDate.getDate();
                // var month = EndDate.getMonth();
                // var year = EndDate.getFullYear();
                // $scope.resDetails.EndDate = EndDate;
                // console.log(startDate);
                $scope.resDetails = res;
                $scope.getReservationRooms();
                $http.post('../ajax/guestDetails.php', { CustomerID: $scope.resDetails.GuestID }).success(function(res) {
                    console.log(res);
                    $scope.guest = res;
                })
                $http.post('../ajax/guestDetails.php', { CustomerID: $scope.resDetails.BillToID }).success(function(res) {
                    console.log(res);
                    $scope.billingPartry = res;
                })
            })
        }
        $scope.checkIn = function(){
            $scope.checkindata = { BillToID: $scope.resDetails.BillToID, GuestID: $scope.resDetails.GuestID, ReservationID: $scope.resDetails.ReservationID, EventID: $scope.resDetails.EventID, RoomID: $scope.RoomID, RoomType: $scope.resDetails.RoomType, AnicipatedCheckout: $scope.resDetails.EndDate, Rate: null, Deposit: null }
            console.log($scope.checkindata);
                $http.post('../ajax/stayinsert.php', { BillToID: $scope.resDetails.BillToID, GuestID: null, ReservationID: $scope.resDetails.ReservationID, EventID: null, RoomID: $scope.RoomID, RoomType: null, AnicipatedCheckout: null, Rate: null, Deposit: null }).success(function(res) {
                    console.log(res);
                    // $http.post('../ajax/guestDetails.php', { BillToID: $scope.resDetails.BillToID, GuestID: $scope.resDetails.GuestID, ReservationID: $scope.resDetails.ReservationID, EventID: $scope.resDetails.EventID, RoomID: $scope.RoomID, RoomType: $scope.resDetails.RoomType, AnicipatedCheckout: $scope.resDetails.EndDate, Rate: null, Deposit: null }).success(function(res) {
                    //     console.log(res);

                    // })
                })
        }
        $scope.selectRoom = function(roomID){
            $scope.RoomID = roomID;
            $scope.checkIn();

        }
        $scope.getReservationRooms = function(){
            $scope.pstartdate = $scope.resDetails.StartDate.toString();
            $scope.penddate = $scope.resDetails.EndDate.toString();
            $scope.smoking = $scope.resDetails.Smoking;
            // $scope.proomtype = $scope.resDetails.RoomType;
            // var prequirements = "";

                // $scope.pstartdate = "2015-02-01 00:00:00";
                // $scope.penddate = "2015-02-21 00:00:00";
                // $scope.smoke = "0";
                $scope.proomtype = 15;
                $scope.prequirements = "";

            $http.post('../ajax/getAvailableRooms.php', { psmoking: $scope.smoking, pstartdate: $scope.pstartdate, penddate: $scope.penddate, proomtype: $scope.proomtype, prequirements: $scope.prequirements }).success(function(res) {

                $scope.availRooms = res;
                console.log(res);
                $scope.filteredItems = $scope.availRooms.length;
                $scope.searchLimit = 10;
                $scope.entryLimit = 5;
                $scope.maxSize = 10;
                $scope.currentPage = 1;
            });
        }
        $scope.getTodaysReservations = function(){
            var startRange = $scope.today;// + " 11:00:00";
            var endRange = $scope.today + " 16:00:00";
            $http.post('../ajax/getReservations.php', { StartRange: startRange, EndRange: endRange }).success(function(res) {
                console.log(res);
                $scope.reservations = res;
                $scope.reservationItems = $scope.reservations.length;
                $scope.searchLimit = 10;
                $scope.entryLimit = 5;
                $scope.maxSize = 10;
                $scope.currentPage = 1;
                // console.log(res);
            })
        }
        $scope.getToday = function(){
            var tDate = new Date();
            var year = tDate.getFullYear().toString();
            var month = (tDate.getMonth()+1).toString();
            var day = tDate.getDate().toString();
            $scope.today = year + "-" + month + "-" + day;
        }
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
        };
         // Run initializing function
        $scope.init();
    });
