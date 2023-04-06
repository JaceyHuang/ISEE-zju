<?php

	$json_post = json_decode(file_get_contents('php://input'), true);

	$id = $json_post["id"];
    $name = $json_post["name"];
    $type = $json_post["type"];
	$value = $json_post["value"];
	
	$dbusrname = "devUser";
	$dbpass = "hnvBdzPxtjuD84xQ";
	$dbhost = "127.0.0.1";
	$dbdatabase = "dbdevices";
	
	
	//creat a connect
	$db_connect = new mysqli($dbhost, $dbusrname, $dbpass, $dbdatabase);
	if ($db_connect -> connect_errno){
		echo json_encode(array(
			"id" => $db_connect->connect_errno,
			"name" => $db_connect->error,
			"type" => "111",
            "value" => "111"
		));
		die();
	}
	//执行插入新纪录的操作，若重复则先删除旧数据再添加新数据
	$strsql = "REPLACE INTO `sensor` (`id`,`name`,`type`,`value`) VALUES (".$id.",'".$name."','".$type."','".$value."')";
	$result = $db_connect->query($strsql);
	if ($db_connect ->errno != 0 ){
		echo json_encode(array(
			"id" => $db_connect->errno,
			"name" => $db_connect->error,
			"type" => "222",
            "value" => "222"
		));
		die();
	}
	//获取表格中的第一行数据
	$strsql = "SELECT * FROM `sensor` WHERE `id`=".$id." limit 1";
	$result = $db_connect->query($strsql);
	if ($db_connect ->errno != 0 ){
		echo json_encode(array(
			"id" => $db_connect->errno,
			"name" => $db_connect->error,
			"type" => "333",
            "value" => "333"
		));
		die();
	}
	//返回第一行数据
	$row = mysqli_fetch_assoc($result);
	$db_connect ->close();
	
	//设置返回信息的HTTP header信息
	header('Content-Type: application/json');
	echo json_encode(array(
		"id" => $row["id"],
		"name" => $row["name"],
		"type" => $row["type"],
        "value" => $row["value"]
	));

?>