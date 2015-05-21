nhldir <- './development/R/nhl/'
setwd(nhldir)

theSeason <- '20142015'

library(nhlscrapr)
library(dplyr)

all.games <- full.game.database()
table(all.games$season,all.games$session)

summary(all.games)
head(filter(all.games, season==theSeason, session=='Playoffs'))

temp <- filter(all.games, season==theSeason, session=='Playoffs')
table(temp$status, temp$gamenumber)

theGames <- c(temp$gcode)

theFiles <- lapply(1:10, function(x) { paste0("./nhlr-data/20142015-", x, "-processed.RData")})
result <- lapply(theFiles, )