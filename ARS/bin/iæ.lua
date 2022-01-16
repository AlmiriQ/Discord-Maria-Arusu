return function(env)
   if not env.Maria then return -1 end
   if not env.message then return -1 end
   local obj_lvl = env.Maria.get_user_level(env.Maria.client:getUser(env.argv[2]))
   if obj_lvl <= env.user.level then
      env.message.channel:send("Object level is: " .. env.Maria.level_to_string(obj_lvl))
   else
      env.message.channel:send("You do not have enough permissions to perform operations on this file!")
   end
end