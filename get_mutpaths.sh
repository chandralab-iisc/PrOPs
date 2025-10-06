#!/bin/sh

#to get mutpath based on quantiles for all patients in a cohort
#for only one sample, ignore the while loop
#sruti

pat_list=$1;
data_dir="data/"

file=$1"_sp.txt"; 
echo $file;
file_quant=$1"_sp.txt_score_quantile";

mutfile=$1"_mutation.txt";
#intfile=$name"_toppath_int";
#wtfile=$edgewt_dir"/"$name"_edgewt_repressed";
wtfile=$1"_edgewt.tsv";

#degfile=$deg_dir"/"$name"_tmm_deg";
degfile=$1"_deg.txt"

toppath=$name"_toppath";
toppath_int=$name"_toppath_int";
toppath_nodes=$name"_toppath_nodes.txt";

toppath_deg=$name'_toppath_deg.txt';
toppath_mut=$name'_toppath_mut.txt';
toppath_int_wt=$name'_toppath_int_wt.txt';

#toppath
echo "Obtaining mutpaths";
cutoff=`awk 'FNR==12{print $2}' $file_quant`; #for 0.01% toppath
awk -v a="$cutoff" '{if($4<=a) print $5}' $file > $toppath;

unset cutoff;

#replaces "-" with "_" for the gene names (mostly TF-gene complexes). 
#Useful for downstream analysis.
sed -i 's/-/_/g' $toppath

#toppath_int
awk '$1=$1' FS="," OFS="\t" $toppath|awk '{for(i=1;i<NF;++i){print $i"\t"$(i+1)"\n"}}'|awk 'NF>0'|sort -u > $toppath_int

sed 's/\t/\n/g' $toppath_int|sort -u > $toppath_nodes; 

#node lists from toppath, toppath deg nodes and toppath mutated nodes
grep -xf $toppath_nodes $degfile|sort -u > $toppath_deg;
grep -xf $toppath_nodes $mutfile|sort -u > $toppath_mut;
grep -wf $toppath_int $wtfile > $toppath_int_wt; #needed for cytoscape visualization

