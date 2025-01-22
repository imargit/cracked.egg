library(tidyverse)
library(jsonlite)
library(scales) 

# Cut-off value: At least this number of republicans or democrats have attended this university
cut_off = 10
# Cut-off value (%): There is at least this percentage MORE democrats/republicans (100% = same amount)
cut_off_surplus = 150

repu_df <- as.data.frame(fromJSON('Data/republican.json', flatten = TRUE)) |>
  pivot_longer(cols = everything(), names_to = 'Universities', values_to = 'Frequency')|>
  mutate(University = str_replace_all(Universities, '\\.',' ')) |>
  select(University,Frequency)

demo_df <- as.data.frame(fromJSON('Data/democrat.json', flatten = TRUE)) |>
  pivot_longer(cols = everything(), names_to = 'Universities', values_to = 'Frequency')|>
  mutate(University = str_replace_all(Universities, '\\.',' ')) |>
  select(University,Frequency)

merged_df <- merge(repu_df,demo_df, by = 'University') |>
  rename(repu_freq = Frequency.x, demo_freq = Frequency.y)

df_3 <- merged_df |>
  mutate(surplus_demo = demo_freq - repu_freq) |>
  mutate(surplus_demo_grouping = surplus_demo > 0) |> 
  group_by(surplus_demo_grouping) |>
  rename(institution_name = University) |>
  filter(repu_freq > cut_off | demo_freq > cut_off) |>
  filter((demo_freq/repu_freq)*100 > cut_off_surplus | (repu_freq/demo_freq)*100 > cut_off_surplus) 
print(df_3)

endowment_person <- read_csv('Data/graduation.csv') |>
  group_by(year) |>
  filter(year == 2018)

merged_data <-  merge(df_3, endowment_person, by = 'institution_name') 
#create a new column with frequencies for the party that the university has a surplus of
#mutate(freq_party = case_when(surplus_demo_grouping == "TRUE", demo_freq | surplus_demo_grouping == "FALSE", repu_freq))
  

#create summary
summarized_merged <- merged_data |>
  group_by(surplus_demo_grouping) |>
  summarize(mean = mean(endowment_pp, na.rm = TRUE))


#create barplot
plot_endowment <- ggplot(data = summarized_merged) +
  aes(x = surplus_demo_grouping, y = mean)  +
  geom_col(fill=c("red","blue")) +
  labs(x = 'University affiliation', 
       y = 'Endowment per student ($)')+
  scale_x_discrete(labels = c('Republican','Democrat'))+
  scale_y_continuous(labels = scales::comma)
ggsave('figures/endowment_per_university_affiliation.pdf', width = 7, height = 5)

#create scatterplot
# x = amount of students
# y = edowment pp
print(plot_endowment)