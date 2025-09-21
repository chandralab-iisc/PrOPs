#to get interaction from paths - sruti - 22.11.18
#i/p : paths from sp file
#o/p : interaction file


#read the path file line by line
#convert the , to \t
#and give a second column by starting from second line
#remove the line whose second field is empty

#or after reading line by line 

file=$1;
echo $file;

outfile=$file'_int';
awk '$1=$1' FS="," OFS="\t" $file|awk '{for(i=1;i<NF;++i){print $i"\t"$(i+1)"\n"}}'|awk 'NF>0'|sort -u > $outfile

# awk '$1=$1' --- is a dummy variable
# awk 'NF>0' --- omits blank lines

#### other commands to change the delimiter
#sed 's/,/\t/g' $file)
#awk 'gsub(",","\t")' $file
#tr ',' '\t' < $file



