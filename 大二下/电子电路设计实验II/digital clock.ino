/* * 
 * LCD RS pin to digital pin 12
 * LCD Enable pin to digital pin 11
 * LCD D4 pin to digital pin 5
 * LCD D5 pin to digital pin 4
 * LCD D6 pin to digital pin 3
 * LCD D7 pin to digital pin 2
 * LCD R/W pin to ground
 * LCD VSS pin to ground
 * LCD VCC pin to 5V 
 * */
#include <DS1302.h>    
#include <LiquidCrystal.h>       //LCD1602显示头文件
#include <OneWire.h> 
#include <DallasTemperature.h>  //温度传感器DS18B20头文件
#include <EEPROM.h>            //EEPROM头文件
#define ONE_WIRE_BUS A3            //DS18B20 信号端口 
OneWire oneWire(ONE_WIRE_BUS); 
DallasTemperature sensors(&oneWire);
LiquidCrystal lcd(12, 11, 5, 4, 3, 2); 
#define choose  A0   //选择端口
#define add  A1      //加
#define minus  A2    //减
#define Tone 13      //蜂鸣器端口
uint8_t CE_PIN   = 8;   //DS1302 RST端口
uint8_t IO_PIN   = 9;   //DS1302 DAT端口
uint8_t SCLK_PIN = 10;  //DS1302 CLK端口
DS1302 rtc(CE_PIN, IO_PIN, SCLK_PIN);  //创建 DS1302 对象
unsigned long seconds = 0;
int s = 0, m = 0, h = 0, d = 0, mon = 0, y = 0;   //时间进位
int second = 0, minute = 0, hour = 0, day = 0, month = 0, year = 0;  //当前时间
int SECOND = 0, MINUTE = 0, HOUR = 0, DAY = 0, MONTH = 0, YEAR = 0;  //初始时间
int chose = 0, alarm_choose = 0 ,ButtonDelay = 10, frequence = 2093;
int alarm_hour = 7, alarm_minute = 30, alarm_second = 0;  //闹钟时间
double Temperatures, Temp_Alarm = 30 ; 

union data
{
  int a;
  byte b[4];
};
data temp; //保存年份

void setup(){    
    for(int i = 2;i <= 13; i++){
        pinMode(i,OUTPUT); 
    }                
    digitalWrite(add, HIGH);
    digitalWrite(minus, HIGH);
    digitalWrite(choose, HIGH);  
    lcd.begin(16, 2);  //初始化LCD1602 
    sensors.begin();   //初始化温度传感器DS18B20  
    rtc.write_protect(false);  // 关闭DS1302芯片写保护
    rtc.halt(false);           //为true时DS1302暂停
    //YEAR = 2021; //第一次运行时的时间初始化，此时需要将下方的YEAR~SECOND赋值注释掉
    //MONTH = 5;   //使用此段赋值
    //DAY = 1;
    //HOUR = 0;
    //MINUTE = 0;
    //SECOND = 0; 
    for (int i=0;i<4;i++){
      temp.b[i]=EEPROM.read(i);
    }
    YEAR = temp.a; //第一次时间存入EPPROM后，将上段内容注释，使用此段赋值，重新上传
    MONTH = EEPROM.read(4); //从而具有断电时间保存功能
    DAY = EEPROM.read(5);
    HOUR = EEPROM.read(6);
    MINUTE = EEPROM.read(7);
    SECOND = EEPROM.read(8) + 1;
    if (DAY == 1){
        MONTH--;
    }
}

/** 格式化输出 */
void FormatDisplay(int col, int row, int num){
    lcd.setCursor(col, row); 
    if(num < 10)   lcd.print("0");
    lcd.print(num);   
}

/** 计算时间 */
void time() {    
    second = (SECOND + seconds) % 60;   //计算秒
    m = (SECOND + seconds) / 60;        //分钟进位
    FormatDisplay(6,1,second);
    
    minute = (MINUTE + m) % 60;  //计算分钟
    h = (MINUTE + m) / 60;       //小时进位
    FormatDisplay(3,1,minute);      

    hour = (HOUR + h) % 24;   //计算小时
    d = (HOUR + h) / 24;      //天数进位
    FormatDisplay(0,1,hour); 
    
    lcd.setCursor(2, 1);   
    lcd.print(":");   
    lcd.setCursor(5, 1);   
    lcd.print(":");  
}

/** 根据年月计算当月天数 */
int Days(int year, int month){
    int days = 0;
    if (month != 2){
        switch(month){
            case 1: case 3: case 5: case 7: case 8: case 10: case 12: days = 31;  break;
            case 4: case 6: case 9: case 11: days = 30;  break;
        }
    }else{   //闰年    
        if(year % 4 == 0 && year % 100 != 0 || year % 400 == 0){
            days = 29;          
        }    
        else{
            days = 28;  
        }     
    }  
    return days;   
}

/** 计算当月天数 */ 
void Day(){     
    int days = Days(year,month);
    int days_up;
    if(month == 1){
        days_up = Days(year - 1, 12); 
    }   
    else{
        days_up = Days(year, month - 1);
    }  
    day = (DAY + d) % days;
    if(day == 0){
        day = days;  
    }     
    if((DAY + d) == days + 1 ){
        DAY -= days;
        mon++;
    }
    if((DAY + d) == 0){
        DAY += days_up;
        mon--;
    }
    FormatDisplay(8,0,day); 
}

/** 计算月份 */
void Month(){  
    month = (MONTH + mon) % 12;
    if(month == 0){
        month = 12;
    }  
    y = (MONTH + mon - 1) / 12;
    FormatDisplay(5,0,month); 
    lcd.setCursor(7, 0);   
    lcd.print('-'); 
}

/** 计算年份 */
void Year(){ 
    year = ( YEAR + y ) % 9999;
    if(year == 0){
        year = 9999;
    } 
    lcd.setCursor(0, 0); 
    if(year < 1000){ 
        lcd.print("0"); 
    }
    if(year < 100){ 
        lcd.print("0"); 
    }
    if(year < 10){ 
        lcd.print("0"); 
    }
    lcd.print(year);
    lcd.setCursor(4, 0);   
    lcd.print('-'); 
}

/** 根据年月日计算星期几 */
void Week(int y,int m, int d){           
    if(m == 1){
        m = 13;
    }
    if(m == 2){
        m = 14;
    } 
    int week = (d+2*m+3*(m+1)/5+y+y/4-y/100+y/400)%7+1; 
    String weekstr = "";
    switch(week){
        case 1: weekstr = "Mon. ";   break;
        case 2: weekstr = "Tues. ";  break;
        case 3: weekstr = "Wed. ";   break;
        case 4: weekstr = "Thur. ";  break;
        case 5: weekstr = "Fri. ";   break;
        case 6: weekstr = "Sat. ";   break;
        case 7: weekstr = "Sun. ";   break;
    }    
    lcd.setCursor(11, 0);  
    lcd.print(weekstr);
}

/** 显示时间、日期、星期 */
void Display() { 
    time();
    Day();  
    Month();
    Year();
    Week(year,month,day);  
}

/** 显示光标 */
void DisplayCursor(int rol, int row) {
    lcd.setCursor(rol, row);   
    lcd.cursor();
    delay(100);     
    lcd.noCursor();
    delay(100);    
}

/** 通过按键设置时间 */
void Set_Time(int rol, int row, int &Time){
    DisplayCursor(rol, row); 
    if(digitalRead(add) == LOW){
        delay(ButtonDelay);
        if(digitalRead(add) == LOW){
            Time ++;
            tone(Tone,frequence); /** 按下蜂鸣 */
            delay(100);
            noTone(Tone);  
        }           
        Display();      
    }  
    if(digitalRead(minus) == LOW){
        delay(ButtonDelay);
        if(digitalRead(minus) == LOW){
            Time --; 
            tone(Tone,frequence); /** 按下蜂鸣 */
            delay(100);
            noTone(Tone);  
        }            
        Display();  
    }
}

/** 按键选择 */
void Set_Clock(){
    if(digitalRead(choose)==LOW){  
        lcd.setCursor(9, 1);  
        lcd.print("SetTime");
        while(1){       
            if(digitalRead(choose) == LOW){
                delay(ButtonDelay);
                if(digitalRead(choose) ==LOW){
                    tone(Tone,frequence); /** 按下蜂鸣 */
                    delay(100);
                    noTone(Tone);  
                    chose++;  
                }
            } 
            seconds = millis()/1000; 
            Display(); 
            if(chose == 1){
                Set_Time(1, 1, HOUR);      //SetHour
            }else if(chose == 2){ 
                Set_Time(4, 1, MINUTE);    //SetMinute
            }else if(chose == 3){
                Set_Time(7, 1, SECOND);    //SetSecond
            }else if(chose == 4){
                Set_Time(9, 0, DAY);       //SetDay
            }else if(chose == 5){
                Set_Time(6, 0, MONTH);     // SetMonth
            }else if(chose == 6){            
                Set_Time(3, 0, YEAR);      //SetYear
            }else if(chose >= 7) {
                chose = 0; 
                break;
            }
        }
    }  
}

/** 设置闹钟小时 */
void Set_Alarm_Hour(){
   DisplayCursor(1, 1);   
   if(digitalRead(add) == LOW){
       delay(ButtonDelay);
       if(digitalRead(add) == LOW){
           alarm_hour ++;
           tone(Tone,frequence); /** 按下蜂鸣 */
           delay(100);
           noTone(Tone);  
           if(alarm_hour == 24){
               alarm_hour = 0;
           }   
           FormatDisplay(0,1,alarm_hour);   
       }
   }
    if(digitalRead(minus) == LOW){
        delay(ButtonDelay);
        if(digitalRead(minus) == LOW){                
            alarm_hour --;
            tone(Tone,frequence); /** 按下蜂鸣 */
            delay(100);
            noTone(Tone);  
            if(alarm_hour == -1){
                alarm_hour = 23;
            }   
            FormatDisplay(0,1,alarm_hour); 
        }
    }
}

/** 设置闹钟分钟 */
void Set_Alarm_Minute(){
   DisplayCursor(4, 1); 
   if(digitalRead(add) == LOW) {
       delay(ButtonDelay);
       if(digitalRead(add) == LOW){
            alarm_minute ++;
            tone(Tone,frequence); /** 按下蜂鸣 */
            delay(100);
            noTone(Tone);  
            if(alarm_minute == 60){
                alarm_minute = 0;
            }  
            FormatDisplay(3,1,alarm_minute); 
       }
   }
    if(digitalRead(minus) == LOW){
        delay(ButtonDelay);
        if(digitalRead(minus) == LOW){                
            alarm_minute --;
            tone(Tone,frequence); /** 按下蜂鸣 */
            delay(100);
            noTone(Tone);  
            if(alarm_minute == -1){
                alarm_minute = 59;
            }  
            FormatDisplay(3,1,alarm_minute); 
        } 
    }  
}

/** 设置报警温度 */
void Set_Alarm_Temp(){  
    DisplayCursor(10, 1); 
    if(digitalRead(add) == LOW) {
        delay(ButtonDelay);
        if(digitalRead(add) == LOW){
            Temp_Alarm ++; 
            tone(Tone,frequence); /** 按下蜂鸣 */
            delay(100);
            noTone(Tone);  

        }             
    }
    if(digitalRead(minus) == LOW){
        delay(ButtonDelay);
        if(digitalRead(minus) == LOW){
            Temp_Alarm --; 
            tone(Tone,frequence); /** 按下蜂鸣 */
            delay(100);
            noTone(Tone);  

        }   
    }
}

/** 进入报警设置 */
void Set_Alarm(){
    if(digitalRead(add) == LOW && digitalRead(minus) == LOW){
        alarm_hour = hour;
        alarm_minute = minute;
        //alarm_choose  = 1;
        lcd.setCursor(0, 0);   
        lcd.print("set alarm       ");  
        lcd.setCursor(6, 1);   
        lcd.print("00");         //闹钟秒数      
        while(1){
            if(digitalRead(choose) == LOW){
                delay(ButtonDelay);
                if(digitalRead(choose) == LOW){
                    alarm_choose++; 
                    tone(Tone,frequence); /** 按下蜂鸣 */
                    delay(100);
                    noTone(Tone);  
                }                    
            }
            lcd.setCursor(9, 1);   
            lcd.print(Temp_Alarm);
            lcd.setCursor(14, 1);  
            lcd.print((char)223);    //显示o符号
            lcd.setCursor(15, 1);  
            lcd.print("C");          //显示字母C     
            if(alarm_choose == 1){
                Set_Alarm_Hour();
            }else if(alarm_choose == 2){
                Set_Alarm_Minute();        
            }else if(alarm_choose == 3){
                Set_Alarm_Temp(); 
            }else if(alarm_choose >= 4){
                alarm_choose = 0;
                break;
            }       
        }
    }
} 

/** 正点蜂鸣 */
void Point_Time_Alarm(){
    if(minute == 0 && second == 0){
        tone(Tone,frequence); 
        delay(500);
        noTone(Tone);   
    }    
}

/** 闹钟 指定时间蜂鸣 */
void Clock_Alarm(){
  if(hour == alarm_hour && minute == alarm_minute && second == alarm_second){
        //《两只老虎》
        tone(Tone,1778); 
        delay(500);
        noTone(Tone);     //1
        tone(Tone,1996); 
        delay(500);
        noTone(Tone);     //2
        tone(Tone,2240); 
        delay(500);
        noTone(Tone);     //3
        tone(Tone,1778);  
        delay(500);
        noTone(Tone);     //1
        tone(Tone,1778); 
        delay(500);
        noTone(Tone);     //1
        tone(Tone,1996); 
        delay(500);
        noTone(Tone);     //2
        tone(Tone,2240); 
        delay(500);
        noTone(Tone);     //3
        tone(Tone,1778);  
        delay(500);
        noTone(Tone);     //1
        tone(Tone,2240); 
        delay(500);
        noTone(Tone);     //3
        tone(Tone,2373);  
        delay(500);
        noTone(Tone);     //4
        tone(Tone,2661); 
        delay(1000);
        noTone(Tone);     //5
        tone(Tone,2240); 
        delay(500);
        noTone(Tone);     //3
        tone(Tone,2373);  
        delay(500);
        noTone(Tone);     //4
        tone(Tone,2661); 
        delay(1000);
        noTone(Tone);     //5
        tone(Tone,2661);  
        delay(250);
        noTone(Tone);     //5
        tone(Tone,2772);   
        delay(250);
        noTone(Tone);     //6
        tone(Tone,2661);   
        delay(250);
        noTone(Tone);     //5
        tone(Tone,2373);   
        delay(250);
        noTone(Tone);     //4
        tone(Tone,2240);   
        delay(500);
        noTone(Tone);     //3
        tone(Tone,1778);   
        delay(500);
        noTone(Tone);     //1
        tone(Tone,2661);  
        delay(250);
        noTone(Tone);     //5
        tone(Tone,2640);   
        delay(250);
        noTone(Tone);     //6
        tone(Tone,2661);   
        delay(250);
        noTone(Tone);     //5
        tone(Tone,2373);   
        delay(250);
        noTone(Tone);     //4
        tone(Tone,2240);   
        delay(500);
        noTone(Tone);     //3
        tone(Tone,1778);   
        delay(500);
        noTone(Tone);     //1
        tone(Tone,1778);   
        delay(500);
        noTone(Tone);     //1
        tone(Tone,1333);   
        delay(500);
        noTone(Tone);     //低音5
        tone(Tone,1778);   
        delay(1000);
        noTone(Tone);     //1
        tone(Tone,1778);   
        delay(500);
        noTone(Tone);     //1
        tone(Tone,1333);   
        delay(500);
        noTone(Tone);     //低音5
        tone(Tone,1778);   
        delay(1000);
        noTone(Tone);     //1
  }
} 

/** 获取DS18B20温度 */
void GetTemperatures(){
    sensors.requestTemperatures(); // Send the command to get temperatures
    Temperatures = sensors.getTempCByIndex(0);
    lcd.setCursor(9, 1) ;    
    lcd.print(Temperatures); //获取温度
    lcd.setCursor(14, 1);  
    lcd.print((char)223); //显示o符号
    lcd.setCursor(15, 1);  
    lcd.print("C"); //显示字母C     
}

/** 超过指定温度报警 */
void Temperatures_Alarm(){
    if(Temperatures >= Temp_Alarm){
        tone(Tone,frequence); 
        delay(500);
        noTone(Tone);       
    }
}

/** 保存时间 */
void Save_time(){
    temp.a = year;
    for (int i=0;i<4;i++){
      EEPROM.write(i,temp.b[i]);
    }
    EEPROM.write(4, month);
    EEPROM.write(5, day);
    EEPROM.write(6, hour);
    EEPROM.write(7, minute);
    EEPROM.write(8, second);
}

void loop() { 
    seconds = millis()/1000;    //获取单片机当前运行时间 
    Display();       //显示时间
    Set_Clock();     //设置时间  
    Set_Alarm();     //设置闹钟
    Point_Time_Alarm();    //正点蜂鸣
    Clock_Alarm();         //闹钟时间蜂鸣
    GetTemperatures();     //获取DS18B20温度
    Temperatures_Alarm();  //超过指定温度报警
    Time t(year, month, day, hour, minute, second, 1); 
    rtc.time(t);
    Save_time();
}
