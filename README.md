# APIs - Banxico, FRED & Yahoo Finance

Before running the application, you must obtain an API token/key to access Banxico’s and FRED’s data. To do so, register with your email on the <a href="https://www.banxico.org.mx/SieAPIRest/service/v1/token">Banxico API registration page</a> and the <a href="https://fred.stlouisfed.org/docs/api/api_key.html">FRED API registration page</a>.

## Data Sources

- **Banxico API** via `{siebanxicor}`  
- **FRED (Federal Reserve Economic Data)** via `{fredr}`  
- **Yahoo Finance** via `{quantmod}`

## How it Works

This example retrieves the most recent values (including closing prices) for some important Mexican and U.S. economic indicators and market indexes.

### 1) Package Management

```r
if (!require(pacman)) install.packages("pacman")
library(pacman)
p_load("siebanxicor", "quantmod", "dplyr", "httr",
       "jsonlite", "tidyverse", "fredr")
```

- Checks if pacman is installed; if not, installs it.
- Loads pacman and uses p_load() to install/load all required packages in one step.
- Key packages:
  - siebanxicor: Interface to Banxico’s API.
  - fredr: Interface to the FRED API.
  - quantmod: Retrieves financial market data from Yahoo Finance.
  - dplyr / tidyverse: Data wrangling.
  - httr / jsonlite: HTTP and JSON processing.

### 2) Helper to Get the Latest Non-Missing Observation

```r
last.val <- function(df) {
  df <- df[!is.na(df$value), ]
  df[which.max(as.Date(df$date)), ]
}
```

- Removes rows where value is missing.
- Finds the row with the maximum (latest) date.
- Returns a single-row data frame: the most recent observation.

### 3) Banxico

```r
# TOKEN
setToken("YourToken")

# Bulk download and split into series
data_banxico <- getSeriesData(
  c("SF45470", "SF61745", "SF43783", "SP30578",
    "SP74662", "SP74665", "SF60653"),
  endDate = Sys.Date()
)

cetes28    <- getSerieDataFrame(data_banxico, "SF45470")
tiie28     <- getSerieDataFrame(data_banxico, "SF43783")
tasa_refmx <- getSerieDataFrame(data_banxico, "SF61745")
pimx       <- getSerieDataFrame(data_banxico, "SP30578")
pismx      <- getSerieDataFrame(data_banxico, "SP74662")
pinsmx     <- getSerieDataFrame(data_banxico, "SP74665")
tcmx       <- getSerieDataFrame(data_banxico, "SF60653")

# Keep only the latest observation
cetes28    <- last.val(cetes28)
tiie28     <- last.val(tiie28)
tasa_refmx <- last.val(tasa_refmx)
pimx       <- last.val(pimx)
pismx      <- last.val(pismx)
pinsmx     <- last.val(pinsmx)
tcmx       <- last.val(tcmx)
```

- Authenticates to Banxico API with setToken().
- Downloads multiple economic series in bulk up to the current date.
- Splits the bulk object into individual tidy data frames for each series.
- Uses last.val() to keep only the latest observation for dashboard display.

**The complete catalog of Banxico’s series codes is available <a href="https://www.banxico.org.mx/SieAPIRest/service/v1/doc/catalogoSeries">here</a>.**

| Object       | Banxico code | Description (short)    |
| ------------ | ------------ | ---------------------- |
| `cetes28`    | SF45470      | 28-day CETES yield     |
| `tiie28`     | SF43783      | TIIE 28-day            |
| `tasa_refmx` | SF61745      | Mexico policy rate     |
| `pimx`       | SP30578      | Price index (headline) |
| `pismx`      | SP74662      | Core price index       |
| `pinsmx`     | SP74665      | Non-core price index   |
| `tcmx`       | SF60653      | MXN/USD exchange rate  |

### 4) FRED

```r
# KEY
fredr_set_key("YOUR_FRED_API_KEY")

piusa       <- fredr(series_id = "CPIAUCSL", observation_end = Sys.Date())
tasa_refusa <- fredr(series_id = "DFEDTARU",  observation_end = Sys.Date())
sofr        <- fredr(series_id = "SOFR",      observation_end = Sys.Date())
tbill28     <- fredr(series_id = "DTB4WK",    observation_end = Sys.Date())

# Keep only latest value
piusa       <- last.val(piusa)       %>% dplyr::select(date, value)
tasa_refusa <- last.val(tasa_refusa) %>% dplyr::select(date, value)
sofr        <- last.val(sofr)        %>% dplyr::select(date, value)
tbill28     <- last.val(tbill28)     %>% dplyr::select(date, value)
```

- Authenticates with fredr_set_key().
- Downloads selected U.S. economic indicators from FRED.
- Filters each series to keep only the most recent value.

### 5) Yahoo Finance

```r
sp500  <- getSymbols("^GSPC", src = "yahoo", from = "2025-01-01",
                     to = Sys.Date(), periodicity = "daily", auto.assign = FALSE)
dow    <- getSymbols("^DJI",  src = "yahoo", from = "2025-01-01",
                     to = Sys.Date(), periodicity = "daily", auto.assign = FALSE)
nasdaq <- getSymbols("^IXIC", src = "yahoo", from = "2025-01-01",
                     to = Sys.Date(), periodicity = "daily", auto.assign = FALSE)
vix    <- getSymbols("^VIX",  src = "yahoo", from = "2025-01-01",
                     to = Sys.Date(), periodicity = "daily", auto.assign = FALSE)
ipc    <- getSymbols("^MXX",  src = "yahoo", from = "2025-01-01",
                     to = Sys.Date(), periodicity = "daily", auto.assign = FALSE)

sp500  <- data.frame(date = index(sp500),  coredata(sp500))  %>%
  dplyr::select(date, GSPC.Close) %>% dplyr::rename(value = GSPC.Close)
dow    <- data.frame(date = index(dow),    coredata(dow))    %>%
  dplyr::select(date, DJI.Close)  %>% dplyr::rename(value = DJI.Close)
nasdaq <- data.frame(date = index(nasdaq), coredata(nasdaq)) %>%
  dplyr::select(date, IXIC.Close) %>% dplyr::rename(value = IXIC.Close)
vix    <- data.frame(date = index(vix),    coredata(vix))    %>%
  dplyr::select(date, VIX.Close)  %>% dplyr::rename(value = VIX.Close)
ipc    <- data.frame(date = index(ipc),    coredata(ipc))    %>%
  dplyr::select(date, MXX.Close)  %>% dplyr::rename(value = MXX.Close)

# Keep only latest close
sp500  <- last.val(sp500)
dow    <- last.val(dow)
nasdaq <- last.val(nasdaq)
vix    <- last.val(vix)
ipc    <- last.val(ipc)
```

- Uses quantmod::getSymbols() to fetch daily closing prices since 2025-01-01 for:
  - S&P 500 (^GSPC)
  - Dow Jones Industrial Average (^DJI)
  - NASDAQ Composite (^IXIC)
  - CBOE Volatility Index (^VIX)
  - IPC Mexico (^MXX)
- Converts each xts object to a tidy data frame with date and value.
- Keeps only the most recent close for dashboard display.
