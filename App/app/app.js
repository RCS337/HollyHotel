angular.module('ProtoApp', ['ngRoute', 'ui.bootstrap', 'ui.date'])
    .config(function ($routeProvider, $locationProvider) {
        $routeProvider
             .when('/', {
                controller: 'DashboardController',
                templateUrl: 'views/dashboard.html'
            })
            .when('/index.php', {
                controller: 'DashboardController',
                templateUrl: 'views/dashboard.html'
            })
            .when('/dashboard', {
                controller: 'DashboardController',
                templateUrl: 'views/dashboard.html'
            })
            .when('/sandbox', {
                controller: 'SandboxController',
                templateUrl: 'views/sandbox.html'
            })
            .when('/reservations', {
                controller: 'ReservationController',
                templateUrl: 'views/reservations.html'
            })
            .when('/reservations/new', {
                controller: 'ReservationController',
                templateUrl: 'views/reservationNew.html'
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
            .when('/checkin/reservation', {
                controller: 'CheckInController',
                templateUrl: 'views/checkin.html'
            })
            .when('/checkin/reservation/:reservationID', {
                controller: 'CheckInController',
                templateUrl: 'views/checkInReservation.html'
            })
            .when('/checkin/guest', {
                controller: 'CheckInController',
                templateUrl: 'views/checkin.html'
            })
            .when('/checkin/guest/:guestID', {
                controller: 'CheckInController',
                templateUrl: 'views/checkInGuest.html'
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
                controller: 'GuestsController',
                templateUrl: 'views/guests.html',
                title: 'Guests'
            })
            .when('/guests/new', {
                controller: 'GuestsController',
                templateUrl: 'views/newGuest.html',
                title: 'New Guests'
            })
            .when('/guests/:guestID', {
                controller: 'GuestsController',
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