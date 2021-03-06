#' Rboretum Unique Topology Fetcher
#' 
#' This function takes a multiPhylo where all trees share 3 or more taxa, and returns the unique topologies after pruning to a common set of taxa
#' @param trees Named, rooted multiPhylo object where all trees share at least three taxa
#' @param print_table OPTIONAL: If TRUE, return trees, and print summary table
#' @param return_table OPTIONAL: If TRUE, return summary table rather than multiPhylo
#' @return multiPhylo containing unique topologies
#' @export

getUniqueTopologies <- function(trees,print_table,return_table){
  
  if(!Rboretum::isMultiPhylo(trees,check_rooted = TRUE,check_named = TRUE,check_three_taxa = TRUE)){
    stop("'trees' must be a named, rooted multiPhylo object where all trees share at least three taxa.")
  } else if(Rboretum::isMultiPhylo(trees,check_all_equal = TRUE)){ # One unique tree, return first
    print("Note: All trees have the same topology. Returning first tree...")
    return(trees[[1]])
  } else if(Rboretum::isMultiPhylo(trees,check_all_unique = TRUE)){ # Trees are already unique
    return(trees)
  }
  
  if(missing(print_table)){
    print_table <- FALSE
  } else if(!is.logical(print_table)){
    print_table <- FALSE
  }
  
  if(missing(return_table)){
    return_table <- FALSE
  } else if(!is.logical(return_table)){
    return_table <- FALSE
  }
  
  tree_taxa <- Rboretum::getSharedTaxa(trees)
  
  if(!Rboretum::isMultiPhylo(trees,check_all_taxa = TRUE)){ # Trim to common taxa 
    trees <- Rboretum::treeTrimmer(trees,tree_taxa)
  }
  
  raw_tree_count <- length(trees)
  raw_tree_names <- names(trees)
  
  # Compare all tree topologies
  tree_a <- c()
  tree_b <- c()
  top_check <- c()
  
  for(i in 1:(raw_tree_count-1)){
    for(j in (i+1):raw_tree_count){
      tree_a <- c(tree_a,raw_tree_names[[i]])
      tree_b <- c(tree_b,raw_tree_names[[j]])
      top_check <- c(top_check,ape::all.equal.phylo(trees[[i]],trees[[j]],use.edge.length = FALSE))
    }
  }
  
  tree_compare <- data.frame(Tree_1=tree_a,Tree_2=tree_b,Same_Topology=top_check,stringsAsFactors = FALSE) %>% filter(Same_Topology)
  
  tree_groups <- list()
  grouped_trees <- c()
  rep_trees <- c()
  
  for(i in 1:raw_tree_count){
    
    next_pos <- length(tree_groups) + 1
    
    focal_tree <- raw_tree_names[[i]]
    if(!focal_tree %in% grouped_trees){
      
      rep_trees <- c(rep_trees,i)
      
      tree_group <- tree_compare %>% filter(Tree_1 == focal_tree | Tree_2 == focal_tree)
      
      if(nrow(tree_group)==0){
        tree_groups[[next_pos]] <- focal_tree
        grouped_trees <- c(grouped_trees,focal_tree) %>% unique() %>% sort()
      }
      else{
        tree_groups[[next_pos]] <- as.vector(as.matrix(tree_compare[,c("Tree_1", "Tree_2")])) %>% unique() %>% sort()
        grouped_trees <- c(grouped_trees,as.vector(as.matrix(tree_compare[,c("Tree_1", "Tree_2")])) %>% unique() %>% sort()) %>% unique() %>% sort()
      }
    }
  }
  
  unique_trees_unsorted <- purrr::map(.x = rep_trees,.f = function(x){trees[[x]]})
  class(unique_trees_unsorted) <- 'multiPhylo'
  
  tree_coords <- 1:length(tree_groups)
  top_count <- purrr::map(.x = tree_coords, .f = function(x){length(tree_groups[[x]])}) %>% unlist() %>% as.integer()
  top_trees <- purrr::map(.x = tree_coords, .f = function(x){paste(tree_groups[[x]],collapse = ";")}) %>% unlist() %>% as.character()
  
  tree_sorter <- data.frame(Tree_ID = as.integer(tree_coords),
                            Tree_Count = as.integer(top_count),
                            Tree_Name = as.character(top_trees),stringsAsFactors = FALSE) %>%
    arrange(desc(Tree_Count),Tree_Name) %>%
    pull(Tree_ID) %>%
    as.integer()
  
  unique_trees <- unique_trees_unsorted[tree_sorter]
  names(unique_trees) <- purrr::map(.x=1:length(tree_groups),.f=function(x){paste(c("Topology",x),collapse = '_')})
  top_count <- top_count[tree_sorter]
  top_trees <- top_trees[tree_sorter]
  
  summary_df <- data.frame(Tree_Name = names(unique_trees),
                           Trees_with_Topology = as.character(top_trees),
                           Tree_Count = as.integer(top_count),
                           Tree_Percent = round((top_count/as.numeric(raw_tree_count)*100),1),stringsAsFactors = FALSE)
  if(print_table){
    print(summary_df)
  }
  
  if(return_table){
    return(summary_df)
  } else{
    return(unique_trees)
  }
}