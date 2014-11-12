# Run scoring in Shiny -- ui
#
# written by Martin Monkman
# last update: 2014-11-09
#
# resources used & plagarized
#  - RStudio's widget gallery http://shiny.rstudio.com/gallery/widget-gallery.html
#
library(shiny)

shinyUI(navbarPage("MLB run scoring trends",
                   tabPanel("league",
                            #
                            titlePanel("Per-game run scoring by league"),
                            #
                            # Sidebar with a dropdown list of ministry names
                            sidebarLayout(
                              
                              sidebarPanel(

                                # slider for year range
                                uiOutput("lg_yearrange"),
                                hr(),
                                # checkbox for league split into facet
                                checkboxInput("leaguesplitselect", label = h4("Plot each league separately"), value = FALSE),
                                hr(),
                                hr(),
                                # checkbox for trend line
                                checkboxInput("trendlineselect", label = h4("Add a trend line"), value = FALSE),
                                # slider bar for trend line sensitivity 
                                sliderInput("trendline_sen_sel", 
                                            label = (h5("Select trend line sensitivity")), 
                                            min = 0.05, max = 1, value = .50, step = .05),
                                hr(),
                                # radio buttons for trend line confidence interval 
                                radioButtons("trendline_conf_sel", 
                                             label = h5("Select trend line confidence level"),
                                             choices = list("0.10" = .1, "0.50" = 0.5,
                                                            "0.90" = 0.9, "0.95" = 0.95,
                                                            "0.99" = 0.99, "0.999" = 0.999, 
                                                            "0.9999" = 0.9999), 
                                             selected = 0.95),
                                hr(),
                                column(4, verbatimTextOutput("trendline_conf"))
                              ),
                              # ---- end sidebarPanel
                              # 
                              mainPanel(
                                plotOutput("plot_MLBtrend")
                              )
                              # ---- end mainPanel
                            )
                            # ---- end sidebarLayout                              
                   ),
                   # ---------- end tabPanel "league"
                   #
                   tabPanel("reference",
                              mainPanel(
                                   includeMarkdown("runscoring_references.Rmd")
                            )
                   )
                   
                   # ----- end tabPanel "reference"
))
# ---------- end navbarPage
#  
#  
