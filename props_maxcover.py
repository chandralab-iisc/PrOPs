from __future__ import division
import os
import math
import argparse
import sys
import itertools
import json
import numpy as np
import networkx as nx
from itertools import chain, combinations
from collections import Counter

# maximum coverage function
def sruti_max_cover(universe, subsets):
    covered_key = set()
    covered_set = set()
    temp_set = set()
    current_set_len = 0
    print("Required len to cover the universe", round(coverage))

    for i in range(max_key_len):
        current_key_set = [
            key for key, val in subsets.items() if len(val) == max_key_len - i]
        for j in range(len(current_key_set)):
            current_set_len = len(covered_set)
            temp_set.update(subsets.get(current_key_set[j]))

            if len(temp_set) <= round(coverage):
                print("elements_covered_so_far for the present keys",
                      subsets.get(current_key_set[j]))
                print("len of covered_set", len(temp_set))

                if len(temp_set) > current_set_len:
                    covered_key.add((current_key_set[j]))
                    print("key", current_key_set[j])
                    covered_set.update(subsets.get(current_key_set[j]))

            else:
                covered_key.add(current_key_set[j])
                print("key", current_key_set[j])
                covered_set.update(subsets.get(current_key_set[j]))
                return covered_set, covered_key
        # break
    print("covered_set", len(covered_set), covered_set)
    print("covered_key", len(covered_key), covered_key)
    return covered_set, covered_key

# main function -- read in the inputs
if __name__ == "__main__":
    # read in the toppath mut, toppath deg and toppath weighted interaction files
    parser = argparse.ArgumentParser(
        description='This code outputs maximum set coverage for the given coverage cutoff', epilog='sruti')
    parser.add_argument('edgewtfile', type=str,
                        help='List of edges and weigths of the toppath')
    parser.add_argument('mutfile', type=str,
                        help='Mutated node list from the toppath')
    parser.add_argument('degfile', type=str,
                        help='DEG node list from the toppath')
    parser.add_argument('coverage_cutoff', type=int,
                        help='desired coverage cut-off. Eg: for 70% coverage, enter the value 70')
    args = parser.parse_args()

    toppath = open(args.edgewtfile, 'r')
    mut_file = open(args.mutfile, 'r')
    deg_file = open(args.degfile, 'r')
    coverage_cutoff = int(sys.argv[4])

    pat_name = sys.argv[1]
    pat_name1 = pat_name.split("_", 4)
    pat_name2 = '_'.join(pat_name1[0:4])
    print "Current patient: ", pat_name2
    print "Reading input arguments"
    print "The input coverage cutoff is: ", int(coverage_cutoff)
    mutnodes = mut_file.read().splitlines()
    degnodes = deg_file.read().splitlines()
    G = nx.read_weighted_edgelist(
        toppath, nodetype=str, create_using=nx.DiGraph())

    # declare the subset dictionary
    mut_subsets = {}
    # fill in the dict keys w/o values
    for i in mutnodes:
        mut_subsets[i] = None

    # find the successor nodes of mutnodes, filter to keep only the degnodes
    # and update the dict
    for mut in mutnodes:
        mut_down = list(nx.dfs_postorder_nodes(G, source=mut, depth_limit=4))
        # retain only the degnodes
        mut_deg = [a for a in mut_down if a in degnodes]
        mut_subsets[mut] = mut_deg
    print("Created the mut_subsets dictionary")

    # the mut_subsets has a list of all captured degnodes --- use as Universe set
    # first flatten the list of lists and convert it to a set object
    universe = set([item for sublist in mut_subsets.values()
                   for item in sublist])
    coverage = (coverage_cutoff/100)*len(universe)
    max_key_len = max([len(mut_subsets[ele]) for ele in mut_subsets])

    max_cover_out = sruti_max_cover(universe, mut_subsets)
    print("Calculated max_set for the desired coverage cutoff")
    print("\n")
    foutput1 = pat_name2+"_maxset.txt_70"
    with open(foutput1, 'w') as w1:
        w1.write(str(max_cover_out[0]))  # covered_set
        w1.write("\n")
        w1.write(str(max_cover_out[1]))  # covered_keys
        w1.write("\n")
        w1.close()

    score_set = {}
    for i in max_cover_out[1]:
        score_set[i] = None

    for i in max_cover_out[1]:
        #print i
        mut = i
        mut_down_4 = list(nx.dfs_postorder_nodes(G, source=mut, depth_limit=4))
        mut_down_4 = len([a for a in mut_down_4 if a in degnodes])
        mut_down_3 = list(nx.dfs_postorder_nodes(G, source=mut, depth_limit=3))
        mut_down_3 = len([a for a in mut_down_3 if a in degnodes])
        mut_down_2 = list(nx.dfs_postorder_nodes(G, source=mut, depth_limit=2))
        mut_down_2 = len([a for a in mut_down_2 if a in degnodes])
        mut_down_1 = list(nx.dfs_postorder_nodes(G, source=mut, depth_limit=1))
        mut_down_1 = len([a for a in mut_down_1 if a in degnodes])
        score= mut_down_1 + (mut_down_2-mut_down_1)/2 + (mut_down_3 - mut_down_2)/3 +(mut_down_4 - mut_down_3)/4
        score_set[mut] = score

    foutput2 = pat_name2 + "_score_for_surv.txt"
    with open(foutput2, 'w') as w2:
        for key, value in score_set.items():
            w2.write('%s\t%s\n' % (key, value)) 
