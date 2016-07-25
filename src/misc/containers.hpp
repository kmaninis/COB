#ifndef CONTAINERS_HPP
#define CONTAINERS_HPP

#include <vector>
#include <list>
#include <set>
#include <map>

typedef uint32_t label_type;
typedef std::set<label_type> set_type;
typedef std::map<double,std::list<set_type> > map_type;

struct merging_sequence
{
    std::vector<label_type>         parent_labels;
    std::vector<std::list<label_type> >  children_labels;
    std::vector<double>         start_ths;
    
    std::size_t n_max_children;
    std::size_t n_leaves;
    std::size_t n_regs;
    
    
    void print() const
    {
        for(std::size_t ii=0; ii<parent_labels.size(); ++ii)
        {
            for(label_type id: children_labels[ii])
                printf("%d\t",id);
            printf("-->\t%d\n", parent_labels[ii]);
        }
    }
};


struct cont_elem
{
    cont_elem(size_t new_x, size_t new_y)
                 : x(new_x), y(new_y)
    {
    }

    size_t x;
    size_t y;
};

struct contour_container: public std::map<std::pair<label_type,label_type>, std::list<cont_elem> >
{
    contour_container(): std::map<std::pair<label_type,label_type>, std::list<cont_elem> >()
    {
    }
    
    void print() const
    {
        for(auto elem:(*this))
        {
            printf("[%d,%d] -  ", elem.first.first, elem.first.second);
            
            for(const cont_elem& cont: elem.second)
                printf("(%d,%d), ",cont.x,cont.y);
            printf("\n");
        }
    }
};


#endif