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
                controller: 'RoomsCtrl',
                templateUrl: 'views/rooms.html'
            })
            .when('/guests', {
                controller: 'GuestsCtrl',
                templateUrl: 'views/guests.html'
            })
            .otherwise({
                controller: 'DashboardCtrl',
                templateUrl: 'views/dashboard.html'
            });
        $locationProvider.html5Mode(true);
    });