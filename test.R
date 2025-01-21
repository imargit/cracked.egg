library(tidyverse)
library(jsonlite)

df <- as.data.frame(fromJSON('democrat.json', flatten = TRUE)) |>
  pivot_longer(cols = everything(), names_to = 'Universities', values_to = 'Frequency')|>
  mutate(University = str_replace_all(Universities, '\\.',' ')) |>
  select(University,Frequency)
print(df)
