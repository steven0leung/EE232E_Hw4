import pandas
import numpy as np
import csv
import igraph
from pprint import pprint

def main():
        from igraph import *
        g1 = Graph.Read_Ncol('double_mst.txt', directed=False)
        el = g1.get_edgelist()

        from FindEulerTour import find_euler_tour

        tour = find_euler_tour(el)

        
        tsp = []
        for i in tour:
            if i not in tsp:
                tsp.append(i)
        tsp.append(0)

        print tsp

        thefile = open('tsp.txt', 'w')
        for item in tsp:
          print>>thefile, item + 1

if __name__ == '__main__':
        main()
