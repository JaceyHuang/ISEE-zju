#include<stdio.h>
#include<math.h>

int main(int argc, char* argv[])
{
    int a=1, b=10;
    char c[20]="Hello world! ", d[20]="RISC-V!";
    if (a+2==sqrt(b-1)){
        printf("%s",c);
        printf("My name is %s\n",d);
    }
    else {
        printf("Sorry! Please have another try!");
    }
    return 0;
}