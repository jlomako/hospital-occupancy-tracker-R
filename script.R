########################################################################
# hospital occupancy tracker
# reads file from web, sorts/processes data, saves new data to csv, plots data

# renv::init()

# load packages
library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)


url <- "https://www.msss.gouv.qc.ca/professionnels/statistiques/documents/urgences/Releve_horaire_urgences_7jours.csv"

# read csv file with french characters
df <- read.csv(url, encoding = "latin1")

update <- as.Date(df$Mise_a_jour[1])
update_time <- df$Heure_de_l.extraction_.image.[1]

# select montreal hospitals
df <- df %>% select(etab = Nom_etablissement, hospital_name = Nom_installation, beds_total = Nombre_de_civieres_fonctionnelles, beds_occ = Nombre_de_civieres_occupees) %>%
  filter(str_detect(etab, "Montr|CHUM|CUSM|CHU Sainte-Justine")) %>%
  mutate(beds_total = as.numeric(beds_total), beds_occ = as.numeric(beds_occ)) %>% 
  select(hospital_name, beds_occ, beds_total)
# calculate total and add to df
df %>% summarise(sum(beds_total, na.rm=TRUE), sum(beds_occ, na.rm=TRUE)) -> total
df <- df %>% add_row(hospital_name = "Total", beds_occ = total[1,2], beds_total = total[1,1] ) %>%
  mutate(occupancy_rate = round(100*(beds_occ/beds_total)), Date = update) %>%
  select(Date, hospital_name, occupancy_rate)

# write row to csv
row <- df %>% pivot_wider(names_from=hospital_name, values_from=occupancy_rate)
# write.csv(row, file = "data/hospitals.csv", row.names = FALSE) # creates file, run only once!
write.table(row, "data/hospitals.csv", append = T, row.names = F, col.names = F, sep = ",")

# visualization

update_txt <- paste("\nlast update:", update, "at", update_time)
df %>% 
  filter(hospital_name != "Total") %>%
  filter(hospital_name != "Total Montréal") %>%
  mutate(occupancy_rate = ifelse(is.na(occupancy_rate), -0.01, occupancy_rate)) %>%
  ggplot(aes(x = reorder(hospital_name, occupancy_rate), y = occupancy_rate, fill = occupancy_rate)) +
  geom_col(position = "identity", size = 3, show.legend = F) +
  scale_y_continuous(expand = c(0,0)) + # gets rid of gap between y-axis and plot
  geom_text(aes(label = if_else(occupancy_rate < 0, "no data", NULL)), colour = "grey", size = 3, hjust = "inward", na.rm=T) +
  geom_text(aes(label = if_else(occupancy_rate >= 0 & occupancy_rate <= 49, paste0(occupancy_rate,"%"), NULL)), colour = "#595959", size = 3, hjust = -0.1, position = position_stack(vjust = 0), na.rm=T) +
  geom_text(aes(label = if_else(occupancy_rate > 49, paste0(occupancy_rate,"%"), NULL)), colour = "white", size = 3, hjust = -0.1, position = position_stack(vjust = 0), na.rm=T) +
  coord_flip() +
  scale_fill_distiller(palette = "YlOrRd", direction = 1, limits = c(0,max(df$occupancy_rate))) + 
  theme_minimal() +
  labs(x = NULL, y = NULL, caption = paste(update_txt)) +
  theme(panel.grid = element_blank(), axis.ticks.x = element_blank(), axis.text.x = element_blank())

#ggsave("img/today.png")
ggsave("img/today.jpeg")
