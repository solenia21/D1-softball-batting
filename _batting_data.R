library(httr2)
library(jsonlite)
library(rvest)
library(dplyr)
library(purrr)

fetch_season_batting <- \(season) {
  payload <- list(
    `batting-table` = list(
      callback = "adv_stats",
      args = list(
        object_id = 0,
        post_type = "national",
        season = as.character(season),
        split_type = "overall",
        template = "batting-table"
      )
    )
  )

  resp <- request("https://d1softball.com/wp-json/d1/v1/dynamic-content/") |>
    req_body_json(payload) |>
    req_perform() |>
    resp_body_string() |>
    fromJSON()

  read_html(resp$content$`batting-table`) |>
    html_element("#batting-stats") |>
    html_table() |>
    mutate(Season = as.character(season))
}

batting <- map(c(2025, 2026), fetch_season_batting) |>
  list_rbind() |>
  select(Season, Player, Team, Class, POS, BA, OBP, SLG, OPS, GP, PA, AB, H, HR, BB, K) |>
  filter(!is.na(BA), !is.na(OBP), !is.na(SLG))
