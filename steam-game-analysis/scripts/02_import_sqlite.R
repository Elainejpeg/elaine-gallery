# Optional: create a local SQLite database from the CSV.
# Run from the steam-game-analysis directory:
# source("scripts/02_import_sqlite.R")

library(readr)
library(DBI)
library(RSQLite)

dir.create("outputs", showWarnings = FALSE)
df <- read_csv("data/steam_sample.csv", show_col_types = FALSE)
con <- dbConnect(SQLite(), "outputs/steam_games.sqlite")
dbWriteTable(con, "steam_games", df, overwrite = TRUE)
dbDisconnect(con)
cat("Created outputs/steam_games.sqlite with", nrow(df), "rows.\n")
