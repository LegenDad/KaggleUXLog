system.time(source("nthread4.R"))
#user  system elapsed
#187.868  17.628  67.054
#Time difference of 1.072269 mins
# Time difference of 4.555502 mins
# 
system.time(source("nthread8.R"))
#user  system elapsed
#278.416   7.680  48.818
#Time difference of 3.534013 mins
#ing 1e6 ; Time difference of 6.418927 mins
# 1.31664 min
system.time(source("nthread10.R"))
#user    system   elapsed
#15157.904    56.572  3560.605

system.time(source("nthread16.R"))
#user    system   elapsed
#16949.148    79.680  2780.596

system.time(source("nthread20.R")) #giveup
system.time(source("nthread40.R")) #giveup



