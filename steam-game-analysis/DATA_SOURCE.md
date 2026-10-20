# Data provenance and limitations

## Attribution

Original: **Nik Davis**, [Steam Store Games (Clean dataset)](https://www.kaggle.com/datasets/nikdavis/steam-store-games), collected around May 2019. Licensed **Creative Commons Attribution 4.0 International (CC BY 4.0)**: https://creativecommons.org/licenses/by/4.0/

Intermediate reformatted CSV: **Charan1kh**, [Steam_store_analysis](https://github.com/Charan1kh/Steam_store_analysis), \`steamDataSet.csv\`, itself crediting Nik Davis. No independent licence claim is made about Charan1kh's additional formatting.

## Included data

\`data/steam_sample.csv\` contains 1200 distinct game records selected for beginner practice. The source CSV has about 27,000 rows. This is a **transformed, deterministic educational subset**, not a full official Steam export.

Processing:
1. Read the third-party CSV described above.
2. Retain only \`appid\`, \`name\`, \`genres\` (joined from genre 1/2/3), \`positive_ratings\`, \`negative_ratings\`, and \`price\`.
3. Exclude invalid numeric rows and a small set of categories/titles unsuitable for this classroom-style exercise.
4. Order the remaining records by the unsigned 32-bit value of \`appid * 2654435761\` (integer overflow); keep the first 1200, then sort by app ID for readability.

This is **not a rigorously designed probability sample**. No population-level claims should be made from it. The excluded categories, historical collection period, and transformations could affect patterns.

## Field descriptions

| Field | Meaning |
|---|---|
| appid | Historical Steam application ID |
| name | Game title |
| genres | Up to three genre fields joined with \`;\` |
| positive_ratings | Historical count of positive reviews/ratings |
| negative_ratings | Historical count of negative reviews/ratings |
| price | Historical numeric price in the source; currency/region unverified |

The R script calculates \`positive_share = positive_ratings / (positive_ratings + negative_ratings)\` when there is at least one review. It is not an official weighted Steam score.

**Do not treat these values as 2026 prices, popularity, active users, or current Steam rankings.**
