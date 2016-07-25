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
