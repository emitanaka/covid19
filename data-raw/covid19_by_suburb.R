# The data have been compiled by Guardian Australia 
# https://www.theguardian.com/au

library(tidyverse)
# library(googlesheets4)
library(jsonlite)
library(here)

# sheets_deauth()

# df_updates <- read_sheet("1q5gdePANXci8enuiS4oHUJxcxC13d6bjMRSicakychE", sheet = "updates")
# df_age <- read_sheet("1q5gdePANXci8enuiS4oHUJxcxC13d6bjMRSicakychE", sheet = "age distribution")

# convert all to character so as not to get error
# in particular nsw has a count of "1-4". 
# this causes error when binding the rows 
df_loc_nsw <- fromJSON("https://interactive.guim.co.uk/covidfeeds/nsw.json") %>% 
  mutate_all(as.character)
df_loc_vic <- fromJSON("https://interactive.guim.co.uk/covidfeeds/victoria.json")  %>% 
  mutate_all(as.character)
df_loc_qld <- fromJSON("https://interactive.guim.co.uk/covidfeeds/queensland.json") %>% 
  mutate_all(as.character)
df_loc_wa <- fromJSON("https://interactive.guim.co.uk/covidfeeds/wa.json") %>% 
  mutate_all(as.character)

covid19_by_suburb_today <- bind_rows(mutate(df_loc_nsw, state = "NSW"),
          mutate(df_loc_vic, state = "VIC"),
          mutate(df_loc_qld, state = "QLD"),
          mutate(df_loc_wa, state = "WA")) %>% 
  mutate(scrapped = as.character(Sys.time()))

file_update <- here("data-raw", "covid19_by_suburb.csv")

covid19_by_suburb_past <- read_csv(file_update, col_types = list()) %>% 
  mutate_all(as.character)

covid19_by_suburb_combined <- bind_rows(covid19_by_suburb_past, 
                               covid19_by_suburb_today) 
  
write_csv(covid19_by_suburb_combined, 
          path = file_update)

covid19_by_suburb <- covid19_by_suburb_combined %>% 
  distinct(date, place, count, state)

usethis::use_data(covid19_by_suburb, overwrite = TRUE)
