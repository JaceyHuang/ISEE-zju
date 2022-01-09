#include<stdio.h>

int minRefuelStops(int target, int startFuel, int stations[][0], int stationsSize, int* stationsColSize);

int main(){
    // int target = 100;
    // int startFuel = 10;
    // int stations[4][2] = {10,60,20,30,30,30,60,40};
    // int stationsSize = 4;
    int target = 1;
    int startFuel = 1;
    int stations[0][0] = {};
    int stationsSize = 0;
    int stationsColSize[1] = {1}; // 函数中未用到，故可任意取值
    int result = minRefuelStops(target, startFuel, stations, stationsSize, stationsColSize);
    printf("The minRefuelStops is %d", result);
    return 0; 
}

int minRefuelStops(int target, int startFuel, int stations[][0], int stationsSize, int* stationsColSize){
    int n = stationsSize;
    long F[n+1][n+1]; // 最大距离矩阵, 大小设置为(n+1)*(n+1)是为了防止越界
    int i, j;
    for (i=0;i<n+1;i++){
        for (j=0;j<n+1;j++){
            F[i][j] = 0; // 二维数组初始化
        }
    }
    for (i=0;i<n+1;i++){
        F[i][0] = startFuel; // 初始条件
    }
    for (i=1;i<n+1;i++){ // 从上到下逐行填写
        for (j=1;j<=i;j++){ // 注意下标不能小于0
            if (F[i-1][j]>=stations[i-1][0]){ // 第i站不加油
                F[i][j] = F[i-1][j];
            }
            if (F[i-1][j-1]>=stations[i-1][0]){ // 第i站加油
                if (F[i][j] < F[i-1][j-1]+stations[i-1][1]){ // 更大值
                    F[i][j] = F[i-1][j-1]+stations[i-1][1];
                }
            }
        }
    } 
    for (j=0;j<=n;j++){ // 从小到大遍历，找到最小的j
        if (F[n][j] >= target){
            return j;
        }
    }
    return -1;
}
