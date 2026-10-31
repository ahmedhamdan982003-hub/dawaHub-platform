(function () {
  'use strict';

  angular
    .module('dawahub', [])
    .controller('HomeController', ['$http', function ($http) {
      var home = this;
      home.status = 'Checking service status…';

      $http.get('/api/v1/health').then(
        function () {
          home.status = 'Service and database are connected.';
        },
        function () {
          home.status = 'Service status is unavailable. Please try again later.';
        }
      );
    }]);
})();
