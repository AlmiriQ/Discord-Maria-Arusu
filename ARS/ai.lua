return function(Maria, message)
   local id = message.author.id
   print("/ai", id)
   local function level_to_string(n)
      if     n >= 128 then return "Maria"
      elseif n >= 64  then return "God"
      elseif n >= 32  then return "Overprotected"
      elseif n >= 16  then return "Protection"
      elseif n >= 8   then return "Admin"
      elseif n >= 4   then return "System"
      elseif n >= 2   then return "User"
      elseif n >= 1   then return "Application"
      else                 return "File"
      end
   end
   local function getDefaultLevel(user)
      if user.bot then return 1 end
      return 2
   end
   message.channel:send("Your level is: " .. 
      level_to_string(tonumber(
         Maria.user_db:exec(
            (([[
               INSERT OR IGNORE INTO user VALUES(%s, %s);
               SELECT level FROM user WHERE id == %s;
            ]])):format(id, getDefaultLevel(message.member), id)
         )[1][1]
      ))
   )
end