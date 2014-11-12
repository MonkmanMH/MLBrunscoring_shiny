# Run scoring in Shiny -- server
#
# written by Martin Monkman
# last update: 2014-11-09
#
#
# ####################
#
# package load 
library(shiny)
library(dplyr)
library(ggplot2)
library(Lahman)
#
# load the Lahman data table "Teams"
data(Teams)
#
#
# CREATE LEAGUE SUMMARY TABLES
# ============================
#
# select a sub-set of teams from 1901 [the establishment of the American League] forward to most recent year
#
LG_RPG <- Teams %>%
  filter(yearID > 1900, lgID != "FL") %>%
  group_by(yearID, lgID) %>%
  summarise(R=sum(R), RA=sum(RA), G=sum(G)) %>%
  mutate(RPG=R/G, RAPG=RA/G)
# and a version with just the MLB totals
MLB_RPG <- Teams %>%
  filter(yearID > 1900, lgID != "FL") %>%
  group_by(yearID) %>%
  summarise(R=sum(R), RA=sum(RA), G=sum(G)) %>%
  mutate(RPG=R/G, RAPG=RA/G)
#
firstyear <- MLB_RPG$yearID[1]
mostrecentyear <- tail(MLB_RPG$yearID, 1)
#
#
# ####################################################
# 
# Define server logic
shinyServer(function(input, output) {
  
  # trendline select (TRUE / FALSE)
  output$trendlineselectvalue <- renderPrint({ input$trendlineselect })
  
  # trendline sensitivity (slider)
  output$trendline_sen <- renderPrint({ input$trendline_sen_sel })
  
  # trendline confidence interval (slider)
  output$trendline_conf <- renderPrint({ input$trendline_conf_sel })
  
  # define yearrange for UI 
  output$lg_yearrange <- renderUI({
    sliderInput("lg_yearrange_input", label = h4("Select year range to plot"), 
                min = 1901, max = mostrecentyear, value = c(1901, mostrecentyear), 
                step = 1, round = TRUE, format = "####",
                animate = TRUE)
  })
  #
# +++++ PLOTS: RUNS SCORED PER GAME BY LEAGUE

# American League
output$plot_MLBtrend <- renderPlot({
    # plot the data
    MLBRPG <- ggplot(MLB_RPG, aes(x=yearID, y=RPG)) +
             geom_point() +
             xlim(input$lg_yearrange_input[1], input$lg_yearrange_input[2]) +
             ylim(3, 6) +
             ggtitle(paste("Major League Baseball: runs per team per game", 
                           input$lg_yearrange_input[1], "-", input$lg_yearrange_input[2])) +
             xlab("year") + ylab("runs per game")  
    # plot each league separately?
    if (input$leaguesplitselect == TRUE) {
      MLBRPG <- ggplot(LG_RPG, aes(x=yearID, y=RPG)) +
        geom_point() +
        xlim(input$lg_yearrange_input[1], input$lg_yearrange_input[2]) +
        ylim(3, 6) +
        ggtitle(paste("Major League Baseball: runs per team per game", 
                      input$lg_yearrange_input[1], "-", input$lg_yearrange_input[2])) +
        xlab("year") + ylab("runs per game") +
        facet_grid(lgID ~ .)
    }
    # add trend line to plot?
      if (input$trendlineselect == TRUE) {
          MLBRPG <- MLBRPG + 
            stat_smooth(method=loess, 
                        span=input$trendline_sen_sel,
                        level=as.numeric(input$trendline_conf_sel))
         }
    # final plot
    MLBRPG

  })
  # ----------- end MLBtrend plot

#
})
# ----------- end shinyServer function 