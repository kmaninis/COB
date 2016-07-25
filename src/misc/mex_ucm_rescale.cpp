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
#include "ucm2hier.hpp"
#include "part2cont.hpp"
#include "ucm_fill_gaps.hpp"
#include "mex_helpers.hpp"

#include <iostream>
#include <vector>
#include <Eigen/Dense>

using namespace std;

template<class T>
std::pair<T,T> get_sorted_pair(T n1, T n2)
{
    if (n1<n2)
        return std::make_pair(n1,n2);
    else
        return std::make_pair(n2,n1);
}


void mexFunction( int nlhs, mxArray *plhs[], 
        		  int nrhs, const mxArray*prhs[] )
{
    if(nrhs!=5)
        mexErrMsgTxt("There should be 5 input parameters");
    
    /* Input parameters */
    auto ucm2              =     eigen_map<double>(prhs[0]);
    auto lp_ucm            = eigen_map<label_type>(prhs[1]);
    std::size_t nr_ucm     =           mxGetScalar(prhs[2]);
    auto lp_project        = eigen_map<label_type>(prhs[3]);
    std::size_t mode       =           mxGetScalar(prhs[4]);

    /* Check sizes */
    if (ucm2.rows() != 2*lp_ucm.rows()+1)
        mexErrMsgTxt("UCM and partitions sizes not coherent");
    

// for(std::size_t xx=0; xx<lp_project.rows(); ++xx)
// {
//     for(std::size_t yy=0; yy<lp_project.cols(); ++yy)
//        printf("%d\t",lp_proj_rel(xx,yy));
//     printf("\n");
// }

    
    /* Extract the contour positions of lp_project */
    contour_container conts = part2cont(lp_project);
// printf("Conts:\n");    
// conts.print();
    
    /* Get the neighbors of each region */
    std::map<label_type,std::set<label_type> > neighbors;
    for(const auto& elem: conts)
    {
        neighbors[elem.first.first].insert(elem.first.second);
        neighbors[elem.first.second].insert(elem.first.first);
    }
    
    
// printf("Neighbors:\n");    
// for(const auto& elem: neighbors)
// {
//     printf("%d: ",elem.first);
//     for(const auto& elem2: elem.second)
//         printf("%d,  ",elem2);
//     printf("\n");
// }    

    /* Get the hierarchy out of the ucm */
    merging_sequence ms = ucm2hier(ucm2, lp_ucm);
// printf("Merging sequence:\n");  
// ms.print();
    
    /* Get the maximum ucm threshold */
    double max_ucm_th = *(std::max_element(ms.start_ths.begin(), ms.start_ths.end()));
    double step_th = max_ucm_th/100.;
    double curr_ucm_th = step_th;

    /* Allocation ucm2_project */
    plhs[0] = mxCreateDoubleMatrix(2*lp_project.rows()+1,2*lp_project.cols()+1,mxREAL);
    auto ucm2_project = eigen_map<double>(plhs[0]);
    
    /* Redo the merging sequence on lp_project and get mark the ucm contours */
    label_type new_region = ms.n_regs;
    for(std::size_t ii=0; ii<ms.parent_labels.size(); ++ii)
    {
        /* Sweep all children */
        std::size_t num_children_done = 0;
        for(auto it = ms.children_labels[ii].begin(); it!=ms.children_labels[ii].end(); ++it, ++num_children_done)
        {
            
            auto itb = it; ++itb;
            if (itb==ms.children_labels[ii].end())
                break;

            /* Two labels being merged */
            label_type lab1;
            if (num_children_done==0)
                lab1 = *it;
            else
                lab1 = new_region;
            label_type lab2 = *itb;
            
            /* Is it the last we'll do? */
            label_type parent_label;
            auto itc = itb; ++itc;
            if (itc==ms.children_labels[ii].end())
                parent_label = ms.parent_labels[ii];
            else
            {    
                new_region++;
                parent_label = new_region;
            }
      
            /* Get the threshold value to apply (quantized or not) */
            double threshold_value;
            if (mode==1)
                threshold_value = ms.start_ths[ms.n_leaves+ii];
            else if (mode==2)
            {
                while(curr_ucm_th+step_th < ms.start_ths[ms.n_leaves+ii])
                    curr_ucm_th += step_th;
                
                threshold_value = curr_ucm_th;
            }
            else
                mexErrMsgTxt("Unknown mode");


            
            auto it2 = conts.find(get_sorted_pair(lab1,lab2));
            if (it2==conts.end())
            {
//     printf("Not found (%d,%d) - %0.3f\n",lab1,lab2,ms.start_ths[ms.n_leaves+ii]);
            }
            else
            {
//     printf("Found (%d,%d) - %0.3f\n",lab1,lab2,ms.start_ths[ms.n_leaves+ii]);
                for (const cont_elem& ct:it2->second)
                    ucm2_project(ct.x,ct.y) = threshold_value;
    // printf("Next step\n");

                /* Erase merged neighbors */
                conts.erase(it2);
                neighbors[lab1].erase(lab2);
                neighbors[lab2].erase(lab1);
    // printf("Erased\n");

            }

            /* Redo the neighbors with the parent */
            for (label_type neigh:neighbors[lab1])
            {
//     printf("    - Scanning (%d,%d)\n",get_sorted_pair(lab1,neigh).first,get_sorted_pair(lab1,neigh).second);
                auto it3 = conts.find(get_sorted_pair(lab1,neigh));
                for (const cont_elem& ct2: it3->second)
                    conts[get_sorted_pair(parent_label,neigh)].push_back(ct2);
                conts.erase(get_sorted_pair(lab1,neigh));
                neighbors[neigh].erase(lab1);
                neighbors[parent_label].insert(neigh);
                neighbors[neigh].insert(parent_label);
//     printf("    - Adding (%d,%d)\n",neigh,parent_label);

            }
            for (label_type neigh:neighbors[lab2])
            {
//     printf("    - Scanning (%d,%d)\n",get_sorted_pair(lab2,neigh).first,get_sorted_pair(lab2,neigh).second);            
                auto it3 = conts.find(get_sorted_pair(lab2,neigh));
                for (const cont_elem& ct2: it3->second)
                    conts[get_sorted_pair(parent_label,neigh)].push_back(ct2);
                conts.erase(get_sorted_pair(lab2,neigh));
                neighbors[neigh].erase(lab2);
                neighbors[parent_label].insert(neigh);
                neighbors[neigh].insert(parent_label);

//     printf("    - Adding (%d,%d)\n",neigh,parent_label);

            }

//             /* Erase merged entries in the neighbors */
//             neighbors.erase(lab1);
//             neighbors.erase(lab2);

// printf("Conts:\n");      
// conts.print();
// 
// printf("Neighbors:\n");    
// for(const auto& elem: neighbors)
// {
//     printf("%d: ",elem.first);
//     for(const auto& elem2: elem.second)
//         printf("%d,  ",elem2);
//     printf("\n");
// }   
        }
// for(std::size_t xx=0; xx<ucm2_project.rows(); ++xx)
// {
//     for(std::size_t yy=0; yy<ucm2_project.cols(); ++yy)
//        printf("%0.1f\t",ucm2_project(xx,yy));
//     printf("\n");
// }  
    
    }
    
    
    /* Connect the gaps in the UCM */
    ucm_fill_gaps(ucm2_project);
}
    
