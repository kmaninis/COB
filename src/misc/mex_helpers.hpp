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