setwd('./development/R/nhl/')

library(nhlscrapr)
library(dplyr)

all.games <- full.game.database()
table(all.games$season,all.games$session)

distinct(select(all.games,session))
distinct(select(all.games,season))

# select only the playoff games for 2014/2015 season
filter(all.games, session=='Playoffs', season==20142015)
playoffgames <- filter(all.games, season == 20142015, session=='Playoffs')

head(playoffgames)

# download all the game info for playoff games
compile.all.games(new.game.table=playoffgames)

# figure out how to isolate just the info required for goals/assists
# then iterate through each file and process
load("./nhlr-data/20142015-30216-processed.RData")
game.info$date
summary(game.info)
head(game.info$playbyplay)

game.info$playbyplay[[:3,4]]

summary(game.info$playbyplay)

head(game.info$playbyplay['etype'])
distinct(game.info$playbyplay['etype'])

goaldata <- filter(game.info$playbyplay,etype=='GOAL')
head(goaldata)
goaldata[1,]
summary(goaldata)
goaldata

# create a table with pool participant to player lookup

# merge the 2 tables

# plot the cumulative point haul by day