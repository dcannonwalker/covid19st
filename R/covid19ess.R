library(proxy)
library(dplyr)
load("data/saves/daily_window4_wide.rds")
source("R/sim_county.R")
counts <- covid.daily.window4 %>% select(starts_with("X"))

# can't have negative daily case count,
# but there's probably a better way to deal 
# with reporting errors (?)

counts[counts < 0] <- 0
counts[counts < 0]
counts <- as.matrix(counts)

# filter out counties with 0 cases in the entire window
# this should be done earlier in the data wrangling step
counts <- counts[rowSums(counts) != 0, ]
counts.small = counts[1:10, 1:10]
distance.matrix = proxy::simil(counts.small, method = sim_county)
test = proxy::pr_simil2dist(distance.matrix)
distance.matrix
# some distances are `NaN` because some counties have no events in common
cltest = hclust(distance.matrix, method = "ward.D2")

cut = cutree(cltest, k = 4)

aggregate(counts.small, by = list(cut), function(x) sum(scale(counts, scale = F)^2))
