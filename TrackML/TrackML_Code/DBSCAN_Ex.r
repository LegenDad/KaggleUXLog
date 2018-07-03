# Ref : https://github.com/mhahsler/dbscan

install.packages("dbscan")
library("dbscan")

data("iris")
x <- as.matrix(iris[, 1:4])
x
db <- dbscan(x, eps = .4, minPts = 4)
db

pairs(x, col = db$cluster + 1L)

lof <- lof(x, k = 4)
pairs(x, cex = lof)

opt <- optics(x, eps = 1, minPts = 4)
opt

opt <- extractDBSCAN(opt, eps_cl = .4)
plot(opt)

opt <- extractXi(opt, xi = .05)
opt
plot(opt)

hdb <- hdbscan(x, minPts = 4)
hdb

plot(hdb, show_flat = T)

colors <- mapply(function(col, i) adjustcolor(col, alpha.f = hdb$membership_prob[i]), 
                 palette()[hdb$cluster+1], seq_along(hdb$cluster))
plot(x, col=colors, pch=20)
