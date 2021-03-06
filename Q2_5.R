# EE232E Homework 4 Question 2-5

# clearing workspace
closeAllConnections()
rm(list=ls())

library('igraph')
library('readr')

############## Question 2 ##############
cat("\n \n ############## Question 2 ############## \n")

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
  co_data_close = read.csv(fname_co,stringsAsFactors = FALSE)$Close #get all closing data
  
  r_i_local = numeric(0) # clear variable
  
  for (j in 2:length(co_data_close)){
    r_i_local[j-1] = log(co_data_close[j]) - log(co_data_close[j-1])  #r_i formula
  }
    
  r_i_mat[[row_count,1]] = i
  r_i_mat[[row_count,2]] = r_i_local
  }

edge_count = 0
count = 1
tot_d_ij = numeric()
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
    d_ij = sqrt(2*(1-P_ij))
    
    tot_d_ij = c(tot_d_ij , d_ij)
    P.data[edge_count,1] = co_names[i] # store to data.frame
    P.data[edge_count,2] = co_names[j]
    P.data[edge_count,3] = d_ij
  }
}

g1 = graph.data.frame(P.data,directed = FALSE)

cat("Number of nodes in the network: ",length(V(g1)),"\n")
cat("Number of edges in the network: ",length(E(g1)),"\n")

hist( x= tot_d_ij, breaks = seq(from = min(tot_d_ij), to = max(tot_d_ij), by = (max(tot_d_ij)-min(tot_d_ij))/50), 
      main = "Histogram of d_ij's", xlab = "d_ij Value", ylab = "Frequency")


############## Question 3 ##############
cat("\n \n ############## Question 3 ############## \n")

nodes = V(g1)$name # vector of all nodes
sectors = ticker$Sector # vector of all sectors 
u_sectors = unique(sectors)

node_cols = rep(0,length(nodes))
col_id = 1
for(i in u_sectors){
  node_cols[which(sectors == i)] = col_id #identify colors to unique sectors
  col_id = col_id + 1
}

g1_mst = mst(g1 , weights = P.data$weights) # create minimal spanning tree

cat("Number of nodes in the network: ",length(V(g1_mst)),"\n") # as a sanity check
cat("Number of edges in the network: ",length(E(g1_mst)),"\n")

plot(g1, vertex.color = node_cols,
     vertex.size = rep(7,length(nodes)),
     vertex.label = NA,
     main = "Correlations Graph" ) # correlation graph

plot(g1_mst, vertex.color = node_cols ,
     vertex.size = rep(7,length(nodes)) , 
     vertex.label = NA, 
     main = "Minimal Spanning Tree" ) # mst

############## Question 4 ##############
cat("\n \n ############## Question 4 ############## \n")

alpha = numeric()
random_sector = numeric()
for(i in u_sectors){
  u_sec_nodes = nodes[which(sectors == i)] # all nodes in sector
  tot_prob = 0
  for(j in u_sec_nodes){
    temp_neigh = as.vector(neighbors(g1_mst , j , mode = "all")) # return neighbors node IDs
    j_node_id = which(j == nodes) # find id of jth node
    num_same_sec = length(which(sectors[temp_neigh] == sectors[j_node_id])) # number of neighbors in same sector
    temp_prob = num_same_sec / length(temp_neigh) # ratio of neighbors in the same sector vs tot neighbors
    tot_prob = tot_prob + temp_prob # running sum
  }
  alpha = c(alpha , tot_prob/length(u_sec_nodes))
  random_sector = c(random_sector,length(u_sec_nodes)/length(nodes)) #ratio of num nodes in sector i vs total nodes in graph 
}

sector_clustering_results = cbind(alpha,random_sector) # VIEW THIS VARIABLE IN THE ENVIRONMENT TO SEE RESULTS
rownames(sector_clustering_results) = u_sectors
colnames(sector_clustering_results) = c("Alpha","Random Sector")

############## Question 5 ##############
cat("\n \n ############## Question 5 ############## \n")
g1_mst_dir = as.directed(g1_mst, 'mutual')
g1_double_mst = as.undirected(g1_mst_dir, 'each' )

el = get.edgelist(g1_double_mst)
v3 = as.vector(E(g1_double_mst)$weights)
out = cbind(el, v3)

#Exporting the graph to python to fine Euler Tour
write.csv(out, file = "double_mst.csv",row.namames=FALSE)

#Read in the results from python
tsp_python = read.table('tsp.txt')
tsp_path_names = as.vector(tsp_python[,1])

node_names = V(g1)$name
tsp_path_idx = numeric()
for(i in 1:length(tsp_path_names)){
  matches = which(tsp_path_names[i] == node_names)
  tsp_path_idx = c(tsp_path_idx,matches)
}

adjacency_matrix = get.adjacency(g1, attr = 'weights',sparse = FALSE, names = FALSE)

#Calculate weight of travelling salesman path
tsp_weight = 0
for(i in 2:length(tsp_path_idx)){
  tsp_weight = tsp_weight + adjacency_matrix[tsp_path_idx[i],tsp_path_idx[i-1]]
}

lower_bound = sum(E(g1_mst)$weights)
upper_bound = sum(E(g1_double_mst)$weights)

cat("Sum of weights of min spanning tree: ",lower_bound,"\n")
cat("Sum of weights of double min spanning tree: ",upper_bound,"\n")
cat("Sum of edge weights of TSP solution: ", tsp_weight,"\n")