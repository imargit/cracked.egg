library(tidyverse)
library(tidyr)

repu_df <- read_csv('frequencies_repu.csv')
demo_df <- read_csv('frequencies_demo.csv')

new_df <- merge(repu_df,demo_df, by = 'uni') |>
  mutate(neg_repu_freq = -abs(repu_freq)) |>
  filter(repu_freq > 25 | demo_freq > 25) |>
  pivot_longer(neg_repu_freq:demo_freq, names_to = 'Party', values_to = 'Frequency')

print(new_df, n = 22)

plot <- ggplot(data = new_df)+
  aes(x = uni, y = Frequency, fill = Party)+
  geom_col()+
  coord_flip()+
  scale_fill_manual(values=c("blue", 
                             "red"))+
  theme_minimal()+
  scale_y_continuous(n.breaks = 6)
print(plot)