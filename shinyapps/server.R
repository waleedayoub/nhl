library(shiny)
# load the other libraries
library(nhlscrapr)
library(dplyr)
library(ggplot2)
library(stringi)
library(tidyr)
library(lubridate)

# load the pool member data
members <- read.table("poolmember_lkp.txt", sep="\t", header = TRUE, stringsAsFactors = FALSE,
                      strip.white = TRUE)
members <- rename(members, playername = PLAYER_NAME)

# load the nhl data
load('nhlscrapr-20142015.RData')
load('nhlscrapr-core.RData')

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

# Define a server for the Shiny app
shinyServer(function(input, output) {
  
  # Fill in the spot we created for a plot
  output$ptsDatePlot <- renderPlot({
    
    # Render a barplot
    ggplot(z3, aes(x=date, y=cumpts)) + ylab("Points") + geom_line(aes(colour=POOL_MEMBER))
    
  })
})