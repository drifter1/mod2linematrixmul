#include <stdio.h>
#define M 4
#define N 2
int main(){
	int A[M] = {1,1,1,1};
	int H[M][N] = {1,0,0,1,1,0,1,1};
	int R[N];
	int i, j;
	int res, temp;
	
	// print A
	printf("A:\n");
	for(i = 0; i < M; i++){
		printf("%d", A[i]);
	}
	printf("\n\n");	
	
	// print H
	printf("H:\n");
	for(i = 0; i < M; i++){
		for(j = 0; j < N; j++){
			printf("%d ", H[i][j]);
		}
		printf("\n");
	}
	printf("\n");	
	
	// calculate and print R
	printf("R:\n");
	for(i = 0; i < N; i++){
		res = 0;
		for(j = 0; j < M; j++){
			temp = A[j] & H[j][i];
			res = res ^ temp;
		}
		R[i] = res;
		printf("%d", R[i]);
	}
}
