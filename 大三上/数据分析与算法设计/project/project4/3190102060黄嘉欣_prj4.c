#include <stdio.h>
#include <stdbool.h>

bool canCross(int* stones, int stonesSize);

int main()
{
    int stones[8] = {0,1,2,4,5,7,11,16};
    int stonesSize = sizeof(stones)/sizeof(int);
    if (canCross(stones, stonesSize))
        printf("The frog can reach the other side of the river.");
    else 
        printf("The frog can NOT reach the other side of the river.");
    return 0; 
}

bool canCross(int* stones, int stonesSize)
{
    int F[stonesSize][stonesSize];
    int i, j, k;
    for (i=0;i<stonesSize;i++){
        for (j=0;j<stonesSize;j++){
            F[i][j] = 0; // 二维数组初始化
        }
    }
    F[0][0] = 1; // 初始条件
    for (i=1;i<stonesSize; ++i) { // 注意起始点
        for (j=i-1; j>=0;j--) {
            k = stones[i]-stones[j]; // 跳跃距离
            if (k>j+1) { // 限制条件
                break;
            }
            F[i][k] = F[j][k-1]||F[j][k]||F[j][k+1]; // 填充
        }
    }
    for (k=0;k<stonesSize;k++){
        if (F[stonesSize-1][k] == 1)
            return true; // 能到达最后一块石子
    }
    return false; // 无法到达
}
