setwd('./development/R/nhl/')

library(nhlscrapr)
library(dplyr)

all.games <- full.game.database()
table(all.games$season,all.games$session)
distinct(select(all.games,session))
distinct(select(all.games,season))

filter(all.games, session=='Playoffs', season==20142015)
these.games <- subset(all.games, season == 20142015 & gcode >= 30214 & gcode <=30220)

compile.all.games(new.game.table=these.games)
load("./nhlr-data/20142015-30216-processed.RData")
game.info$date
summary(game.info)
head(game.info$playbyplay)

head(game.info$playbyplay['etype'])
distinct(game.info$playbyplay['etype'])

goaldata <- filter(game.info$playbyplay,etype=='GOAL')
head(goaldata)
goaldata[1,]
summary(goaldata)
goaldata
