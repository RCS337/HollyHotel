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
    .controller('GuestsController', function ($rootScope, $scope, $http, $timeout, $route, $routeParams, GuestListFactory) {
        // Set page title
        $rootScope.title = $route.current.title;

        $scope.init = function () {
            // Check for guest details
            if($routeParams.guestID){
                $http.post('../ajax/guestDetails.php', { CustomerID: $routeParams.guestID }).success(function(res) {
                    $scope.guest = res;
                });
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
    .controller('ReservationController', function ($scope, $http, $timeout, $routeParams, ReservationFactory) {
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
            ReservationFactory.getAll().then(function(res) {
                // Success - Assign data to list
                $scope.list = ReservationFactory.list;
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
    });
