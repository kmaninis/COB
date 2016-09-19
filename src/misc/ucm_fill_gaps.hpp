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
#ifndef UCM_FILL_GAPS_HPP
#define UCM_FILL_GAPS_HPP

#include <iostream>
#include "containers.hpp"
#include <Eigen/Dense>

void ucm_fill_gaps(Eigen::Map<Eigen::Array<double,Eigen::Dynamic,Eigen::Dynamic> >& ucm2)
{
    /* Sizes */
    std::size_t sx = ucm2.rows();
    std::size_t sy = ucm2.cols();

    /*-------------------------------------------------------------*/
    /* Create LUT of contour positions and sets of labels to merge */
    /*-------------------------------------------------------------*/
    map_type ucm_th_leaves_pairs;
    
    /* Scan horizontal contours*/
    for (std::size_t xx=0; xx<sx; xx+=2)
    {
        for (std::size_t yy=0; yy<sy; yy+=2)
        {
            double curr_max = 0;
            if(xx>0)
                curr_max = std::max(curr_max,ucm2(xx-1,yy));
            if(yy>0)
                curr_max = std::max(curr_max,ucm2(xx,yy-1));
            if(xx<sx-1)
                curr_max = std::max(curr_max,ucm2(xx+1,yy));
            if(yy<sy-1)
                curr_max = std::max(curr_max,ucm2(xx,yy+1));
            
            ucm2(xx,yy) = curr_max;
        }
    }
}

#endif
