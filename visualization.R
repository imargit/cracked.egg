library(tidyverse)
library(dplyr)

df <- read_csv('frequencies_2.csv')

repu_df <- read_csv('frequencies_repu.csv')
demo_df <- read_csv('frequencies_demo.csv')

print(repu_df)
print(demo_df)

new_df <- df |>
  merge(repu_df, demo_df, by = 'uni')

print(new_df, n = 22)