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
  ) %>% 
  #PRINT REPORT
  cleanepi::print_report()
  
#viewing cleaned data 
view(cleaned_data)































