library(reshape2)
str(grand.data)

blah <- select(grand.data, gcode, hometeam, awayteam, home.score, away.score) %>%
  group_by(gcode, hometeam, awayteam) %>%
  summarise(home.score = max(home.score), away.score = max(away.score)) %>%
  distinct(hometeam, awayteam, home.score, away.score)

blah$winner <- (ifelse(blah$home.score>blah$away.score, blah$hometeam, blah$awayteam))

head(blah,n=20)
t1 <- distinct(grand.data, hometeam) %>% distinct(hometeam) %>% select(hometeam) %>% rename(team=hometeam)
t2 <- distinct(grand.data, awayteam) %>% distinct(awayteam) %>% select(awayteam) %>% rename(team=awayteam)
teams <- inner_join(t1, t2, by='team')

# these give you games played
table(blah$hometeam)
table(blah$awayteam)

# this gives you remaining status
table(blah$winner)
head(members)
filter(members, POOL_MEMBER=="WALEED")
filter(members, playername=="PATRICK KANE")

ptsData.byMember <- group_by(cumPts, POOL_MEMBER) %>% 
  summarise(goals=sum(goals), assists=sum(assists), points = sum(points)) %>% 
  arrange(desc(points))

tail(goaldata, n=10)
tail(blah, n=10)
ptsData.byMember

# need a table that looks like this
# TEAM REMAINING
# MTL 0
# CHI 1
# etc...