
#Loading Packages

library(epidemics)
library(socialmixr)
library(tidyverse)

# Building an SEIRV MODEL

burkina_fasso_ppn <- 23.5e6
burkina_fasso_obj <- epidemics::population(
  name="Burkina Fasso",
  demography_vector = burkina_fasso_ppn,
  contact_matrix = matrix(1.0),
  initial_conditions = matrix(
    c(1-1/burkina_fasso_ppn,#S initial value, 
      0,# E initial value
      1/burkina_fasso_ppn,#I initial value
      0,# R initial value
      0 # V initial value
  ),
  nrow = 1,
  col = 5
)
)

# Run the following code in console to check for initial conditions
burkina_fasso_obj$initial_conditions

# running the model
simple_model <- epidemics::model_default(
  population = burkina_fasso_obj,
  recovery_rate = 1/5,# recovery gamma is 5days so recovery rate is 1/5
  transmission_rate = 9/5,# we are given tha RO IS 9, R0 =BETA/GAMA,Beta=R0*gamma,Beta= 1/5*9
  infectiousness_rate = 1/8,
  time_end = 120,
  increment = 1
)

#View the model

View(simple_model)

#plotting the model for visualisation

simple_model %>% 
  ggplot(aes(x=time,y=value, col=compartment)
         )+
geom_line()

# Building an SEIRV MODEL for a heterogenous population

bf_ppn <- burkina_fasso_ppn*c(0.44,0.195,0.29,0.05,0.025)# inputing the % of diff ppn groups
 
socialmixr::list_surveys() 

bf_survey <- socialmixr::get_survey("https://doi.org/10.5281/zenodo.13101862")

bf_contact_data <- socialmixr::contact_matrix(
  survey = bf_survey,
  countries = "Gambia",
  age.limits =c(0,15,25,55,65)
 )

bf_contact_data$participants

bf_contact_data$matrix

bf_contact_matrix <- bf_contact_data$matrix

#transpose the data to make sure it aligns with epidemics library

bf_contact_matrix <- t(bf_contact_data$matrix)

names(bf_ppn)=row.names(bf_contact_matrix)
initial_conditions=c(S=1-1/1e6,E=0,I=1/1e6,R=0,V=0)
#creating a matrix for 5 groups
initial_conditions_matrix <- rbind(initial_conditions,initial_conditions,initial_conditions,
                                   initial_conditions,initial_conditions)

#create age structured population objects
bf_ppn_group_obj <- epidemics::population(
  name = "BF",
  demography_vector =bf_ppn,
  initial_conditions = initial_conditions_matrix,
  contact_matrix = bf_contact_matrix

)

#create age structure model
base_line_model <- epidemics::model_default(
  population = bf_ppn_group_obj,
  infectiousness_rate = 1/8,
  recovery_rate = 1/5,
  transmission_rate = 9/5,
  time_end = 120,
  increment = 1)
#view baseline model
View(base_line_model)

#plotting the baseline mode
base_line_model %>% 
ggplot(aes(x=time,y=value,col=compartment,linetype = demography_group))+
         geom_line(linewidth=1.2)+
  theme_bw()+
  labs(x="Time in days",y="Cases",title="Baseline Model")

#Creating an intervention,vaccine roll out
vaccine_roll_oUT<- epidemics::vaccination(
  name = "vaccine rollout",
  time_begin = matrix(c(25,25,24,20,15),nrow=5,ncol = 1),# if different begin time for the different 5 age groups
  time_end = matrix(25 + 50,nrow(bf_contact_matrix)),
  nu=matrix(c(0.5,0.1,0.1,0,0)) # vaccination % for each age group
)

#create model with vaccine
vaccine_model <- epidemics::model_default(
  population = bf_ppn_group_obj,
  time_end = 120,
  increment = 1,
  recovery_rate = 1/5,
  infectiousness_rate = 1/8,
  transmission_rate = 9/5,
  vaccination = vaccine_roll_oUT
)
#view the vaccine model

View(vaccine_model)

#Plotting the model
vaccine_model %>% 
  ggplot(aes(x=time,y=value,col=compartment,linetype = demography_group))+
  geom_line(linewidth=1.5)+
  theme_bw()+
  labs(x="Time in days",y="Number of Cases",title="Vaccination Model")

# Calculate  new infections

baseline_data <- epidemics::new_infections(
  base_line_model,by_group = FALSE)
baseline_data$scenario<-"Baseline"
View(baseline_data)

vaccine_data <- epidemics::new_infections(
  vaccine_model,
  by_group = FALSE,
)
#if you have 2 dataframes ,these can be merged
vaccine_data$scenario <- "Vaccine"
baseline_vaccine_combined<- rbind(baseline_data,vaccine_data)

#view baseline data and vaccine data combined

view(baseline_vaccine_combined)


# view plots of combined

baseline_vaccine_combined %>%
  ggplot(aes(
    x= time,
    y= new_infections,
    col= scenario
  ))+ geom_line()


#Create a mask interention
mask<- epidemics::intervention(
  name = "mask",
  time_begin = 30,
  time_end = 30+60,
  reduction = 0.3,
  type = "rate" ) #what are you reducing,rate/contact time/etc

#view mask
view(mask)

mask_model<- epidemics::model_default(
  population = bf_ppn_group_obj,
  recovery_rate = 1/5,
  transmission_rate = 9/5,
  infectiousness_rate = 1/8,
  intervention = list(transmission_rate=mask),
  time_end = 120,
  increment = 1
)
#################
# evaluating the effectiveness of the mask intervention
#calculate new infections from mask model

mask_data <- epidemics::new_infections(
  mask_model,by_group = FALSE
)
 
View(mask_data)
  
#add a new column mask-data dataframe
mask_data$scenario <- "Mask"

#combine mask data and baseline data to compare and assess the effect of mask intervention

baseline_mask_combined<- rbind(
  baseline_data,
  mask_data
)
 view(baseline_mask_combined) 
  
# Plotting graphs to compare the effect on new infections 
 
 baseline_mask_combined %>%
   ggplot(aes(
     x= time,
     y= new_infections,
     col= scenario
   ))+ geom_line(
     linewidth=1.5
   )

  
  
  
  
  
  