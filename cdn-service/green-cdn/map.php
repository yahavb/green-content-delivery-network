<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

require 'Predis/Autoloader.php';
use Predis\Collection\Iterator;
Predis\Autoloader::register();

if (isset($_GET['cmd']) === true) {
  $host = 'redis-master';
  if (getenv('GET_HOSTS_FROM') == 'env') {
    $host=getenv('REDIS_MASTER_SERVICE_HOST');
  }
  header('Content-Type: application/json');


  switch ($_GET['cmd']){
    case 'set':
       $client = new Predis\Client([
	'scheme'=> 'tcp',
    	'host'  => $host,
	'port'	=> 6379,
       ]);
       $client->set($_GET['key'],$_GET['value']);
       print('{"message": "Updated"}');
       break;
    case 'append':
       $client = new Predis\Client([
	'scheme'=> 'tcp',
    	'host'  => $host,
	'port'	=> 6379,
       ]);
       $val=",(".$_GET['value'].")";
       $client->append($_GET['key'],$val);
       print('{"message": "Updated"}');
       break;
    case 'get':
       $host = 'redis-slave';
       if (getenv('GET_HOSTS_FROM') == 'env') {
        $host = getenv('REDIS_SLAVE_SERVICE_HOST');
       }
       $client = new Predis\Client([
        'scheme' => 'tcp',
        'host'   => $host,
        'port'   => 6379,
       ]);
       $value = $client->get($_GET['key']);
       print('{"data": "' . $value.'"}');
       break;
    case 'purge':
       $host = 'redis-master';
       if (getenv('GET_HOSTS_FROM') == 'env') {
        $host = getenv('REDIS_MASTER_SERVICE_HOST');
       }
       $client = new Predis\Client([
        'scheme' => 'tcp',
        'host'   => $host,
        'port'   => 6379,
        'profile'=>'2.8',
       ]);
       $client->flushall();
       print('{"message": "Flashed"}');
       break;
    case 'all':
       $host = 'redis-slave';
       if (getenv('GET_HOSTS_FROM') == 'env') {
        $host = getenv('REDIS_SLAVE_SERVICE_HOST');
       }
       $client = new Predis\Client([
        'scheme' => 'tcp',
        'host'   => $host,
        'port'   => 6379,
        'profile'=>'2.8',
       ]);
       $dbsize=$client->dbsize();
       print('DBZIE='.$dbsize.PHP_EOL);
       if (empty($_GET['pattern']))
	$pattern='*';
       else
	$pattern=$_GET['pattern'];
          #print('{"data": "');
       foreach (new Iterator\Keyspace($client, $pattern) as $key) {
        $val = $client->get($key);
           #print('{'. $key . ":" . $val .'},');
        print($key.",".$val.PHP_EOL);
       }
          #print('"}');
       break;
    default:
       print('http://host/map.php?cmd=set&key=key1&value=val1'.PHP_EOL);
       print('http://host/map.php?cmd=append&key=key1&value=val1'.PHP_EOL);
       print('http://host/map.php?cmd=get&key=key1'.PHP_EOL);
       print('http://host/map.php?cmd=all'.PHP_EOL);
       print('http://host/map.php?cmd=all&pattern=*a*'.PHP_EOL);
  }
} else {
  print('http://host/map.php?cmd');
  phpinfo();
} ?>
