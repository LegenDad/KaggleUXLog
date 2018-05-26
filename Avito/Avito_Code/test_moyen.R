library(data.table)
files <- list.files("../SubM")
sub1 <- fread(paste0("../SubM/",files[1]))
sub2 <- fread(paste0("../SubM/",files[2]))
head(sub2)

sub2[,'deal_probability':= (sub1[,'deal_probability']+sub2[,'deal_probability'])/2]
sub1[,'deal_probability':= (sub1[,'deal_probability']+sub2[,'deal_probability'])/2]
sub2[,'deal_probability':= (sub1[,'deal_probability']+sub2[,'deal_probability'])/2]
sub1[,'deal_probability':= (sub1[,'deal_probability']+sub2[,'deal_probability'])/2]
sub2[,'deal_probability':= (sub1[,'deal_probability']+sub2[,'deal_probability'])/2]
sub1[,'deal_probability':= (sub1[,'deal_probability']+sub2[,'deal_probability'])/2]

fwrite(sub1, "../SubM/bagging1.csv")
fwrite(sub2, "../SubM/bagging2.csv")
