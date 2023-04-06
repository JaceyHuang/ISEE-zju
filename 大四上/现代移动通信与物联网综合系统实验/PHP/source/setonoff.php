<?php
	//首先获取客户端POST过来的所有内容并解码成数组
	$json_post = json_decode(file_get_contents('php://input'),true);

	$id = $json_post["id"];
	if( array_key_exists("name",$json_post) )
		$name = $json_post["name"];		//获取name
	if( array_key_exists("type",$json_post) )
		$type = $json_post["type"];		//获取type
	$value = $json_post["value"];
	
	//数据库连接配置信息
	$dbusrname = "devUser";
	$dbpass = "B2CZunSSWSdj2reS";
	$dbhost = "127.0.0.1";
	$dbdatabase = "dbdevices";
	
	//设置返回信息的HTTP header信息
	header('Content-Type: application/json');
	
	//建立数据库连接
	$db_connect = new mysqli($dbhost, $dbusrname, $dbpass, $dbdatabase);
	if ($db_connect -> connect_errno){//连接失败，返回失败信息
		//返回错误给客户端
		echo json_encode(array(
			"id" => $db_connect->connect_errno,
			"name" => $dbdatabase.".controller.".$id,
			"type" => urlencode($db_connect->connect_error),
			"value" => "数据库连接失败!",
		));
		die();
	}
	
	//获取表格中的第一行数据，用于判断对应id的逻辑设备是否存在
	$strsql = "SELECT * FROM `controller` WHERE `id`=".$id." limit 1";
	$result = $db_connect->query($strsql);
	if ($db_connect ->errno != 0 ){//errno非0表示有错误产生，返回错误信息
		//返回错误给客户端
		echo json_encode(array(
			"id" => $db_connect->errno,
			"name" => $dbdatabase.".controller.".$id,
			"type" => urlencode($db_connect->error),
			"value" => "数据库第一次查询失败!",
		));
		die();
	}
	if(mysqli_num_rows($result)){//逻辑设备已经存在
		$strsql = "UPDATE `controller` SET `value`='".$value."' WHERE `id`=".$id." limit 1";
		$result = $db_connect->query($strsql);
		if ($db_connect ->errno != 0 ){//errno非0表示有错误产生，返回错误信息
			//返回错误给客户端
			echo json_encode(array(
				"id" => $db_connect->errno,
				"name" => $dbdatabase.".controller.".$id,
				"type" => urlencode($db_connect->error),
				"value" => "数据库设备更新失败!",
			));
			die();
		}
	}
	else{		
		if (!ISSET($name)){
			$name = "unknow-name";
		}
		if (!ISSET($type)){
			$type = "unknow-type";
		}
		$strsql = "INSERT INTO `controller` (`id`,`name`,`type`,`value`) VALUES (".$id.",'".$name."','".$type."','".$value."')";
		$result = $db_connect->query($strsql);
		if ($db_connect ->errno != 0 ){//errno非0表示有错误产生，返回错误信息
			//返回错误给客户端
			echo json_encode(array(
				"id" => $db_connect->errno,
				"name" => $dbdatabase.".controller.".$id,
				"type" => urlencode($db_connect->error),
				"value" => "数据库新建逻辑设备失败!",
			));
			die();
		}
	}	
	
	//再次查询获取表格中的第一行数据
	$strsql = "SELECT * FROM `controller` WHERE `id`=".$id." limit 1";
	$result = $db_connect->query($strsql);
	if ($db_connect ->errno != 0 ){//errno非0表示有错误产生，返回错误信息
		//返回错误给客户端
		echo json_encode(array(
			"id" => $db_connect->errno,
			"name" => $dbdatabase.".controller.".$id,
			"type" => urlencode($db_connect->error),
			"value" => "数据库再次查询失败!",
		));
		die();
	}
	$row = mysqli_fetch_assoc($result);
	if(count($row)==0)  //还是为空，为空表示逻辑设备不存在，返回错误
	{
		//返回错误给客户端
		echo json_encode(array(
			"id" => 99999,
			"name" => $dbdatabase.".controller.".$id,
			"type" => urlencode($db_connect->error),
			"value" => "第二次查询还是查询不到?",
		));
		die();
	}
	$db_connect ->close();
	
	echo json_encode(array(
		"id" => $row["id"],
		"name" => $row["name"],
		"type" => $row["type"],
		"value" => $row["value"]
	));

?>