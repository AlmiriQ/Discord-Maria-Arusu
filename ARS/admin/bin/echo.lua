return function(env)
   if not env.Maria then return -1 end
   if not env.message then return -1 end
   if not env.user then return -1 end
   if env.user.level >= 64 then
      env.message.channel:send(env.message.content:gsub(env.command[1], ""):trim())
      env.message:delete()
   else
      env.message.channel:send"You do not have enough permissions to execute this file!"
   end
end