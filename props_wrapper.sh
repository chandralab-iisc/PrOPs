#sruti - modified on 20.01.2025
#write to shrisrutis@gmail.com for queries.

#run as bash predd_pipeline.sh <sample_id> <3> <Active>

#This script takes in sample name, network file, pathlength threshold, edge wt calculation modes (Active, Repressed or perturbed)
#And calculates 
  #1. edge_wt_calc.awk - edgewt calc (options - active, repressed or perturbed)
  #2. predd_sp.py (Djikstra's - Mutated nodes vs All nodes)
  #3. quantile.R - quantile calculation for deciding the toppath cutoff
  #4. path_to_node.sh - modify it to get mutpaths
  #5. maxcover.py - greedy cover algorithm to identify panel genes

sample_id=$1 #example: TCGA_06_0157_01A; in case of a cohort run, give the input as a list of all patient ids.
path_cutoff= $2; #default : 3
mode=$3 ; #can be either Active or Repressed or Perturbed

#assuming that all the files are stored in the /data directory
#change the file suffixes accordingly
nodewt_file="data/"$1"_nodewt.tsv";
mutfile="data/"$1"_mutated_genes.txt";
degfile="data/"$1"_deg.txt";
network_file="hPPiN2.csv"; #change here for other networks
edgewt_file="data/"$1"_edgewt.tsv";

script_dir="scripts/"
#initializing the file names for the toppath metrics
toppath=$1"_toppath";
toppath_int=$1"_toppath_int";
toppath_int_wt=$1'_toppath_int_wt.txt';
toppath_nodes=$1"_toppath_nodes.txt";
toppath_deg=$1'_toppath_deg.txt';
toppath_mut=$1'_toppath_mut.txt';

#---------------------- Edge weight calculation -------------------------------# 
echo "Calculating edge weights";
gawk -v nodefile="$nodewt_file" -v mode="$mode" -f $script_dir/edge_wt_calc.awk "$network_file" > $edgewt_file 

#-------------- Shortest path - Mutated node vs all nodes ---------------------# 
echo "Running network analysis";
python3 $script_dir/props_sp.py "$edgewt_file" "$mutfile" "$path_cutoff"; #output-$1"_sp.tsv"
#default: path_cutoff = 3
cut -f4 $1"_sp.tsv"|sed 1d|sort -n|uniq > $1"_sp_score.txt";

#---------------------- Mutpath calculation -----------------------------------#
#quantile calculation for Mutpaths identification
echo "Calculating quantiles";
Rscript $script_dir/quantile.R $1"_sp_score.txt";

echo "Obtaining mutpaths";
cutoff=`awk 'FNR==12{print $2}' $1"_score_quantile"`; #for the 0.01% cutoff.
awk -v a="$cutoff" '{if($4<=a) print $5}' $1"_sp.tsv" > $toppath;
unset cutoff;

#replaces "-" with "_" for the gene names (mostly TF-gene complexes). 
#Useful for downstream analysis.
sed -i 's/-/_/g' $toppath 

#gets the toppath nodes from the path line a,b,c,d to a\tb,b\tc, etc.
bash $script_dir/path_to_node.sh $toppath

#node lists from toppath, toppath deg nodes and toppath mutated nodes
sed 's/\t/\n/g' $toppath_int|sort -u > $toppath_nodes; 
grep -wf $toppath_nodes $degfile|sort -u > $toppath_deg;
grep -wf $toppath_nodes $mutfile|sort -u > $toppath_mut;
grep -wf $toppath_int $edgewt_file > $toppath_int_wt; #needed for cytoscape visualization

#---------------------- Max cover algorithm --------------------------------#
#can change the parameter for the coverage; default: 70
python3 $script_dir/props_maxcover.py $1"_toppath_int_wt.txt" $1"_toppath_mut.txt" $1"_toppath_deg.txt" 70 $sample_id

