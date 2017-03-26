# ## These functions are designed to work with a local server only, which must be running separately
# ## These methods are depricated at this time, see lifx-cloud.R functions instead. 
# 
# server_ping <- function(){
#   results <- GET("http://localhost:56780/lights.json")
#   if(results$status_code != 200)
#     message("LIFX server could not be reached")
#   else
#     message("ping! LIFX server is active.")
# }
# 
# server_status <- function(selector="all"){
#   results <- GET(paste0("http://localhost:56780/lights/", selector))
#   dat <- RJSONIO::fromJSON(content(results, as="text"))
# }
# 
# 
# server_on <- function(selector="all"){
#   results <- PUT(paste0("http://localhost:56780/lights/", selector, "/on"))
# }
# 
# server_off <- function(selector="all"){
#   results <- PUT(paste0("http://localhost:56780/lights/", selector, "/off"))
# }
# 
# 
# server_toggle <- function(selector="all"){
#   results <- PUT(paste0("http://localhost:56780/lights/", selector, "/toggle"))
# }
# 
# server_color <- function(selector="all", hue, saturation=1, brightness=1, duration=1){
#   settings <- RJSONIO::toJSON(list(hue=hue, saturation=saturation, brightness=brightness, duration=duration))
#   results <- PUT(paste0("http://localhost:56780/lights/", selector, "/color"), body=settings, encode="json")
# }
# 
# # Briefly set light(s) to green, then restore previous setting
# # @param selector which lights should we toggle?
# # @param duration time in seconds for how long should the light be green?
# # 
# server_success <- function(selector="all", duration=Inf){
#   current <- server_status(selector)
#   server_color(selector, hue=120, saturation=1, brightness=1, duration=0.1) # duration is speed of change
#   if(duration < Inf){
#     Sys.sleep(duration)
#     # FIXME restores all bulbs to the property of the first bulb
#     server_color(selector, 
#           hue = current[[1]]$color[["hue"]], 
#           saturation = current[[1]]$color[["saturation"]],
#           brightness = current[[1]]$color[["brightness"]],
#           duration = 0.1)
#   }
# }
# 
# # Briefly set light(s) to red
# # @param selector which lights should we toggle?
# # @param duration time in seconds for how long should the light be green?
# # 
# server_fail <-  function(selector="all", duration=Inf){
#   current <- server_status(selector)
#   server_color(selector, hue=1, saturation=1, brightness=1, duration=0.1) # duration is speed of change
#   if(duration < Inf){
#     Sys.sleep(duration)
#     # FIXME restores all bulbs to the property of the first bulb
#     server_color(selector, 
#           hue = current[[1]]$color[["hue"]], 
#           saturation = current[[1]]$color[["saturation"]],
#           brightness = current[[1]]$color[["brightness"]],
#           duration = 0.1)
#   }
# }
# 
# 
