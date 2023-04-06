<?php

	$json_post = json_decode(file_get_contents('php://input'),true);

	$a = $json_post["a"];
	$b = $json_post["b"];
	$c = $json_post["c"];
	
	$dbusrname = "devUser";
	$dbpass = "hnvBdzPxtjuD84xQ";
	$dbhost = "127.0.0.1";
	$dbdatabase = "dbdevices";
	
	
	//creat a connect
	$db_connect = new mysqli($dbhost, $dbusrname, $dbpass, $dbdatabase);
	if ($db_connect -> connect_errno){
		echo json_encode(array(
			"a" => $db_connect->connect_errno,
			"b" => $db_connect->error,
			"c" => "111"
		));
		die();
	}
	//执行插入新纪录的操作
	$strsql = "INSERT INTO `me` (`a`,`b`,`c`) VALUES (".$a.",'".$b."','".$c."')";
	$result = $db_connect->query($strsql);
	if ($db_connect ->errno != 0 ){
		echo json_encode(array(
			"a" => $db_connect->errno,
			"b" => $db_connect->error,
			"c" => "222"
		));
		die();
	}
	//获取表格中的第一行数据
	$strsql = "SELECT * FROM `me` WHERE `a`=".$a." limit 1";
	$result = $db_connect->query($strsql);
	if ($db_connect ->errno != 0 ){
		echo json_encode(array(
			"a" => $db_connect->errno,
			"b" => $db_connect->error,
			"c" => "333"
		));
		die();
	}
	//返回第一行数据
	$row = mysqli_fetch_assoc($result);
	$db_connect ->close();
	
	//设置返回信息的HTTP header信息
	header('Content-Type: application/json');
	echo json_encode(array(
		"a" => $row["a"],
		"b" => $row["b"],
		"c" => $row["c"]
	));

?>