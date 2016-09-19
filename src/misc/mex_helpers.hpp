// ------------------------------------------------------------------------ 
//  Copyright (C)
//  ETH Zurich - Switzerland
// 
//  Kevis-Kokitsi Maninis <kmaninis@vision.ee.ethz.ch>
//  Jordi Pont-Tuset <jponttuset@vision.ee.ethz.ch>
//  July 2016
// ------------------------------------------------------------------------ 
// This file is part of the COB package presented in:
//    K.K. Maninis, J. Pont-Tuset, P. Arbelaez and L. Van Gool 
//    Convolutional Oriented Boundaries
//    European Conference on Computer Vision (ECCV), 2016 
// Please consider citing the paper if you use this code.
// ------------------------------------------------------------------------
#ifndef MEX_HELPERS_HPP
#define MEX_HELPERS_HPP

#include "mex.h"
#include <Eigen/Dense>

template<class T, class P>
Eigen::Map<Eigen::Array<T,Eigen::Dynamic,Eigen::Dynamic> > eigen_map(P matlab_pointer)
{
    return Eigen::Map<Eigen::Array<T,Eigen::Dynamic,Eigen::Dynamic> > ((T*)mxGetData(matlab_pointer),mxGetM(matlab_pointer),mxGetN(matlab_pointer));
}

#endif