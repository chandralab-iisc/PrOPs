#!/bin/sh

#to get mutpath based on quantiles for all patients in a cohort
#for only one sample, ignore the while loop
#sruti

pat_list=$1;
deg_dir=$2;
sp_dir=$3;
mut_dir=$4;
edgewt_dir=$5;
quant_dir=$6;

cat $pat_list| while read name
do
#file=$sp_dir"/"$name"_sp_rep.txt";
file=$sp_dir"/"$name"_sp.txt"; 
echo $file;
file_quant=$quant_dir"/"$name"_sp.txt_score_quantile";

mutfile=$mut_dir"/"$name"_mutation.txt";
#intfile=$name"_toppath_int";
#wtfile=$edgewt_dir"/"$name"_edgewt_repressed";
wtfile=$edgewt_dir"/"$name"_edgewt";

#degfile=$deg_dir"/"$name"_tmm_deg";
degfile=$deg_dir"/"$name"_getmm_deg"

toppath=$name"_toppath";
toppath_int=$name"_toppath_int";
toppath_nodes=$name"_toppath_nodes.txt";

toppath_deg=$name'_toppath_deg.txt';
toppath_mut=$name'_toppath_mut.txt';
toppath_int_wt=$name'_toppath_int_wt.txt';

#toppath
cutoff=`awk 'FNR==12{print $2}' $file_quant`;
awk -v a="$cutoff" '{if($4<=a) print $5}' $file > $toppath;

unset cutoff;

#toppath_int
awk '$1=$1' FS="," OFS="\t" $toppath|awk '{for(i=1;i<NF;++i){print $i"\t"$(i+1)"\n"}}'|awk 'NF>0'|sort -u > $toppath_int

sed 's/\t/\n/g' $toppath_int|sort -u > $toppath_nodes; 

grep -xf $toppath_nodes $degfile|sort -u > $toppath_deg;
grep -xf $toppath_nodes $mutfile|sort -u > $toppath_mut;
grep -wf $toppath_int $wtfile > $toppath_int_wt;

done
