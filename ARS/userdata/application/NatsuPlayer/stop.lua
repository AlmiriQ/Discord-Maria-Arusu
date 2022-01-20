return function(env)
   if not env.Maria then return -1 end
   if not env.message then return -1 end
   env.Maria.musicPlayer:emit("queue-stop", env.message)
end