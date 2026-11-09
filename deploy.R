appFiles <- c(
  "ui.R",
  "server.R",
  "www/LegSurvey.png",
  list.files(".", pattern = "^Meta.*_S.*")
)

rsconnect::deployApp(
  appDir = here::here(),
  appFiles = appFiles,
  appName = "Meta_BTS",
  appTitle = "Metadata from Bottom Trawl Surveys"
) # 327 Mb
