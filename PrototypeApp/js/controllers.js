angular.module('ProtoApp')
    .controller('MainController', function ($rootScope, $route, $routeParams) {
        $rootScope.title = $route.current.title;

    })
    .controller('DashboardCtrl', function ($scope) {
        $scope.title = "DashBoard Control";
        $scope.message = "Dashboard Message";
    })
    .controller('GuestsController', function ($scope, $http, $timeout, $routeParams, GuestListFactory) {
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
