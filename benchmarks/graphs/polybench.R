library("ggplot2")
library(ggthemes)
library(dplyr)
library(stats)

# tee <- read.csv(
#   "~/Onderzoek/optee/watz/benchmarks/logs/polybench/tee-unpinned.csv",
#   col.names = c("time")
# )
# tee$name <- c("tee wasm")

tee_pinned <- read.csv(
  "~/Onderzoek/optee/watz/benchmarks/logs/polybench/tee-pinned.csv",
  col.names = c("time")
)
# tee_pinned$name <- c("TEE - Wasm")
tee_pinned$name <- c("tee wasm (pinned to core 8-11)")


# tee_native <- read.csv(
#   "~/Onderzoek/optee/watz/benchmarks/logs/polybench/tee-native.csv",
#   col.names = c("time")
# )
# tee_native$name <- c("tee native")

# tee_native_pinned <- read.csv(
#   "~/Onderzoek/optee/watz/benchmarks/logs/polybench/tee-native-pinned.csv",
#   col.names = c("time")
# )
# tee_native_pinned$name <- c("tee native (pinned to core 8-11)")
# tee_native_pinned$name <- c("TEE - Native")


# tee_native_nice <- read.csv(
#   "~/Onderzoek/optee/watz/benchmarks/logs/polybench/tee-native-nice.csv",
#   col.names = c("time")
# )
# tee_native_nice$name <- c("tee native (with nice -24)")

# ree <- read.csv(
#   "~/Onderzoek/optee/watz/benchmarks/logs/polybench/ree-native.csv",
#   col.names = c("time")
# )
# ree$name <- c("REE - Native")

# ree_wasm <- read.csv(
#   "~/Onderzoek/optee/watz/benchmarks/logs/polybench/ree-wasm.csv",
#   col.names = c("time")
# )
# ree_wasm$name <- c("REE - Wasm")

tee_old <- read.csv(
  "~/Onderzoek/optee/watz/benchmarks/logs/polybench/old_watz/tee-pinned.csv",
  col.names = c("time")
)
tee_old$name <- c("tee wasm (old)")

# ree_wasm_old <- read.csv(
#   "~/Onderzoek/optee/watz/benchmarks/logs/polybench/ree-wasm-old.csv",
#   col.names = c("time")
# )
# ree_wasm_old$name <- c("ree wasm (old)")

# tee_native_qemu <- read.csv("~/Onderzoek/optee/watz/benchmarks/logs/polybench/qemu_native_tee.csv", col.names = c("iter", "time"))
# tee_native_qemu$name <- c("qemu native tee")

# Q1 <- quantile(tee$time, .25)
# Q3 <- quantile(tee$time, .75)
# IQR <- IQR(tee$time)
# outliers <- subset(tee, tee$time<(Q1 - 1.5*IQR) | tee$time>(Q3 + 1.5*IQR))
# outliers <- subset(tee_native_qemu, tee_native_qemu$time>9204930)
#
# outliers$name <- c("tee  wasm (outliers)")

# combined <- rbind(tee, tee_pinned, tee_native, tee_native_pinned, tee_native_nice, ree, ree_wasm, ree_wasm_old, tee_old)
# combined <- rbind(tee, tee_pinned, tee_native, tee_native_pinned)
combined <- rbind(tee_pinned, tee_old)
# combined <- rbind(tee_pinned, tee_native_pinned, ree, ree_wasm)
# combined <- rbind(tee, tee_native)

ns_to_micros <- function(ns)
  ns / 1e3
ns_to_millis <- function(ns)
  ns / 1e6

# df <- combined %>% 
#   group_by(name) %>% 
#   mutate(max_time = ns_to_micros(max(time))) %>% 
#   mutate(min_time = ns_to_micros(min(time))) %>% 
#   select(name, max_time, min_time) %>% 
#   distinct()


# ggplot(df) +
#   geom_segment(aes(x = min_time, xend = max_time,
#                    y = name, yend = name)) +
#   geom_point(aes(x = min_time, y = name), size = 1) +
#   geom_point(aes(x = max_time, y = name), size = 1) +
#   theme_tufte()

ggplot(combined, aes(x = ns_to_micros(time), y = name)) +
  # stat_summary(geom = "linerange", fun.min = "min", fun.max = "max") +
  # geom_point() +
  geom_violin() +
  stat_summary(fun.y=mean, geom="point", shape=23, size=10, color="red") +
  ylab("") +
  xlab("Time (in ms)") +
  # scale_x_continuous(breaks = round(seq(0,3, by = 0.2),50)) +
  theme_tufte()

# print(summary(tee$time))
print(summary(tee_pinned$time))
print(summary(tee_old$time))

t.test(tee_pinned$time, tee_old$time)
# print(summary(tee_native$time))
# print(summary(tee_native_pinned$time))
# print(summary(ree_wasm$time))
# print(summary(ree$time))
# print(summary(ree_wasm_old$time))