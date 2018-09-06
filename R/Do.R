# Author:Sifan Liu
# Date: Tue Sep  4 10:33:37 2018
# --------------
pkgs <- c('dplyr')
check <- sapply(pkgs,require,warn.conflicts = TRUE,character.only = TRUE)
if(any(!check)){
  pkgs.missing <- pkgs[!check]
  install.packages(pkgs.missing)
  check <- sapply(pkgs.missing,require,warn.conflicts = TRUE,character.only = TRUE)
}


# define entre

startup <- c("fashion","food","technology","design","games")



union_summary <- union_merge %>% 
  mutate(startup = ifelse(category %in% startup,1,0),
         success = ifelse(state.x == "successful", 1,0)) %>%
  group_by(startup, success) %>%
  summarise(total.pledged = sum(pledged, na.rm = TRUE),
            mean.pledged = mean(pledged, na.rm = TRUE),
            median.pledged = median(pledged, na.rm = TRUE),
            count = n())

union_msa <- union_merge %>% 
  filter(state.x == "successful") %>%
  mutate(startup = ifelse(category %in% startup,1,0)) %>%
  group_by(startup) %>%
  mutate(total.pledged = sum(pledged, na.rm = TRUE)) %>%
  ungroup() %>% group_by(cbsa, cbsaname15) %>%
  mutate(pop10 = sum(as.numeric(as.character(pop10)), na.rm = TRUE))%>%
  group_by(cbsa, cbsaname15, pop10, total.pledged, startup, success) %>%
  summarise(pledged = sum(pledged, na.rm = TRUE),
            count = n(),
            backers = sum(backers_count, na.rm = TRUE)) %>%
  mutate(pledged.share = pledged/total.pledged, 
         pledged.percap = pledged/pop10,
         count.percap = count/pop10)

write.csv(union_msa, "union_msa.csv")

# ====

VC <- read.csv("../source/pitchbook_msa.csv") %>%
mutate(VC_value = rowSums(.[3:8], na.rm = TRUE),
       cbsa = as.character(cbsa13)) %>% 
  select(-contains("X")) %>%
  filter(!is.na(cbsa13))
# I5hgc <- read.csv("analysis/source/I5HGC_density.csv")
I5hgc <- read.csv("../source/I5HGC_density.csv") %>%
  mutate(cbsa = as.character(CBSA))

union_msa_startup <- union_msa %>%
  filter(startup==1) %>%
  left_join(VC, by = "cbsa") %>%
  left_join(I5hgc, by = "cbsa") %>%
  mutate(r_KS_VC = pledged/VC_value,
         pc_VC_value = VC_value/pop10)

ggplot(data = union_msa_startup %>% filter(!is.na(I5HGC_Density)), 
       aes(log(count.percap), log(I5HGC_Density), color = Size_Category))+
  geom_point()+
  geom_smooth(method = lm)+
  ggtitle("Number of high growth firms and Kickstarter projects, 2010 - 2016")+
  facet_wrap(~Size_Category)
            
ggplot(data = union_msa_startup %>% filter(!is.na(VC_value)), 
       aes(log(pc_pledged), log(pc_VC_value)))+
  geom_point()+
  geom_smooth(method = lm)+
  # geom_rect(xmin = 11, xmax = 14, ymin = 5,ymax = 12, alpha = 0, color = "red")+
  ggtitle("Total VC and total pledged amount on Kickstarter, by size of metro, 2010 - 2015") +
  # scale_color_brewer(palette = "Set1", 
                     # name = "2016 population",
                     # labels = c(" < 250 k", "250 k - 1 m", " > 1m"))+
  theme_minimal()

GGally::ggpairs(union_msa_startup %>% ungroup() %>% 
                  select(pledged,count,backers,VC_value,
                         pledged.percap,count.percap,I5HGC_Density,pc_VC_value) %>%
                  mutate(lg_VC = log(VC_value),
                         lg_pledged = log(pledged)))

write.csv(union_msa_startup, "union_msa_startup.csv")

# bubble_map(df_i5hgc, "I5HGC_Density", "pc_success_pledged")