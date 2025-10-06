# PrOPs
Precision Oncopanels (PrOPs)- An algorithm to identify short individualised actionable panels that can guide cancer treatment

PrOPs can be run by using the wrapper script as
bash props_wrapper.sh <sample_id> <3> <Active>

This algorithm requires the following inputs:
1. Node weight file which contains the foldchange values of the gene in condition with respect to the control,
2. A mutation file that contains a list of all mutated genes in that patient.
3. DEG file that contains all the differentially regulated genes in that patient.
4. Human protein-protein interaction network file. data/hPPin2.csv is the network file used in this study.
    
The other parameters required are the path length and coverage cutoff for calculating the shortest paths 
and the mode to calculate the edge weight for the nodes in the sample. 

PrOPs identifies the iPanel for each patient through these steps:
1. Edge weight calculation (options: active, repressed or perturbed)
2. Response net (Shortest path calculation - based on the pathlength threshold)
3. MutPath calculation based on the quantile cutoffs calculated by quantile.R, path_to_node.sh scripts.
4. iPanel genes calculated by the props_maxcover.py script.

