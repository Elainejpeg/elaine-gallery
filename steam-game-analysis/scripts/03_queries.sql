-- SQLite examples; run after scripts/02_import_sqlite.R.
-- The data is a historical, curated practice sample, not current Steam data.

-- A) Basic record counts and price summary
SELECT COUNT(*) AS game_count,
       ROUND(AVG(price), 2) AS average_recorded_price,
       SUM(CASE WHEN price = 0 THEN 1 ELSE 0 END) AS free_games
FROM steam_games;

-- B) Top primary genres (the first semicolon-delimited genre)
SELECT CASE
         WHEN instr(genres, ';') = 0 THEN genres
         ELSE substr(genres, 1, instr(genres, ';') - 1)
       END AS primary_genre,
       COUNT(*) AS number_of_games
FROM steam_games
GROUP BY primary_genre
ORDER BY number_of_games DESC
LIMIT 10;

-- C) Mean positive-review share among games with at least 20 reviews
SELECT CASE WHEN price = 0 THEN 'Free' ELSE 'Paid' END AS price_type,
       COUNT(*) AS n_games,
       ROUND(AVG(1.0 * positive_ratings /
             (positive_ratings + negative_ratings)), 3) AS mean_positive_share
FROM steam_games
WHERE positive_ratings + negative_ratings >= 20
GROUP BY price_type
ORDER BY price_type;

-- D) Your turn: adapt the price threshold and interpret the output.
SELECT name, price, positive_ratings, negative_ratings
FROM steam_games
WHERE price > 0 AND positive_ratings + negative_ratings >= 100
ORDER BY positive_ratings DESC
LIMIT 10;
