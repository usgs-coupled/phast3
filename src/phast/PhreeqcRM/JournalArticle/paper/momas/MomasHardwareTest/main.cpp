#include<iostream>
#include <ctime> 

using namespace std;

extern double cpuTest();

int main()
{
	double time = 0.0;
	int n = 0;
	for (n = 0; n < 20; ++n)
	{
		time += cpuTest();
	}
	time /= n;
	cout << "Average CPU time for " << n << " test cycles: " << time << " s" << endl;

	system("pause");
}

double cpuTest()
{
	clock_t startTime = clock();

	const int siz = 1000;
	double ** matrixA = new double *[siz];
	double ** matrixB = new double *[siz];
	double ** matrixC = new double *[siz];
	for (int i = 0; i < siz; i++){
		matrixA[i] = new double[siz];
		matrixB[i] = new double[siz];
		matrixC[i] = new double[siz];
	}

	srand((unsigned)time(0));
	for (int i = 0; i < siz; i++){
		for (int j = 0; j < siz; j++){
			matrixA[i][j] = ((double)rand() / (double)RAND_MAX);
			matrixB[i][j] = ((double)rand() / (double)RAND_MAX);
		}
	}

	for (int i = 0; i < siz; i++){
		for (int j = 0; j < siz; j++){
			matrixC[i][j] = 0;
			for (int k = 0; k < siz; k++){
				matrixC[i][j] += (matrixA[i][k] * matrixB[k][j]);
			}
		}
	}

	for (int i = 0; i < siz; i++)
	{
		delete[] matrixA[i];
		delete[] matrixB[i];
		delete[] matrixC[i];
	}
	delete[] matrixA;
	delete[] matrixB;
	delete[] matrixC;

	double time = ((double)clock() - startTime) / CLOCKS_PER_SEC;
	return time;
}