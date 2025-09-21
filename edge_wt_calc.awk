BEGIN{                                                                          
  while( getline line < nodefile ){                                             
    split(line,arr,"\t");                                                       
    if( length(arr) == 2 )                                                      
      data[arr[1]] = arr[2];                                                    
  }                                                                             
}

NF == 2 && data[$1] != "" && data[$2] != "" {
	if (mode=="Active") {
		printf "%s\t%s\t%8.6f\n",$1,$2,(1/sqrt(data[$1] * data[$2]));
	}
	if (mode=="Repressed") {
		printf "%s\t%s\t%8.6f\n",$1,$2,(sqrt(data[$1] * data[$2]));
	}
#	if (mode=="Perturbed") {
#		printf "%s\t%s\t%8.6f\n",$1,$2,(abs(sqrt(data[$1] * data[$2])));
#	}
}

