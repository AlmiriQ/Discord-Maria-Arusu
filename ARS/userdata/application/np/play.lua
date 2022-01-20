return function(env)
   if not env.Maria then return -1 end
   if not env.message then return -1 end
   env.Maria.musicPlayer.queue_push(env.argv[2])
   if not env.Maria.musicPlayer.playing then
      env.Maria.musicPlayer:emit("queue-play", env.message)
   end
end