var redisApp = angular.module('redis', ['ui.bootstrap']);

/**
 * Constructor
 */
function RedisController() {}

RedisController.prototype.onRedisDemand = function() {
    this.scope_.demandEvents.push(this.scope_.event);
    this.scope_.event = "";
    var value = this.scope_.demandEvents.join();
    this.http_.get("map.php?cmd=set&key=demandEvents&value=" + value)
            .success(angular.bind(this, function(data) {
                this.scope_.redisResponse = "Updated.";
            }));
};
redisApp.controller('RedisDemandCtrl', function ($scope, $http, $location) {
        $scope.controller = new RedisController();
        $scope.controller.scope_ = $scope;
        $scope.controller.location_ = $location;
        $scope.controller.http_ = $http;

        $scope.controller.http_.get("map.php?cmd=get&key=demandEvents")
            .success(function(data) {
                console.log(data);
                $scope.demandEvents = data.data.split(",");
            });
});


RedisController.prototype.onRedisSupply = function() {
    this.scope_.supplyEvents.push(this.scope_.event);
    this.scope_.event = "";
    var value = this.scope_.supplyEvents.join();
    this.http_.get("map.php?cmd=set&key=supplyEvents&value=" + value)
            .success(angular.bind(this, function(data) {
                this.scope_.redisResponse = "Updated.";
            }));
};

redisApp.controller('RedisSupplyCtrl', function ($scope, $http, $location) {
        $scope.controller = new RedisController();
        $scope.controller.scope_ = $scope;
        $scope.controller.location_ = $location;
        $scope.controller.http_ = $http;

        $scope.controller.http_.get("map.php?cmd=get&key=supplyEvents")
            .success(function(data) {
                console.log(data);
                $scope.supplyEvents = data.data.split(",");
            });
});