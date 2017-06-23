rm(list=ls())

library(dplyr)
library(readr)
vegStr <- read_csv("~/Documents/PhD/Projects/PythonNEON/inputs/insitu/vegStr.csv")
foliarChem <- read_csv("~/Documents/PhD/Projects/PythonNEON/inputs/insitu/foliarChem.csv")
link <- read_csv("~/Documents/PhD/Projects/PythonNEON/inputs/insitu/link.csv")
linked_str = inner_join(link, vegStr, by="tagID")
vegData = inner_join(foliarChem, linked_str, by="Individual")
write_csv(vegData, '../inputs/insitu/vegData.csv')

