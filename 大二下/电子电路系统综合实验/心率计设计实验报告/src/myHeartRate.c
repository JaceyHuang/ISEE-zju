#include "reg51.h"
#include "intrins.h"
#include "stc12c.h"
#include "string.h"

#define KEY_RESET 0 // 第三次按下按键或未按下按键
#define KEY_START_POTENTIAL 1 // 第一次按下按键（防抖动）
#define KEY_START 2 // 第一次按下按键
#define KEY_END_POTENTIAL 3 // 第二次按下按键（防抖动）
#define KEY_END 4 // 第二次按下按键
#define KEY_RESET_POTENTIAL 5 // 第三次按下按键或未按下按键（防抖动）

#define NORMAL 0 // 心率正常
#define FAST 1 // 心率过快
#define SLOW 2 // 心率过慢

#define dataPort P1 // 数据端口
#define BUSY 0x80

unsigned int tick = 0;
unsigned int old_ticks;
unsigned int old_ticks_potential;
unsigned int ADC_ticks = 0;
unsigned int startTime, endTime;
unsigned int result = 0;
unsigned int heartRate = 0;
unsigned int hrpm = 0; // heartRate per minute
unsigned char key_state;
unsigned char error_short = 0; // 测量时间过短
unsigned char start = 0;
unsigned char end = 0;
unsigned char reset = 0;
unsigned char speed = 0; // 存储心率速度是否正常
unsigned char cnt = 0;
unsigned char count = 0;

struct mychar {
    unsigned char row1[16]; // 第一行的字符串
    unsigned char number[6]; // 心率
    unsigned char row2[16]; // 第二行
} wData;

sbit beep = P2^0;   // 蜂鸣器输入
sbit key = P2^1;     // 开关
sbit RS = P3^2;     // 定义LCD的RS脚
sbit RW = P3^3;     // LCD的R/W脚
sbit Elcm = P3^4;      // LCD的E脚
sbit impulse = P3^7;   // 输入脉冲

char last_impulse = 0;

void STC_Init(void);
void UartInit(void); // 波特率
void Delay_us(unsigned int us); 
void Delay_ms(unsigned int ms);
void Lcd_Init(void);
void waitForEnable(void);
void lcdWriteCommand(unsigned char CMD);
void Timer_Init(void); // 定时器
unsigned int getTicks(void);
void Key_Init(void);
void Beep_Init(void); // 蜂鸣器
void key_task(void);
void key_scan(void); // 按键扫描
void key_treat(void);  // 按键处理
void ADC_task(unsigned char n);
void delay(unsigned int t);
void processData(void);
void lcd_task(void);
void displayOneChar(unsigned char x, unsigned char y, char c); // 写入一个字符
void getLocation(unsigned char x, unsigned char y);
void lcdWriteData(char c);
void bluetooth_task(void);
void sendString(char *s);
void sendOneChar(char c);
void sendInt(unsigned int i);
void beep_task(void);

void main(void){
    STC_Init();   // 初始化STC
    Key_Init();   // 初始化按键
    Beep_Init();  // 初始化蜂鸣器
    Lcd_Init();   // 初始化LCD
    while (1){
        key_task();
        ADC_task(0);
        processData();
        lcd_task();
        beep_task();
        bluetooth_task();
        // if (start == 1 && reset == 0 && end == 0) {
        //     sendInt(result); // MATLAB数据
        // }
    }
}

void STC_Init(void){
    P2M0 = 0x00; // b0000 0000
    P2M1 = 0x01; // b0000 0001
    P3M0 = 0x00; // b0000 0000
    P3M1 = 0x1c; // b0001 1100
    Timer_Init(); // 初始化定时器
    UartInit();
    return;
}

void Timer_Init(void){  // Timer0 mode 1 16位
    TMOD = 0x01;
    TL0 = 0x66;
	TH0 = 0xFC; // 定时1ms
    EA = 1;
    ET0 = 1;
    TR0 = 1;
    return;
}

void Timer_Itr(void) interrupt 1 {
    TL0 = 0x66;
	TH0 = 0xFC; // 重置
	tick++;
}

void UartInit(void){
    EA = 1; // 开总开关
	ES = 1; // 开串口中断
	TMOD |= 0x20; // 定义TIMER1为定时器1模式，TM0D为00100010，为8位方式
	SCON = 0x50; // 01010000
	TH1 = 0xFD; // 定义波特率为9600
	TL1 = 0xFD;
	TR1 = 1; // 开定时器中断
}

void Uart_Itr(void) interrupt 4 {
    unsigned char temp;   
    ES = 0;     
    if (RI) { // 判断是接收中断产生
        RI = 0;  //标志位清零
        temp = SBUF; //读入缓冲区的值
        SBUF = temp; //把接收到的值再发回电脑端
    }
    ES = 1;
}

unsigned int getTicks(void){
    unsigned int re = 0;
    EA = 0;
	re = tick; // 读取自系统开始运行至今的毫秒数
	EA = 1;
	return re;
}

void Key_Init(void){
    key_state = KEY_RESET; // 初始状态为RESET
    return;
}

void Beep_Init(void){
    beep = 0; // 不蜂鸣
    return;
}

void Lcd_Init(void){
    lcdWriteCommand(0x28); // 显示模式设置(不检测忙信号)
    Delay_ms(5);
    lcdWriteCommand(0x28); // 共三次
    Delay_ms(5);
    lcdWriteCommand(0x28);
    Delay_ms(5);
    lcdWriteCommand(0x28); // 显示模式设置,四位显示
    lcdWriteCommand(0x08); // 显示关闭
    lcdWriteCommand(0x01); // 显示清屏
    lcdWriteCommand(0x06); // 显示光标移动设置
    lcdWriteCommand(0x0c); // 显示开及光标设置
    return;
}

void waitForEnable(void) {
    unsigned char state1, state2;
    dataPort = dataPort | 0xF0; // 取高四位
    RS = 0;
    RW = 1;
    do{
        Elcm = 1; // 使能
        Delay_us(5);
        state1 = dataPort;
        Elcm = 0;
        state1 = state1 & 0xF0;
        Delay_us(5);
        Elcm = 1;
        Delay_us(5);
        state2 = dataPort;
        Elcm = 0;
        state2 = state2 >> 4;
        state1 = state1 | state2; // 合并
    } while (state1 & 0x80); // DB7为1，即LCD正忙
}

void lcdWriteCommand(unsigned char CMD){
    waitForEnable();
    RS = 0;     
    RW = 0;
    Elcm = 1;
    dataPort &= 0x0F; // 清空高四位 
    dataPort |= CMD & 0xF0; // 写高四位
    Delay_us(5);
    Elcm = 0;
    CMD = CMD << 4; // 低四位移到高四位
    Elcm = 1;
    dataPort &= 0x0F; // 清空高四位
    dataPort |= CMD & 0xF0; // 写低四位
    Delay_us(5);
    Elcm = 0;
}

void key_task(void){
    key_scan();
    key_treat();
    return;
}

void key_scan(void){
    unsigned int ticks = 0;
    ticks = getTicks();
    switch (key_state){
        case KEY_RESET: 
            if (key == 1) key_state = KEY_RESET; // 未按下按键，状态保持
            else {// 按下按键
                old_ticks = ticks;
                key_state = KEY_START_POTENTIAL; // 可能是开始测量
            }
            break;
        case KEY_START_POTENTIAL:  // 防抖动
            if (ticks - old_ticks > 20) { // 保持20ms低电平
                if (key == 0) {
                    key_state = KEY_START; // 非抖动引起
                    old_ticks = ticks;
                    startTime = ticks;
                    cnt = 0;
                    beep = 1;
                    Delay_ms(100);
                    beep = 0;
                }
                else key_state = KEY_RESET; // 否则重新回到未按过状态
            }
            break;
        case KEY_START:
            if (key == 0) { // 第二次按按键
                if (ticks - old_ticks < 5000) {// 测量时间小于5s
                    error_short = 1;
                }
                else {
                    error_short = 0;
                }
                key_state = KEY_END_POTENTIAL;
                old_ticks_potential = ticks;
            }
            else key_state = KEY_START; // 继续测量，状态保持不变
            break;
        case KEY_END_POTENTIAL: // 防抖动
            if (ticks - old_ticks_potential > 20) { // 保持20ms低电平
                if (key == 0) {
                    key_state = KEY_END; // 非抖动引起
                    endTime = ticks; // 计算测量时间
                    cnt = 0;
                    beep = 1;
                    Delay_ms(100);
                    beep = 0;
                    heartRate = 0;
                }
                else key_state = KEY_START; // 否则重新回到测量状态
            }
            break;
        case KEY_END: 
            if (key == 0) { // 第三次按按键
                old_ticks = ticks;
                key_state = KEY_RESET_POTENTIAL;
            }
            else key_state = KEY_END;
            break;
        case KEY_RESET_POTENTIAL:
            if (ticks - old_ticks > 20) { // 保持20ms低电平
                if (key == 0){
                    key_state = KEY_RESET; // 非抖动引起
                    count = 0;
                    cnt = 0;
                    beep = 1;
                    Delay_ms(100);
                    beep = 0;
                    heartRate = 0;
                }
                else key_state = KEY_END; // 否则回到结束状态
            }
            break;
        default: key_state = KEY_RESET; break;
    }
    return;
}

void key_treat(void){
    switch (key_state) {
        case KEY_RESET:
            reset = 1; // 全局变量，用于LCD输出控制以及输入数据处理
            start = 0;
            end = 0;
            break;
        case KEY_START:
            start = 1;
            reset = 0;
            end = 0;
            break;
        case KEY_END:
            end = 1;
            start = 0;
            reset = 0;
            break;
        default: reset = 1; 
                 start = 0;
                 end = 0; 
                 break;
    }
    return;
}

void delay(unsigned int t){ // 延时
  	unsigned int i, j; 
  	for(i=0;i<t;i++) {
  		for(j=0;j<10;j++) {
		;
        } 
    } 
} 

void ADC_task(unsigned char n) {
    unsigned char i;	
    unsigned int ticks = getTicks();
    ticks = getTicks();
    result = 0; // 保存转化后的幅值
    ADC_CONTR = ADC_CONTR | 0x80;
    delay(10);
    i = 0x01 << 0;
    P1M0 = P1M0 | i; // 端口功能设置
    P1M1 = P1M1 | i;
    delay(10); 
    ADC_CONTR = 0xE0 | 0;
    delay(10);
    ADC_DATA = 0; // 高8位
    ADC_LOW2 = 0; // 低2位
    ADC_CONTR = ADC_CONTR | 0x08;
    delay(10);
    ADC_CONTR = ADC_CONTR & 0xE7;
    result = ADC_DATA;
    result <<= 2;
    result = result & 0x03FC; // b0000 0111 1111 1100
    result = result | (ADC_LOW2 & 0x03);
    if (start == 1 && reset == 0 && end == 0){ // 测量时
        if (ticks - ADC_ticks > 300) {
            if (result >= 300) { // 大于等于1.47V
                heartRate++;
                ADC_ticks = ticks; // 避免重复计数
            }
        }
    }
}

void processData(void){
    unsigned char i = 2;
    unsigned int ticks = getTicks();
    if (end == 1 && start == 0 && reset == 0) { // 结束
        if (error_short == 0){ // 测量满5s
            hrpm = heartRate * 60.0 * 1000 / (endTime - startTime);
            if (hrpm >= 60 && hrpm <= 90 ) {
                strcpy(wData.row2, "Normal Rate     ");
                speed = NORMAL;
            }
            else if (hrpm > 90) {
                strcpy(wData.row2, "Fast Rate       ");
                speed = FAST;
            }
            else {
                strcpy(wData.row2, "Slow Rate       ");
                speed = SLOW;
            }
            if (hrpm == 0) {
                wData.number[0] = '0';
            }
            while (hrpm){
                wData.number[i] = hrpm % 10 + '0';
                hrpm /= 10;
                i--;
            }
            if (i == 1) { // 心率数字长度只有一位
                wData.number[0] = wData.number[2];
                wData.number[1] = wData.number[2] = ' ';
            }
            else if (i == 0) { // 心率数字长度只有两位
                wData.number[0] = wData.number[1];
                wData.number[1] = wData.number[2];
                wData.number[2] = ' ';
            } 
            wData.number[3] = ' ';
            wData.number[4] = ' ';
            wData.number[5] = ' ';
            strcpy(wData.row1, "HeartRate:");
        }
        else { // 测量时间过短
            strcpy(wData.row1, "Measure time    ");
            strcpy(wData.row2, "is too short    ");
            strcpy(wData.number, "\0");
        }
    }
    else if (start == 1 && end == 0 && reset == 0) { // 测量时
        strcpy(wData.row1, "Measuring...    ");
        strcpy(wData.row2, "Please wait     ");
        strcpy(wData.number, "\0");
    }
    else if (reset == 1 && start == 0 && end == 0) { // 处于RESET时
        strcpy(wData.row1, "HeartRate:");
        strcpy(wData.number, "0     ");
        strcpy(wData.row2, "                "); // 空格填充
        
    }
}

void Delay_us(unsigned int us){
    unsigned int i;
	for (i=0; i<us; i++) {
		_nop_();
		_nop_();
		_nop_();
		_nop_();
		_nop_();
		_nop_();
		_nop_();
    }
}

void Delay_ms(unsigned int ms){
    unsigned int i;
	for (i=0; i<ms; i++)	
 		Delay_us(1000); 
}

void lcd_task(void){ // 将数据输出在LCD显示屏上
    int i;
    if (end == 1 && start == 0 && reset == 0) { // 结束
        if (error_short == 0){ // 测量满5s
            for (i=0;i<10;i++){ // 第一行
                displayOneChar(i, 0, wData.row1[i]);
            }
            for (i=0;i<6;i++){
                displayOneChar(i+10, 0, wData.number[i]);
            }
            for (i=0;i<16;i++){ // 第二行
                displayOneChar(i, 1, wData.row2[i]);
            }
        }
        else { // 未测满5s
            for (i=0;i<16;i++){
                displayOneChar(i, 0, wData.row1[i]);
            }
            for (i=0;i<16;i++){
                displayOneChar(i, 1, wData.row2[i]);
            }
        }
    }
    else if (start == 1 && end == 0 && reset == 0) { // 测量时
        for (i=0;i<16;i++){ // 第一行
            displayOneChar(i, 0, wData.row1[i]);
        }
        for (i=0;i<16;i++){ // 第二行
            displayOneChar(i, 1, wData.row2[i]);
        }
    }
    else if (reset == 1 && start == 0 && end == 0) {
        for (i=0;i<10;i++){ // 第一行
            displayOneChar(i, 0, wData.row1[i]);
        }
        for (i=0;i<6;i++){
            displayOneChar(i+10, 0, wData.number[i]);
        }
        for (i=0;i<16;i++){ // 第二行
            displayOneChar(i, 1, wData.row2[i]);
        }
    }
}

void displayOneChar(unsigned char x, unsigned char y, char c){
    getLocation(x, y); // 显示位置
    lcdWriteData(c); // 写字符
}

void getLocation(unsigned char x, unsigned char y){
    unsigned char temp;
    temp = x & 0x0f;
    y &= 0x01;
    if ( y == 1) {
        temp |= 0x40;
    }
    temp |= 0x80;
    lcdWriteCommand(temp);
}

void lcdWriteData(char c){
    waitForEnable();
    RS = 1; 
    RW = 0;
    Elcm = 1;
    dataPort &= 0x0F; // 清高四位
    dataPort |= c & 0xF0; // 写高四位 
    Delay_us(5);
    Elcm = 0;
    c = c << 4; // 移到高四位
    Elcm = 1;
    dataPort &= 0x0F; // 清高四位
    dataPort |= c & 0xF0; // 写低四位 
    Delay_us(5);
    Elcm = 0;
}

void beep_task(){
    unsigned int ticks = getTicks();
    if (end == 1 && start == 0 && reset == 0) { // 结束时
        if ((speed == FAST || speed == SLOW) && !error_short && count == 0) {
            count = 1;
            if (ticks - endTime < 3000) { // 只警报三秒
                beep = 1;
            }
        }
        if (ticks - endTime >= 3000) beep = 0;
    }
    else beep = 0; // 其余时间不能报警
}

void bluetooth_task(void){
    if (cnt == 0) {
        if (reset == 1 && start == 0 && end == 0) { // 未开始测量
            ES = 0;
            sendString("Not starting to measure yet.  \n");
            ES = 1;
        }
        else if (start == 1 && reset == 0 && end == 0) { // 正在测量
            ES = 0;
            sendString("Measuring...Please wait.  \n");
            ES = 1;
        }
        else if (end == 1 && start == 0 && reset == 0) { // 测量结束
            ES = 0;
            if (error_short == 0) {
                sendString("HeartRate:");
                sendString(wData.number);
                sendString("\n");
                sendString(wData.row2);
                sendString("\n");
            }
            else sendString("Measure time is too short.  \n");
            ES = 1;
        }
        cnt = 1; // 只发送一次
    }
}

void sendString(char *s){
    while (*s) {
        sendOneChar(*s++); 
    }
}

void sendOneChar(char c){
    SBUF = c; // 一个字符
    while(!TI);
    TI=0;
}

void sendInt(unsigned int i) {
    int j = 0;
    unsigned char c[2];
    if (!i) {
        sendOneChar('#'); // 输出给MATLAB标准格式，'#'开头，接两位十六进制数
        sendOneChar('0');
        sendOneChar('0');
    }
    else {
        c[0] = i / 256;
        c[1] = i % 256;
        sendOneChar('#');
        for (j=0;j<2;j++){
            sendOneChar(c[j]);
        }
    }            
    
}