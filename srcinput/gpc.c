#define EXTERNAL extern
#include "hstinpt.h"
#include "message.h"
static char const svnid[] = "$Id$";
/*
===========================================================================

Project:   Generic Polygon Clipper

           A new algorithm for calculating the difference, intersection,
           exclusive-or or union of arbitrary polygon sets.

File:      gpc.c
Author:    Alan Murta (amurta@cs.man.ac.uk)
Version:   2.21
Date:      19th August 1998

Copyright: (C) 1997, Advanced Interfaces Group, University of Manchester.
           All rights reserved.

           This software may be freely copied, modified, and redistributed
           provided that this copyright notice is preserved on all copies.
           The intellectual property rights of the algorithms used reside
           with the University of Manchester Advanced Interfaces Group.

           You may not distribute this software, in whole or in part, as
           part of any commercial product without the express consent of
           the author.

           There is no warranty or other guarantee of fitness of this
           software for any purpose. It is provided solely "as is".

===========================================================================
*/


/*
===========================================================================
                                Includes
===========================================================================
*/

#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>
#include "gpc.h"


/*
===========================================================================
                                Constants
===========================================================================
*/

#ifndef TRUE
#define FALSE              0
#define TRUE               1
#endif

#define LEFT               0
#define RIGHT              1

#define ABOVE              0
#define BELOW              1

#define CLIP               0
#define SUBJ               1

#define INVERT_TRISTRIPS   FALSE


/*
===========================================================================
                                 Macros 
===========================================================================
*/

#define EQ(a, b)           (fabs((a) - (b)) <= gpc_epsilon)
#define NE(a, b)           (fabs((a) - (b)) >  gpc_epsilon)
#define GT(a, b)           (((a) - (b))     >  gpc_epsilon)
#define LT(a, b)           (((b) - (a))     >  gpc_epsilon)
#define GE(a, b)           (!LT((a), (b)))
#define LE(a, b)           (!GT((a), (b)))

#define PREV_INDEX(i, n)   ((i - 1 + n) % n)
#define NEXT_INDEX(i, n)   ((i + 1    ) % n)

#define OPTIMAL(v, i, n)   (NE(v[PREV_INDEX(i, n)].y, v[i].y) || \
                            NE(v[NEXT_INDEX(i, n)].y, v[i].y))

#define FWD_MIN(v, i, n)   (GE(v[PREV_INDEX(i, n)].vertex.y, v[i].vertex.y) \
                         && GT(v[NEXT_INDEX(i, n)].vertex.y, v[i].vertex.y))

#define NOT_FMAX(v, i, n)   GT(v[NEXT_INDEX(i, n)].vertex.y, v[i].vertex.y)

#define REV_MIN(v, i, n)   (GT(v[PREV_INDEX(i, n)].vertex.y, v[i].vertex.y) \
                         && GE(v[NEXT_INDEX(i, n)].vertex.y, v[i].vertex.y))

#define NOT_RMAX(v, i, n)   GT(v[PREV_INDEX(i, n)].vertex.y, v[i].vertex.y)

#define VERTEX(e, s, x, y) {add_vertex(&((e)->outp->v[(s)]), x, y); \
                            (e)->outp->active++;}

#define P_EDGE(d, e, i, y) {(d)= (e); \
                            do {(d)= (d)->prev;} while (!(d)->outp); \
                            (i)= (d)->bot.x + (d)->delx * (y);}

#define N_EDGE(d, e, i, y) {(d)= (e); \
                            do {(d)= (d)->next;} while (!(d)->outp); \
                            (i)= (d)->bot.x + (d)->delx * (y);}

#define MALLOC(p, b, s)    {p= malloc(b); if (!(p)) { \
                            output_msg(OUTPUT_STDERR, "gpc malloc failure: %s\n", s); \
                            exit(1);}}

#define FREE(p)            {free(p); (p)= NULL;}

#define CFREE(p)           if(p) FREE(p)


/*
===========================================================================
                            Private Data Types
===========================================================================
*/

typedef enum                        /* Edge intersection classes         */
{
  NUL,                              /* Empty non-intersection            */
  EMX,                              /* External maximum                  */
  ELI,                              /* External left intermediate        */
  TED,                              /* Top edge                          */
  ERI,                              /* External right intermediate       */
  RED,                              /* Right edge                        */
  IMM,                              /* Internal maximum and minimum      */
  IMN,                              /* Internal minimum                  */
  EMN,                              /* External minimum                  */
  EMM,                              /* External maximum and minimum      */
  LED,                              /* Left edge                         */
  ILI,                              /* Internal left intermediate        */
  BED,                              /* Bottom edge                       */
  IRI,                              /* Internal right intermediate       */
  IMX,                              /* Internal maximum                  */
  FUL                               /* Full non-intersection             */
} vertex_type;

typedef enum                        /* Horizontal edge states            */
{
  NH,                               /* No horizontal edge                */
  BH,                               /* Bottom horizontal edge            */
  TH                                /* Top horizontal edge               */
} h_state;

typedef struct v_shape              /* Internal vertex list datatype     */
{
  double              x;            /* X coordinate component            */
  double              y;            /* Y coordinate component            */
  struct v_shape     *next;         /* Pointer to next vertex in list    */
} vertex_node;

typedef struct p_shape              /* Internal polygon / tristrip type  */
{
  int                 active;       /* Active flag / vertex count        */
  vertex_node       **proxy;        /* Pointer to actual v[] list in use */
  vertex_node        *v[2];         /* Left and right vertex list ptrs   */
  struct p_shape     *next;         /* Pointer to next polygon contour   */
} polygon_node;

typedef struct edge_shape
{
  gpc_vertex          vertex;       /* Piggy-backed contour vertex data  */
  gpc_vertex          bot;          /* Edge lower (x, y) coordinate      */
  gpc_vertex          top;          /* Edge upper (x, y) coordinate      */
  double              delx;         /* Change in x for a unit y increase */
  int                 type;         /* Clip / subject edge flag          */
  int                 head;         /* Head of bundle flag               */
  int                 bundle[2][2]; /* Bundle edge flags                 */
  int                 bside[2];     /* Bundle left / right indicators    */
  polygon_node       *outp;         /* Output polygon / tristrip ptr     */
  struct edge_shape  *prev;         /* Previous edge in the AET          */
  struct edge_shape  *next;         /* Next edge in the AET              */
  struct edge_shape  *pred;         /* Edge connected at the lower end   */
  struct edge_shape  *succ;         /* Edge connected at the upper end   */
  struct edge_shape  *next_bound;   /* Pointer to next bound in LMT      */
} edge_node;

typedef struct lmt_shape            /* Local minima table                */
{
  double              y;            /* Y coordinate at local minimum     */
  edge_node          *first_bound;  /* Pointer to bound list             */
  struct lmt_shape   *next;         /* Pointer to next local minimum     */
} lmt_node;

typedef struct sbt_t_shape          /* Scanbeam tree                     */
{
  double              y;            /* Scanbeam node y value             */
  struct sbt_t_shape *less;         /* Pointer to nodes with lower y     */
  struct sbt_t_shape *more;         /* Pointer to nodes with higher y    */
} sb_tree;

typedef struct it_shape             /* Intersection table                */
{
  edge_node          *ie[2];        /* Intersecting edge (bundle) pair   */
  gpc_vertex          point;        /* Point of intersection             */
  struct it_shape    *next;         /* The next intersection table node  */
} it_node;

typedef struct st_shape             /* Sorted edge table                 */
{
  edge_node          *e;            /* Pointer to AET edge               */
  double              xtop;         /* X coordinate at top of scanbeam   */
  struct st_shape    *prev;         /* Previous edge in sorted list      */
} st_node;


/*
===========================================================================
                               Global Data
===========================================================================
*/

/* Minimum difference for equality determination */
static double gpc_epsilon;

/* Horizontal edge state transitions within scanbeam boundary */
const h_state next_h_state[3][6]=
{
  /*        ABOVE     BELOW     CROSS */
  /*        L   R     L   R     L   R */  
  /* NH */ {BH, TH,   TH, BH,   NH, NH},
  /* BH */ {NH, NH,   NH, NH,   TH, TH},
  /* TH */ {NH, NH,   NH, NH,   BH, BH}
};


/*
===========================================================================
                             Private Functions
===========================================================================
*/

static void reset_it(it_node **it)
{
  it_node *itn;

  while (*it)
  {
    itn= (*it)->next;
    FREE(*it);
    *it= itn;
  }
}


static void reset_lmt(lmt_node **lmt)
{
  lmt_node *lmtn;

  while (*lmt)
  {
    lmtn= (*lmt)->next;
    FREE(*lmt);
    *lmt= lmtn;
  }
}


static void insert_bound(edge_node **b, edge_node *e)
{
  edge_node *existing_bound;

  if (!*b)
  {
    /* Link node e to the tail of the list */
    *b= e;
  }
  else
  {
    /* Do primary sort on the bot.x field */
    if (LT(e[0].bot.x, (*b)[0].bot.x))
    {
      /* Insert a new node mid-list */
      existing_bound= *b;
      *b= e;
      (*b)->next_bound= existing_bound;
    }
    else
    {
      if (EQ(e[0].bot.x, (*b)[0].bot.x))
      {
        /* Do secondary sort on the delx field */
        if (LT(e[0].delx, (*b)[0].delx))
        {
          /* Insert a new node mid-list */
          existing_bound= *b;
          *b= e;
          (*b)->next_bound= existing_bound;
        }
        else
        {
          /* Head further down the list */
          insert_bound(&((*b)->next_bound), e);
        }
      }
      else
      {
        /* Head further down the list */
        insert_bound(&((*b)->next_bound), e);
      }
    }
  }
}


static edge_node **bound_list(lmt_node **lmt, double y)
{
  lmt_node *existing_node;

  if (!*lmt)
  {
    /* Add node onto the tail end of the LMT */
    MALLOC(*lmt, sizeof(lmt_node), "LMT insertion");
    (*lmt)->y= y;
    (*lmt)->first_bound= NULL;
    (*lmt)->next= NULL;
    return &((*lmt)->first_bound);
  }
  else
    if (LT(y, (*lmt)->y))
    {
      /* Insert a new LMT node before the current node */
      existing_node= *lmt;
      MALLOC(*lmt, sizeof(lmt_node), "LMT insertion");
      (*lmt)->y= y;
      (*lmt)->first_bound= NULL;
      (*lmt)->next= existing_node;
      return &((*lmt)->first_bound);
    }
    else
      if (EQ(y, (*lmt)->y))
        /* Use this existing LMT node */
        return &((*lmt)->first_bound);
      else
        /* Head further up the LMT */
        return bound_list(&((*lmt)->next), y);
}


static void add_to_sbtree(int *entries, sb_tree **sbtree, double *y)
{
  if (!*sbtree)
  {
    /* Add a new tree node here */
    MALLOC(*sbtree, sizeof(sb_tree), "scanbeam tree insertion");
    (*sbtree)->y= *y;
    (*sbtree)->less= NULL;
    (*sbtree)->more= NULL;
    (*entries)++;
  }
  else
  {
    if (GT((*sbtree)->y, *y))
    {
    /* Head into the 'less' sub-tree */
      add_to_sbtree(entries, &((*sbtree)->less), y);
    }
    else
    {
      if (LT((*sbtree)->y, *y))
      {
        /* Head into the 'more' sub-tree */
        add_to_sbtree(entries, &((*sbtree)->more), y);
      }
    }
  }
}


static void build_sbt(int *entries, double *sbt, sb_tree *sbtree)
{
  if (sbtree->less)
    build_sbt(entries, sbt, sbtree->less);
  sbt[*entries]= sbtree->y;
  (*entries)++;
  if (sbtree->more)
    build_sbt(entries, sbt, sbtree->more);
}


static void free_sbtree(sb_tree **sbtree)
{
  if (*sbtree)
  {
    free_sbtree(&((*sbtree)->less));
    free_sbtree(&((*sbtree)->more));
    FREE(*sbtree);
  }
}


static int count_optimal_vertices(gpc_vertex_list c)
{
  int result= 0, i;

  for (i= 0; i < c.num_vertices; i++)
    /* Ignore superfluous vertices embedded in horizontal edges */
    if (OPTIMAL(c.vertex, i, c.num_vertices))
      result++;
  return result;
}


static edge_node *build_lmt(lmt_node **lmt, sb_tree **sbtree,
                            int *sbt_entries, gpc_polygon *p, int type,
                            gpc_op op)
{
  int          c, i, min, max, num_edges, v, num_vertices;
  int          total_vertices= 0, e_index=0;
  edge_node   *e, *edge_table;

  for (c= 0; c < p->num_contours; c++)
    total_vertices+= count_optimal_vertices(p->contour[c]);

  /* Create the entire input polygon edge table in one go */
  MALLOC(edge_table, total_vertices * sizeof(edge_node),
         "edge table creation");

  for (c= 0; c < p->num_contours; c++)
  {
    /* Perform contour optimisation */
    num_vertices= 0;
    for (i= 0; i < p->contour[c].num_vertices; i++)
      if (OPTIMAL(p->contour[c].vertex, i, p->contour[c].num_vertices))
      {
        edge_table[num_vertices].vertex.x= p->contour[c].vertex[i].x;
        edge_table[num_vertices].vertex.y= p->contour[c].vertex[i].y;

        /* Record vertex in the scanbeam table */
        add_to_sbtree(sbt_entries, sbtree, &edge_table[num_vertices].vertex.y);

        num_vertices++;
      }

    /* Do the contour forward pass */
    for (min= 0; min < num_vertices; min++)
    {
      /* If a forward local minimum... */
      if (FWD_MIN(edge_table, min, num_vertices))
      {
        /* Search for the next local maximum... */
        num_edges= 1;
        max= NEXT_INDEX(min, num_vertices);
        while (NOT_FMAX(edge_table, max, num_vertices))
        {
          num_edges++;
          max= NEXT_INDEX(max, num_vertices);
        }

        /* Build the next edge list */
        e= &edge_table[e_index];
        e_index+= num_edges;
        v= min;
        for (i= 0; i < num_edges; i++)
        {
          e[i].bot.x= edge_table[v].vertex.x;
          e[i].bot.y= edge_table[v].vertex.y;

          v= NEXT_INDEX(v, num_vertices);

          e[i].top.x= edge_table[v].vertex.x;
          e[i].top.y= edge_table[v].vertex.y;
          e[i].delx= (edge_table[v].vertex.x - e[i].bot.x) /
                     (e[i].top.y - e[i].bot.y);
          e[i].type= type;
          e[i].outp= NULL;
          e[i].next= NULL;
          e[i].prev= NULL;
          e[i].succ= ((num_edges > 1) && (i < (num_edges - 1))) ?
                     &(e[i + 1]) : NULL;
          e[i].pred= ((num_edges > 1) && (i > 0)) ? &(e[i - 1]) : NULL;
          e[i].next_bound= NULL;
          e[i].bside[CLIP]= (op == GPC_DIFF) ? RIGHT : LEFT;
          e[i].bside[SUBJ]= LEFT;
        }
        insert_bound(bound_list(lmt, edge_table[min].vertex.y), e);
      }
    }

    /* Do the contour reverse pass */
    for (min= 0; min < num_vertices; min++)
    {
      /* If a reverse local minimum... */
      if (REV_MIN(edge_table, min, num_vertices))
      {
        /* Search for the previous local maximum... */
        num_edges= 1;
        max= PREV_INDEX(min, num_vertices);
        while (NOT_RMAX(edge_table, max, num_vertices))
        {
          num_edges++;
          max= PREV_INDEX(max, num_vertices);
        }

        /* Build the previous edge list */
        e= &edge_table[e_index];
        e_index+= num_edges;
        v= min;
        for (i= 0; i < num_edges; i++)
        {
          e[i].bot.x= edge_table[v].vertex.x;
          e[i].bot.y= edge_table[v].vertex.y;

          v= PREV_INDEX(v, num_vertices);

          e[i].top.x= edge_table[v].vertex.x;
          e[i].top.y= edge_table[v].vertex.y;
          e[i].delx= (edge_table[v].vertex.x - e[i].bot.x) /
                     (e[i].top.y - e[i].bot.y);
          e[i].type= type;
          e[i].outp= NULL;
          e[i].next= NULL;
          e[i].prev= NULL;
          e[i].succ= ((num_edges > 1) && (i < (num_edges - 1))) ?
                     &(e[i + 1]) : NULL;
          e[i].pred= ((num_edges > 1) && (i > 0)) ? &(e[i - 1]) : NULL;
          e[i].next_bound= NULL;
          e[i].bside[CLIP]= (op == GPC_DIFF) ? RIGHT : LEFT;
          e[i].bside[SUBJ]= LEFT;
        }
        insert_bound(bound_list(lmt, edge_table[min].vertex.y), e);
      }
    }
  }
  return edge_table;
}


static void add_edge_to_aet(edge_node **aet, edge_node *edge, edge_node *prev)
{
  if (!*aet)
  {
    /* Append edge onto the tail end of the AET */
    *aet= edge;
    edge->prev= prev;
    edge->next= NULL;
  }
  else
  {
    /* Do primary sort on the bot.x field */
    if (LT(edge->bot.x, (*aet)->bot.x))
    {
      /* Insert edge here (before the AET edge) */
      edge->prev= prev;
      edge->next= *aet;
      (*aet)->prev= edge;
      *aet= edge;
    }
    else
    {
      if (EQ(edge->bot.x, (*aet)->bot.x))
      {
        /* Do secondary sort on the delx field */
        if (LT(edge->delx, (*aet)->delx))
        {
          /* Insert edge here (before the AET edge) */
          edge->prev= prev;
          edge->next= *aet;
          (*aet)->prev= edge;
          *aet= edge;
        }
        else
        {
          /* Head further into the AET */
          add_edge_to_aet(&((*aet)->next), edge, *aet);
        }
      }
      else
      {
        /* Head further into the AET */
        add_edge_to_aet(&((*aet)->next), edge, *aet);
      }
    }
  }
}


static void add_intersection(it_node **it, edge_node *edge0, edge_node *edge1,
                             double x, double y)
{
  it_node *existing_node;

  if (!*it)
  {
    /* Append a new node to the tail of the list */
    MALLOC(*it, sizeof(it_node), "IT insertion");
    if (GT(edge0->delx, edge1->delx))
    {
      (*it)->ie[0]= edge0;
      (*it)->ie[1]= edge1;
    }
    else
    {
      (*it)->ie[0]= edge1;
      (*it)->ie[1]= edge0;
    }
    (*it)->point.x= x;
    (*it)->point.y= y;
    (*it)->next= NULL;
  }
  else
  {
    if (GT((*it)->point.y, y))
    {
      /* Insert a new node mid-list */
      existing_node= *it;
      MALLOC(*it, sizeof(it_node), "IT insertion");
      if (GT(edge0->delx, edge1->delx))
      {
        (*it)->ie[0]= edge0;
        (*it)->ie[1]= edge1;
      }
      else
      {
        (*it)->ie[0]= edge1;
        (*it)->ie[1]= edge0;
      }
      (*it)->point.x= x;
      (*it)->point.y= y;
      (*it)->next= existing_node;
    }
    else
      /* Head further down the list */
      add_intersection(&((*it)->next), edge0, edge1, x, y);
  }
}


static void add_st_edge(st_node **st, it_node **it, edge_node *edge,
                        double xtop, double dy, double yt)
{
  st_node *existing_node;
  double   x, y;

  if (!*st)
  {
    /* Append edge onto the tail end of the ST */
    MALLOC(*st, sizeof(st_node), "ST insertion");
    (*st)->e= edge;
    (*st)->xtop= xtop;
    (*st)->prev= NULL;
  }
  else
  {
    /* Do primary sort on the xtop field */
    if (GE(xtop, (*st)->xtop) ||
        EQ(edge->delx, (*st)->e->delx)) /* Parallel lines never cross! */

    {
      /* Insert edge here (before the ST edge) */
      existing_node= *st;
      MALLOC(*st, sizeof(st_node), "ST insertion");
      (*st)->e= edge;
      (*st)->xtop= xtop;
      (*st)->prev= existing_node;

    }
    else
    {
      /* Compute intersection between ST edge and AET edge */
      y= ((*st)->e->bot.x - edge->bot.x) /
         (edge->delx - (*st)->e->delx);
      x= (*st)->e->delx * y + (*st)->e->bot.x;

      /* Insert the intersection and the edge pointers in the IT */
      add_intersection(it, edge, (*st)->e, x, y);

      /* Head further into the ST */
      add_st_edge(&((*st)->prev), it, edge, xtop, dy, yt);
    }
  }
}


static void build_intersection_table(it_node **it, edge_node *aet,
                                     double dy, double yt)
{
  st_node   *st, *stp;
  edge_node *edge;

  /* Build intersection table for the current scanbeam */
  reset_it(it);
  st= NULL;

  /* Process each AET edge */
  for (edge= aet; edge; edge= edge->next)
  {
    if (edge->bundle[ABOVE][CLIP] || edge->bundle[ABOVE][SUBJ] || edge->head)
    {
      if (EQ(edge->top.y, yt))
        add_st_edge(&st, it, edge, edge->top.x, dy, yt);
      else
        add_st_edge(&st, it, edge, edge->bot.x + edge->delx * dy, dy, yt);
    }
  }
  while (st)
  {
    stp= st->prev;
    FREE(st);
    st= stp;
  }
}


static int count_vertices(vertex_node *vertex)
{
  int total;

  for (total= 0; vertex; vertex= vertex->next)
    total++;
  return total;
}


static int count_contours(polygon_node *polygon)
{
  int total;

  for (total= 0; polygon; polygon= polygon->next)
    if (polygon->active)
      total++;
  return total;
}


static void add_left(polygon_node *P, double x, double y)
{
  vertex_node *nv;

  /* Create a new vertex node and set its fields */
  MALLOC(nv, sizeof(vertex_node), "vertex node creation");
  nv->x= x;
  nv->y= y;

  /* Add vertex nv to the left end of the polygon's vertex list */
  nv->next= P->proxy[LEFT];

  /* Update proxy[LEFT] to point to nv */
  P->proxy[LEFT]= nv;
}


static void merge_left(polygon_node *P, polygon_node *Q, polygon_node *list)
{
  vertex_node **target;

  if (P->proxy != Q->proxy)
  {
    /* Assign P's vertex list to the left end of Q's list */
    P->proxy[RIGHT]->next= Q->proxy[LEFT];
    Q->proxy[LEFT]= P->proxy[LEFT];

    /* Redirect both P->proxy references to Q->proxy */
    target= P->proxy;
    while(list)
    {
      if (list->proxy == target)
      {
        list->active= FALSE;
        list->proxy= Q->proxy;
      }
      list= list->next;
    }
  }
}


static void add_right(polygon_node *P, double x, double y)
{
  vertex_node *nv;

  /* Create a new vertex node and set its fields */
  MALLOC(nv, sizeof(vertex_node), "vertex node creation");
  nv->x= x;
  nv->y= y;
  nv->next= NULL;

  /* Add vertex nv to the right end of the polygon's vertex list */
  P->proxy[RIGHT]->next= nv;

  /* Update proxy[RIGHT] to point to v */
  P->proxy[RIGHT]= nv;
}


static void merge_right(polygon_node *P, polygon_node *Q, polygon_node *list)
{
  vertex_node **target;

  if (P->proxy != Q->proxy)
  {
    /* Assign P's vertex list to the right end of Q's list */
    Q->proxy[RIGHT]->next= P->proxy[LEFT];
    Q->proxy[RIGHT]= P->proxy[RIGHT];

    /* Redirect both P->proxy references to Q->proxy */
    target= P->proxy;
    while(list)
    {
      if (list->proxy == target)
      {
        list->active= FALSE;
        list->proxy= Q->proxy;
      }
      list= list->next;
    }
  }
}


static void add_local_min(polygon_node **P, edge_node *edge,
                          double x, double y)
{
  vertex_node *nv;

  if (!(*P))
  {
    MALLOC(*P, sizeof(polygon_node), "polygon node creation");

    /* Create a new vertex node and set its fields */
    MALLOC(nv, sizeof(vertex_node), "vertex node creation");
    nv->x= x;
    nv->y= y;
    nv->next= NULL;

    /* Initialise proxy to point to P's own v[] list */
    (*P)->proxy= (*P)->v;
    (*P)->active= TRUE;
    (*P)->next= NULL;

    /* Make v[LEFT] and v[RIGHT] point to new vertex nv */
    (*P)->v[LEFT]= nv;
    (*P)->v[RIGHT]= nv;

    /* Assign polygon P to the edge */
    edge->outp= *P;
  }
  else
    /* Head further down the list */
    add_local_min(&((*P)->next), edge, x, y);
}


static int count_tristrips(polygon_node *tn)
{
  int total;

  for (total= 0; tn; tn= tn->next)
    if (tn->active > 2)
      total++;
  return total;
}


static void add_vertex(vertex_node **t, double x, double y)
{
  if (!(*t))
  {
    MALLOC(*t, sizeof(vertex_node), "tristrip vertex creation");
    (*t)->x= x;
    (*t)->y= y;
    (*t)->next= NULL;
  }
  else
    /* Head further down the list */
    add_vertex(&((*t)->next), x, y);
}


static void new_tristrip(polygon_node **tn, edge_node *edge,
                         double x, double y)
{
  if (!(*tn))
  {
    MALLOC(*tn, sizeof(polygon_node), "tristrip node creation");
    (*tn)->next= NULL;
    (*tn)->v[LEFT]= NULL;
    (*tn)->v[RIGHT]= NULL;
    (*tn)->active= 1;
    add_vertex(&((*tn)->v[LEFT]), x, y); 
    edge->outp= *tn;
  }
  else
    /* Head further down the list */
    new_tristrip(&((*tn)->next), edge, x, y);
}


static int set_gpc_epsilon(gpc_polygon *sp, gpc_polygon *cp)
{
  double xmin, xmax, ymin, ymax;
  int    c, v;

  /* Calculate bounding box */
  xmin= DBL_MAX;
  xmax= -DBL_MAX;
  ymin= DBL_MAX;
  ymax= -DBL_MAX;

  /* Inspect subject polygon */
  for (c= 0; c < sp->num_contours; c++)
    for (v= 0; v < sp->contour[c].num_vertices; v++)
    {
      if (sp->contour[c].vertex[v].x < xmin)
        xmin= sp->contour[c].vertex[v].x;
      if (sp->contour[c].vertex[v].x > xmax)
        xmax= sp->contour[c].vertex[v].x;
      if (sp->contour[c].vertex[v].y < ymin)
        ymin= sp->contour[c].vertex[v].y;
      if (sp->contour[c].vertex[v].y > ymax)
        ymax= sp->contour[c].vertex[v].y;
    }

  /* Inspect clip polygon */
  for (c= 0; c < cp->num_contours; c++)
    for (v= 0; v < cp->contour[c].num_vertices; v++)
    {
      if (cp->contour[c].vertex[v].x < xmin)
        xmin= cp->contour[c].vertex[v].x;
      if (cp->contour[c].vertex[v].x > xmax)
        xmax= cp->contour[c].vertex[v].x;
      if (cp->contour[c].vertex[v].y < ymin)
        ymin= cp->contour[c].vertex[v].y;
      if (cp->contour[c].vertex[v].y > ymax)
        ymax= cp->contour[c].vertex[v].y;
    }

  /* Return if nothing to clip */
  if (xmin >= xmax)
    return FALSE;

  xmax-= xmin;
  ymax-= ymin;

  if (xmax > ymax)
    gpc_epsilon= xmax / pow(10.0, (double)(DBL_DIG - 2));
  else
    gpc_epsilon= ymax / pow(10.0, (double)(DBL_DIG - 2));

  return TRUE;
}


/*
===========================================================================
                             Public Functions
===========================================================================
*/

void gpc_free_polygon(gpc_polygon *p)
{
  int c;

  for (c= 0; c < p->num_contours; c++)
    CFREE(p->contour[c].vertex);
  CFREE(p->contour);
  p->num_contours= 0;
}


void gpc_read_polygon(FILE *fp, gpc_polygon *p)
{
  int c, v;

  fscanf(fp, "%d", &(p->num_contours));
  MALLOC(p->contour, p->num_contours
         * sizeof(gpc_vertex_list), "contour creation");
  for (c= 0; c < p->num_contours; c++)
  {
    fscanf(fp, "%d", &(p->contour[c].num_vertices));
    MALLOC(p->contour[c].vertex, p->contour[c].num_vertices
           * sizeof(gpc_vertex), "vertex creation");
    for (v= 0; v < p->contour[c].num_vertices; v++)
      fscanf(fp, "%lf %lf", &(p->contour[c].vertex[v].x),
                            &(p->contour[c].vertex[v].y));
  }
}

#ifdef SKIP
void gpc_write_polygon(FILE *fp, gpc_polygon *p)
{
  int c, v;

  fprintf(fp, "%d\n", p->num_contours);
  for (c= 0; c < p->num_contours; c++)
  {
    fprintf(fp, "%d\n", p->contour[c].num_vertices);
    for (v= 0; v < p->contour[c].num_vertices; v++)
      fprintf(fp, "% .*lf % .*lf\n",
              DBL_DIG, p->contour[c].vertex[v].x,
              DBL_DIG, p->contour[c].vertex[v].y);
  }
}
#endif

void gpc_add_contour(gpc_polygon *p, gpc_vertex_list *new_contour)
{
  int              c, v;
  gpc_vertex_list *extended_contour;

  /* Create an extended contour array */
  MALLOC(extended_contour, (p->num_contours + 1)
         * sizeof(gpc_vertex_list), "contour addition");

  /* Copy the old contour into the extended contour array */
  for (c= 0; c < p->num_contours; c++)
    extended_contour[c]= p->contour[c];

  /* Copy the new contour onto the end of the extended contour array */
  c= p->num_contours;
  extended_contour[c].num_vertices= new_contour->num_vertices;
  MALLOC(extended_contour[c].vertex, new_contour->num_vertices
         * sizeof(gpc_vertex), "contour addition");
  for (v= 0; v < new_contour->num_vertices; v++)
    extended_contour[c].vertex[v]= new_contour->vertex[v];

  /* Dispose of the old contour */
  CFREE(p->contour);

  /* Update the polygon information */
  p->num_contours++;
  p->contour= extended_contour;
}


void gpc_polygon_clip(gpc_op op, gpc_polygon *subject, gpc_polygon *clip,
                      gpc_polygon *result)
{
  sb_tree       *sbtree= NULL;
  it_node       *it= NULL, *intersect;
  edge_node     *edge, *prev_edge, *next_edge, *succ_edge, *e0, *e1;
  edge_node     *aet= NULL, *c_heap, *s_heap;
  lmt_node      *lmt= NULL, *local_min;
  polygon_node  *out_poly= NULL, *P, *Q, *poly, *npoly, *cf= NULL;
  vertex_node   *vtx, *nv;
  h_state        horiz[2];
  int            in[2], exists[2], parity[2]= {LEFT, LEFT};
  int            c, v, contributing, search, scanbeam= 0, sbt_entries= 0;
  int            class, bl, br, tl, tr;
  double        *sbt= NULL, xb, px, yb, yt, dy, ix, iy, tedx, tndx;

  if (!set_gpc_epsilon(subject, clip))
  {
    /* Return a NULL result */
    result->num_contours= 0;
    result->contour= NULL;
    return;
  }

  /* Build LMT */
  s_heap= build_lmt(&lmt, &sbtree, &sbt_entries, subject, SUBJ, op);
  c_heap= build_lmt(&lmt, &sbtree, &sbt_entries, clip,    CLIP, op);

  /* Build scanbeam table from scanbeam tree */
  MALLOC(sbt, sbt_entries * sizeof(double), "sbt creation");
  build_sbt(&scanbeam, sbt, sbtree);
  scanbeam= 0;
  free_sbtree(&sbtree);

  /* Allow pointer re-use without causing memory leak */
  if (subject == result)
    gpc_free_polygon(subject);
  if (clip == result)
    gpc_free_polygon(clip);

  /* Invert clip polygon for difference operation */
  if (op == GPC_DIFF)
    parity[CLIP]= RIGHT;

  local_min= lmt;

  /* Process each scanbeam */
  while (scanbeam < sbt_entries)
  {
    /* Set yb to the bottom of the scanbeam */
    yb= sbt[scanbeam++];

    /* === SCANBEAM BOUNDARY PROCESSING ================================ */

    /* If LMT node corresponding to yb exists */
    if (local_min)
    {
      if (EQ(local_min->y, yb))
      {
        /* Add edges starting at this local minimum to the AET */
        edge= local_min->first_bound;
        while(edge)
        {
          add_edge_to_aet(&aet, edge, NULL);
          edge= edge->next_bound;
        }
        local_min= local_min->next;
      }
    }

    /* Set dummy previous x value */
    px= -DBL_MAX;

    /* Create bundles within AET */
    e0= aet;
    e1= aet;

    /* Set up bundle fields of first edge */
    aet->bundle[ABOVE][ aet->type]= NE(aet->top.y, yb);
    aet->bundle[ABOVE][!aet->type]= FALSE;
    aet->head= FALSE;
    aet->bundle[BELOW][ aet->type]= NE(aet->bot.y, yb) || aet->pred;
    aet->bundle[BELOW][!aet->type]= FALSE;
    if (aet->bundle[BELOW][aet->type])
      tedx= EQ(e1->bot.y, yb)? e1->pred->delx: e1->delx;
    else
      tedx= -DBL_MAX;

    for (next_edge= aet->next; next_edge; next_edge= next_edge->next)
    {
      /* Set up bundle fields of next edge */
      next_edge->bundle[ABOVE][ next_edge->type]= NE(next_edge->top.y, yb);
      next_edge->bundle[ABOVE][!next_edge->type]= FALSE;
      next_edge->bundle[BELOW][ next_edge->type]= NE(next_edge->bot.y, yb)
        || next_edge->pred;
      next_edge->bundle[BELOW][!next_edge->type]= FALSE;
      next_edge->head= FALSE;

      /* Bundle edges above the scanbeam boundary if they coincide */
      if (next_edge->bundle[ABOVE][next_edge->type])
      {
        if (EQ(e0->bot.x, next_edge->bot.x) && EQ(e0->delx, next_edge->delx)
	 && NE(e0->top.y, yb))
        {
          next_edge->bundle[ABOVE][ next_edge->type]^= 
            e0->bundle[ABOVE][ next_edge->type];
          next_edge->bundle[ABOVE][!next_edge->type]= 
            e0->bundle[ABOVE][!next_edge->type];
          next_edge->head= TRUE;
          e0->bundle[ABOVE][CLIP]= FALSE;
          e0->bundle[ABOVE][SUBJ]= FALSE;
          e0->head= FALSE;
        }
        e0= next_edge;
      }

      /* Bundle edges below the scanbeam boundary if they coincide */
      if (next_edge->bundle[BELOW][next_edge->type])
      {
        tndx= EQ(next_edge->bot.y, yb) ?
          next_edge->pred->delx : next_edge->delx;
        if (EQ(e1->bot.x, next_edge->bot.x) && EQ(tedx, tndx)
         && (NE(e1->bot.y, yb) || e1->pred))
        { 
          next_edge->bundle[BELOW][ next_edge->type]^= 
            e1->bundle[BELOW][ next_edge->type];
          next_edge->bundle[BELOW][!next_edge->type]= 
            e1->bundle[BELOW][!next_edge->type];
          e1->bundle[BELOW][CLIP]= FALSE;
          e1->bundle[BELOW][SUBJ]= FALSE;
        }
        e1= next_edge;
        tedx= tndx;
      }
    }

    horiz[CLIP]= NH;
    horiz[SUBJ]= NH;

    /* Process each edge at this scanbeam boundary */
    for (edge= aet; edge; edge= edge->next)
    {
      exists[CLIP]= edge->bundle[ABOVE][CLIP] + 
                   (edge->bundle[BELOW][CLIP] << 1);
      exists[SUBJ]= edge->bundle[ABOVE][SUBJ] + 
                   (edge->bundle[BELOW][SUBJ] << 1);

      if (exists[CLIP] || exists[SUBJ])
      {
        /* Set bundle side */
        edge->bside[CLIP]= parity[CLIP];
        edge->bside[SUBJ]= parity[SUBJ];

        /* Determine contributing status and quadrant occupancies */
        switch (op)
        {
        case GPC_DIFF:
        case GPC_INT:
          contributing= (exists[CLIP] && (parity[SUBJ] || horiz[SUBJ]))
                     || (exists[SUBJ] && (parity[CLIP] || horiz[CLIP]))
                     || (exists[CLIP] && exists[SUBJ]
                     && (parity[CLIP] == parity[SUBJ]));
          br= (parity[CLIP])
           && (parity[SUBJ]);
          bl= (parity[CLIP] ^ edge->bundle[ABOVE][CLIP])
           && (parity[SUBJ] ^ edge->bundle[ABOVE][SUBJ]);
          tr= (parity[CLIP] ^ (horiz[CLIP]!=NH))
           && (parity[SUBJ] ^ (horiz[SUBJ]!=NH));
          tl= (parity[CLIP] ^ (horiz[CLIP]!=NH) ^ edge->bundle[BELOW][CLIP]) 
           && (parity[SUBJ] ^ (horiz[SUBJ]!=NH) ^ edge->bundle[BELOW][SUBJ]);
          break;
        case GPC_XOR:
          contributing= exists[CLIP] || exists[SUBJ];
          br= (parity[CLIP])
            ^ (parity[SUBJ]);
          bl= (parity[CLIP] ^ edge->bundle[ABOVE][CLIP])
            ^ (parity[SUBJ] ^ edge->bundle[ABOVE][SUBJ]);
          tr= (parity[CLIP] ^ (horiz[CLIP]!=NH))
            ^ (parity[SUBJ] ^ (horiz[SUBJ]!=NH));
          tl= (parity[CLIP] ^ (horiz[CLIP]!=NH) ^ edge->bundle[BELOW][CLIP]) 
            ^ (parity[SUBJ] ^ (horiz[SUBJ]!=NH) ^ edge->bundle[BELOW][SUBJ]);
          break;
        case GPC_UNION:
          contributing= (exists[CLIP] && (!parity[SUBJ] || horiz[SUBJ]))
                     || (exists[SUBJ] && (!parity[CLIP] || horiz[CLIP]))
                     || (exists[CLIP] && exists[SUBJ]
                     && (parity[CLIP] == parity[SUBJ]));
          br= (parity[CLIP])
           || (parity[SUBJ]);
          bl= (parity[CLIP] ^ edge->bundle[ABOVE][CLIP])
           || (parity[SUBJ] ^ edge->bundle[ABOVE][SUBJ]);
          tr= (parity[CLIP] ^ (horiz[CLIP]!=NH))
           || (parity[SUBJ] ^ (horiz[SUBJ]!=NH));
          tl= (parity[CLIP] ^ (horiz[CLIP]!=NH) ^ edge->bundle[BELOW][CLIP]) 
           || (parity[SUBJ] ^ (horiz[SUBJ]!=NH) ^ edge->bundle[BELOW][SUBJ]);
          break;
        }

        /* Update parity */
        parity[CLIP]^= edge->bundle[ABOVE][CLIP];
        parity[SUBJ]^= edge->bundle[ABOVE][SUBJ];

        /* Update horizontal state */
        if (exists[CLIP])         
          horiz[CLIP]=
            next_h_state[horiz[CLIP]]
                        [((exists[CLIP] - 1) << 1) + parity[CLIP]];
        if (exists[SUBJ])         
          horiz[SUBJ]=
            next_h_state[horiz[SUBJ]]
                        [((exists[SUBJ] - 1) << 1) + parity[SUBJ]];

        class= tr + (tl << 1) + (br << 2) + (bl << 3);

        if (contributing)
        {
          xb= edge->bot.x;

          switch (class)
          {
          case EMN:
          case IMN:
            add_local_min(&out_poly, edge, xb, yb);
            px= xb;
            cf= edge->outp;
            break;
          case ERI:
            if (NE(xb, px))
            {
              add_right(cf, xb, yb);
              px= xb;
            }
            edge->outp= cf;
            cf= NULL;
            break;
          case ELI:
            add_left(edge->outp, xb, yb);
            px= xb;
            cf= edge->outp;
            edge->outp= NULL;
            break;
          case EMX:
            if (NE(xb, px))
            {
              add_left(cf, xb, yb);
              px= xb;
            }
            merge_right(cf, edge->outp, out_poly);
            cf= NULL;
            edge->outp= NULL;
            break;
          case ILI:
            if (NE(xb, px))
            {
              add_left(cf, xb, yb);
              px= xb;
            }
            edge->outp= cf;
            cf= NULL;
            break;
          case IRI:
            add_right(edge->outp, xb, yb);
            px= xb;
            cf= edge->outp;
            edge->outp= NULL;
            break;
          case IMX:
            if (NE(xb, px))
            {
              add_right(cf, xb, yb);
              px= xb;
            }
            merge_left(cf, edge->outp, out_poly);
            cf= NULL;
            edge->outp= NULL;
            break;
          case IMM:
            if (NE(xb, px))
              add_right(cf, xb, yb);
            merge_left(cf, edge->outp, out_poly);
            add_local_min(&out_poly, edge, xb, yb);
            px= xb;
            cf= edge->outp;
            break;
          case EMM:
            if (NE(xb, px))
              add_left(cf, xb, yb);
            merge_right(cf, edge->outp, out_poly);
            add_local_min(&out_poly, edge, xb, yb);
            px= xb;
            cf= edge->outp;
            break;
          case LED:
            if (EQ(edge->bot.y, yb))
              add_left(edge->outp, xb, yb);
            px= xb;
            break;
          case RED:
            if (EQ(edge->bot.y, yb))
              add_right(edge->outp, xb, yb);
            px= xb;
            break;
          default:
            break;
          } /* End of switch */
        } /* End of contributing conditional */
      } /* End of edge exists conditional */
    } /* End of AET loop */

    /* Delete terminating edges from the AET */
    for (edge= aet; edge; edge= edge->next)
    {
      if (EQ(edge->top.y, yb))
      {
        prev_edge= edge->prev;
        next_edge= edge->next;
        if (prev_edge)
          prev_edge->next= next_edge;
        else
          aet= next_edge;
        if (next_edge)
          next_edge->prev= prev_edge;

        if (edge->head)
        {
          prev_edge->outp= edge->outp;
          prev_edge->bside[CLIP]= edge->bside[CLIP];
          prev_edge->bside[SUBJ]= edge->bside[SUBJ];
          prev_edge->bundle[ABOVE][CLIP]= edge->bundle[ABOVE][CLIP];
          prev_edge->bundle[ABOVE][SUBJ]= edge->bundle[ABOVE][SUBJ];
        }
      }
    }

    if (scanbeam < sbt_entries)
    {
      /* === SCANBEAM INTERIOR PROCESSING ============================== */

      /* Set yt to the top of the scanbeam */
      yt= sbt[scanbeam];

      /* Set dy to the height of the current scanbeam */
      dy= yt - yb;

      build_intersection_table(&it, aet, dy, yt);

      /* Process each node in the intersection table */
      for (intersect= it; intersect; intersect= intersect->next)
      {
        e0= intersect->ie[0];
        e1= intersect->ie[1];

        /* Only generate output for contributing intersections */
        if ((e0->bundle[ABOVE][CLIP] || e0->bundle[ABOVE][SUBJ])
         && (e1->bundle[ABOVE][CLIP] || e1->bundle[ABOVE][SUBJ]))
	{
          P= e0->outp;
          Q= e1->outp;
          ix= intersect->point.x;
          iy= intersect->point.y + yb;
 
          in[CLIP]= ( e0->bundle[ABOVE][CLIP] && !e0->bside[CLIP])
                 || ( e1->bundle[ABOVE][CLIP] &&  e1->bside[CLIP])
                 || (!e0->bundle[ABOVE][CLIP] && !e1->bundle[ABOVE][CLIP]
                     && e0->bside[CLIP] && e1->bside[CLIP]);
          in[SUBJ]= ( e0->bundle[ABOVE][SUBJ] && !e0->bside[SUBJ])
                 || ( e1->bundle[ABOVE][SUBJ] &&  e1->bside[SUBJ])
                 || (!e0->bundle[ABOVE][SUBJ] && !e1->bundle[ABOVE][SUBJ]
                     && e0->bside[SUBJ] && e1->bside[SUBJ]);
       
          /* Determine quadrant occupancies */
          switch (op)
          {
          case GPC_DIFF:
          case GPC_INT:
            tr= (in[CLIP])
             && (in[SUBJ]);
            tl= (in[CLIP] ^ e1->bundle[ABOVE][CLIP])
             && (in[SUBJ] ^ e1->bundle[ABOVE][SUBJ]);
            br= (in[CLIP] ^ e0->bundle[ABOVE][CLIP])
             && (in[SUBJ] ^ e0->bundle[ABOVE][SUBJ]);
            bl= (in[CLIP] ^ e1->bundle[ABOVE][CLIP] ^ e0->bundle[ABOVE][CLIP])
             && (in[SUBJ] ^ e1->bundle[ABOVE][SUBJ] ^ e0->bundle[ABOVE][SUBJ]);
            break;
          case GPC_XOR:
            tr= (in[CLIP])
              ^ (in[SUBJ]);
            tl= (in[CLIP] ^ e1->bundle[ABOVE][CLIP])
              ^ (in[SUBJ] ^ e1->bundle[ABOVE][SUBJ]);
            br= (in[CLIP] ^ e0->bundle[ABOVE][CLIP])
              ^ (in[SUBJ] ^ e0->bundle[ABOVE][SUBJ]);
            bl= (in[CLIP] ^ e1->bundle[ABOVE][CLIP] ^ e0->bundle[ABOVE][CLIP])
              ^ (in[SUBJ] ^ e1->bundle[ABOVE][SUBJ] ^ e0->bundle[ABOVE][SUBJ]);
            break;
          case GPC_UNION:
            tr= (in[CLIP])
             || (in[SUBJ]);
            tl= (in[CLIP] ^ e1->bundle[ABOVE][CLIP])
             || (in[SUBJ] ^ e1->bundle[ABOVE][SUBJ]);
            br= (in[CLIP] ^ e0->bundle[ABOVE][CLIP])
             || (in[SUBJ] ^ e0->bundle[ABOVE][SUBJ]);
            bl= (in[CLIP] ^ e1->bundle[ABOVE][CLIP] ^ e0->bundle[ABOVE][CLIP])
             || (in[SUBJ] ^ e1->bundle[ABOVE][SUBJ] ^ e0->bundle[ABOVE][SUBJ]);
            break;
          }
	  
          class= tr + (tl << 1) + (br << 2) + (bl << 3);
	  
          switch (class)
          {
          case EMN:
            add_local_min(&out_poly, e0, ix, iy);
            e1->outp= e0->outp;
            break;
          case ERI:
            if (P)
            {
              add_right(P, ix, iy);
              e1->outp= P;
              e0->outp= NULL;
            }
            break;
          case ELI:
            if (Q)
            {
              add_left(Q, ix, iy);
              e0->outp= Q;
              e1->outp= NULL;
            }
            break;
          case EMX:
            if (P && Q)
            {
              add_left(P, ix, iy);
              merge_right(P, Q, out_poly);
              e0->outp= NULL;
              e1->outp= NULL;
            }
            break;
          case IMN:
            add_local_min(&out_poly, e0, ix, iy);
            e1->outp= e0->outp;
            break;
          case ILI:
            if (P)
            {
              add_left(P, ix, iy);
              e1->outp= P;
              e0->outp= NULL;
            }
            break;
          case IRI:
            if (Q)
            {
              add_right(Q, ix, iy);
              e0->outp= Q;
              e1->outp= NULL;
            }
            break;
          case IMX:
            if (P && Q)
            {
              add_right(P, ix, iy);
              merge_left(P, Q, out_poly);
              e0->outp= NULL;
              e1->outp= NULL;
            }
            break;
          case IMM:
            if (P && Q)
            {
              add_right(P, ix, iy);
              merge_left(P, Q, out_poly);
              add_local_min(&out_poly, e0, ix, iy);
              e1->outp= e0->outp;
            }
            break;
          case EMM:
            if (P && Q)
            {
              add_left(P, ix, iy);
              merge_right(P, Q, out_poly);
              add_local_min(&out_poly, e0, ix, iy);
              e1->outp= e0->outp;
            }
            break;
          default:
            break;
          } /* End of switch */
	} /* End of contributing intersection conditional */

        /* Swap bundle sides in response to edge crossing */
        if (e0->bundle[ABOVE][CLIP])
	  e1->bside[CLIP]= !e1->bside[CLIP];
        if (e1->bundle[ABOVE][CLIP])
	  e0->bside[CLIP]= !e0->bside[CLIP];
        if (e0->bundle[ABOVE][SUBJ])
	  e1->bside[SUBJ]= !e1->bside[SUBJ];
        if (e1->bundle[ABOVE][SUBJ])
	  e0->bside[SUBJ]= !e0->bside[SUBJ];
        
        /* Swap e0 and e1 bundles in the AET */
        prev_edge= e0->prev;
        next_edge= e1->next;
        if (e1->next)
          e1->next->prev= e0;

        if (e0->head)
        {
          search= TRUE;
          while (search)
          {
            prev_edge= prev_edge->prev;
            if (prev_edge)
            {
              if (prev_edge->bundle[ABOVE][CLIP]
               || prev_edge->bundle[ABOVE][SUBJ]
               || prev_edge->head)
                search= FALSE;
            }
            else
              search= FALSE;
          }
        }
        if (!prev_edge)
        {
          e1->next= aet;
          aet= e0->next;
        }
        else
        {
          e1->next= prev_edge->next;
          prev_edge->next= e0->next;
        }
        e0->next->prev= prev_edge;
        e1->next->prev= e1;
        e0->next= next_edge;
      } /* End of IT loop*/

      /* Prepare for next scanbeam */
      for (edge= aet; edge; edge= next_edge)
      {
        next_edge= edge->next;
        succ_edge= edge->succ;

        if (EQ(edge->top.y, yt) && succ_edge)
        {
          /* Replace AET edge by its successor */
          succ_edge->outp= edge->outp;
          prev_edge= edge->prev;
          if (prev_edge)
            prev_edge->next= succ_edge;
          else
            aet= succ_edge;
          if (next_edge)
            next_edge->prev= succ_edge;
          succ_edge->prev= prev_edge;
          succ_edge->next= next_edge;
        }
        else
        {
          /* Update this edge */
          if (EQ(edge->top.y, yt))
            edge->bot.x= edge->top.x;
          else
            edge->bot.x+= (edge->delx * dy);
        }
      }
    }
  } /* === END OF SCANBEAM PROCESSING ================================== */

  /* Generate result polygon from out_poly */
  result->contour= NULL;
  result->num_contours= count_contours(out_poly);
  if (result->num_contours > 0)
  {
    MALLOC(result->contour, result->num_contours
           * sizeof(gpc_vertex_list), "contour creation");
    poly= out_poly;
    c= 0;

    while (poly)
    {
      npoly= poly->next;
      if (poly->active)
      {
        result->contour[c].num_vertices=
          count_vertices(poly->proxy[LEFT]);
        MALLOC(result->contour[c].vertex,
          result->contour[c].num_vertices * sizeof(gpc_vertex),
          "vertex creation");
        vtx= poly->proxy[LEFT];
        for (v= 0; v < result->contour[c].num_vertices; v++)
        {
          nv= vtx->next;
          result->contour[c].vertex[v].x= vtx->x;
          result->contour[c].vertex[v].y= vtx->y;
          FREE(vtx);
          vtx= nv;
        }
        c++;
      }
      FREE(poly);
      poly= npoly;
    }
  }

  /* Tidy up */
  reset_it(&it);
  reset_lmt(&lmt);
  FREE(c_heap);
  FREE(s_heap);
  FREE(sbt);
}


void gpc_free_tristrip(gpc_tristrip *t)
{
  int s;

  for (s= 0; s < t->num_strips; s++)
    CFREE(t->strip[s].vertex);
  CFREE(t->strip);
  t->num_strips= 0;
}


void gpc_polygon_to_tristrip(gpc_polygon *s, gpc_tristrip *t)
{
  gpc_polygon c;

  c.num_contours= 0;
  c.contour= NULL;
  gpc_tristrip_clip(GPC_DIFF, s, &c, t);
}


void gpc_tristrip_clip(gpc_op op, gpc_polygon *subject, gpc_polygon *clip,
                        gpc_tristrip *result)
{
  sb_tree       *sbtree= NULL;
  it_node       *it= NULL, *intersect;
  edge_node     *edge, *prev_edge, *next_edge, *succ_edge, *e0, *e1;
  edge_node     *aet= NULL, *c_heap, *s_heap, *cf;
  lmt_node      *lmt= NULL, *local_min;
  polygon_node  *tlist= NULL, *tn, *tnn, *P, *Q;
  vertex_node   *lt, *ltn, *rt, *rtn;
  h_state        horiz[2];
  int            in[2], exists[2], parity[2]= {LEFT, LEFT};
  int            s, v, contributing, search, scanbeam= 0, sbt_entries= 0;
  int            class, bl, br, tl, tr;
  double        *sbt= NULL, xb, px, nx, yb, yt, dy, idy, ix, iy, tedx, tndx;


  if (!set_gpc_epsilon(subject, clip))
  {
    /* Return a NULL result */
    result->num_strips= 0;
    result->strip= NULL;
    return;
  }

  /* Build LMT */
  s_heap= build_lmt(&lmt, &sbtree, &sbt_entries, subject, SUBJ, op);
  c_heap= build_lmt(&lmt, &sbtree, &sbt_entries, clip,    CLIP, op);

  /* Build scanbeam table from scanbeam tree */
  MALLOC(sbt, sbt_entries * sizeof(double), "sbt creation");
  build_sbt(&scanbeam, sbt, sbtree);
  scanbeam= 0;
  free_sbtree(&sbtree);

  /* Invert clip polygon for difference operation */
  if (op == GPC_DIFF)
    parity[CLIP]= RIGHT;

  local_min= lmt;

  /* Process each scanbeam */
  while (scanbeam < sbt_entries)
  {
    /* Set yb to the bottom of the scanbeam */
    yb= sbt[scanbeam++];

    /* === SCANBEAM BOUNDARY PROCESSING ================================ */

    /* If LMT node corresponding to yb exists */
    if (local_min)
    {
      if (EQ(local_min->y, yb))
      {
        /* Add edges starting at this local minimum to the AET */
        edge= local_min->first_bound;
        while(edge)
        {
          add_edge_to_aet(&aet, edge, NULL);
          edge= edge->next_bound;
        }
        local_min= local_min->next;
      }
    }

    /* Set dummy previous x value */
    px= -DBL_MAX;

    /* Create bundles within AET */
    e0= aet;
    e1= aet;

    /* Set up bundle fields of first edge */
    aet->bundle[ABOVE][ aet->type]= NE(aet->top.y, yb);
    aet->bundle[ABOVE][!aet->type]= FALSE;
    aet->head= FALSE;
    aet->bundle[BELOW][ aet->type]= NE(aet->bot.y, yb) || aet->pred;
    aet->bundle[BELOW][!aet->type]= FALSE;
    if (aet->bundle[BELOW][aet->type])
      tedx= EQ(e1->bot.y, yb)? e1->pred->delx: e1->delx;
    else
      tedx= -DBL_MAX;

    for (next_edge= aet->next; next_edge; next_edge= next_edge->next)
    {
      /* Set up bundle fields of next edge */
      next_edge->bundle[ABOVE][ next_edge->type]= NE(next_edge->top.y, yb);
      next_edge->bundle[ABOVE][!next_edge->type]= FALSE;
      next_edge->bundle[BELOW][ next_edge->type]= NE(next_edge->bot.y, yb)
        || next_edge->pred;
      next_edge->bundle[BELOW][!next_edge->type]= FALSE;
      next_edge->head= FALSE;

      /* Bundle edges above the scanbeam boundary if they coincide */
      if (next_edge->bundle[ABOVE][next_edge->type])
      {
        if (EQ(e0->bot.x, next_edge->bot.x) && EQ(e0->delx, next_edge->delx)
	 && NE(e0->top.y, yb))
        {
          next_edge->bundle[ABOVE][ next_edge->type]^= 
            e0->bundle[ABOVE][ next_edge->type];
          next_edge->bundle[ABOVE][!next_edge->type]= 
            e0->bundle[ABOVE][!next_edge->type]; 
          next_edge->head= TRUE;
          e0->bundle[ABOVE][CLIP]= FALSE;
          e0->bundle[ABOVE][SUBJ]= FALSE;
          e0->head= FALSE;
        }
        e0= next_edge;
      }

      /* Bundle edges below the scanbeam boundary if they coincide */
      if (next_edge->bundle[BELOW][next_edge->type])
      {
        tndx= EQ(next_edge->bot.y, yb)? next_edge->pred->delx: next_edge->delx;
        if (EQ(e1->bot.x, next_edge->bot.x) && EQ(tedx, tndx)
	 && (NE(e1->bot.y, yb) || e1->pred))
        { 
          next_edge->bundle[BELOW][ next_edge->type]^= 
            e1->bundle[BELOW][ next_edge->type];
          next_edge->bundle[BELOW][!next_edge->type]= 
            e1->bundle[BELOW][!next_edge->type];
          e1->bundle[BELOW][CLIP]= FALSE;
          e1->bundle[BELOW][SUBJ]= FALSE;
        }
        e1= next_edge;
        tedx= tndx;
      }
    }

    horiz[CLIP]= NH;
    horiz[SUBJ]= NH;

    /* Process each edge at this scanbeam boundary */
    for (edge= aet; edge; edge= edge->next)
    {
      exists[CLIP]= edge->bundle[ABOVE][CLIP] + 
                   (edge->bundle[BELOW][CLIP] << 1);
      exists[SUBJ]= edge->bundle[ABOVE][SUBJ] + 
                   (edge->bundle[BELOW][SUBJ] << 1);

      if (exists[CLIP] || exists[SUBJ])
      {
        /* Set bundle side */
        edge->bside[CLIP]= parity[CLIP];
        edge->bside[SUBJ]= parity[SUBJ];

        /* Determine contributing status and quadrant occupancies */
        switch (op)
        {
        case GPC_DIFF:
        case GPC_INT:
          contributing= (exists[CLIP] && (parity[SUBJ] || horiz[SUBJ]))
                     || (exists[SUBJ] && (parity[CLIP] || horiz[CLIP]))
                     || (exists[CLIP] && exists[SUBJ]
                     && (parity[CLIP] == parity[SUBJ]));
          br= (parity[CLIP])
           && (parity[SUBJ]);
          bl= (parity[CLIP] ^ edge->bundle[ABOVE][CLIP])
           && (parity[SUBJ] ^ edge->bundle[ABOVE][SUBJ]);
          tr= (parity[CLIP] ^ (horiz[CLIP]!=NH))
           && (parity[SUBJ] ^ (horiz[SUBJ]!=NH));
          tl= (parity[CLIP] ^ (horiz[CLIP]!=NH) ^ edge->bundle[BELOW][CLIP]) 
           && (parity[SUBJ] ^ (horiz[SUBJ]!=NH) ^ edge->bundle[BELOW][SUBJ]);
          break;
        case GPC_XOR:
          contributing= exists[CLIP] || exists[SUBJ];
          br= (parity[CLIP])
            ^ (parity[SUBJ]);
          bl= (parity[CLIP] ^ edge->bundle[ABOVE][CLIP])
            ^ (parity[SUBJ] ^ edge->bundle[ABOVE][SUBJ]);
          tr= (parity[CLIP] ^ (horiz[CLIP]!=NH))
            ^ (parity[SUBJ] ^ (horiz[SUBJ]!=NH));
          tl= (parity[CLIP] ^ (horiz[CLIP]!=NH) ^ edge->bundle[BELOW][CLIP])
            ^ (parity[SUBJ] ^ (horiz[SUBJ]!=NH) ^ edge->bundle[BELOW][SUBJ]);
          break;
        case GPC_UNION:
          contributing= (exists[CLIP] && (!parity[SUBJ] || horiz[SUBJ]))
                     || (exists[SUBJ] && (!parity[CLIP] || horiz[CLIP]))
                     || (exists[CLIP] && exists[SUBJ]
                     && (parity[CLIP] == parity[SUBJ]));
          br= (parity[CLIP])
           || (parity[SUBJ]);
          bl= (parity[CLIP] ^ edge->bundle[ABOVE][CLIP])
           || (parity[SUBJ] ^ edge->bundle[ABOVE][SUBJ]);
          tr= (parity[CLIP] ^ (horiz[CLIP]!=NH))
           || (parity[SUBJ] ^ (horiz[SUBJ]!=NH));
          tl= (parity[CLIP] ^ (horiz[CLIP]!=NH) ^ edge->bundle[BELOW][CLIP])
           || (parity[SUBJ] ^ (horiz[SUBJ]!=NH) ^ edge->bundle[BELOW][SUBJ]);
          break;
        }

        /* Update parity */
        parity[CLIP]^= edge->bundle[ABOVE][CLIP];
        parity[SUBJ]^= edge->bundle[ABOVE][SUBJ];

        /* Update horizontal state */
        if (exists[CLIP])         
          horiz[CLIP]=
            next_h_state[horiz[CLIP]]
                        [((exists[CLIP] - 1) << 1) + parity[CLIP]];
        if (exists[SUBJ])         
          horiz[SUBJ]=
            next_h_state[horiz[SUBJ]]
                        [((exists[SUBJ] - 1) << 1) + parity[SUBJ]];
        
        class= tr + (tl << 1) + (br << 2) + (bl << 3);

        if (contributing)
        {
          xb= edge->bot.x;

          switch (class)
          {
          case EMN:
            new_tristrip(&tlist, edge, xb, yb);
            px= xb;
            cf= edge;
            break;
          case ERI:
            if (NE(xb, px))
              VERTEX(cf, RIGHT, xb, yb);
            edge->outp= cf->outp;
            cf= NULL;
            break;
          case ELI:
            VERTEX(edge, LEFT, xb, yb);
            edge->outp= NULL;
            px= xb;
            cf= edge;
            break;
          case EMX:
            VERTEX(edge, RIGHT, xb, yb);
            edge->outp= NULL;
            cf= NULL;
            break;
          case IMN:
            if (NE(cf->bot.y, yb) && NE(cf->top.y, yb))
              VERTEX(cf, LEFT, cf->bot.x, yb);
            new_tristrip(&tlist, cf, cf->bot.x, yb);
            edge->outp= cf->outp;
            VERTEX(edge, RIGHT, xb, yb);
            px= xb;
            cf= edge;
            break;
          case ILI:
            new_tristrip(&tlist, edge, xb, yb);
            px= xb;
            cf= edge;
            break;
          case IRI:
            if (NE(cf->bot.y, yb) && NE(cf->top.y, yb))
              VERTEX(cf, LEFT, cf->bot.x, yb);
            VERTEX(edge, RIGHT, xb, yb);
            edge->outp= NULL;
            new_tristrip(&tlist, cf, cf->bot.x, yb);
            px= cf->bot.x;
            break;
          case IMX:
            VERTEX(edge, LEFT, xb, yb);
            edge->outp= NULL;
            break;
          case IMM:
            VERTEX(edge, LEFT, xb, yb);
            if (NE(cf->bot.y, yb) && NE(cf->top.y, yb))
              VERTEX(cf, LEFT, cf->bot.x, yb);
            new_tristrip(&tlist, cf, cf->bot.x, yb);
            edge->outp= cf->outp;
            VERTEX(edge, RIGHT, xb, yb);
            px= xb;
            cf= edge;
            break;
          case EMM:
            VERTEX(edge, RIGHT, xb, yb);
            edge->outp= NULL;
            new_tristrip(&tlist, edge, xb, yb);
            px= xb;
            cf= edge;
            break;
          case LED:
            if (EQ(edge->bot.y, yb))
              VERTEX(edge, LEFT, xb, yb);
            cf= edge;
            px= xb;
            break;
          case RED:
            if (EQ(edge->bot.y, yb) || EQ(cf->bot.y, yb)
               || (cf->outp != edge->outp))
            {
              if (cf->outp != edge->outp)
              {
                VERTEX(edge, RIGHT, xb, yb);
                edge->outp= cf->outp;
              }
              else
              {
                if (NE(cf->bot.y, yb))
                  VERTEX(cf, LEFT, cf->bot.x, yb);
              }
              VERTEX(edge, RIGHT, xb, yb);
            }
            cf= NULL;
            break;
          default:
            break;
          } /* End of switch */
        } /* End of contributing conditional */
      } /* End of edge exists conditional */
    } /* End of AET loop */

    /* Delete terminating edges from the AET */
    for (edge= aet; edge; edge= edge->next)
    {
      if (EQ(edge->top.y, yb))
      {
        prev_edge= edge->prev;
        next_edge= edge->next;
        if (prev_edge)
          prev_edge->next= next_edge;
        else
          aet= next_edge;
        if (next_edge)
          next_edge->prev= prev_edge;

        if (edge->head)
        {
          prev_edge->outp= edge->outp;
          prev_edge->bside[CLIP]= edge->bside[CLIP];
          prev_edge->bside[SUBJ]= edge->bside[SUBJ];
          prev_edge->bundle[ABOVE][CLIP]= edge->bundle[ABOVE][CLIP];
          prev_edge->bundle[ABOVE][SUBJ]= edge->bundle[ABOVE][SUBJ];
        }
      }
    }

    if (scanbeam < sbt_entries)
    {
      /* === SCANBEAM INTERIOR PROCESSING ============================== */
  
      /* Set yt to the top of the scanbeam */
      yt= sbt[scanbeam];

      /* Set dy to the height of the current scanbeam */
      dy= yt - yb;

      build_intersection_table(&it, aet, dy, yt);

      /* Process each node in the intersection table */
      for (intersect= it; intersect; intersect= intersect->next)
      {
        e0= intersect->ie[0];
        e1= intersect->ie[1];

        /* Only generate output for contributing intersections */
        if ((e0->bundle[ABOVE][CLIP] || e0->bundle[ABOVE][SUBJ])
         && (e1->bundle[ABOVE][CLIP] || e1->bundle[ABOVE][SUBJ]))
	{
          P= e0->outp;
          Q= e1->outp;
          ix= intersect->point.x;
          idy= intersect->point.y;
          iy= idy+ yb;

          in[CLIP]= ( e0->bundle[ABOVE][CLIP] && !e0->bside[CLIP])
                 || ( e1->bundle[ABOVE][CLIP] &&  e1->bside[CLIP])
                 || (!e0->bundle[ABOVE][CLIP] && !e1->bundle[ABOVE][CLIP]
                     && e0->bside[CLIP] && e1->bside[CLIP]);
          in[SUBJ]= ( e0->bundle[ABOVE][SUBJ] && !e0->bside[SUBJ])
                 || ( e1->bundle[ABOVE][SUBJ] &&  e1->bside[SUBJ])
                 || (!e0->bundle[ABOVE][SUBJ] && !e1->bundle[ABOVE][SUBJ]
                     && e0->bside[SUBJ] && e1->bside[SUBJ]);

          /* Determine quadrant occupancies */
          switch (op)
          {
          case GPC_DIFF:
          case GPC_INT:
            tr= (in[CLIP])
             && (in[SUBJ]);
            tl= (in[CLIP] ^ e1->bundle[ABOVE][CLIP])
             && (in[SUBJ] ^ e1->bundle[ABOVE][SUBJ]);
            br= (in[CLIP] ^ e0->bundle[ABOVE][CLIP])
             && (in[SUBJ] ^ e0->bundle[ABOVE][SUBJ]);
            bl= (in[CLIP] ^ e1->bundle[ABOVE][CLIP] ^ e0->bundle[ABOVE][CLIP])
             && (in[SUBJ] ^ e1->bundle[ABOVE][SUBJ] ^ e0->bundle[ABOVE][SUBJ]);
            break;
          case GPC_XOR:
            tr= (in[CLIP])
              ^ (in[SUBJ]);
            tl= (in[CLIP] ^ e1->bundle[ABOVE][CLIP])
              ^ (in[SUBJ] ^ e1->bundle[ABOVE][SUBJ]);
            br= (in[CLIP] ^ e0->bundle[ABOVE][CLIP])
              ^ (in[SUBJ] ^ e0->bundle[ABOVE][SUBJ]);
            bl= (in[CLIP] ^ e1->bundle[ABOVE][CLIP] ^ e0->bundle[ABOVE][CLIP])
              ^ (in[SUBJ] ^ e1->bundle[ABOVE][SUBJ] ^ e0->bundle[ABOVE][SUBJ]);
            break;
          case GPC_UNION:
            tr= (in[CLIP])
             || (in[SUBJ]);
            tl= (in[CLIP] ^ e1->bundle[ABOVE][CLIP])
             || (in[SUBJ] ^ e1->bundle[ABOVE][SUBJ]);
            br= (in[CLIP] ^ e0->bundle[ABOVE][CLIP])
             || (in[SUBJ] ^ e0->bundle[ABOVE][SUBJ]);
            bl= (in[CLIP] ^ e1->bundle[ABOVE][CLIP] ^ e0->bundle[ABOVE][CLIP])
             || (in[SUBJ] ^ e1->bundle[ABOVE][SUBJ] ^ e0->bundle[ABOVE][SUBJ]);
            break;
          }

          class= tr + (tl << 1) + (br << 2) + (bl << 3);

          switch (class)
          {
          case EMN:
            new_tristrip(&tlist, e1, ix, iy);
            e0->outp= e1->outp;
            break;
          case ERI:
            if (P)
            {
              P_EDGE(prev_edge, e0, px, idy);
              VERTEX(prev_edge, LEFT, px, iy);
              VERTEX(e0, RIGHT, ix, iy);
              e1->outp= e0->outp;
              e0->outp= NULL;
            }
            break;
          case ELI:
            if (Q)
            {
              N_EDGE(next_edge, e1, nx, idy);
              VERTEX(e1, LEFT, ix, iy);
              VERTEX(next_edge, RIGHT, nx, iy);
              e0->outp= e1->outp;
              e1->outp= NULL;
            }
            break;
          case EMX:
            if (P && Q)
            {
              VERTEX(e0, LEFT, ix, iy);
              e0->outp= NULL;
              e1->outp= NULL;
            }
            break;
          case IMN:
            P_EDGE(prev_edge, e0, px, idy);
            VERTEX(prev_edge, LEFT, px, iy);
            N_EDGE(next_edge, e1, nx, idy);
            VERTEX(next_edge, RIGHT, nx, iy);
            new_tristrip(&tlist, prev_edge, px, iy); 
            e1->outp= prev_edge->outp;
            VERTEX(e1, RIGHT, ix, iy);
            new_tristrip(&tlist, e0, ix, iy);
            next_edge->outp= e0->outp;
            VERTEX(next_edge, RIGHT, nx, iy);
            break;
          case ILI:
            if (P)
            {
              VERTEX(e0, LEFT, ix, iy);
              N_EDGE(next_edge, e1, nx, idy);
              VERTEX(next_edge, RIGHT, nx, iy);
              e1->outp= e0->outp;
              e0->outp= NULL;
            }
            break;
          case IRI:
            if (Q)
            {
              VERTEX(e1, RIGHT, ix, iy);
              P_EDGE(prev_edge, e0, px, idy);
              VERTEX(prev_edge, LEFT, px, iy);
              e0->outp= e1->outp;
              e1->outp= NULL;
            }
            break;
          case IMX:
            if (P && Q)
            {
              VERTEX(e0, RIGHT, ix, iy);
              VERTEX(e1, LEFT, ix, iy);
              e0->outp= NULL;
              e1->outp= NULL;
              P_EDGE(prev_edge, e0, px, idy);
              VERTEX(prev_edge, LEFT, px, iy);
              new_tristrip(&tlist, prev_edge, px, iy);
              N_EDGE(next_edge, e1, nx, idy);
              VERTEX(next_edge, RIGHT, nx, iy);
              next_edge->outp= prev_edge->outp;
              VERTEX(next_edge, RIGHT, nx, iy);
            }
            break;
          case IMM:
            if (P && Q)
            {
              VERTEX(e0, RIGHT, ix, iy);
              VERTEX(e1, LEFT, ix, iy);
              P_EDGE(prev_edge, e0, px, idy);
              VERTEX(prev_edge, LEFT, px, iy);
              new_tristrip(&tlist, prev_edge, px, iy);
              N_EDGE(next_edge, e1, nx, idy);
              VERTEX(next_edge, RIGHT, nx, iy);
              e1->outp= prev_edge->outp;
              VERTEX(e1, RIGHT, ix, iy);
              new_tristrip(&tlist, e0, ix, iy);
              next_edge->outp= e0->outp;
              VERTEX(next_edge, RIGHT, nx, iy);
            }
            break;
          case EMM:
            if (P && Q)
            {
              VERTEX(e0, LEFT, ix, iy);
              new_tristrip(&tlist, e1, ix, iy);
              e0->outp= e1->outp;
            }
            break;
          default:
            break;
          } /* End of switch */
	} /* End of contributing intersection conditional */

        /* Swap bundle sides in response to edge crossing */
        if (e0->bundle[ABOVE][CLIP])
	  e1->bside[CLIP]= !e1->bside[CLIP];
        if (e1->bundle[ABOVE][CLIP])
	  e0->bside[CLIP]= !e0->bside[CLIP];
        if (e0->bundle[ABOVE][SUBJ])
	  e1->bside[SUBJ]= !e1->bside[SUBJ];
        if (e1->bundle[ABOVE][SUBJ])
	  e0->bside[SUBJ]= !e0->bside[SUBJ];

        /* Swap e0 and e1 bundles in the AET */
        prev_edge= e0->prev;
        next_edge= e1->next;
        if (e1->next)
          e1->next->prev= e0;

        if (e0->head)
        {
          search= TRUE;
          while (search)
          {
            prev_edge= prev_edge->prev;
            if (prev_edge)
            {
              if (prev_edge->bundle[ABOVE][CLIP]
               || prev_edge->bundle[ABOVE][SUBJ]
               || prev_edge->head)
                search= FALSE;
            }
            else
              search= FALSE;
          }
        }
        if (!prev_edge)
        {
           e1->next= aet;
           aet= e0->next;
        }
        else
        {
          e1->next= prev_edge->next;
          prev_edge->next= e0->next;
        }
        e0->next->prev= prev_edge;
        e1->next->prev= e1;
        e0->next= next_edge;
      } /* End of IT loop*/

      /* Prepare for next scanbeam */
      for (edge= aet; edge; edge= next_edge)
      {
        next_edge= edge->next;
        succ_edge= edge->succ;

        if (EQ(edge->top.y, yt) && succ_edge)
        {
          /* Replace AET edge by its successor */
          succ_edge->outp= edge->outp;
          prev_edge= edge->prev;
          if (prev_edge)
            prev_edge->next= succ_edge;
          else
            aet= succ_edge;
          if (next_edge)
            next_edge->prev= succ_edge;
          succ_edge->prev= prev_edge;
          succ_edge->next= next_edge;
        }
        else
        {
          /* Update this edge */
          if (EQ(edge->top.y, yt))
            edge->bot.x= edge->top.x;
          else
            edge->bot.x+= (edge->delx * dy);
        }
      }
    }
  } /* === END OF SCANBEAM PROCESSING ================================== */

  /* Generate result tristrip from tlist */
  result->strip= NULL;
  result->num_strips= count_tristrips(tlist);
  if (result->num_strips > 0)
  {
    MALLOC(result->strip, result->num_strips * sizeof(gpc_vertex_list),
           "tristrip list creation");
    tn= tlist;
    s= 0;

    while(tn)
    {
      tnn= tn->next;

      if (tn->active > 2)
      {
        /* Valid tristrip: copy the vertices and free the heap */
        result->strip[s].num_vertices= tn->active;
        MALLOC(result->strip[s].vertex, tn->active * sizeof(gpc_vertex),
               "tristrip creation");
        v= 0;
        if (INVERT_TRISTRIPS)
        {
          lt= tn->v[RIGHT];
          rt= tn->v[LEFT];
        }
        else
        {
          lt= tn->v[LEFT];
          rt= tn->v[RIGHT];
        }
        while (lt || rt)
        {
          if (lt)
          {
            ltn= lt->next;
            result->strip[s].vertex[v].x= lt->x;
            result->strip[s].vertex[v].y= lt->y;
            v++;
            FREE(lt);
            lt= ltn;
          }
          if (rt)
          {
            rtn= rt->next;
            result->strip[s].vertex[v].x= rt->x;
            result->strip[s].vertex[v].y= rt->y;
            v++;
            FREE(rt);
            rt= rtn;
          }
        }
        s++;
      }
      else
      {
        /* Invalid tristrip: just free the heap */
        lt= tn->v[LEFT];
        while (lt)
        {
          ltn= lt->next;
          FREE(lt);
          lt= ltn;
        }
        rt= tn->v[RIGHT];
        while (rt)
        {
          rtn= rt->next;
          FREE(rt);
          rt= rtn;
        }
      }
      FREE(tn);
      tn= tnn;
    }
  }

  /* Tidy up */
  reset_it(&it);
  reset_lmt(&lmt);
  FREE(c_heap);
  FREE(s_heap);
  FREE(sbt);
}


/*
===========================================================================
                           End of file: gpc.c
===========================================================================
*/
