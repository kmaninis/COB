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
// mex_seg2contourlist(partition, border, simplify_tol)
#include "mex.h"
#include "matlab_multiarray.hpp"
#include "seg2contourlist.hpp"

using namespace std;

void mexFunction( int nlhs, mxArray *plhs[], 
        		  int nrhs, const mxArray*prhs[] )
{
    /* Check number of input parameter */
    if (nrhs==0)
        mexErrMsgTxt("There should be at least 1 input parameter");
    else if (nrhs>3)
        mexErrMsgTxt("Maximum 3 input parameters");
    
    /* Read constants or set the default values */
    /* Whether to include the coordinates of the image border */
    double border;
    if(nrhs<2)
        border = 0;
    else
        border = mxGetScalar(prhs[1]);

    /* Parameter controling the amount of simplifiction of the contour points */
    double simplify_tol;
    if(nrhs<3)
        simplify_tol = 0;
    else
        simplify_tol = mxGetScalar(prhs[2]);
    
    /* Input segmentation - Matrix of labels */
    ConstMatlabMultiArray<double> seg(prhs[0]);

    /* Call the actual code */
    std::vector<cont_piece> all_cont_pieces;
    std::vector<std::set<double> > reg_table;
    boost::multi_array<double,2> junction_ids;
    std::vector<junction> junction_set;
    seg2contourlist(seg, border, simplify_tol, all_cont_pieces, reg_table, junction_ids, junction_set);
    
    /*-------------------------------------------*/
    /*                 Output                    */
    /*-------------------------------------------*/
    
    /* ---- Contour list ---- */
    /* Allocate */
    const char **fieldnames;
    fieldnames = (const char **)mxCalloc(4, sizeof(*fieldnames));
    fieldnames[0] = "origin_junction";
    fieldnames[1] = "end_junction";
    fieldnames[2] = "neighbors";
    fieldnames[3] = "contour_coords";

    plhs[0] = mxCreateStructMatrix(1,all_cont_pieces.size(),4,fieldnames);
    mxFree((void *)fieldnames);
    
    /* Copy to output struct */
    for (std::size_t ii=0; ii<all_cont_pieces.size(); ++ii)
    {   
        /* Copy origin junction */
        mxArray * curr_field = mxCreateDoubleMatrix((mwSize)1, (mwSize)2, mxREAL);
        double * ptr = mxGetPr(curr_field);
        ptr[0] = junction_set[all_cont_pieces[ii].orig_junc-1].pos.x;
        ptr[1] = junction_set[all_cont_pieces[ii].orig_junc-1].pos.y;
        mxSetFieldByNumber(plhs[0], (mwIndex)ii, 0, curr_field);

        /* Copy end junction */
        curr_field = mxCreateDoubleMatrix((mwSize)1, (mwSize)2, mxREAL);
        ptr = mxGetPr(curr_field);
        ptr[0] = junction_set[all_cont_pieces[ii].end_junc-1].pos.x;
        ptr[1] = junction_set[all_cont_pieces[ii].end_junc-1].pos.y;
        mxSetFieldByNumber(plhs[0], (mwIndex)ii, 1, curr_field);
        
        /* Copy neighbors */
        curr_field = mxCreateDoubleMatrix((mwSize)1, (mwSize)2, mxREAL);
        ptr = mxGetPr(curr_field);
        ptr[0] = all_cont_pieces[ii].neigh_region1[0];
        ptr[1] = all_cont_pieces[ii].neigh_region2[0];
        mxSetFieldByNumber(plhs[0], (mwIndex)ii, 2, curr_field);
        
        /* Copy contour coordinates */
        curr_field = mxCreateDoubleMatrix((mwSize)all_cont_pieces[ii].cont_coords.size(), (mwSize)2, mxREAL);
        ptr = mxGetPr(curr_field);
        for (std::size_t jj=0; jj<all_cont_pieces[ii].cont_coords.size(); ++jj)
        {
            ptr[jj] = all_cont_pieces[ii].cont_coords[jj].x;
            ptr[jj+all_cont_pieces[ii].cont_coords.size()] = all_cont_pieces[ii].cont_coords[jj].y;
        }
        mxSetFieldByNumber(plhs[0], (mwIndex)ii, 3, curr_field);
    }
    
    /* ---- Region table ---- */
    /* Allocate */
    mwSize dims_out[1]; 
    dims_out[0] = reg_table.size();
    plhs[1] = mxCreateCellArray(1, dims_out);
    
    /* Copy region table to output */
    for (std::size_t ii=0; ii<reg_table.size(); ++ii)
    {
        mxArray* curr_entry = mxCreateNumericMatrix(1, reg_table[ii].size(), mxDOUBLE_CLASS, mxREAL);
        double* curr_pr = mxGetPr(curr_entry);
        std::size_t curr_jj = 0;
        for(std::set<double>::iterator it=reg_table[ii].begin(); it!=reg_table[ii].end(); ++it)
        {
            curr_pr[curr_jj] = *it+1; // Matlab 1-indexing
            curr_jj++;
        }
        mxSetCell(plhs[1], ii, curr_entry);
    }
    
    /* ---- Junction map ---- */
    /* Allocate */
    plhs[2] = mxCreateDoubleMatrix(junction_ids.shape()[0],junction_ids.shape()[1],mxREAL);
    MatlabMultiArray<double> junction_ids_out(plhs[2]);
    
    /* Copy junction map to output */
    for (std::size_t xx=0; xx<junction_ids.shape()[0]; ++xx)
        for (std::size_t yy=0; yy<junction_ids.shape()[1]; ++yy)
            junction_ids_out[xx][yy] = junction_ids[xx][yy];
    
    /*-------------------------------------------*/
}
    
