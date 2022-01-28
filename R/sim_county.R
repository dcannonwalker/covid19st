# similarity function
#' Calculate the similarity metric between two event sequences
#' 
#' @param es1 Numeric vector of event levels for county 1
#' @param es2 Numeric vector of event levels for county 2
sim_county <- function(es1, es2) {
    es.sum = es1 + es2
    
    # coocurrence 
    cooc = (es1 * es2) != 0
    # union of event sequences
    union = (es1 + es2) != 0
    es1.rel = es1[cooc] / es.sum[cooc]
    es2.rel = es2[cooc] / es.sum[cooc]
    sum(1 - abs(es1.rel - es2.rel)) / sum(union)
}
