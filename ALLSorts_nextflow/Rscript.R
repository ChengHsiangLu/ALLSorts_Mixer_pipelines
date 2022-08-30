library(dplyr)
library(stringr)

args = commandArgs()

# gtf=read.table(args[6],sep="\t",header = F)
# gtf$gene_id = stringr::str_extract(string = gtf$V9, pattern = "ENSG[0-9,.]*")
# gtf$gene_name = stringr::str_extract(string = (gtf$V9), pattern = "gene_name\ [A-Z,a-z,0-9,.,-]*") %>% gsub("gene_name ","",.)
# gtf1 = gtf %>% dplyr::select(gene_id,gene_name) %>% distinct()
gtf1 = read.table(args[6],sep=",")#'/home/ec2-user/mynextflow/gtf1.txt' or args[6]

# df = read.table(args[7],sep="\t", header=T) %>% dplyr::select(Name)
df = read.table(args[7],sep=",")#'/home/ec2-user/mynextflow/df.txt' or args[7]

#CPM00004614-BM-R_20220217_RNASEQ_Clinical1.0_dragen.quant.genes.sf or args[8]
#print(args[8])
df1 = read.table(args[8],sep="\t", header=T) %>% dplyr::select(NumReads) 
colnames(df1)=gsub("_RNASEQ_Clinical1.0_dragen.quant.genes.sf","",basename(args[8]))
df = cbind(df,df1)

c1 = df %>% left_join(gtf1, by=c("Name"="gene_id")) %>% dplyr::select(-Name)
#dim(c1)
c1=c1[!duplicated(c1$gene_name),]
c1=c1[!is.na(c1$gene_name),]
c1=c1[c1$gene_name!="",]
c2=c1[,c(dim(c1)[2],grep("M",colnames(c1)))]
rownames(c2)=c2$gene_name
c2 = c2 %>% dplyr::select(-gene_name)
c2=as.data.frame(t(as.matrix(c2)))
write.table(c2,args[9],quote=FALSE,sep=",")#counts.csv or args[9]
