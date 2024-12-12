
######Accessing delay distribution using epi_parameter######

#AIM: Access to COVID 19 generation
library(tidyverse) #to use the %>%  operation

#To access all related databases

epiparameter::epiparameter_db(epi_name = "generation")
epiparameter::epiparameter_db(
  disease = "covid",
  epi_name = "serial"
) %>% 
  epiparameter::parameter_tbl()

#to access a specific dataset of the suggested in the earlier code
epiparameter::epiparameter_db(epi_name = "generation")
covid_serialint<-epiparameter::epiparameter_db(
  disease = "covid",
  epi_name = "serial",
  single_epiparameter = TRUE)
#subset = sample_size==131)

#or add the line below foe the most ideal data inplace of subset that is specific
  single_epiparameter = TRUE
  
#if you want to be free,look for all the content using the str()
str(covid_serialint)

#Get summary statistics value
covid_serialint$summary_stats
covid_serialint$summary_stats$mean
covid_serialint$summary_stats$sd

#Plot
covid_serial_params<-covid_serialint %>% 
  plot()
  epiparameter::get_parameters()


#Get specific parametrers
covid_serial_params["meanlog"]

#get access to sdlog
epiparameter::epiparameter_db(
  disease = "covid",
  epi_name = "serial") %>% 
  epiparameter::parameter_tbl()
  
  
  #aim: create a gamma distribution with mean=4 and sd=2 for COVID-19 serial interval
EpiNow2::Gamma(mean = covid_serialint$summary_stats$mean,
               sd=covid_serialint$summary_stats$sd,
               max=15)

#AIM: CREATE lognormal distribution with mean=4,sd=2, for COVID-19 serial interval
covid_serial_logndist<-EpiNow2::LogNormal(mean = covid_serialint$summary_stats$mean,
                                          sd=covid_serialint$summary_stats$sd,
                                          max=15)
plot(covid_serial_logndist)



#reporting delays

covid_reporting_delay<- EpiNow2::Gamma(
  mean = EpiNow2::Normal(
    mean=4,sd=0.5),
    sd=EpiNow2::Normal(
      mean=2,
      sd=0.5),
  max=15)
  
  
plot(covid_reporting_delay)

##uncertainty distribution for reporting delay

library(tidyverse)
cases <- incidence2::covidregionaldataUK %>%
  as_tibble() %>% 
  # use {tidyr} to preprocess missing values
  tidyr::replace_na(base::list(cases_new = 0)) %>%
  # use {incidence2} to compute the daily incidence
  incidence2::incidence(
    date_index = "date",
    counts = "cases_new",
    count_values_to = "confirm",
    date_names_to = "date",
    complete_dates = TRUE
  ) %>%
  dplyr::select(-count_variable)

#view cases
cases


#to increase speed, increase number of cores to run in parallel
withr::local_options(list(mc.cores=4)) 

#Estimating Rt
EpiNow2::epinow(
# with slice_head we keep the first 90 rows of the dataframe  
  data = cases %>% dplyr::slice_head(n=90),
  generation_time = EpiNow2::generation_time_opts(covid_serial_logndist),
  delays = EpiNow2::delay_opts(covid_reporting_delay),
  stan = EpiNow2::stan_opts(samples = 1000,chains=3)
)

#to get the incubation period for COVID 19
epiparameter::epiparameter_db(
  disease = "covid",
  epi_name = "incubation",
  single_epiparameter=TRUE
)
  
 # create a log distribution for incubation
covid_incubation<-epiparameter::epiparameter_db(
  disease = "covid",
  epi_name = 
)
covid_incubation_params<- epiparameter::get_parameters(
  covid_incubation
)
# Plot the epiparameter object to estimate the max value
plot(covid_incubation)

covid_incubation_distr<- EpiNow2::LogNormal(
  meanlog = covid_incubation_params["meanlog"],
  sdlog = covid_incubation_params["sdlog"],
  max=20
  
)

#estimating Rt
estimates <- EpiNow2::epinow(
  data=cases,
  generation_time = EpiNow2::generation_time_opts(covid_serial_logndist),
  delays = EpiNow2::delay_opts(covid_reporting_delay+covid_incubation_distr),
  stan = EpiNow2::stan_opts(samples = 1000,chain=3))
  
                  

plot(estimates)


