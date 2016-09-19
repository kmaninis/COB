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

#ifndef SEG2CONTOURLIST_HPP
#define SEG2CONTOURLIST_HPP

#include "matlab_multiarray.hpp"
#include <iostream>
#include <list>
#include <set>
#include <map>
#include <algorithm>
#include "psimpl/psimpl.h"
#include "containers.hpp"

typedef boost::multi_array_types::index_range range;


void explore_contour(cont_piece& curr_cont, 
                     std::vector<junction>& junction_set,
                     boost::multi_array<bool,2>& visited,
                     boost::multi_array<double,2>& junction_ids,
                     boost::multi_array<double,2>& neigh_max)
{   
    /* This will contain the next contour coordinate to explore at each iteration */
    coord next_to_visit = curr_cont.cont_coords[0];
    curr_cont.cont_coords.pop_back();
    
    /* Store the next 'junction point' to be visited */
    coord junct_visited(junction_set[curr_cont.orig_junc-1].pos);
    coord junct_to_visit = junct_visited;
        
    /* Keep exploring until we find a junction */
    bool found = false;
    while(!found)
    {
        /* Mark the visited junction point as visited */
        visited[junct_visited.x][junct_visited.y] = true;
        
        /* Get the coordinate to explore */
        coord cont_to_visit = next_to_visit;
        
        /* Is it a vertical or horizontal contour? */
        coord extreme1;
        coord extreme2;
        if (cont_to_visit.x % 2) // Vertical
        {
            extreme1.x = cont_to_visit.x+1;
            extreme1.y = cont_to_visit.y;
            extreme2.x = cont_to_visit.x-1;
            extreme2.y = cont_to_visit.y;
        }
        else // Horizontal
        {
            extreme1.x = cont_to_visit.x;
            extreme1.y = cont_to_visit.y-1;
            extreme2.x = cont_to_visit.x;
            extreme2.y = cont_to_visit.y+1;
        }
        
        /* Get the next junction point to visit */
        if(!visited[extreme1.x][extreme1.y])       /* Next 'junction point' not visited */
        {
            junct_to_visit.x = extreme1.x;
            junct_to_visit.y = extreme1.y;
        }
        else if (!visited[extreme2.x][extreme2.y]) /* Other not visited */
        {
            junct_to_visit.x = extreme2.x;
            junct_to_visit.y = extreme2.y;
        }
        else  /* Both visited, look for the junction, which will be the end of the piece */
        {
            if (extreme1.x==junct_to_visit.x && extreme1.y==junct_to_visit.y)
            {
                junct_to_visit.x = extreme2.x;
                junct_to_visit.y = extreme2.y;
            }
            else
            {
                if (!(extreme2.x==junct_to_visit.x && extreme2.y==junct_to_visit.y))
                    mexErrMsgTxt("Oh oh 1");
                junct_to_visit.x = extreme1.x;
                junct_to_visit.y = extreme1.y;
            }
        }

        /* Mark the contour and junction as visited */
        visited[cont_to_visit.x][cont_to_visit.y] = true;
        visited[junct_to_visit.x][junct_to_visit.y] = true;
        
        /* Is the 'junction point' to be visited really a junction? */
        if (junction_ids[junct_to_visit.x][junct_to_visit.y]>0) /* Yes it is, so we finish */
        {
            found = true;
            curr_cont.end_junc = junction_ids[junct_to_visit.x][junct_to_visit.y];
        }
        else /* It is not a junction, keep visiting */
        {
            /* Look for the next unvisited direction with contour (neigh_max)*/
            if (neigh_max[junct_to_visit.x+1][junct_to_visit.y]>0 && !visited[junct_to_visit.x+1][junct_to_visit.y])
                next_to_visit = coord(junct_to_visit.x+1,junct_to_visit.y);
            else if (neigh_max[junct_to_visit.x-1][junct_to_visit.y]>0 && !visited[junct_to_visit.x-1][junct_to_visit.y])
                next_to_visit = coord(junct_to_visit.x-1,junct_to_visit.y);
            else if (neigh_max[junct_to_visit.x][junct_to_visit.y+1]>0 && !visited[junct_to_visit.x][junct_to_visit.y+1])
                next_to_visit = coord(junct_to_visit.x,junct_to_visit.y+1);
            else
            {
                if(!(neigh_max[junct_to_visit.x][junct_to_visit.y-1]>0 && !visited[junct_to_visit.x][junct_to_visit.y-1]))
                    mexErrMsgTxt("Oh oh 2");
                next_to_visit = coord(junct_to_visit.x,junct_to_visit.y-1);
            }
        }
        
        /* Add the contour coordinate to the list */
        curr_cont.cont_coords.push_back(coord(cont_to_visit.x,cont_to_visit.y));
    }
}



/* Implementation of the actual function: from an image partition (matrix of labels), we get the
 * set of junctions and the set of contour pieces that form that partition. We simplify the
 * number of contour points by the Douglas-Peucker algorithm. We index all the contour pieces
 * around each region */
template<typename MatrixContainer>
void seg2contourlist(const MatrixContainer& seg,                   /* Input segmentation */
                     double border,                                /* Whether we include the borders of the image as contours */
                     double simplify_tol,                          /* Tolerance of the line simplification algorithm */
                     std::vector<cont_piece>& all_cont_pieces,     /* Vector containing the finished contour pieces */
                     std::vector<std::set<double> >& reg_table,    /* Contour pieces indexed by region */
                     boost::multi_array<double,2>& junction_ids,   /* Position of all junctions in the contour grid */
                     std::vector<junction>& junction_set)          /* Vector containing all junction descriptions */
{
    /* Input size */
    int sx   = seg.shape()[0];
    int sy   = seg.shape()[1];
        
    /* Add padding to seg and count the number of regions */
    boost::multi_array<double,2> seg_pad(boost::extents[sx+2][sy+2]);
    seg_pad.reindex(-1);
    double n_regs = 0;
    for (int xx=0; xx<sx; ++xx)
    {
        for (int yy=0; yy<sy; ++yy)
        {
            seg_pad[xx][yy] = seg[xx][yy];
            n_regs = std::max(n_regs, seg[xx][yy]);
        }
    }

    /*--------------------------------------------------------------------*/
    /* Sweep in all directions to get contour places with neighbor labels */
    /*--------------------------------------------------------------------*/
    /* Neighbors minimum and maximum label */
    /* We add a padding of value -1 to avoid accessing out of the image */
    /* The container has negative coordinates to avoid having to add +1 everywhere */ 
    boost::multi_array<double,2> neigh_min(boost::extents[2*sx+3][2*sy+3]);
    boost::multi_array<double,2> neigh_max(boost::extents[2*sx+3][2*sy+3]);
    neigh_min.reindex(-1);
    neigh_max.reindex(-1);
    
    /* Add -1 in the borders */
    std::fill(neigh_min[boost::indices[range(-1,2*sx+2)][-1]].begin(), neigh_min[boost::indices[range(-1,2*sx+2)][-1]].end(), -1);
    std::fill(neigh_max[boost::indices[range(-1,2*sx+2)][-1]].begin(), neigh_max[boost::indices[range(-1,2*sx+2)][-1]].end(), -1);
     
    std::fill(neigh_min[boost::indices[range(-1,2*sx+2)][2*sy+1]].begin(), neigh_min[boost::indices[range(-1,2*sx+2)][2*sy+1]].end(), -1);
    std::fill(neigh_max[boost::indices[range(-1,2*sx+2)][2*sy+1]].begin(), neigh_max[boost::indices[range(-1,2*sx+2)][2*sy+1]].end(), -1);
    
    std::fill(neigh_min[boost::indices[-1][range(-1,2*sy+2)]].begin(), neigh_min[boost::indices[-1][range(-1,2*sy+2)]].end(), -1);
    std::fill(neigh_max[boost::indices[-1][range(-1,2*sy+2)]].begin(), neigh_max[boost::indices[-1][range(-1,2*sy+2)]].end(), -1);
    
    std::fill(neigh_min[boost::indices[2*sx+1][range(-1,2*sy+2)]].begin(), neigh_min[boost::indices[2*sx+1][range(-1,2*sy+2)]].end(), -1);
    std::fill(neigh_max[boost::indices[2*sx+1][range(-1,2*sy+2)]].begin(), neigh_max[boost::indices[2*sx+1][range(-1,2*sy+2)]].end(), -1); 
    
    /* Vertical contours */
    for (int xx=0; xx<sx; ++xx)
    {
        for (int yy=-1; yy<sy; ++yy)
        {
            if (seg_pad[xx][yy]!=seg_pad[xx][yy+1])
            {
                neigh_min[2*xx+1][2*yy+2] = std::min(seg_pad[xx][yy],seg_pad[xx][yy+1]);
                neigh_max[2*xx+1][2*yy+2] = std::max(seg_pad[xx][yy],seg_pad[xx][yy+1]);
            }
        }
    }
    /* Horizontal contours */
    for (int xx=-1; xx<sx; ++xx)
    {
        for (int yy=0; yy<sy; ++yy)
        {
            if (seg_pad[xx][yy]!=seg_pad[xx+1][yy])
            {
                neigh_min[2*xx+2][2*yy+1] = std::min(seg_pad[xx][yy],seg_pad[xx+1][yy]);
                neigh_max[2*xx+2][2*yy+1] = std::max(seg_pad[xx][yy],seg_pad[xx+1][yy]);
            }
        }
    }
    
    
    
    /*-------------------------------------------*/
    /*            Look for junctions             */
    /*-------------------------------------------*/
    /* Containers */
    junction_ids.resize(boost::extents[2*sx+1][2*sy+1]);
    std::size_t n_junctions = 0;
    
    /*       1
     *       |  
     *  2 -- X -- 4
     *       |   
     *       3
     *
     * Treat them all as 'central' junctions, thanks to the padding added to neighs */
    for (std::size_t xx=0; xx<2*sx+2; xx+=2)
    {
        for (std::size_t yy=0; yy<2*sy+2; yy+=2)
        {
            junction tmp_jct = junction(n_junctions+1,xx,yy);
            std::set<double> curr_neighs;
            if (neigh_min[xx-1][yy]!=neigh_max[xx-1][yy]) // Case 1
            {
                tmp_jct.cont_pos.push_back(coord(xx-1,yy));
                curr_neighs.insert(neigh_min[xx-1][yy]);
                curr_neighs.insert(neigh_max[xx-1][yy]);
            }
            if (neigh_min[xx][yy-1]!=neigh_max[xx][yy-1]) // Case 2
            {
                tmp_jct.cont_pos.push_back(coord(xx,yy-1));
                curr_neighs.insert(neigh_min[xx][yy-1]);
                curr_neighs.insert(neigh_max[xx][yy-1]);
            }
            if (neigh_min[xx+1][yy]!=neigh_max[xx+1][yy]) // Case 3
            {
                tmp_jct.cont_pos.push_back(coord(xx+1,yy));             
                curr_neighs.insert(neigh_min[xx+1][yy]);
                curr_neighs.insert(neigh_max[xx+1][yy]);
            }
            if (neigh_min[xx][yy+1]!=neigh_max[xx][yy+1]) // Case 4
            {
                tmp_jct.cont_pos.push_back(coord(xx,yy+1));              
                curr_neighs.insert(neigh_min[xx][yy+1]);
                curr_neighs.insert(neigh_max[xx][yy+1]);
            }
            if (curr_neighs.size()>2)
            {
                tmp_jct.neighs.insert(curr_neighs.begin(),curr_neighs.end());
                junction_set.push_back(tmp_jct);
                junction_ids[xx][yy] = n_junctions + 1;
                n_junctions++;
            }
        }
    }
    

    
    /*--------------------------------------------------------------------*/
    /*     Sweep all contour places and connect them in a sorted way      */
    /*--------------------------------------------------------------------*/
    /* Vector containing the next contours to explore */
    std::vector<cont_piece> to_explore;
    /* Mask of the visited positions */
    boost::multi_array<bool,2> visited(boost::extents[2*sx+1][2*sy+1]);

    /* Explore all junctions to start from there. Please note that the hole contours will *
     * not be added here because they have no junction, but they will be added afterwards */
    for(std::size_t jj=0; jj<junction_set.size(); ++jj)
    {
        for(std::size_t ii=0; ii<junction_set[jj].cont_pos.size(); ++ii)
        {
            if (!border && (junction_set[jj].cont_pos[ii].x==0 || junction_set[jj].cont_pos[ii].y==0 || junction_set[jj].cont_pos[ii].x==2*sx ||  junction_set[jj].cont_pos[ii].y==2*sy))
                continue;

            to_explore.push_back(cont_piece(junction_set[jj].id,
                                            junction_set[jj].cont_pos[ii],
                                            neigh_min[junction_set[jj].cont_pos[ii].x][junction_set[jj].cont_pos[ii].y],
                                            neigh_max[junction_set[jj].cont_pos[ii].x][junction_set[jj].cont_pos[ii].y]));
        }
    }

    while (to_explore.size()>0)
    {
        /* Get the current contour to explore */
        cont_piece curr_cont = to_explore.back();
        to_explore.pop_back();
        
        /* Check it was not explored before */
        if(visited[curr_cont.cont_coords.back().x][curr_cont.cont_coords.back().y])
            continue;

//         mexPrintf("Exploring: %d, %d\n", curr_cont.cont_coords.back().x, curr_cont.cont_coords.back().y);
        
        /* Do the actual exploration */
        explore_contour(curr_cont, junction_set, visited, junction_ids, neigh_max);
        
        /* Store it as finished */
        all_cont_pieces.push_back(curr_cont);
    }
    
    /*--------------------------------------------------------------------*/
    /*   Rescan contours to find holes and create artificial junctions    */ 
    /*--------------------------------------------------------------------*/
    /* Vertical contours */
    /* Horizontal contours are not necessary because there will always be a vertical contour in any hole */
    for (int xx=0; xx<sx; ++xx)
    {
        int offset;
        if (border) offset=1; else offset = 0;
        for (int yy=-offset; yy<sy+offset-1; ++yy)
        {
            if ((neigh_max[2*xx+1][2*yy+2]>0) && (visited[2*xx+1][2*yy+2]==0))
            {                
                /* Create an 'artificial' junction */
                n_junctions++;
                junction tmp_jct(n_junctions,2*xx,2*yy+2);
                tmp_jct.neighs.insert(neigh_max[2*xx+1][2*yy+2]);
                tmp_jct.neighs.insert(neigh_min[2*xx+1][2*yy+2]);
                tmp_jct.cont_pos.push_back(coord(2*xx+1,2*yy+2));

                /* Add it to the set of junctions */
                junction_set.push_back(tmp_jct);
                junction_ids[2*xx][2*yy+2] = n_junctions;
                        
                /* Create the contour piece to explore */
                cont_piece curr_cont = cont_piece(tmp_jct.id,
                                                  tmp_jct.cont_pos[0],
                                                  neigh_min[2*xx+1][2*yy+2],
                                                  neigh_max[2*xx+1][2*yy+2]);
        
                /* Do the actual exploration */
                explore_contour(curr_cont, junction_set, visited, junction_ids, neigh_max);
                
                /* Store it as finished */
                all_cont_pieces.push_back(curr_cont);
            }
        }
    }
    

    
    /*-------------------------------------------*/
    /*            Simplify points                */
    /*-------------------------------------------*/
    if (simplify_tol>0)
    {
        for (std::size_t ii=0; ii<all_cont_pieces.size(); ++ii) 
        {
            /* Copy the data to the structure needed to simplify */
            std::list<double> to_simpl;
            for (std::size_t jj=0; jj<all_cont_pieces[ii].cont_coords.size(); ++jj)
            {
                /* Coordinates in the form x1,y1,x2,y2, etc. */
                to_simpl.push_back(all_cont_pieces[ii].cont_coords[jj].x);
                to_simpl.push_back(all_cont_pieces[ii].cont_coords[jj].y);
            }
            std::list<double> simplified(to_simpl.size());
            std::fill(simplified.begin(), simplified.end(), -1);

            /* Simplify */
            psimpl::simplify_douglas_peucker<2>(to_simpl.begin(), to_simpl.end(), simplify_tol, simplified.begin());

            /* Copy back to the Coord vector */
            all_cont_pieces[ii].cont_coords.resize(0);
            for(std::list<double>::iterator it=simplified.begin(); it!=simplified.end(); ++it)
            {   
                if(*it==-1)
                    break;
                double tmp_x = *it;
                ++it;
                double tmp_y = *it;

                all_cont_pieces[ii].cont_coords.push_back(coord(tmp_x, tmp_y));
            }
        }
    }
    
    
    /*-------------------------------------------*/
    /*         Create region table               */
    /*-------------------------------------------*/
    reg_table.resize(n_regs);
    
    /* Sweep all contours pieces to put them at the neighboring
     * regions, to build an index of the contours around each region */
    for (std::size_t ii=0; ii<all_cont_pieces.size(); ++ii)
    {
        if (all_cont_pieces[ii].neigh_region1[0]>0)
            reg_table[all_cont_pieces[ii].neigh_region1[0]-1].insert(ii);
        if (all_cont_pieces[ii].neigh_region2[0]>0)
            reg_table[all_cont_pieces[ii].neigh_region2[0]-1].insert(ii);        
    }
    
    
    
    /*-------------------------------------------*/
    /*       Fill junction contour pieces        */
    /*-------------------------------------------*/
    for (std::size_t ii=0; ii<all_cont_pieces.size(); ++ii)
    {
        junction_set[all_cont_pieces[ii].orig_junc-1].cont_pieces.insert(ii);
        junction_set[all_cont_pieces[ii].end_junc-1].cont_pieces.insert(ii);
    }
}





#endif


