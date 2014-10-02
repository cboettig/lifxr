

#' @import httr
#' @import RJSONIO
ping <- function(){
  results <- GET("http://localhost:56780/lights.json")
  if(results$status_code != 200)
    message("LIFX server could not be reached")
  else
    message("ping! LIFX server is active.")
}

status <- function(selector="all"){
  results <- GET(paste0("http://localhost:56780/lights/", selector))
  dat <- RJSONIO::fromJSON(content(results, as="text"))
}


toggle <- function(selector="all"){
  results <- PUT(paste0("http://localhost:56780/lights/", selector, "/toggle"))
}

color <- function(selector="all", hue, saturation=1, brightness=1, duration=1){
  settings <- RJSONIO::toJSON(list(hue=hue, saturation=saturation, brightness=brightness, duration=duration))
  results <- PUT(paste0("http://localhost:56780/lights/", selector, "/color"), body=settings, encode="json")
}

#' Briefly set light(s) to green, then restore previous setting
#' @param selector which lights should we toggle?
#' @param duration time in seconds for how long should the light be green?
success <- function(selector="all", duration=4){
  current <- status(selector)
  color(selector, hue=120, saturation=1, brightness=1, duration=0.1) # duration is speed of change
  Sys.sleep(duration)
  # FIXME restores all bulbs to the property of the first bulb
  color(selector, 
        hue = current[[1]]$color[["hue"]], 
        saturation = current[[1]]$color[["saturation"]],
        brightness = current[[1]]$color[["brightness"]],
        duration = 0.1)
}

#' Briefly set light(s) to red
fail <-  function(selector="all", duration=4){
  current <- status(selector)
  color(selector, hue=1, saturation=1, brightness=1, duration=0.1) # duration is speed of change
  Sys.sleep(duration)
  # FIXME restores all bulbs to the property of the first bulb
  color(selector, 
        hue = current[[1]]$color[["hue"]], 
        saturation = current[[1]]$color[["saturation"]],
        brightness = current[[1]]$color[["brightness"]],
        duration = 0.1)
}


