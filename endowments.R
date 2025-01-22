library(tidyverse)
library(jsonlite)

edowment <- read_csv('university_characteristics.csv') 

cut_off = 1

repu_df <- as.data.frame(fromJSON('republican.json', flatten = TRUE)) |>
  pivot_longer(cols = everything(), names_to = 'Universities', values_to = 'Frequency')|>
  mutate(University = str_replace_all(Universities, '\\.',' ')) |>
  select(University,Frequency)

demo_df <- as.data.frame(fromJSON('democrat.json', flatten = TRUE)) |>
  pivot_longer(cols = everything(), names_to = 'Universities', values_to = 'Frequency')|>
  mutate(University = str_replace_all(Universities, '\\.',' ')) |>
  select(University,Frequency)

merged_df <- merge(repu_df,demo_df, by = 'University') |>
  rename(repu_freq = Frequency.x, demo_freq = Frequency.y)

df_3 <- merged_df |>
  filter(repu_freq > cut_off | demo_freq > cut_off) |>
  mutate(surplus_demo = demo_freq - repu_freq) |>
  mutate(surplus_demo_grouping = surplus_demo > 0) |> 
  group_by(surplus_demo_grouping) |>
  rename(institution_name = University)
print(df_3)

merged_df <- merge(repu_df,demo_df, by = 'University') |>
  rename(repu_freq = Frequency.x, demo_freq = Frequency.y) 


endowment_person <- read_csv('graduation.csv') |>
  group_by(year) |>
  filter(year == 2018)
print(endowment_person)

merged_data <-  merge(df_3, endowment_person, by = 'institution_name') 
  #create a new column with frequencies for the party that the university has a surplus of
#mutate(freq_party = case_when(surplus_demo_grouping == "TRUE", demo_freq | surplus_demo_grouping == "FALSE", repu_freq))
  

#create summary
summarized_merged <- merged_data |>
  group_by(surplus_demo_grouping) |>
  summarize(mean = mean(endowment_pp, na.rm = TRUE))
print(summarized_merged)

#create barplot
plot_endowment <- ggplot(data = summarized_merged) +
  aes(x = surplus_demo_grouping, y = mean)  +
  geom_col() +
  labs(x = 'Party', y = 'Endowment per student')


#create scatterplot
# x = amount of students
# y = edowment pp





print(plot_endowment)