# EE232E Homework 4 Question 7

# clearing workspace
closeAllConnections()
rm(list=ls())

library('igraph')
library('readr')

############## Question 7 ##############
cat("\n \n ############## Question 7 ############## \n")

fname_ticker = "finance_data/Name_sector.csv"
ticker = read.csv(fname_ticker,stringsAsFactors = FALSE) 

co_names = ticker$Symbol

r_i_mat = matrix(list(),length(co_names),2)

P.data <- data.frame(A = character(),
                     B = character(), 
                     C = numeric(), 
                     stringsAsFactors=FALSE) 
colnames(P.data) = c("Node 1", "Node 2", "weights")


row_count = 0
for(i in co_names) { #loop through each company name
  
  row_count = row_count + 1
  cat("Processing processing" , row_count , "out of", length(co_names),"\n")
  fname_co = paste('finance_data/data/',i,'.csv',sep = "") #get directory of current company name
  co_data_close = read.csv(fname_co,stringsAsFactors = FALSE)$Close # get all closing data
  co_date = as.Date(read.csv(fname_co,stringsAsFactors = FALSE)$Date,'%Y-%m-%d') # get all dates of data
  
  if (is.na(co_date[1])) { # 2 formats of dates in the data files (check which one '%Y-%m-%d'  vs '%m/%d/%y')
    co_date = as.Date(read.csv(fname_co,stringsAsFactors = FALSE)$Date,'%m/%d/%y') # get all dates of data
  }
  
  mondays_idx = which(weekdays(as.Date(co_date,'%Y-%m-%d')) == "Monday") # find idx of all mondays
  monday_data = co_data_close[mondays_idx] # find closing value on monday
  
  r_i_local = numeric(0) # clear variable
  for (j in 2:length(monday_data)){
    r_i_local[j-1] = log(monday_data[j]) - log(monday_data[j-1])  #r_i formula
  }
  
  r_i_mat[[row_count,1]] = i
  r_i_mat[[row_count,2]] = r_i_local
}

edge_count = 0
count = 1
tot_d_ij = numeric()
tot_P_ij = numeric()
for( i in 1 : (length(co_names)-1) ) {
  cat("Creating Graph for Stock",count, "of",length(co_names),"\n")
  count = count + 1
  for( j in (i+1) : length(co_names) ){
    
    edge_count = edge_count + 1
    P_i = r_i_mat[[i,2]]
    P_j = r_i_mat[[j,2]]
    
    avg_i = mean(P_i) # <P_i>
    avg_j = mean(P_j)
    avg2_i = mean(P_i^2) # <P_i^2>
    avg2_j = mean(P_j^2)
    
    P_ij = (mean(P_i*P_j)  - avg_i * avg_j) / sqrt((avg2_j - avg_i^2) * (avg2_i - avg_j^2)) # P_ij formula
    tot_P_ij = c(tot_P_ij , P_ij) #un-modified P_ij's
    
    if(P_ij > 0.3){
      P_ij = -1 # modify P_ij
    }
    
    d_ij = sqrt(2*(1-P_ij)) # d_ij from modified P_ij
    
    tot_d_ij = c(tot_d_ij , d_ij)
    P.data[edge_count,1] = co_names[i] # store to data.frame
    P.data[edge_count,2] = co_names[j]
    P.data[edge_count,3] = d_ij
  }
}

g1 = graph.data.frame(P.data,directed = FALSE)

cat("Number of nodes in the network (Using only Monday data) : ",length(V(g1)),"\n")
cat("Number of edges in the network (Using only Monday data) : ",length(E(g1)),"\n")

# Hist of un-modified P_ij's 
hist( x= tot_P_ij, breaks = seq(from = min(tot_P_ij), to = max(tot_P_ij), by = (max(tot_P_ij)-min(tot_P_ij))/50), 
      main = "Histogram of Un-modified P_ij's (Using only Monday Data)", xlab = "d_ij Value", ylab = "Frequency")

# Hist of d_ij calculated from modified P_ij
hist( x= tot_d_ij, breaks = seq(from = min(tot_d_ij), to = max(tot_d_ij), by = (max(tot_d_ij)-min(tot_d_ij))/50), 
      main = "Histogram of Modified d_ij's (Using only Monday Data)", xlab = "d_ij Value", ylab = "Frequency")
