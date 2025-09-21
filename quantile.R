args<-commandArgs(TRUE)                                                         
file =  args[1]                                                                 
data <- read.csv(file, header=FALSE, sep = "\t", stringsAsFactors = FALSE)      
z <- quantile(data,probs = seq(0,1,0.0001),na.rm = TRUE)                        
df_final <- data.frame(id=names(z), values=unname(z), stringsAsFactors=FALSE)   
write.table(df_final[1:30,],sep="\t",file=paste0(file,"_quantile"),row.names = FALSE,append=FALSE,quote=FALSE)
