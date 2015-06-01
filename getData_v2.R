# set working directory
# need to figure out how to make this system agnostic
# will load all this to a shinyapps account anyway...
# os x dir location
nhldir1 <- '/Users/waleed/development/R/nhl/'
nhldir <- './'
nhldata <- paste0(nhldir1, 'nhlr-data/')
setwd(nhldir1)

# load libraries
library(nhlscrapr)
library(dplyr)
library(ggplot2)
library(stringi)
library(tidyr)
# set the season to grab data for
theSeason <- '20142015'

# import the pool member to player look up table
# i create this in excel from Dean's pool file
members <- read.table("poolmember_lkp.txt", sep="\t", header = TRUE, stringsAsFactors = FALSE,
                      strip.white = TRUE)
members <- rename(members, playername = PLAYER_NAME)
head(members)
str(members)

# start the process to get data using nhlscrapr
# full.game.database creates a table with all available games
all.games <- full.game.database()
table(all.games$season,all.games$session)

summary(all.games)
head(filter(all.games, season==theSeason, session=='Playoffs'))

# grab just the 2014/2015 playoff games
playoffgames <- filter(all.games, season==theSeason, session=='Playoffs')

#### only run this when grabbing new games
#### will need to figure out how to only get the new games
# compile.all.games(new.game.table=playoffgames)
####

# keep only the downloaded info with the word processed in it
a1 <- dir(nhldata)
theFiles <- a1[ grepl("processed", a1) ]

# now load all those files
nGames <- length(theFiles)

# put all this into a function that you use lapply on based on nGames

for(i in 1:nGames) {
  load(paste0(nhldata,theFiles[i]))
  print(game.info$teams)
  print(game.info$score)
}

load(paste0(nhldata,theFiles[2]))

distinct(game.info$playbyplay['etype'])

summary(game.info$playbyplay)
game.info$teams
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

# split the player number and name into 2 fields in order to match to lookup
t4 <- mutate(t3, playernum = gsub(" .*$", "", player), 
             playername = substr(player, regexec(" ", player)[[1]][1]+1, nchar(player)))

# clean up and keep just the fields you need for the viz
ptsTable <- select(t4, refdate, team, playernum, playername, tot_pts)

# join ptsTable with members table to get points by member
t5 <- merge(ptsTable, members, by="playername")
t6 <- group_by(t5, refdate, POOL_MEMBER) %>% summarise(POINTS = sum(tot_pts))
t6
ptsMember <- merge(ptsMember, t6, by=POOL_MEMBER, all=TRUE)
ptsMember <- group_by(ptsMember, POOL_MEMBER) %>% summarise(POINTS = sum(POINTS))
# ptsMember is the final table we need to add to and then plot
ggplot(t6, aes(x=refdate, y=POINTS)) + geom_line() + geom_point()
