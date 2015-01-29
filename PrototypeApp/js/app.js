angular.module('ProtoApp', ['ngRoute', 'ui.bootstrap'])
    .config(function ($routeProvider, $locationProvider) {
        $routeProvider
             .when('/', {
                controller: 'DashboardCtrl',
                templateUrl: 'views/dashboard.html'
            })
            .when('/dashboard', {
                controller: 'DashboardCtrl',
                templateUrl: 'views/dashboard.html'
            })
            .when('/rooms', {
                controller: 'MainController',
                templateUrl: 'views/rooms.html',

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
            .otherwise({
                controller: 'DashboardCtrl',
                templateUrl: 'views/dashboard.html'
            });
        $locationProvider.html5Mode(true);
    });