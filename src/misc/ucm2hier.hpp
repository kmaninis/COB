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
#ifndef UCM2HIER_HPP
#define UCM2HIER_HPP

#include <iostream>
#include "containers.hpp"
#include <Eigen/Dense>


void insert_labels_to_merge(label_type lab1,label_type lab2,std::list<set_type>& to_merge)
{
    std::list<set_type>::iterator l1 = to_merge.begin();
    for( ; l1!=to_merge.end(); ++l1)
        if (l1->find(lab1) != l1->end())
            break;
    std::list<set_type>::iterator l2 = to_merge.begin();
    for( ; l2!=to_merge.end(); ++l2)
        if (l2->find(lab2) != l2->end())
            break;

    if (l1==to_merge.end() && l2==to_merge.end())  // Neither label found --> New set
    {
        set_type to_put;
         to_put.insert(lab1);
         to_put.insert(lab2);
        to_merge.push_back(to_put);
    }
    else if (l1==to_merge.end() && l2!=to_merge.end())  // Found one of the two in one set --> Add the other
        l2->insert(lab1);
    else if (l1!=to_merge.end() && l2==to_merge.end())  // Found one of the two in one set --> Add the other
        l1->insert(lab2);
    else if (l1!=l2)  // Both found in different sets --> Merge the two sets
    {
        l1->insert(l2->begin(), l2->end());
        to_merge.erase(l2);
    }
}


merging_sequence ucm2hier(const Eigen::Array<double,Eigen::Dynamic,Eigen::Dynamic>& ucm2, const Eigen::Array<label_type,Eigen::Dynamic,Eigen::Dynamic>& lp)
{
    /* Sizes */
    std::size_t sx = lp.rows();
    std::size_t sy = lp.cols();

    /*-------------------------------------------------------------*/
    /* Create LUT of contour positions and sets of labels to merge */
    /*-------------------------------------------------------------*/
    map_type ucm_th_leaves_pairs;
    
    /* Scan horizontal contours*/
    for (std::size_t xx=2; xx<2*sx; xx+=2)
    {
        for (std::size_t yy=1; yy<2*sy; yy+=2)
        {
            if (ucm2(xx,yy)>0)
            {
                std::size_t n1_x = (xx/2)-1;
                std::size_t n1_y = (yy-1)/2;
                std::size_t n2_x = xx/2;
                std::size_t n2_y = (yy-1)/2;
                label_type lab1 = std::min(lp(n1_x,n1_y),lp(n2_x,n2_y));
                label_type lab2 = std::max(lp(n1_x,n1_y),lp(n2_x,n2_y));

                /* Get the sets of regions to be merged                       */
                /* In one threshold there can be more than one region forming */
                map_type::iterator map_it = ucm_th_leaves_pairs.find(ucm2(xx,yy));
                if (map_it==ucm_th_leaves_pairs.end()) // New ucm threshold
                {
                    set_type set_to_put;
                     set_to_put.insert(lab1);
                     set_to_put.insert(lab2);
                    std::list<set_type> to_put;
                    to_put.push_back(set_to_put); // Add up and down neighbors
                    ucm_th_leaves_pairs.insert(map_type::value_type(ucm2(xx,yy), to_put));
                }
                else
                    insert_labels_to_merge(lab1,lab2,map_it->second);
            }
        }
    }

    /* Scan vertical contours*/
    for (std::size_t xx=1; xx<2*sx; xx+=2)
    {
        for (std::size_t yy=2; yy<2*sy; yy+=2)
        {
            if (ucm2(xx,yy)>0)
            {
                std::size_t n1_x = (xx-1)/2;
                std::size_t n1_y = (yy/2)-1;
                std::size_t n2_x = (xx-1)/2;
                std::size_t n2_y = yy/2;
                label_type lab1 = std::min(lp(n1_x,n1_y),lp(n2_x,n2_y));
                label_type lab2 = std::max(lp(n1_x,n1_y),lp(n2_x,n2_y));

                /* Get the sets of regions to be merged                       */
                /* In one threshold there can be more than one region forming */
                map_type::iterator map_it = ucm_th_leaves_pairs.find(ucm2(xx,yy));
                if (map_it==ucm_th_leaves_pairs.end()) // New ucm threshold
                {
                    set_type set_to_put;
                     set_to_put.insert(lab1);
                     set_to_put.insert(lab2);
                    std::list<set_type> to_put;
                    to_put.push_back(set_to_put); // Add left and right neighbors
                    ucm_th_leaves_pairs.insert(map_type::value_type(ucm2(xx,yy), to_put));
                }
                else
                    insert_labels_to_merge(lab1,lab2,map_it->second);
            }
        }
    }
    
    /* Number of thresholds is number of mergings */
    int n_merges = ucm_th_leaves_pairs.size();
    /*-------------------------------------------------------------*/
    
   
    /*-----------------------------------------------------------*/
    /*  Scan all thresholds of the UCM in increasing order and   */
    /*   do the mergings of the N regions that 'disappear'       */
    /*-----------------------------------------------------------*/

    /* Get number of leaves */
    label_type curr_max = 0;
    for (std::size_t xx=0; xx<sx; ++xx)
        for (std::size_t yy=0; yy<sy; ++yy)
            curr_max = std::max(curr_max, lp(xx,yy));
    label_type n_leaves = curr_max;
    
    /* Start LUT with leaves */
    std::vector<label_type> lut(n_leaves);
    std::vector<set_type> ilut(n_leaves);
    for (std::size_t ll=0; ll<n_leaves; ++ll)
    {
        lut[ll] = ll+1;
        ilut[ll].insert(ll+1);
    }
    
    /* Scan */
    merging_sequence ms;
    ms.n_max_children = 1;
    ms.start_ths = std::vector<double>(n_leaves,0);
    
    map_type::iterator it = ucm_th_leaves_pairs.begin();
    for ( ; it!=ucm_th_leaves_pairs.end(); ++it)
    {        
        std::list<set_type>& leaves_to_merge = it->second;
        std::list<set_type>    regs_to_merge;
        
        std::list<set_type>::iterator it3 = leaves_to_merge.begin();
        for ( ; it3!=leaves_to_merge.end(); ++it3)
        {
            /* Get the labels of the children regions from the leave labels */
            set_type::iterator it4  = it3->begin();
            set_type::iterator it4b = it3->begin();
            ++it4b;
            
            for( ; it4b!=it3->end(); ++it4b)
                insert_labels_to_merge(lut[*it4-1],lut[*it4b-1],regs_to_merge);
        }
        
        it3 = regs_to_merge.begin();
        for ( ; it3!=regs_to_merge.end(); ++it3)
        {
            curr_max += 1;
            ilut.push_back(set_type());

            /* Update LUT */
            set_type to_update(*it3);
            while(!to_update.empty())
            {
                /* Get the first to update */
                label_type curr = *(to_update.begin());             
                to_update.erase(to_update.begin());
                if (lut[curr-1]!=curr)
                    to_update.insert(lut[curr-1]);
                
                set_type::iterator it5 = ilut[curr-1].begin();
                for( ; it5!=ilut[curr-1].end(); ++it5)
                {
                    lut[*it5-1] = curr_max;
                    ilut[curr_max-1].insert(*it5);
                }
                ilut[curr-1].clear();
            }

            /* Copy the labels to the merging sequence */
            ms.children_labels.push_back(std::list<label_type>(it3->begin(),it3->end()));
            ms.n_max_children = std::max(ms.n_max_children,it3->size());
            
            /* Add parent to the LUT and to out*/
            lut.push_back(curr_max);
            ms.parent_labels.push_back(curr_max);
            
            /* Store the start contour threshold */
            ms.start_ths.push_back(it->first);
        }
    }
    ms.n_regs = curr_max;
    ms.n_leaves = n_leaves;
    /*-----------------------------------------------------------*/
    
    if(ms.n_regs!=ms.start_ths.size())
        mexErrMsgTxt("Oh oh");
    
    
    return ms;
}

#endif
