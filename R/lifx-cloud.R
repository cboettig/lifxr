## SEE Docs: https://api.lifx.com/

BASE <- "https://api.lifx.com"
VERSION <- "v1beta1"

#
#' @import httr
#' @import RJSONIO
ping <- function(){
  results <- GET(paste0(BASE, "/", VERSION, "/lights.json"), 
                 query = list(access_token = getOption("LIFX_PAT", "")))
  if(results$status_code != 200)
    message("LIFX server could not be reached")
  else
    message("ping! LIFX server is active.")
}


#' @param selector a string in format '[type]:[value]', where type can be 
#' 'all', 'id', 'label', 'group', 'group_id', 'location', 'location_id', 
#' 'scene_id', and value is what you want to target.
#' @export
#' @details Use the default selector to get a list of all lights and properties
lights <- function(selector = "all"){
  results <- GET(paste0(BASE, "/", VERSION, "/lights/", selector), 
                 query = list(access_token = getOption("LIFX_PAT", "")))
  RJSONIO::fromJSON(content(results, as="text"))
}




current_color <- function(selector = "all"){
  light_list <- lights(selector = selector)
  sapply(light_list, 
         function(light){

           if(light$color[["saturation"]] > 0)
             paste("hsb:", 
                   light$color[["hue"]], ",",
                   light$color[["saturation"]], ",",
                   light$brightness,
                   sep="")
             else 
               paste("kelvin:", 
                     light$color[["kelvin"]], 
                     " brightness:",
                     light$brightness*100, "%", 
                     sep="")
         })
}



#' @export
toggle <- function(selector = "all"){
  POST(paste0(BASE, "/", VERSION, "/lights/", selector, "/toggle.json"), 
       query = list(access_token = getOption("LIFX_PAT", "")))
}

#' @export
power <- function(state = c("on", "off"), selector = "all", duration = 1.0){
  state <- match.arg(state)
  PUT(paste0(BASE, "/", VERSION, "/lights/", selector, "/power.json"), 
      query = list(state = state, 
                   duration = duration, 
                   access_token = getOption("LIFX_PAT", "")))
}

#' color
#' 
#' set lifx color
#' @param color a string describing the desired color; see examples
#' @inheritParams lights
#' @details Note that the kelvin temperature ranges from 2700 to 8000. 
#' 
#' @examples
#'  color("green", "label:desk")   # deep green, brightness untouched on lights labeled 'desk'
#'  color("blue brightness:100%")  # deep blue, maximum brightness
#'  color("hsb:0,1,1")             # deep red, maximum brightness
#'  color("random")                # random hue, maximum saturation, brightness untouched
#'  color("kelvin:2700")           # warm white, brightness untouched
#'  color("saturation:100%")       # set maximum saturation
#' @export
color <- function(color, selector="all", duration = 1.0, power_on = TRUE){
  PUT(paste0(BASE, "/", VERSION, "/lights/", selector, "/color.json"), 
      query = list(color = color, 
                   duration = duration, 
                   power_on = power_on,
                   access_token = getOption("LIFX_PAT", "")))
}

#' breathe("purple", "blue")
breathe <- function(color, from_color, period = 10.0, cycles = 2, persist = FALSE,
                    peak = 0.5, selector="all", power_on = TRUE){
  settings <- list(color = color, 
                   from_color = from_color,
                   period = period,
                   cycles = cycles,
                   persist = persist,
                   peak = peak,
                   power_on = power_on,
                   access_token = getOption("LIFX_PAT", ""))
  POST(paste0(BASE, "/", VERSION, "/lights/", selector, "/effects/breathe.json"),
       query = settings)
}



pulse <- function(color, from_color, period = 5.0, cycles = 1, persist = FALSE,
                    duty_cycle = 0.5, selector="all", power_on = TRUE){
  settings <- list(color = color, 
                   from_color = from_color,
                   period = period,
                   cycles = cycles,
                   persist = persist,
                   duty_cycle = duty_cycle,
                   power_on = power_on,
                   access_token = getOption("LIFX_PAT", ""))
  POST(paste0(BASE, "/", VERSION, "/lights/", selector, "/effects/pulse.json"),
       query = settings)
}



label <- function(label, selector) {
  PUT(paste0(BASE, "/", VERSION, "/lights/", selector, "/label.json"), 
      query = list(label = label, 
                   access_token = getOption("LIFX_PAT", "")))
}

scene <- function(state = c("on", "off"), scene_id, duration = 1.0){
  state <- match.arg(state)
  PUT(paste0(BASE, "/", VERSION, "/scenes/scene_id:", scene_id, "/power.json"), 
      query = list(state = state, 
                   duration = duration, 
                   access_token = getOption("LIFX_PAT", "")))
}

parse_color <- function(string){
  results <- PUT(paste0(BASE, "/", VERSION, "/color.json"), 
                 query = list(string = string,
                              access_token = getOption("LIFX_PAT", "")))
  RJSONIO::fromJSON(content(results, as="text"))
}

