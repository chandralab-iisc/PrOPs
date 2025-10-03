# PrOPs
Precision Oncopanels (PrOPs)- An algorithm to identify short individualised actionable panels that can guide cancer treatment

PrOPs can be run by using the wrapper script as
bash wrapper.sh <sample_id> <mut_file> <deg_file> <node_file> <network> <pathlength_cutoff> <sp_mode> <maxcover_cutoff>

This algorithm requires the following inputs:
1. Node weight file which contains the foldchange values of the gene in condition with respect to the control,
2. Mutation file that contains a list of all mutated genes in that patient.
3. DEG file that contains all the differentially regulated genes in that patient.
   
The other parameters rewuired are the path length and coverage cutoff for calculating the shortest paths and 

PrOPs identifies the iPanel for each patient through these steps:
1. Edge weight calculation (options - active, repressed or perturbed)
2. Response net (Djikstra's shortest path calulation - based on the pathlength threshold)
3. MutPath calculation based on the quantile cutoffs calculated by quantile.R, get_mutpaths.py scripts.
4. iPanel genes calculated by the props_maxcover.py script.

