#include<stdio.h>

int superEggDrop(int k, int n);

int main()
{
    int k = 3; // k = 1
    int n = 14; // n = 2
    int result = superEggDrop(k,n);
    printf("The minimum number of operations is: %d", result);
    return 0; 
}

int superEggDrop(int k, int n)
{
    int F[k+1][n+1]; // 最大楼层数矩阵
    int i, j;
    for (i=0;i<k+1;i++){
        for (j=0;j<n+1;j++){
            F[i][j] = 0; // 二维数组初始化
        }
    }
    for (i=0;i<k+1;i++){ // 初始条件
        F[i][0] = 0;
    }
    for (j=0;j<n+1;j++){
        F[0][j] = 0;
    }
    j = 0; // 操作次数
    while (F[k][j]<n){
        j++; // 注意不要下标越界
        for (i=1;i<k+1;i++){
            F[i][j] = F[i-1][j-1]+F[i][j-1]+1;
        }
    }
    return j;
}
