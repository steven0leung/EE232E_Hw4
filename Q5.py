import pandas
import numpy as np
import csv
import igraph
from pprint import pprint

def main():
        from igraph import *
        g1 = Graph.Read_Ncol('double_mst.txt', directed=False)
        el = g1.get_edgelist()

        print g1.vs[0]['name']
        from FindEulerTour import find_euler_tour

        tour = find_euler_tour(el)

        
        tsp = []
        tsp_names = []
        for i in tour:
            if i not in tsp:
                tsp.append(i)
                tsp_names.append(g1.vs[i]['name'])
        tsp_names.append(g1.vs[0]['name'])

        

        thefile = open('tsp.txt', 'w')
        for item in tsp_names:
          print>>thefile, item 

if __name__ == '__main__':
        main()
