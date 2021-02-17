#include<iostream>
#include <ctime> 

using namespace std;
int main()
{
	const int siz = 1000;
	double ** matrixA = new double * [siz];
	double ** matrixB = new double * [siz];
	double ** matrixC = new double * [siz];
	for(int i = 0; i < siz; i++){
		matrixA[i]=new double[siz];
		matrixB[i]=new double[siz];
		matrixC[i]=new double[siz];
	}

	srand((unsigned)time(0));
	for(int i = 0; i < siz; i++){
		for(int j = 0; j < siz; j++){
			matrixA[i][j] = ((double)rand()/(double)RAND_MAX);
			matrixB[i][j] = ((double)rand()/(double)RAND_MAX);
		}
	}

	clock_t startTime = clock();
	for(int i = 0; i < siz; i++){
		for(int j = 0; j < siz; j++){
			matrixC[i][j] = 0;
			for(int k = 0; k < siz; k++){
				matrixC[i][j] = matrixC[i][j] + (matrixA[i][k] * matrixB[k][j]);
			}
		}
	}
	double time = ((double)clock() - startTime) / CLOCKS_PER_SEC;


	cout << "CPU time for matrix multiplication of size " << siz << ": " << time << " s" << endl;

	for (int i = 0; i < siz; i++)
	{
		delete[] matrixA[i];
		delete[] matrixB[i];
		delete[] matrixC[i];
	}
	delete[] matrixA;
	delete[] matrixB;
	delete[] matrixC;

	system("pause");
	return 0;
}