library(cleanepi)
data<- read_csv(
  here::here("data","simulated_ebola_2.csv")
)

#View data
View(data)

#viewing names of the columns
names(data)

#Clean column names
data %>% 
  cleanepi::standardize_column_names()

cleaned_data<- data %>% 
  cleanepi::standardize_column_names()

view(cleaned_data)

#Renaming columns
cleaned_data<- data %>% 
  cleanepi::standardize_column_names() %>% 
  cleanepi::standardize_column_names(
    rename = c("index"= "x1")) %>% 
  #remove constraints,1 means 100% entries of the col are the same
  cleanepi::remove_constants(cutoff = 1) %>% 
  #remove duplicates
  cleanepi::remove_duplicates() %>% 
  #replace missing values
  cleanepi::replace_missing_values(
    na_strings = "") %>% 
  cleanepi::convert_to_numeric(target_columns = "age") %>% 
  cleanepi::standardize_dates(
    target_columns = c("date_onset","date_sample"),
    timeframe = c(as.Date("2014-01-01"), as.Date("2016-12-30"))
  ) 

####Incidence###

#create an incidence object from the cleaned linelist

df_incid<- incidence2::incidence(
  cleaned_data,
  date_index = "date_onset",
  interval = 1,
  groups = "status"
)
#view to see if data is now the data with the same  date_on_onset is grouped together
#also grouped by status,suspected,confirmed and NA
#Interval is 1,each date will be a standalon,when interval is 7,a range with 7 interval is created
  view(df_incid)
  
# plotting the incidence
  plot(df_incid)

  
#plotting using ggplot
library(dplyr)
  library(ggplot2)
  
  df_incid %>%   
    ggplot() +
    geom_col(
      mapping = aes(
        x = date_index,
        y = count,
        col= status  # Remove quotes around "status"
      )
     
    ) +
    labs(                  # Use labs() instead of labels()
      x = "Time since onset",
      y = "Number of cases"
    ) +
    theme_bw()
  
  
  