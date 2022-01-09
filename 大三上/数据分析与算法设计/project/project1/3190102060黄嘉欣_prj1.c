#include<stdio.h>
 
int maxCoins(int* nums, int numSize);

int main(){
	int nums[3] = {1,3,1};
	int n = maxCoins(nums, sizeof(nums)/sizeof(int));
	printf("The max number of coins is: %d\n", n);
	return 0;
}

int maxCoins(int* nums, int numSize){
    int balls[numSize+2]; // 新气球数组
    int F[numSize+2][numSize+2]; // 最大硬币数矩阵
    int i, j, k;
    // 扩充nums
    balls[0] = balls[numSize+1] = 1;
    for (i=1; i<numSize+1; i++){
       balls[i] = nums[i-1];
    }
    for (i=0; i<numSize+2; i++){
       for (j=0; j<numSize+2; j++){
          F[i][j] = 0; // 初始化
       }
    }
    // 遍历求解
    for (i=numSize; i>=0; i--){ // i从下至上
       for (j=i+1; j<numSize+2; j++){ // j从左往右
          for (k=i+1; k<j; k++){
             if (F[i][j]<F[i][k]+F[k][j]+balls[i]*balls[k]*balls[j])
               F[i][j] = F[i][k]+F[k][j]+balls[i]*balls[k]*balls[j];
          }
       }
    }
    return F[0][numSize+1];
}

