load('./source-data/nhlscrapr-20142015.RData')
summary(grand.data)

distinct(grand.data$refdate)

grand.data %>% select(gcode, hometeam, awayteam) %>% distinct()
for(i in 1:nGames) {
  load(paste0(nhldata,theFiles[i]))
  
  goaldata <- filter(game.info$playbyplay, etype=='GOAL')
  teamdata <- game.info$teams
  scoredata <- game.info$score
  
  
  x <- data.frame(teamdata, scoredata)
  # keep only the relevant fields
  fields <- c('gcode', 'refdate','ev.team','ev.player.1','ev.player.2','ev.player.3')
  goaldata <- goaldata[fields]
  
  if (i==1) {
    x <- goaldata
  } else {
    x <- merge(x, goaldata, all=TRUE)
  }
}

x <- data.frame(date=mdy(paste(game.info$date, collapse="-")), 
                teams=game.info$teams, score=game.info$score)

str(x)
mdy(paste(game.info$date, collapse="-"))

head(x)
summary(game.info)
count(distinct(x, refdate))
filter(goaldata, ev.player.1 == "10 COREY PERRY")
