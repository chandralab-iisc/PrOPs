#This script takes in node wt, pathlength threshold, mut list, deg list and maxcover_cutoff.
#Calculates 
  #1. edge wt (options - active, repressed or perturbed)
  #2. response net (Djikstra's - based on the pathlength threshold)
  #3. quantile calculation for deciding the paths cutoff
  #4. get_tmutpaths.py - filters the sp file to select the mutpaths
  #5. props_maxcover.py - calculates the ipanels for each patient based on their mutpaths.

nodewt_file=$1;
mut_file=$2;
network_file="hPPiN2.csv";
deg_file= $3;
path_cutoff= $4;
mode=$5 ; #can be either Active or Repressed
maxcover_cutoff=$6

#1. edgewt 
echo "Calculating edge weights";
gawk -v nodefile="$nodewt_file" -v mode="$mode" -f edge_wt_calc.awk "$network_file" > edgewt_file.tsv

#2. Shortest path calculation 
echo "Running network analysis";
python props_sp.py "edgewt_file.tsv" "$mut_file" "$path_cutoff"; 

#3. Quantile calculation
echo "Calculating quantiles";
Rscript quantile.R ""

#4. Mutpaths
echo "Obtaining mutpaths";
bash get_mutpaths.sh "$mut_file" "sp.tsv" "$deg_file" ;

#5. iPanels
python props_maxcover.py "$toppath_int_wt" "$toppath_mut" "$toppath_deg" "$maxcover_cutoff"
