#include "mex.h"
#include <string.h>

double ComputeBasisFunction(int size, double *x, int k, int index, double t) {
    double *Ni1 = new double[size - 1];
    bool Ni1IsZero = true;
    for(int i = 0; i < size - 1; i++) {
        if((t >= x[i]) && (t < x[i + 1])) {
            Ni1IsZero = false;
            Ni1[i] = 1;
        }
        else {
            Ni1[i] = 0;
        }
    }
    if(Ni1IsZero) {
        Ni1[((size - 2) - k) + 1] = 1;
    }
    double *N = new double[k * k]();
    // copy k elements of Ni1 starting at 'index - 1' into first row of N
    memcpy((void*)N, (void*)&(Ni1[index - 1]), k * sizeof(double));
    for(int j = 1; j < k; j++) {
        for(int i = 0; i < k - j; i++) {
            double leftDivisor = (x[i+j+index-1]-x[i+index-1]);
            double Nij_left = 0;
            if(leftDivisor != 0) {
                Nij_left = (t-x[i+index-1])*N[(j-1)*k+i] / leftDivisor;
            }
            double rightDivisor = (x[i+j+index-0]-x[i+1+index-1]);
            double Nij_right = 0;
            if(rightDivisor != 0) {
                Nij_right = (x[i+j+index-0]-t)*N[(j-1)*k+i+1] / rightDivisor;
            }
            N[j * k + i] = Nij_left + Nij_right;
        }
    }
    double result = N[(k - 1) * k];
    delete[] Ni1;
    delete[] N;
    return result;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    int r = *mxGetPr(prhs[0]);
    int s = *mxGetPr(prhs[1]);
    int n = *mxGetPr(prhs[2]);
    int m = *mxGetPr(prhs[3]);
    double *x = mxGetPr(prhs[4]);
    int size = mxGetN(prhs[4]);
    int k = *mxGetPr(prhs[5]);
    double *u = mxGetPr(prhs[6]);
    int uNRows = mxGetM(prhs[6]);
    double *w = mxGetPr(prhs[7]);
    int wNRows = mxGetM(prhs[7]);
    
    int nrows = r * s;
    int ncols = n * m;
    plhs[0] = mxCreateDoubleMatrix(nrows, ncols, mxREAL);
    double *outData = (double*)mxGetData(plhs[0]);
    
    for(int i = 0; i < r; i++) {
        for(int j = 0; j < s; j++) {
            for(int p = 0; p < n; p++) {
                for(int q = 0; q < m; q++) {
                    int row = (i * s) + j;
                    int col = (p * m) + q;
                    outData[(col * nrows) + row] = ComputeBasisFunction(size, x, k, p + 1, u[j * uNRows + i]) * ComputeBasisFunction(size, x, k, q + 1, w[j * wNRows + i]);
                }
            }
        }
    }
}