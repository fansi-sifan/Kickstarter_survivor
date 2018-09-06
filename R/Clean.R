load("union.Rda")

# check
cat <- union %>% 
  filter(state != "live") %>%
  group_by(success, category) %>%
  summarize(count = n(),
            mean_goal = mean(goal, na.rm = TRUE),
            mean_pledged = mean(pledged, na.rm = TRUE),
            mean_backers_count = mean(backers_count, na.rm = TRUE),
            median_goal = median(goal, na.rm = TRUE),
            median_pledged = median(pledged, na.rm = TRUE),
            median_backers_count = median(backers_count, na.rm = TRUE))

# match place to counties
xwalk = read.csv("../source/place2county.csv")
place2cty <- xwalk %>% group_by(placefp14, placenm14) %>%
  top_n(1,pop10) %>%
  separate(placenm14,"place","\\s(\\b[a-z]|CDP)") %>%
  separate(place,"place","-") %>%
  dplyr::rename(location_state = stab) %>%
  
  
  
  union <- union %>%
  separate(location_name,"place",",")

union_unmatched <- union %>% 
  filter(location_country=="US") %>%
  left_join(place2cty, by = c("location_state","place")) %>%
  filter(is.na(pop10)) %>%
  select(contains("location"),place) %>%
  group_by(place,location_state) %>%
  summarise(count = n()) %>%
  filter(count>1)

union_unmatched$address <-paste(union_unmatched$place, union_unmatched$location_state, sep = ",")

# union_unmatched_2 <- union_unmatched %>% filter(is.na(FIPS))
# union_unmatched_2$FIPS <- sapply(union_unmatched_2$address,add2FIPS)
# union_unmatched <- bind_rows(union_unmatched %>% filter(!is.na(FIPS)),union_unmatched_2)

# merge back
union_merge <- union %>% 
  filter(location_country=="US") %>%
  left_join(place2cty, by = c("location_state","place")) %>%
  left_join(union_unmatched, by = c("location_state","place"))

union_merge$FIPS <- ifelse(is.na(union_merge$county14),union_merge$FIPS,padz(union_merge$county14,5))

cty2msa <- read.csv("../source/county2msa.csv")

union_merge <- union_merge %>%
  select(-state.y, - placefp, -placefp14, -cntyname2,-county14,-afact,-pop10,-address,-placenm) %>%
  left_join(cty2msa, by = c("FIPS"="county"))

# unmatched address
save(union_merge, file = "union_place.Rda")
write.csv(union_unmatched, "address_map.csv")
write.csv()