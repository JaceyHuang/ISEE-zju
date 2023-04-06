<?php
	error_reporting(E_ALL^E_NOTICE^E_WARNING);
	//设备数据类
	class devData{
		var $id;
		var $name;
		var $type;
		var $value;
	}
	//返回结果类
	class opResult{
		var $result;
		var $id;	//出错时保存错误码
		var $name;	//出错时保存出错源
		var $type;	//出错时保存出错类型
		var $value;	//出错时保存错误详细说明
	}

	$input = file_get_contents("php://input");

	$ret = new opResult;
	
	//获取POST过来的数据
	//修改时的value: {"valname":"power","valdata":false}
	$op = json_decode($input);	//{"op":"create/delete/query/modify","id":0,"name":"xxx","type":"yyy","value":{"power":false,"channel":12,"volume":34}}
		
	header("Content-type: text/html; charset=utf-8");
	//var_dump($op);
	
	//数据库登录信息
    $dbname="devUser";
    $dbpass="hnvBdzPxtjuD84xQ";
    $dbhost="127.0.0.1";
    $dbdatabase="dbdevices";
	
	//设备查询函数，多次使用，返回的就是opResult
	function query_obj($db,$tbName,$id)
	{
		// 获取查询结果
		$func_ret = new opResult;
		
		$strsql = "SELECT * FROM ".$tbName." WHERE `id`=".$id."";
		$result = $db->query($strsql);
		if ($db ->errno != 0 ){
			$func_ret->result = False;  // 有错误发生
			$func_ret->id = 0;
			$func_ret->name = $tbName;
			$func_ret->type = "查询失败!-".$id;
			$func_ret->value = "查询数据时失败!";
			return $func_ret;
		}

		//返回数据
		$row = mysqli_fetch_assoc($result);
		$func_ret->result = True;
		$func_ret->id = $row["id"];
		$func_ret->name = $row["name"];
		$func_ret->type = $row["type"];
		$func_ret->value = json_decode($row["value"]);

		//query_obj返回的对象的value值应该是对象，否则value值得两端会添加两个引号，导致后续处理时无法嵌套。
		//create、modify返回的结果也一样，为了保证结果一致，在create和modify的最后都调用一次query_obj返回
		//最终结果.
		//但是，数据库里面的value字段只能是字符串，我们如何处理呢？
		//假设$row是SELECT操作返回的数据集对象，则：
		//$func_ret->value = json_decode($row["value"])
		
		return $func_ret;
	}
	
	//设备创建函数，多次使用，返回的就是opResult
	function create_obj($db,$tbName,$id,$name,$type,$value)//$value是对象不是字符串!!
	{
		$func_ret = new opResult;

		//注意！这里create_obj传入的参数value可能是前面对$input(POST上来的内容)按json格式解码的结果对象
		//$op下面的子对象$op->{"value"},故此参数value不可直接作为字符串嵌入到SQL语句中，需encode后嵌入。
		//再次强调：value是对象，不是字符串！
		
		$value = json_encode($value);
		$strsql = "INSERT INTO ".$tbName." (`id`,`name`,`type`,`value`) VALUES (".$id.",'".$name."','".$type."','".$value."')";
		$result = $db->query($strsql);
		if ($db ->errno != 0 ){
			$func_ret->result = False;  // 有错误发生
			$func_ret->id = 3;
			$func_ret->name = $tbName;
			$func_ret->type = "创建失败!-".$id;
			$func_ret->value = "创建数据时失败!";
			return $func_ret;
		}
		
		$func_ret = query_obj($db,$tbName,$id);
		
		return $func_ret;
	}
 
    //生成一个连接
    $db_connect= new mysqli($dbhost,$dbname,$dbpass,$dbdatabase);
	
	//数据库连接检查
	if ($db_connect->connect_errno) {
		//数据库连接失败，设置返回信息
		$ret->result = False;	//返回False，标识有错误发生
		$ret->id = 1;			//出错编号=1
		$ret->name = $dbdatabase;	//出错数据库名
		$ret->type = "连接失败!-".$db_connect->connect_errno;	//出错信息ID描述
		$ret->value = urlencode($db_connect->connect_error);	//出错的详细信息
		//把opResult编码成json格式的字符串，然后echo回客户端浏览器或app
		echo json_encode($ret,JSON_UNESCAPED_UNICODE);			
		exit();
	}

	//确定数据表对象，id<100为传感器，否则是控制器
	$tabName = "sensor";
	if( $op->{"id"}>=100 )	$tabName = "controller";
	
	//根据op的操作要求执行不同的操作
	switch( $op->{"op"} )
	{
		case "query":	// ###查询设备数据###			
			// 获取查询结果
			$ret = query_obj($db_connect,$tabName,$op->{"id"});
			echo json_encode($ret,JSON_UNESCAPED_UNICODE);			
			break;
		case "create":	//###创建逻辑设备###
			// 获取查询结果
			$ret = query_obj($db_connect,$tabName,$op->{"id"});
			if( $ret->result==True && $ret->id==NULL ){//已经存在直接返回成功,否则创建
				//注意！这里create_obj传入的参数value是前面对$input(POST上来的内容)按json格式解码的结果对象
				//$op下面的子对象$op->{"value"},故此参数value不可直接作为字符串嵌入到SQL语句中，需encode后嵌入。
				//！！！$op->{"value"}是对象！！！
				$ret = create_obj($db_connect,$tabName,$op->{"id"},$op->{"name"},$op->{"type"},$op->{"value"});
				//注意！！！创建返回的对象的value内容应该是对象不是字符串
			}
			echo json_encode($ret,JSON_UNESCAPED_UNICODE);			
			break;
		case "modify":	// ###更新设备数据###
			do{	//do{...}while(0)，是一种编程技巧，可以使程序结构清晰，避免n多的if else存在。
				//合法性检查，前面没有加上，如果希望系统坚固，那么最好都加上，这里仅做示例
				//输入合法性检查1,POST过来的数据必须至少含有"value"和"id"这两个键值
				if( !property_exists($op,"value") || !property_exists($op,"id") ){
					$ret->result = False;
					$ret->id = 1;
					$ret->name = $tabName;
					$ret->type = $op->{"id"};				
					$ret->value = "修改数据时输入数据格式非法(未找到value或id)!";
					break;
				}
				//输入合法性检查2，POST过来的数据中的"value"必须含有"valname"和"valdata"这两个键值
				if( !property_exists($op->{"value"},"valname") || !property_exists($op->{"value"},"valdata") )
				{
					$ret->result = False;
					$ret->id = 2;
					$ret->name = $tabName;
					$ret->type = $op->{"id"};				
					$ret->value = "修改数据时输入数据value格式非法(未找到valname或者valdata)!";
					break;
				}
				//首先查询逻辑设备
				$ret = query_obj($db_connect,$tabName,$op->{"id"});
				if ($ret->result != True) //如果有错误进行提示.提示内容即查询函数的返回内容
					break;
					
				//创建设备对象，我们的修改是在这个对象上完成的，不是直接操作数据库的。
				$dev_data = new devData;
				
				if( $ret->id==NULL ){//设备不存在，先创建空设备
					//创建逻辑设备
					$ret = create_obj($db_connect,$tabName,
										$op->{"id"},
										property_exists($op,"name")?$op->{"name"}:"unknow-name",	//属性检查，如果POST过来的数据中不包含name或type,则采用默认值
										property_exists($op,"type")?$op->{"type"}:"unknow-type",
										json_decode("{\"".$op->{"value"}->{"valname"}."\":".$op->{"value"}->{"valdata"}."}"));
					if( $ret->result!=True ){//创建失败!
						$ret->result = False;
						$ret->id = 4;
						$ret->name = $tabName;
						$ret->type = $op->{"id"};				
						$ret->value = "修改数据时逻辑设备未找到且创建失败!";
						break;
					}
				}
				
				//此时设备必然存在，复制数据到$dev_data
				$dev_data->id = $ret->id;
				$dev_data->name = $ret->name;
				$dev_data->type = $ret->type;				
				$dev_data->value = $ret->value;

				//将设备数据中的value对象先按json格式转换成字符串，再把字符串转换成php数组
				//这里转成数组的原因是为了必要时添加value中的属性
				
				//$dev_data->value是php对象，endcode 变成字符串，再decode成数组
				$dev_val_json = json_decode(json_encode($dev_data->value),true);
				
				//修改设备对象数组中的对应属性，
				//若属性不存在，php会创建相应的属性并赋值。而如果是对象，你对它不存在的属性赋值会报错。
				$dev_val_json[$op->{"value"}->{"valname"}] = $op->{"value"}->{"valdata"};
				//生成SQL语句。其中把数组格式的设备对象再次还原成json格式的字符串作为数据库字段"value"的值
				$strsql="update ".$tabName." set `value`='".json_encode($dev_val_json)."' where `id` = ".$op->{"id"};

				//执行数据库更新
				$result=$db_connect->query($strsql);
				if ($db_connect->errno != 0) //如果有错误进行提示.
				{
					$ret->result = False;
					$ret->id = 3;
					$ret->name = $dbdatabase;
					$ret->value = "修改数据时更新失败!-".$db_connect->errno;
					$ret->type = urlencode($db_connect->error);
					break;
				}
				//操作成功，返回修改后的设备数据
				$ret = query_obj($db_connect,$tabName,$op->{"id"});
			}while(0);
				
			echo json_encode($ret,JSON_UNESCAPED_UNICODE);			
			break;		
		case "delete":	//###删除逻辑设备###
			// 获取查询结果
			$ret = query_obj($db_connect,$tabName,$op->{"id"});
			if( $ret->result==True )//这里返回True仅仅标识查询操作完成，否则查询失败，$ret中保存的就是查询失败时的出错信息
			{
				if( $ret->id==NULL ){//如果存在则删除,否则提示不存在，但操作不算失败，故$ret->result保持True
					$ret->name = $dbdatabase.".".$tabName;
					$ret->type = $op->{"op"};				
					$ret->value = "删除逻辑设备设备时发现设备不存在!";
				}
				else{//存在，执行删除操作
					$strsql="delete from ".$tabName." where `id` = ".$op->{"id"};
					$result=$db_connect->query($strsql);
					if ($db_connect->errno != 0) //如果有错误进行提示.
					{
						$ret->result = False;
						$ret->id = 2;
						$ret->name = $dbdatabase.".".$tabName;
						$ret->type = $op->{"op"};				
						$ret->value = "删除逻辑设备设备时删除失败!";
					}
				}
			}
			echo json_encode($ret,JSON_UNESCAPED_UNICODE);			
			break;
		default:
			$ret->result = False;
			$ret->id = 2;
			$ret->name = $dbdatabase.".".$tabName;
			$ret->type = $op->{"op"};				
			$ret->value = "未定义的操作!";
			echo json_encode($ret,JSON_UNESCAPED_UNICODE);
			break;
	}
	// 释放资源
	if( is_object($result) )
		$result->close();
	// 关闭连接
	$db_connect->close();
?>