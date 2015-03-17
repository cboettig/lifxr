## SEE Docs: https://api.lifx.com/

BASE <- "https://api.lifx.com"
VERSION <- "v1beta1"

#' ping
#' 
#' ping the lifx API and get a status reply
#' @import httr
#' @import RJSONIO
#' @export
ping <- function(){
  results <- GET(paste0(BASE, "/", VERSION, "/lights.json"), 
                 query = list(access_token = getOption("LIFX_PAT", "")))
  if(results$status_code != 200)
    message("LIFX bulbs could not be reached")
  else
    message("ping! LIFX is active.")
}

#' lights
#' 
#' list lights, their status and properties
#' @param selector a string in format '[type]:[value]', where type can be 
#' 'all', 'id', 'label', 'group', 'group_id', 'location', 'location_id', 
#' 'scene_id', and value is what you want to target. The default is 'all',
#' which needs no value argument. 
#' @return a list of all lights, status, and properties 
#' @export
lights <- function(selector = "all"){
  results <- GET(paste0(BASE, "/", VERSION, "/lights/", selector), 
                 query = list(access_token = getOption("LIFX_PAT", "")))
  RJSONIO::fromJSON(content(results, as="text"))
}

#' current color
#' 
#' list of the current colors, in a format valid for \code{\link{color}}
#' @inheritParams lights
#' @return httr response object
#' @export
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


#' toggle
#' 
#' toggle lights on and off
#' @inheritParams lights
#' @return httr response object
#' @export
toggle <- function(selector = "all"){
  POST(paste0(BASE, "/", VERSION, "/lights/", selector, "/toggle.json"), 
       query = list(access_token = getOption("LIFX_PAT", "")))
}

#' power
#' 
#' power lights on or off with a fade duration
#' @param state on or off?
#' @param duration the length of the effect
#' @inheritParams lights
#' @return httr response object
#' @details Not exported because it conflicts with stats::power. see on() and off()
power <- function(state = c("on", "off"), selector = "all", duration = 1.0){
  state <- match.arg(state)
  PUT(paste0(BASE, "/", VERSION, "/lights/", selector, "/power.json"), 
      query = list(state = state, 
                   duration = duration, 
                   access_token = getOption("LIFX_PAT", "")))
}


#' off
#' 
#' power lights off with a fade duration
#' @param duration the length of the effect
#' @inheritParams lights
#' @return httr response object
#' @export
off <-  function(selector = "all", duration = 1.0){
  power("off", selector = selector, duration = duration)
}


#' on
#' 
#' power lights on 
#' @param duration the length of the effect
#' @inheritParams lights
#' @return httr response object
#' @export
on <- function(selector = "all", duration = 1.0){
  power("on", selector = selector, duration = duration)
}


#' color
#' 
#' set lifx color
#' @param color a string describing the desired color; see examples.
#' @param duration the length of the effect
#' @param power_on should the light be powered on if it is off? (FALSE just leaves light off)
#' @inheritParams lights
#' @details Note that the kelvin temperature ranges from 2700 to 8000. Hue in HSB list is 
#' a number between 0 and 360, whereas saturation and brightness should be between 0 and 1.
#' 
#' @examples \dontrun{
#'  color("green", "label:desk")   # deep green, brightness untouched on lights labeled 'desk'
#'  color("blue brightness:100%")  # deep blue, maximum brightness
#'  color("hsb:0,1,1")             # deep red, maximum brightness
#'  color("random")                # random hue, maximum saturation, brightness untouched
#'  color("kelvin:2700")           # warm white, brightness untouched
#'  color("saturation:100%")       # set maximum saturation
#' }
#' @return httr response object
#' @export
color <- function(color, selector="all", duration = 1.0, power_on = TRUE){
  PUT(paste0(BASE, "/", VERSION, "/lights/", selector, "/color.json"), 
      query = list(color = color, 
                   duration = duration, 
                   power_on = power_on,
                   access_token = getOption("LIFX_PAT", "")))
}


#' breathe
#' 
#' Display a breathe effect
#' @param from_color Same syntax as color, defaults to current color (of first bulb in selection)
#' @param period time in seconds for the cycle to take place
#' @param cycles number of cycles to perform
#' @param persist should the color persist after the effect? default is FALSE (returns to original color)
#' @param peak when in the cycle should the color be at it's maximum intensity?
#' @inheritParams color
#' @examples \dontrun{
#' breathe("purple", "blue")
#' }
#' @export
breathe <- function(color, from_color = current_color(selector)[[1]], 
                    period = 10.0, cycles = 2, persist = FALSE,
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

#' pulse
#' 
#' pulse a color for a defined period
#' @inheritParams breathe
#' @param duty_cycle Ratio of the period where color is active. Only used for pulse. Defaults to 0.5. Range: 0-1
#' @return httr response object
#' @export
pulse <- function(color, from_color = current_color(selector)[[1]], 
                  period = 5.0, cycles = 1, persist = FALSE,
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

#' label
#' 
#' add a label to a bulb
#' @param label the label for the bulb
#' @param selector selector pattern for a single bubl, e.g. id:<idstring>
#' @return httr response object
#' @export
label <- function(label, selector) {
  PUT(paste0(BASE, "/", VERSION, "/lights/", selector, "/label.json"), 
      query = list(label = label, 
                   access_token = getOption("LIFX_PAT", "")))
}

#' scene
#' 
#' turn on a scene for a bulb
#' @inheritParams power
#' @param scene_id the id of the desired scene
#' @return httr response object
#' @export
scene <- function(state = c("on", "off"), scene_id, duration = 1.0){
  state <- match.arg(state)
  PUT(paste0(BASE, "/", VERSION, "/scenes/scene_id:", scene_id, "/power.json"), 
      query = list(state = state, 
                   duration = duration, 
                   access_token = getOption("LIFX_PAT", "")))
}

#' parse color
#'
#' Parse a color string and return hue, saturation, brightness and kelvin values
#' @param string The color string to parse
#' @return hsbk information for the string. NOTE: This API endpoing appears not to be working yet! 
#' @export
parse_color <- function(string){
  results <- PUT(paste0(BASE, "/", VERSION, "/color.json"), 
                 query = list(string = string,
                              access_token = getOption("LIFX_PAT", "")))
  RJSONIO::fromJSON(content(results, as="text"))
}




