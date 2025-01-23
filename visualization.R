library(tidyverse)
library(jsonlite)

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

# BAR PLOT OF UNIVERSITIES AND THEIR POLITICIANS - MIDDLE

df_1 <- merged_df |>
  mutate(neg_repu_freq = -abs(repu_freq)) |>
  #filter(repu_freq + demo_freq > cut_off) |>
  #filter(repu_freq > 5 & demo_freq > 5) |>
  mutate(surplus_demo =  repu_freq - demo_freq) |>
  mutate(surplus_ratio = surplus_demo / (demo_freq+repu_freq)) |>
  mutate(percentage = ((demo_freq/repu_freq))) |>
  pivot_longer(neg_repu_freq:demo_freq, names_to = 'Party', values_to = 'Frequency')

plot_1 <- ggplot(data = df_1)+
  aes(x = reorder(University,surplus_ratio), y = Frequency, fill = Party)+
  geom_col()+
  coord_flip()+
  scale_fill_manual(values=c("blue", 
                             "red"),
                    name = "Party", 
                    labels = c("Democrats","Republicans"))+
  theme_minimal()+
  scale_y_continuous(n.breaks = 6)+
  scale_x_discrete(labels = NULL)+
  labs(x = "Universities")+
  annotate(geom="text", 
           x=25, 
           y=-92, 
           label='100% Republican')+
  annotate(geom="text", 
           x=1155, 
           y=-92, 
           label='100% Democratic')
#ggsave('Figures/sorted_frequency_bar_graph.pdf', width = 8, height = 6)
# BAR PLOT OF UNIVERSITIES AND THEIR POLITICIANS - SIDE

df_2 <- merged_df |>
  filter(repu_freq + demo_freq > cut_off) |>
  pivot_longer(repu_freq:demo_freq, names_to = 'Party', values_to = 'Frequency')

plot_2 <- ggplot(data = df_2)+
  aes(x = University, y = Frequency, fill = Party)+
  geom_col(position = "dodge")+
  coord_flip()+
  scale_fill_manual(values=c("blue", 
                             "red"),
                    name = "Party", 
                    labels = c("Democrats","Republicans"))+
  theme_minimal()+
  scale_y_continuous(n.breaks = 6)+
  labs(
    x = NULL
  )+
  theme_minimal()
#ggsave('Figures/bar_plot.pdf', width = 8, height = 6)

# BAR PLOT OF SURPLUS - FOR DEMOCRATS AND REPUBLICANS

df_3 <- merged_df |>
  filter(repu_freq + demo_freq > cut_off) |>
  mutate(surplus_demo =    repu_freq - demo_freq) |>
  mutate(surplus_ratio = surplus_demo / (demo_freq+repu_freq))
  

# Excluded lines are for cut-off = 10
plot_3 <- ggplot(data = df_3)+
  aes(x = reorder(University, surplus_ratio), y = surplus_ratio, fill = ifelse(surplus_ratio>0, "blue", "red"))+
  geom_col()+
  coord_flip()+
  labs(
    y = 'Surplus ratio',
    x = NULL
  )+
  scale_fill_manual(values=c("red", 
                             "blue"),
                    name = "Party", 
                    labels = c("Republicans","Democrats"))+
  scale_y_continuous(labels = scales::percent,
                    #limits = c(-1,1),
                    n.breaks = 8
                     )+
  scale_x_discrete()+
  theme_minimal()+
  theme(panel.grid.major.x = element_line(color = 'black',
                                          linewidth = 0.3,
                                          linetype = 1))
#ggsave('Figures/surplus_barplot_cutoff=100.pdf', width = 9, height = 6)

# BAR PLOT OF ENDOWMENT PER UNIVERSITY AFFILIATION

df_4 <- merged_df |>
  mutate(surplus_demo =  repu_freq - demo_freq) |>
  mutate(surplus_demo_grouping = surplus_demo < 0) |> 
  rename(institution_name = University) |>
  filter(repu_freq + demo_freq > cut_off) |>
  filter((demo_freq/repu_freq)*100 > cut_off_surplus | (repu_freq/demo_freq)*100 > cut_off_surplus) 

endowment_person <- read_csv('Data/graduation.csv') |>
  group_by(year) |>
  filter(year == 2018)

prepped_df_4 <-  merge(df_4, endowment_person, by = 'institution_name') |>
  #filter(endowment_pp < 1500000) |>
  group_by(surplus_demo_grouping) |>
  summarize(mean = mean(endowment_pp, na.rm = TRUE))

plot_4 <- ggplot(data = prepped_df_4)+
  aes(x = reorder(surplus_demo_grouping,-mean), y = mean)+
  geom_col(fill = c('red','blue'))+
  labs(x = 'University affiliation', 
       y = 'Mean endowment per student ($)')+
  scale_x_discrete(labels = c('Democrat','Republican'),
              #     limits = surplus_demo_grouping
                   )+
  scale_y_continuous(labels = scales::comma)+
  theme_minimal()
#ggsave('figures/endowment_per_university_affiliation_mean.pdf', width = 7, height = 5)

prepped_df_5 <-  merge(df_4, endowment_person, by = 'institution_name')
   # filter(endowment_pp < 1500000)

# VIOLIN PLOT OF ENDOWMENT PER UNIVERSITY AFFILIATION

plot_5 <- ggplot(data = prepped_df_5)+
  aes(x = reorder(surplus_demo_grouping, -endowment_pp), y = endowment_pp)+
  geom_violin(aes(fill = surplus_demo_grouping))+
  labs(x = 'University affiliation', 
       y = 'Endowment per student ($)')+
  scale_fill_manual(values=c("red", 
                             "blue"),
                    guide="none")+
  scale_x_discrete(labels = c('Democrat','Republican'))+
  scale_y_continuous(labels = scales::comma)+
  theme_minimal()
ggsave('figures/endowment_per_university_affiliation_violin_plot.pdf', width = 7, height = 5)
print(plot_5)

df_7 <- merge(df_4, endowment_person, by = 'institution_name') |>
  mutate(total_politicians = demo_freq + repu_freq)

plot_7 <- ggplot(data = df_7)+
  aes(x = endowment_pp, y = total_politicians)+
  geom_point(na.rm = TRUE)+
  scale_y_continuous(trans = 'log10')+
  geom_smooth(method = 'lm',
              na.rm = TRUE)+
  scale_x_continuous(trans='log10',
                     labels = scales::comma,
                     n.breaks = 6,
                     limits = c(10,9000000))+
  labs(x = "Endowment per student ($)",
       y = "Total politicians per university")+
  theme_minimal()
#ggsave('figures/endowment_vs_total_politicians.pdf', width = 7, height = 5)

df_8 <- merged_df |>
  filter(repu_freq + demo_freq > cut_off) |>
  mutate(surplus_demo = repu_freq - demo_freq) |>
  mutate(surplus_ratio = surplus_demo / (demo_freq+repu_freq)) |>
  mutate(total_politicians = demo_freq + repu_freq)


plot_8 <- ggplot(data = df_8)+
  aes(x = total_politicians, y = surplus_ratio, colour = ifelse(surplus_demo>0, "blue", "red"))+
  scale_colour_manual(values = c("blue","red")) +
  geom_point()+
  scale_x_log10()+
  geom_hline(yintercept = 0)+
  geom_smooth(inherit.aes = FALSE,
              method = 'lm',
              aes(x = total_politicians, y = surplus_ratio),
              color = 'black')+
  coord_flip()+
  theme_minimal()+
  scale_y_continuous(labels = scales::percent,
                     limits = c(-1,1))+
  labs(y = 'Surplus ratio of Democrats  //  Republicans',
       x = 'Total politicians per university')+
  theme(legend.position="none")
#ggsave('figures/surplus_ratio_vs_total_politicians.pdf', width = 7, height = 5)