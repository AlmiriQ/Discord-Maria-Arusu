return function(env)
   if not env.Maria then return -1 end
   if not env.message then return -1 end
   env.Maria.musicPlayer:emit("queue-start", env.message)
   env.Maria.musicPlayer.queue_push(env.argv[2])
   env.Maria.musicPlayer:emit("queue-play", env.message)
end