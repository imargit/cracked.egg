library(tidyverse)
library(jsonlite)

cut_off = 45

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

df_1 <- merged_df |>
  mutate(neg_repu_freq = -abs(repu_freq)) |>
  filter(repu_freq > cut_off | demo_freq > cut_off) |>
  pivot_longer(neg_repu_freq:demo_freq, names_to = 'Party', values_to = 'Frequency')

plot_1 <- ggplot(data = df_1)+
  aes(x = University, y = Frequency, fill = Party)+
  geom_col()+
  coord_flip()+
  scale_fill_manual(values=c("blue", 
                             "red"),
                    name = "Party", 
                    labels = c("Democrats","Republicans"))+
  theme_minimal()+
  scale_y_continuous(n.breaks = 6)+
  labs(
    x = NULL)
ggsave('Figures/bar_middle_axis_plot.pdf', width = 8, height = 6)

df_2 <- merged_df |>
  filter(repu_freq > cut_off | demo_freq > cut_off) |>
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
ggsave('Figures/bar_plot.pdf', width = 8, height = 6)

df_3 <- merged_df |>
  filter(repu_freq > cut_off | demo_freq > cut_off) |>
  mutate(surplus_demo = demo_freq - repu_freq)

plot_3 <- ggplot(data = df_3)+
  aes(x = reorder(University, surplus_demo), y = surplus_demo, fill = ifelse(surplus_demo<0, "blue", "red"))+
  geom_col()+
  coord_flip()+
  labs(
    y = 'Surplus of Republicans     //    Surplus of Democrats',
    x = NULL
  )+
  scale_fill_manual(values=c("red", 
                             "blue"),
                    name = "Party", 
                    labels = c("Republicans","Democrats"))+
  scale_y_continuous(limits = c(-76,76),
                     n.breaks = 8)+
  theme_minimal()
ggsave('Figures/surplus_barplot.pdf', width = 9, height = 6)