return function(env)
   if not env.Maria then return -1 end
   if not env.message then return -1 end
   env.message.channel:send("Your level is: " .. env.Maria.level_to_string(env.user.level))
end