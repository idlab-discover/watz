library(dplyr)
library(tidyr)
library(ggplot2)
library(ggthemes)

launch.time <- read.csv("~/Onderzoek/optee/watz/benchmarks/launch-time/launch-time.csv") # |> filter(size != 10) 
    
df <- launch.time |>
  filter(!is.na(repetition)) |>
  mutate(memory=end_memory - start_memory, decryption=end_decrypt - start_decrypt, init=end_init - end_decrypt, load=end_load - end_init, instantiate=end_instantiate - end_load) |>
  select(size, memory, decryption, init, load, instantiate) |>
  pivot_longer(!size, names_to = "span", values_to = "time")
  # select(size, repetition, timed_iter, memory, decryption, init, load, instantiate) |>
  # group_by(size, repetition, timed_iter) |>
  # summarise(memory=mean(memory), decryption=mean(decryption), init=mean(init), load=mean(load), instantiate=mean(instantiate)) |>
  # summarise(memory=mean(memory), decryption=mean(decryption), init=mean(init), load=mean(load), instantiate=mean(instantiate)) |>
  # summarise(memory=mean(memory), decryption=mean(decryption), init=mean(init), load=mean(load), instantiate=mean(instantiate)) |>

df_means <- launch.time |>
  filter(!is.na(repetition)) |>
  mutate(memory=end_memory - start_memory, decryption=end_decrypt - start_decrypt, init=end_init - end_decrypt, load=end_load - end_init, instantiate=end_instantiate - end_load) |>
  select(size, repetition, timed_iter, memory, decryption, init, load, instantiate) |>
  group_by(size, repetition, timed_iter) |>
  summarise(memory=mean(memory), decryption=mean(decryption), init=mean(init), load=mean(load), instantiate=mean(instantiate)) |>
  summarise(memory=mean(memory), decryption=mean(decryption), init=mean(init), load=mean(load), instantiate=mean(instantiate)) |>
  summarise(memory=mean(memory), decryption=mean(decryption), init=mean(init), load=mean(load), instantiate=mean(instantiate)) |> 
  pivot_longer(!size, names_to = "span", values_to = "time")
  
ns_to_micros <- function(ns)
  ns / 1e3
ns_to_millis <- function(ns)
  ns / 1e6

ggplot(df, aes(x=size, y=ns_to_micros(time), group=span, color=span)) +
  geom_point(data=df_means |> filter(size != 10), mapping=aes(x=size,y=ns_to_micros(time))) +
  geom_smooth(se=TRUE) +
  theme_tufte()
  # geom_line() +
# ggplot(df, aes(x = span, y = ns_to_micros(time), fill = span)) +
#   # stat_summary(geom = "linerange", fun.min = "min", fun.max = "max") +
#   # geom_point() +
#   geom_bar(position = "dodge", stat="identity") +
#   facet_wrap(~size) +
#   theme_tufte() + 
#   theme(legend.position = "none")