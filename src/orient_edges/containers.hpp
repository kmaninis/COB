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

#ifndef CONTAINERS_HPP
#define CONTAINERS_HPP

/* Container of a coordinate */
struct coord
{
    coord(std::size_t new_x=0, std::size_t new_y=0)
                  : x(new_x), y(new_y)
    {};
    
    bool operator==(const coord& other)
    {
        return (x==other.x && y==other.y);
    }
    
    bool operator!=(const coord& other)
    {
        return (x!=other.x || y!=other.y);
    }
    
    bool operator<(const coord& other) const
    {
        if (x<other.x)
            return true;
        else if (x>other.x)
            return false;
        else
            if (y<other.y)
                return true;
            else
                return false;
    }
    
    std::size_t x;
    std::size_t y;
};

/* Container of a junction */
struct junction
{
    junction(std::size_t new_id, std::size_t new_x,
                  std::size_t new_y)
                  : id(new_id), pos(new_x,new_y), cont_pos(), neighs()
    {};
    
    /* Label */
    std::size_t id;
    
    /* Position */
    coord pos;

    /* Set of coordinate of the contours that form the junction */
    std::vector<coord> cont_pos;
    
    /* Set of ids of the incident contour pieces */
    std::set<double> cont_pieces;
    
    /* Set of labels of the neighboring regions (three at least) */
    std::set<double> neighs;
};

/* Container of a piece of contour (from junction to junction) */
struct cont_piece
{
    cont_piece()
      : orig_junc(), end_junc(), neigh_region1(), neigh_region2(), children(), parent(-1), cont_coords(), ucm_strength(0)
    {};
    
    cont_piece(std::size_t new_orig_junc, coord first_coord, std::size_t new_neigh_region1, std::size_t new_neigh_region2)
            : orig_junc(new_orig_junc), end_junc(), neigh_region1(1,new_neigh_region1), neigh_region2(1,new_neigh_region2), children(), parent(-1), cont_coords(1,first_coord), ucm_strength(0)
    {};
          
    /* Labels of the junctions */
    std::size_t orig_junc;
    std::size_t end_junc;
    
    /* Labels of the two regions that from the contour */
    std::vector<std::size_t> neigh_region1;
    std::vector<std::size_t> neigh_region2;
    
    /* Children and parent */
    std::vector<std::size_t> children;
    int parent;
        
    /* Set of contour coordinates */
    std::vector<coord> cont_coords;
    
    /* UCM strength */
    double ucm_strength;
};
#endif
