return function(env)
   if not env.Maria then return -1 end
   if not env.message then return -1 end
   if env.user.level < 2 then env.message.channel:send"You do not have enough permissions to execute this file!" return end 
   env.Maria.musicPlayer:emit("infinite-nya-break", env.message)
end