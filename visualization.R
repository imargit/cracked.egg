library(tidyverse)

repu_df <- read_csv('frequencies_repu.csv')
demo_df <- read_csv('frequencies_demo.csv')
merged_df <- merge(repu_df,demo_df, by = 'uni')

df_1 <- merged_df |>
  mutate(neg_repu_freq = -abs(repu_freq)) |>
  filter(repu_freq > 25 | demo_freq > 25) |>
  pivot_longer(neg_repu_freq:demo_freq, names_to = 'Party', values_to = 'Frequency')

plot_1 <- ggplot(data = df_1)+
  aes(x = uni, y = Frequency, fill = Party)+
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
ggsave('bar_middle_axis_plot.pdf', width = 8, height = 6)

df_2 <- merged_df |>
  filter(repu_freq > 25 | demo_freq > 25) |>
  pivot_longer(repu_freq:demo_freq, names_to = 'Party', values_to = 'Frequency')

plot_2 <- ggplot(data = df_2)+
  aes(x = uni, y = Frequency, fill = Party)+
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
ggsave('bar_plot.pdf', width = 8, height = 6)

df_3 <- merged_df |>
  filter(repu_freq > 25 | demo_freq > 25) |>
  mutate(surplus_demo = demo_freq - repu_freq)

plot_3 <- ggplot(data = df_3)+
  aes(x = reorder(uni, surplus_demo), y = surplus_demo, fill = ifelse(surplus_demo<0, "blue", "red"))+
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
  scale_y_continuous(limits = c(-46,46),
                     n.breaks = 8
                     )+
  theme_minimal()
ggsave('surplus_barplot.pdf', width = 8, height = 6)