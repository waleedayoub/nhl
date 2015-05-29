# set working directory
# need to figure out how to make this system agnostic
# will load all this to a shinyapps account anyway...
nhldir <- './'
nhldata <- paste0(nhldir, 'nhlr-data/')
setwd(nhldir)

# load libraries
library(nhlscrapr)
library(dplyr)
library(ggplot2)
library(stringi)
library(tidyr)
# set the season to grab data for
theSeason <- '20142015'


# start the process to get data using nhlscrapr
# full.game.database creates a table with all available games
all.games <- full.game.database()
table(all.games$season,all.games$session)

summary(all.games)
head(filter(all.games, season==theSeason, session=='Playoffs'))

# grab just the 2014/2015 playoff games
temp <- filter(all.games, season==theSeason, session=='Playoffs')

# keep only the downloaded info with the word processed in it
a1 <- dir(nhldata)
theFiles <- a1[ grepl("processed", a1) ]

# now load all those files
nGames <- length(theFiles)

# put all this into a function that you use lapply on based on nGames
load(paste0(nhldata,theFiles[1]))

summary(game.info)
game.info$score
goaldata <- filter(game.info$playbyplay, etype=='GOAL')

# keep only the relevant fields
fields <- c('refdate','ev.team','ev.player.1','ev.player.2','ev.player.3')
goaldata <- goaldata[fields]

# need to create a table that looks like this:
# refdate | team | player_num | player_name | goals | assists | tot_pts = goals*2+assists
# there has to be a way to use some kind of apply or loop function to simplify ...
byGoals <- group_by(goaldata, refdate, team=ev.team, player=ev.player.1)
test <- summarise(byGoals, goals = n())

byAssists1 <- group_by(goaldata, refdate, team=ev.team, player=ev.player.2)
test1 <- summarise(byAssists1, assists = n())

byAssists2 <- group_by(goaldata, refdate, team=ev.team, player=ev.player.3)
test2 <- summarise(byAssists2, assists = n())

mergevars = c('refdate','team','player')
t1 <- merge(test1, test2, by=mergevars, all=TRUE)
t2 <- merge(test, t1, by=mergevars, all=TRUE)

# now calculate the tot_pts field
t2[is.na(t2)] <- 0
t3 <- mutate(t2, tot_pts = goals*2+assists.x+assists.y)
head(t3)

# split the player number and name into 2 fields in order to match to lookup
strsplit(t3$player, " ")

# clean up and keep just the fields you need for the viz
ptsTable <- select(t3, refdate, team, player, tot_pts)

# create a table with player names and pool member

