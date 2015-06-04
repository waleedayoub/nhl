# set working directory
# need to figure out how to make this system agnostic
# will load all this to a shinyapps account anyway...
# os x dir location
nhldir1 <- '/Users/waleed/development/R/nhl/'
nhldir <- './'
nhldata <- paste0(nhldir1, 'nhlr-data/')
sourcedata <- paste0(nhldir1, 'source-data/')
setwd(nhldir1)

# load libraries
library(nhlscrapr)
library(dplyr)
library(ggplot2)
library(stringi)
library(tidyr)
library(lubridate)

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
table(all.games$season,all.games$session)

summary(all.games)
head(filter(all.games, season==theSeason, session=='Playoffs'))

# grab just the 2014/2015 playoff games
playoffgames <- filter(all.games, season==theSeason, session=='Playoffs')
distinct(playoffgames, gcode) %>% select(gcode)
# get the list of downloaded gcodes from the working dir

#### only run this when grabbing new games
#### will need to figure out how to only get the new games
compile.all.games(rdata.folder = nhldata, output.folder = sourcedata, new.game.table=playoffgames)

####

# keep only the downloaded info with the word processed in it

# put all this into a function that you use lapply on based on nGames

load('./source-data/nhlscrapr-20142015.RData')
load('./source-data/nhlscrapr-core.RData')

goaldata <- filter(grand.data, etype=='GOAL')
head(roster.master)
head(goaldata)

# keep only the relevant fields
fields <- c('refdate','ev.team','ev.player.1','ev.player.2','ev.player.3')
goaldata <- goaldata[fields]

goals <- goaldata %>% left_join(roster.master, c("ev.player.1"="player.id"))

goalsPlayer <- group_by(goals, refdate, firstlast) %>% 
  summarise(goals=n()) %>%
  arrange(desc(goals)) %>% 
  mutate(playername=firstlast, date=mdy("Jan 1 2001")+days(refdate)) %>%
  select(date, playername, goals)

assists1 <- goaldata %>% left_join(roster.master, c("ev.player.2"="player.id"))

a1Player <- group_by(assists1, refdate, firstlast) %>% 
  summarise(assists1=n()) %>%
  arrange(desc(assists1)) %>% 
  mutate(playername=firstlast, date=mdy("Jan 1 2001")+days(refdate)) %>%
  select(date, playername, assists1)

assists2 <- goaldata %>% left_join(roster.master, c("ev.player.3"="player.id"))

a2Player <- group_by(assists2, refdate, firstlast) %>% 
  summarise(assists2=n()) %>%
  arrange(desc(assists2)) %>% 
  mutate(playername=firstlast, date=mdy("Jan 1 2001")+days(refdate)) %>%
  select(date, playername, assists2)

assistsPlayer <- merge(a1Player, a2Player, all=TRUE )
ptsPlayer <- merge(goalsPlayer, assistsPlayer, all=TRUE)

ptsPlayer[is.na(ptsPlayer)] <- 0

# add up stuff to get points
x <- mutate(ptsPlayer, points = goals*2+assists1+assists2)

y <- group_by(x, playername) %>% summarise(totpts=sum(points)) %>% arrange(desc(totpts))

# join ptsTable with members table to get points by member
z <- merge(x, members, by="playername")

z1 <- group_by(z, date, POOL_MEMBER) %>% 
  summarise(totpoints = sum(points))

z3 <- group_by(z1, POOL_MEMBER) %>%
  mutate(cumpts = cumsum(totpoints))

write.csv(x=z3, file = "./shinyapps/data.csv")
# ptsMember is the final table we need to add to and then plot
ggplot(z3, aes(x=date, y=cumpts)) + ylab("Points") + geom_line(aes(colour=POOL_MEMBER))
