angular.module('ProtoApp', ['ngRoute', 'ui.bootstrap'])
    .config(function ($routeProvider, $locationProvider) {
        $routeProvider
             .when('/', {
                controller: 'MainController',
                templateUrl: 'views/dashboard.html'
            })
            .when('/dashboard', {
                controller: 'MainController',
                templateUrl: 'views/dashboard.html'
            })
            .when('/reservations', {
                controller: 'MainController',
                templateUrl: 'views/reservations.html'
            })
            .when('/reservations/:reservationID', {
                controller: 'MainController',
                templateUrl: 'views/reservationDetail.html'
            })
            .when('/rooms', {
                controller: 'MainController',
                templateUrl: 'views/rooms.html'
            })
            .when('/rooms/:roomID', {
                controller: 'MainController',
                templateUrl: 'views/roomDetail.html'
            })
            .when('/checkin', {
                controller: 'CheckInController',
                templateUrl: 'views/checkin.html'
            })
            .when('/checkin/:guestID/', {
                controller: 'MainController',
                templateUrl: 'views/checkinGuest.html'
            })
            .when('/checkout', {
                controller: 'MainController',
                templateUrl: 'views/checkout.html'
            })
            .when('/maintanence', {
                controller: 'MainController',
                templateUrl: 'views/maintenance.html'
            })
            .when('/guests', {
                controller: 'MainController',
                templateUrl: 'views/guests.html',
                title: 'Guests'
            })
            .when('/guests/:guestID', {
                controller: 'MainController',
                templateUrl: 'views/guestDetails.html',
                title: 'Guests Details'
            })
            .when('/logout', {
                redirectTo: 'logout.php'
            })
            .otherwise({
                controller: 'MainController',
                templateUrl: 'views/dashboard.html'
            });
        $locationProvider.html5Mode(true);
    });