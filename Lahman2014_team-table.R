######################################################
# 
# A short set of instructions that starts with the "Teams" table in the Lahman database
# and summarizes it for the Shiny app 
#
# 
#
# Thus rather than having the app 
# 1. remove unnecessary records (rows) and fields (columns) and
# 2. run the calculations for the runs-per-game, runs-allowed-per-game, and indexed versions of those
# the calculations are conducted here.
#
# This will vastly improve the performance of the app.
#
######################################################

# package load 
library(dplyr)
library(reshape)
library(ggplot2)
#

# CREATE LEAGUE SUMMARY TABLES
# ============================
#
# load the Lahman data table "Teams", filter
Teams <- read.csv("Teams_2014.csv", header=TRUE)

# select a sub-set of teams from 1901 [the establishment of the American League] forward to most recent year
LG_RPG <- Teams %>%
  filter(yearID > 1900, lgID != "FL") %>%
  group_by(yearID, lgID) %>%
  summarise(R=sum(R), RA=sum(RA), G=sum(G)) %>%
  mutate(leagueRPG=R/G, leagueRAPG=RA/G)
head(LG_RPG)
#
# and a version with just the MLB totals
MLB_RPG <- Teams %>%
  filter(yearID > 1900, lgID != "FL") %>%
  group_by(yearID) %>%
  summarise(R=sum(R), RA=sum(RA), G=sum(G)) %>%
  mutate(leagueRPG=R/G, leagueRAPG=RA/G)
head(MLB_RPG)
#
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#
# create data frame Teams.merge with league averages
Teams.merge <-  Teams %>%
  mutate(teamRPG=(R/G), teamRAPG=(RA/G), WLpct=(W/G)) 
Teams.merge <- 
  merge(Teams.merge, LG_RPG, by = c("yearID", "lgID"))
#
# create new values to compare the individual team's runs/game compares to the league average that season
Teams.merge <- Teams.merge %>%
  # runs scored index where 100=the league average for that season
  mutate(R_index = (teamRPG/leagueRPG)*100) %>%
  mutate(R_index.sd = sd(R_index)) %>%
  mutate(R_z = (R_index - 100)/R_index.sd) %>%
  # runs allowed
  mutate(RA_index = (teamRAPG/leagueRAPG)*100) %>%
  mutate(RA_index.sd = sd(RA_index)) %>%
  mutate(RA_z = (RA_index - 100)/RA_index.sd)
#
head(LG_RPG)
head(MLB_RPG)
head(Teams.merge)
#
# round values for data display
LG_RPG$leagueRPG <- round(LG_RPG$leagueRPG, 2)  
LG_RPG$leagueRAPG <- round(LG_RPG$leagueRAPG, 2)  
#
MLB_RPG$leagueRPG <- round(MLB_RPG$leagueRPG, 2)  
MLB_RPG$leagueRAPG <- round(MLB_RPG$leagueRAPG, 2)  
#
Teams.merge$R_index <- round(Teams.merge$R_index, 2)  
Teams.merge$R_index.sd <- round(Teams.merge$R_index.sd, 2)  
Teams.merge$R_z <- round(Teams.merge$R_z, 2)  
Teams.merge$RA_index <- round(Teams.merge$RA_index, 2)  
Teams.merge$RA_index.sd <- round(Teams.merge$RA_index.sd, 2)  
Teams.merge$RA_z <- round(Teams.merge$RA_z, 2)  
Teams.merge$teamRPG <- round(Teams.merge$teamRPG, 2)  
Teams.merge$teamRAPG <- round(Teams.merge$teamRAPG, 2)  
Teams.merge$leagueRPG <- round(Teams.merge$leagueRPG, 2)  
Teams.merge$leagueRAPG <- round(Teams.merge$leagueRAPG, 2)  
Teams.merge$WLpct <- round(Teams.merge$WLpct, 3)  

head(LG_RPG)
head(MLB_RPG)
head(Teams.merge)


write.csv(LG_RPG, file="LG_RPG.csv", row.names=FALSE)
write.csv(MLB_RPG, file="MLB_RPG.csv", row.names=FALSE)
write.csv(Teams.merge, file="Teams_merge.csv", row.names=FALSE)