// ------------------------------------------------------------------------ 
//  Copyright (C)
//  Universitat Politecnica de Catalunya BarcelonaTech (UPC) - Spain
//  University of California Berkeley (UCB) - USA
// 
//  Jordi Pont-Tuset <jordi.pont@upc.edu>
//  Pablo Arbelaez <arbelaez@berkeley.edu>
//  June 2014
// ------------------------------------------------------------------------ 
// This file is part of the MCG package presented in:
//    Arbelaez P, Pont-Tuset J, Barron J, Marques F, Malik J,
//    "Multiscale Combinatorial Grouping,"
//    Computer Vision and Pattern Recognition (CVPR) 2014.
// Please consider citing the paper if you use this code.
// ------------------------------------------------------------------------
#include "mex.h"
#include "mex_helpers.hpp"
#include "ucm2hier.hpp"

#include <iostream>
#include <vector>
#include <list>
#include <set>
#include <map>
#include <algorithm>
#include <Eigen/Dense>

using namespace std;
using namespace Eigen;


void mexFunction( int nlhs, mxArray *plhs[], 
        		  int nrhs, const mxArray*prhs[] )
{
    if(nrhs!=2)
        mexErrMsgTxt("There should be 2 input parameters");
    
    /* Input parameters */
    auto lp   = eigen_map<label_type>(prhs[0]);
    auto ucm2 = eigen_map<double>(prhs[1]);

    /* Call actual function */
    merging_sequence ms = ucm2hier(ucm2, lp);
            
    /* Output allocation */
    plhs[0] = mxCreateDoubleMatrix(ms.parent_labels.size(),ms.n_max_children+1,mxREAL);
    auto ms_out = eigen_map<double>(plhs[0]);
    plhs[1] = mxCreateDoubleMatrix(ms.n_regs,1,mxREAL);
    auto start_ths_out = eigen_map<double>(plhs[1]);
    plhs[2] = mxCreateDoubleMatrix(ms.n_regs,1,mxREAL);
    auto end_ths_out = eigen_map<double>(plhs[2]);
    
    /* Copy data to output */
    for (size_t ii=0; ii<ms.n_regs; ++ii)
        start_ths_out(ii,0) = ms.start_ths[ii];
        
    for (size_t ii=0; ii<ms.parent_labels.size(); ++ii)
    {
        ms_out(ii,ms.n_max_children) = ms.parent_labels[ii];
        list<label_type>::iterator it4 = ms.children_labels[ii].begin();
        for (size_t jj=0 ; it4!=ms.children_labels[ii].end(); ++it4, ++jj)
        {
            ms_out(ii,jj) = *it4;
            end_ths_out(*it4-1,0) = start_ths_out(ms.parent_labels[ii]-1,0);
        }
    }
    end_ths_out(ms.n_regs-1,0) = 1;
}
    
