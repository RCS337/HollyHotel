angular.module('ProtoApp')
    .controller('SandboxController', function ($scope, $http, $timeout, $routeParams) {
        
        $scope.guestID = 3;
        $scope.StartRange = "2015-02-12";
        $scope.EndRange = "2015-02-24";
        $scope.entryLimit = 10;
        $scope.maxSize = 10;
        $scope.currentPage = 1;
        // $scope.availableRooms = [{"RoomID":"1","RoomNumber":"1040101","BuildingName":"Main Building","WingName":"North Wing","FloorNumber":"1","SmokingAllowed":"0","Beds":"1-Queen Bed,2-Queen Bed","BedTypes":"10,10","Features":"Handicap Accessible,Indoor Pool,Parking Garage","FeatureIDs":"22,24,26"}];
        // $scope.filteredItems = $scope.availableRooms.length;

        // $http.post('../ajax/getAvailableRooms.php', { pstartdate: '2015-02-28 16:00:00', penddate: '2015-02-29 16:00:00', proomtype: 15, psmoking: 0 ,prequirements: null }).success(function(res) {
        //     $scope.availableRooms = res;
        //     console.log(res);
        //     $scope.filteredItems = $scope.availableRooms.length;
        // });
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
         $scope.searchRooms = function () {
            // console.log($scope.roomForm);
            $scope.pstartdate = $scope.roomForm.pstartdate.toString() + " 16:00:00";
            $scope.penddate = $scope.roomForm.penddate.toString() + " 11:00:00";
            $scope.proomtype = $scope.roomForm.proomtype;
            $scope.psmoking = $scope.roomForm.psmoking;

            $http.post('../ajax/getAvailableRooms.php', { pstartdate: $scope.pstartdate, penddate: $scope.penddate, proomtype: $scope.proomtype, psmoking: $scope.psmoking ,prequirements: null }).success(function(res) {
                console.log(res);
                $scope.availableRooms = res;
                $scope.filteredItems = $scope.availableRooms.length;
            });
        };





    });