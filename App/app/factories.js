angular.module('ProtoApp')
    .factory('GuestListFactory', function ($http, $q) {
        var GuestListFactory = this;
        GuestListFactory.guestList = {};

        GuestListFactory.getAll = function () {
            var defer = $q.defer();

            $http.get('../ajax/guestlist.php').success(function(res){
                GuestListFactory.guestList = res;
                defer.resolve(res);
            })
            .error(function(err, status){
                defer.reject(err);
            })
            return defer.promise;
        } // end getAll

        GuestListFactory.getSingle = function ( id ) {
            var defer = $q.defer();
            $http.get('../ajax/getGuestDetail.php',{ params: { guestID: id }}).success(function(res){
                GuestListFactory.guestList = res;
                defer.resolve(res);
            })
            .error(function(err, status){
                defer.reject(err);
            })
            return defer.promise;
        } // end getSingle

        return GuestListFactory;
    }) // end factory
    .factory('RoomsFactory', function ($http, $q) {

        var RoomsFactory = this;
        RoomsFactory.list = {};

        RoomsFactory.getAll = function () {
            var defer = $q.defer();

            $http.get('../ajax/roomlist.php').success(function(res){
                RoomsFactory.list = res;
                defer.resolve(res);
            })
            .error(function(err, status){
                defer.reject(err);
            })

            return defer.promise;
        } // end getAll
        return RoomsFactory;
    })// end factory
    .factory('ReservationFactory', function ($http, $q) {

        var ReservationFactory = this;
        ReservationFactory.list = {};

        ReservationFactory.getAll = function () {
            var defer = $q.defer();

            $http.get('../ajax/reservationlist.php').success(function(res){
                ReservationFactory.list = res;
                defer.resolve(res);
            })
            .error(function(err, status){
                defer.reject(err);
            })

            return defer.promise;
        } // end getAll
        return ReservationFactory;
    }); // end factory