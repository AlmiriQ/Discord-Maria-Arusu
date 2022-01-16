return function(env)
   if not env.Maria then return -1 end
   if not env.message then return -1 end
   local obj = env.Maria.client:getUser(env.argv[2])
   local obj_lvl = env.Maria.get_user_level(obj)
   local lvl2set = env.argv[3]
   if (env.Maria.string_to_level(lvl2set) > env.user.level) or (obj_lvl > env.user.level) then
      env.message.channel:send("You do not have enough permissions to perform operations on this file!")
      return
   end
   env.Maria.set_user_level(obj, env.Maria.string_to_level(lvl2set), true)
end