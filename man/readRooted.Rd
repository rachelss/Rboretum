% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/readRooted.R
\name{readRooted}
\alias{readRooted}
\title{Rboretum Rooted Tree Reader}
\usage{
readRooted(to_root, root_taxa, tree_names, dummy_names, prefix, suffix)
}
\arguments{
\item{to_root}{Where to find tree files. Options include:
\itemize{
  \item A character vector of one or more tree file paths
  \item A path to a single directory containing all tree files
}}

\item{root_taxa}{Character vector containing outgroup species IDs (Must be in tree(s) and monophyletic)}

\item{tree_names}{OPTIONAL: If multiple tree paths are provided, a character vector of names to assign to trees. Length must equal the number of trees. [Default: Trees will be autonamed based on the filename]}

\item{dummy_names}{OPTIONAL: If TRUE, and multiple tree paths are provdied, trees will be named with placeholder names (e.g. Tree_1, Tree_2, etc.) [Default: Trees will be autonamed based on the filename]}

\item{prefix}{OPTIONAL: If 'to_root' is a directory, provide a character vector of file prefixes (e.g. all trees start with "RAxML")}

\item{suffix}{OPTIONAL: If 'to_root' is a directory, provide a character vector of file suffixes (e.g. all trees end with ".nwk")}
}
\value{
A phylo object, rooted at specified taxa, or a named, rooted multiPhlyo
}
\description{
This function simultaenously reads in and roots one or more trees at a common root clade
}
\examples{
# Read in one tree
root_taxa = c('Species_1','Species_2')
myTree <- readRooted('/path/to/tree.nwk',root_taxa)

# Read in multiple trees
tree_paths <- c('/path/to/tree1.nwk','/path/to/tree2.nwk')
tree_names <- c('Tree1','Tree2')
myTrees <- readRooted(tree_paths,root_taxa,tree_names=tree_names)

# Read all trees from a directory
myTrees <- readRooted('/path/to/tree/dir/',root_taxa) # Trees will be named based off their filenames

# Read all .nwk files from a directory
myTrees <- readRooted('/path/to/tree/dir/',root_taxa,suffix=".nwk") # Trees will be named based off their filenames

}
