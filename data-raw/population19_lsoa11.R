# ---- Load ----
library(tidyverse)
library(devtools)
library(readxl)
library(httr)

# Load package
load_all(".")

# Set query url
query_url <-
  query_urls |>
  filter(id == "estimates19_lsoa11") |>
  pull(query)

GET(query_url,
    write_disk(tf <- tempfile(fileext = ".zip")))

# Where to store the unzipped files temporarily
td <- tempdir()
unzip_dir <- file.path(td, "population-lsoa")

# Delete the temp folder if it already exists
if (dir.exists(unzip_dir))
  unlink(unzip_dir, recursive = TRUE)

dir.create(unzip_dir)

unzip(tf, exdir = unzip_dir)

lsoa_pop <- read_excel(file.path(unzip_dir, "SAPE22DT2-mid-2019-lsoa-syoa-estimates-unformatted.xlsx"),
                       sheet = "Mid-2019 Persons", skip = 4)

# Select and rename vars
lsoa_pop <-
  lsoa_pop %>%
  select(
    lsoa11_name = `LSOA Name`,
    lsoa11_code = `LSOA Code`,
    `total_population` = `All Ages`,
    `0`:`90+`
  ) %>%
  distinct()

# Rename
population19_lsoa11 <- lsoa_pop

# Save output to data/ folder
usethis::use_data(population19_lsoa11, overwrite = TRUE)

unlink(tf); rm(tf)
unlink(td); rm(td)