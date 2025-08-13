if (!require(pacman)) install.packages("pacman")
library(pacman) ; p_load("shiny", "siebanxicor", "quantmod", "dplyr", "httr", 
                         "jsonlite", "tidyverse", "fredr")

# FUNCIÓN - TOMAR ÚLTIMO DATO
last.val <- function(df) {
  df <- df[!is.na(df$value), ]
  df[which.max(as.Date(df$date)), ]
}

# ==============================================================================
# BANXICO
#
# TOKEN
setToken("yourtoken")
# ==============================================================================

# DATOS
data_banxico <- getSeriesData(c("SF45470", "SF61745", "SF43783", "SP30578", 
                                "SP74662", "SP74665", "SF60653"), 
                              endDate = Sys.Date())

# SERIES
cetes28 <- getSerieDataFrame(data_banxico, "SF45470")
tiie28 <- getSerieDataFrame(data_banxico, "SF43783")
tasa_refmx <- getSerieDataFrame(data_banxico, "SF61745")
pimx <- getSerieDataFrame(data_banxico, "SP30578")
pismx <- getSerieDataFrame(data_banxico, "SP74662")
pinsmx <- getSerieDataFrame(data_banxico, "SP74665")
tcmx <- getSerieDataFrame(data_banxico, "SF60653")

# GUARDAMOS ÚLTIMO DATO
cetes28 <- last.val(cetes28)
tiie28 <- last.val(tiie28)
tasa_refmx <- last.val(tasa_refmx)
pimx <- last.val(pimx)
pismx <- last.val(pismx)
pinsmx <- last.val(pinsmx)
tcmx <- last.val(tcmx)

# ==============================================================================
# FED
#
# KEY
fredr_set_key("yourtoken")
# ==============================================================================

# SERIES
piusa <- fredr(series_id = "CPIAUCSL", 
               observation_start = NULL,
               observation_end = Sys.Date())
tasa_refusa <- fredr(series_id = "DFEDTARU", 
                     observation_start = NULL,
                     observation_end = Sys.Date())
sofr <- fredr(series_id = "SOFR", 
              observation_start = NULL,
              observation_end = Sys.Date())
tbill28 <- fredr(series_id = "DTB4WK", 
                 observation_start = NULL,
                 observation_end = Sys.Date())

# GUARDAMOS ÚLTIMO DATO
piusa <- last.val(piusa) %>% 
  select(date, value)
tasa_refusa <- last.val(tasa_refusa) %>% 
  select(date, value)
sofr <- last.val(sofr) %>% 
  select(date, value)
tbill28 <- last.val(tbill28) %>% 
  select(date, value)

# ==============================================================================
# YAHOO FINANCE
# ==============================================================================

# SERIES
sp500 <- getSymbols("^GSPC", src = "yahoo", from = "2025-01-01", 
                    to = Sys.Date(), periodicity = "daily", 
                    auto.assign = FALSE)
sp500 <- data.frame(date = index(sp500), coredata(sp500)) %>% 
  select(date, GSPC.Close) %>% 
  rename(value = GSPC.Close)

dow <- getSymbols("^DJI", src = "yahoo", from = "2025-01-01", 
                    to = Sys.Date(), periodicity = "daily", 
                    auto.assign = FALSE)
dow <- data.frame(date = index(dow), coredata(dow)) %>% 
  select(date, DJI.Close) %>% 
  rename(value = DJI.Close)

nasdaq <- getSymbols("^IXIC", src = "yahoo", from = "2025-01-01", 
                  to = Sys.Date(), periodicity = "daily", 
                  auto.assign = FALSE)
nasdaq <- data.frame(date = index(nasdaq), coredata(nasdaq)) %>% 
  select(date, IXIC.Close) %>% 
  rename(value = IXIC.Close)

vix <- getSymbols("^VIX", src = "yahoo", from = "2025-01-01", 
                     to = Sys.Date(), periodicity = "daily", 
                     auto.assign = FALSE)
vix <- data.frame(date = index(vix), coredata(vix)) %>% 
  select(date, VIX.Close) %>% 
  rename(value = VIX.Close)

ipc <- getSymbols("^MXX", src = "yahoo", from = "2025-01-01", 
                  to = Sys.Date(), periodicity = "daily", 
                  auto.assign = FALSE)
ipc <- data.frame(date = index(ipc), coredata(ipc)) %>% 
  select(date, MXX.Close) %>% 
  rename(value = MXX.Close)

sp500 <- last.val(sp500)
dow <- last.val(dow)
nasdaq <- last.val(nasdaq)
vix <- last.val(vix)
ipc <- last.val(ipc)