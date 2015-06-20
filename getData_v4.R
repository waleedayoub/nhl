# set working directory
# need to figure out how to make this system agnostic
# will load all this to a shinyapps account anyway...
# os x dir location
nhldir <- '/Users/waleed/development/R/nhl/'
# otherwise use this location
nhldir <- './'
setwd(nhldir)

databyGame <- paste0(nhldir, 'nhlr-data/')
dataAll <- paste0(nhldir, 'source-data/')

# load libraries
library(nhlscrapr)
library(dplyr)
library(ggplot2)
library(stringi)
library(tidyr)
library(lubridate)
library(scales)
# import the pool member to player look up table
# i create this in excel from Dean's pool file
members <- read.table("poolmember_lkp.txt", sep="\t", header = TRUE, stringsAsFactors = FALSE,
                      strip.white = TRUE)
members <- rename(members, playername = PLAYER_NAME)
head(members)
str(members)

# start the process to get data using nhlscrapr

# set the season to grab data for
theSeason <- '20142015'

# full.game.database creates a table with all available games
all.games <- full.game.database()
table(all.games$season)

# grab just the 2014/2015 playoff games
playoffgames <- filter(all.games, season==theSeason, session=='Playoffs')
gcodesALL <- distinct(playoffgames, gcode) %>% select(gcode, status)
gcodesALL

load('./source-data/nhlscrapr-20142015.RData')
load('./source-data/nhlscrapr-core.RData')

# get the list of downloaded gcodes from the working dir
gcodesPRE <- distinct(grand.data, gcode) %>% select(gcode)

# get the list of gcodes we still need -- how to account for games that didn't happen???
gcodesNEW <- anti_join(gcodesALL, gcodesPRE, by='gcode') %>% select(gcode)

new.games <- inner_join(playoffgames, gcodesNEW, by='gcode')
latestgame <- filter(new.games, gcode==30416)

#### only run this when grabbing new games
#### will need to figure out how to only get the new games
compile.all.games(rdata.folder = databyGame, output.folder = dataAll, new.game.table=playoffgames)

load('./source-data/nhlscrapr-20142015.RData')
load('./source-data/nhlscrapr-core.RData')
####

# keep only the downloaded info with the word processed in it

# put all this into a function that you use lapply on based on nGames

str(grand.data)
str(roster.master)

goaldata <- filter(grand.data, etype=='GOAL')
head(roster.master)
head(goaldata)

# keep only the relevant fields
fields <- c('refdate','ev.team','ev.player.1','ev.player.2','ev.player.3')
goaldata <- goaldata[fields]

# filter goals and assists from the multiple columns
# create a master table with player, date and points accumulated
# get player names into the tables and summarise goals and assists
# by date and by player
goalsPlayer <- left_join(goaldata, roster.master, c("ev.player.1"="player.id")) %>%
  group_by(refdate, firstlast) %>% 
  summarise(goals=n()) %>%
  mutate(playername=firstlast, date=mdy("Jan 1 2001")+days(refdate)) %>%
  select(date, playername, goals)

a1Player <- left_join(goaldata, roster.master, c("ev.player.2"="player.id")) %>%
  group_by(refdate, firstlast) %>% 
  summarise(assists1=n()) %>%
  arrange(desc(assists1)) %>% 
  mutate(playername=firstlast, date=mdy("Jan 1 2001")+days(refdate)) %>%
  select(date, playername, assists1)

a2Player <- left_join(goaldata, roster.master, c("ev.player.3"="player.id")) %>%
  group_by(refdate, firstlast) %>% 
  summarise(assists2=n()) %>%
  arrange(desc(assists2)) %>% 
  mutate(playername=firstlast, date=mdy("Jan 1 2001")+days(refdate)) %>%
  select(date, playername, assists2)

assistsPlayer <- merge(a1Player, a2Player, all=TRUE )
ptsPlayer <- merge(goalsPlayer, assistsPlayer, all=TRUE)

ptsPlayer[is.na(ptsPlayer)] <- 0

# add up stuff to get points
x <- mutate(ptsPlayer, points = goals*2+assists1+assists2)

# join ptsTable with members table to get points by member
z <- merge(x, members, by="playername")

cumPts <- group_by(z, date, POOL_MEMBER) %>% summarise(goals=sum(goals), assists=sum(assists1,assists2), points = sum(points)) %>%
  group_by(POOL_MEMBER) %>% mutate(cumpts = cumsum(points))

tail(cumPts, n=20)
# ptsMember is the final table we need to add to and then plot
cumPts$date <- as.Date(cumPts$date)
ggplot(cumPts, aes(x=date, y=cumpts)) + ylab("Points") + geom_line(aes(colour=POOL_MEMBER)) + 
  scale_x_date(breaks="5 days", labels=date_format("%m/%d"))

saveRDS(cumPts, file='./shinyapps/ptsDatabyDate.rds')

saveRDS(cumPts, file='./shinyapps/ptsDatabyDate.rds')