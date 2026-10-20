# Beginner Steam games EDA
# Run from the steam-game-analysis directory:
# source("scripts/01_analysis.R")
# Requires: readr, dplyr, ggplot2

library(readr)
library(dplyr)
library(ggplot2)

dir.create("outputs", showWarnings = FALSE)

games_raw <- read_csv("data/steam_sample.csv", show_col_types = FALSE)

expected <- c("appid", "name", "genres", "positive_ratings",
              "negative_ratings", "price")
stopifnot(all(expected %in% names(games_raw)))

games <- games_raw %>%
  mutate(
    price = as.numeric(price),
    positive_ratings = as.numeric(positive_ratings),
    negative_ratings = as.numeric(negative_ratings),
    total_reviews = positive_ratings + negative_ratings,
    positive_share = if_else(total_reviews > 0,
                             positive_ratings / total_reviews,
                             NA_real_),
    primary_genre = trimws(sub(";.*$", "", genres)),
    price_type = if_else(price == 0, "Free", "Paid")
  ) %>%
  filter(
    !is.na(price), price >= 0,
    !is.na(positive_ratings), positive_ratings >= 0,
    !is.na(negative_ratings), negative_ratings >= 0,
    !is.na(primary_genre), primary_genre != ""
  )

write_csv(games, "outputs/cleaned_games.csv")

# 1) How many sample games belong to each main genre?
genre_counts <- games %>%
  count(primary_genre, name = "game_count", sort = TRUE)
write_csv(genre_counts, "outputs/genre_counts.csv")

top_genres <- genre_counts %>% slice_head(n = 10)
plot_genres <- ggplot(top_genres,
                      aes(x = reorder(primary_genre, game_count),
                          y = game_count)) +
  geom_col(fill = "#5d83b9") +
  coord_flip() +
  labs(title = "Primary genres in the practice sample",
       subtitle = "Historical sample — not the full Steam catalogue",
       x = "Primary genre", y = "Number of games") +
  theme_minimal(base_size = 12)
ggsave("outputs/01_genre_counts.png", plot_genres,
       width = 9, height = 5.5, dpi = 160)

# 2) Recorded price versus fraction of positive ratings.
# A minimum of 20 reviews reduces extreme 0% / 100% ratios
# based on only one or two ratings.
rated_games <- games %>% filter(total_reviews >= 20)

plot_price <- rated_games %>% filter(price > 0) %>%
  ggplot(aes(x = price, y = positive_share)) +
  geom_point(alpha = 0.35, color = "#236b93") +
  scale_x_log10() +
  scale_y_continuous(labels = function(x) paste0(round(x * 100), "%"),
                     limits = c(0, 1)) +
  labs(title = "Price and positive-review share",
       subtitle = "Paid games with at least 20 recorded reviews",
       x = "Recorded historical price (source units, log scale)",
       y = "Positive reviews / all reviews") +
  theme_minimal(base_size = 12)
ggsave("outputs/02_price_vs_positive_share.png", plot_price,
       width = 9, height = 5.5, dpi = 160)

# 3) Free vs paid: descriptive comparison, not a causal finding.
plot_free_paid <- ggplot(rated_games,
                        aes(x = price_type, y = positive_share,
                            fill = price_type)) +
  geom_boxplot(width = 0.55, alpha = 0.8, outlier.alpha = 0.25) +
  scale_y_continuous(labels = function(x) paste0(round(x * 100), "%"),
                     limits = c(0, 1)) +
  scale_fill_manual(values = c(Free = "#81c7b6", Paid = "#a3a6e8")) +
  guides(fill = "none") +
  labs(title = "Review share by recorded price type",
       subtitle = "Games with at least 20 recorded reviews",
       x = "Recorded price type", y = "Positive review share") +
  theme_minimal(base_size = 12)
ggsave("outputs/03_free_vs_paid.png", plot_free_paid,
       width = 8, height = 5.5, dpi = 160)

summary_by_price <- rated_games %>%
  group_by(price_type) %>%
  summarise(
    number_of_games = n(),
    median_positive_share = median(positive_share, na.rm = TRUE),
    mean_positive_share = mean(positive_share, na.rm = TRUE),
    .groups = "drop"
  )
write_csv(summary_by_price, "outputs/free_paid_summary.csv")

# Spearman rank correlation, if enough paid titles qualify.
paid <- rated_games %>% filter(price > 0, !is.na(positive_share))
spearman <- if (nrow(paid) > 2 && n_distinct(paid$price) > 1) {
  cor(paid$price, paid$positive_share, method = "spearman")
} else {
  NA_real_
}

notes <- c(
  sprintf("Records after numeric validation: %d", nrow(games)),
  sprintf("Records with >=20 reviews: %d", nrow(rated_games)),
  sprintf("Paid reviewed titles for correlation: %d", nrow(paid)),
  sprintf("Spearman price/positive-share correlation (paid games): %s",
          ifelse(is.na(spearman), "NA", round(spearman, 3))),
  "",
  "CAUTION: Historical, curated teaching sample; not a random sample.",
  "Positive-review share is not an official Steam score.",
  "Review count is not player count; prices are not current.",
  "Correlation is descriptive, not evidence of causation."
)
writeLines(notes, "outputs/analysis_notes.txt")
cat(paste(notes, collapse = "\n"), "\n")
