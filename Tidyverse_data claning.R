
#Load the library tidyverse
library(tidyverse)

# Load the dataset

read.csv(here::here('data','linelist.csv'))

#Assign the cases to the data

cases<- readr::read_csv(here::here('data','linelist.csv'))
cases

#Counting number of outcomes

cases %>% #ctrl+shift+M to pipe
  dplyr::count(outcome)

#Changing the shape of the data to connect 
cases %>% #ctrl+shift+M to pipe
  dplyr::select(outcome) %>% # selecting the outcome column
  dplyr::count(outcome) %>% #count the values from the outtcome column
  tidyr::pivot_wider(names_from = outcome,values_from = n) %>% # rearranging from longer to wider
  cleanepi::standardize_column_names() %>% #standardise the column names to all lowercase
  dplyr::mutate(cfr_naive=death/(death+recover))# creating a new column cfr_naive
  
  #Assessing the reporting delay
cases %>% 
  dplyr::select(case_id,date_of_hospitalisation,date_of_onset) %>% 
  dplyr::mutate(reporting_delay = date_of_hospitalisation - date_of_onset) %>% 

#ggplt of reporting delay using histogram
ggplot(aes(x=reporting_delay))+
  geom_histogram(binwidth = 1)
  
  
  

  
  
  








