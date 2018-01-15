// Takes a matrix where each element corresponds to the shape type at that
// pixel. Also takes size of convolution kernel.
// Returns new matrix of same dimensions where each element is the most 
// commonly occurring number in the kernel around the corresponding element
// in the original matrix.
// Has exactly the same external behaviour as 'SurfaceFeatureFilt.m' but is
// considerably faster.
// Author: Kevin Li Sun, Demian Till, Email: lisunsir@gmail.com, demiantill@gmail.com

#include "mex.h"
#define SHAPE_TYPES 50 // at time of writing, there were 9 different 'shape types', hopefully 50 is safe

void SurfaceFeatureFilt(double *surfaceFeature, int rows, int cols, int r, double *out) {
    for(int col = 0; col < cols; col++) {
        for(int row = 0; row < rows; row++) {
            if(surfaceFeature[col * rows + row] == 0) {
                out[col * rows + row] = mxGetNaN();
            }
            else {
                // find most commonly occuring number in square patch +-r around cell
                int left = col - r;
                int right = col + r;
                int up = row - r;
                int down = row + r;
                if(left < 0) left = 0;
                if(right > cols - 1) right = cols - 1;
                if(up < 0) up = 0;
                if(down > rows - 1) down = rows - 1;
                int counts[SHAPE_TYPES] = {0};
                for(int patchCol = left; patchCol <= right; patchCol++) {
                    for(int patchRow = up; patchRow <= down; patchRow++) {
                        counts[(int)surfaceFeature[patchCol * rows + patchRow]]++;
                    }
                }
                int highestCount = counts[1]; // shape types start at 1. Zero is not a shape type
                int correspondingShape = 1;
                for(int i = 2; i < SHAPE_TYPES; i++) {
                    if(counts[i] > highestCount) {
                        highestCount = counts[i];
                        correspondingShape = i;
                    }
                }
                out[col * rows + row] = correspondingShape;
            }
        }
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    double *surfaceFeature = mxGetPr(prhs[0]);
    int r = *mxGetPr(prhs[1]);
    int rows = mxGetM(prhs[0]);
    int cols = mxGetN(prhs[0]);
    plhs[0] = mxCreateDoubleMatrix(rows, cols, mxREAL);
    double *out = (double*)mxGetData(plhs[0]);
    
    SurfaceFeatureFilt(surfaceFeature, rows, cols, r, out);
}
