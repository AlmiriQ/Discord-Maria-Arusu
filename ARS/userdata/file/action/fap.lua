return function(env)
   if not env.Maria then return -1 end
   if not env.message then return -1 end
   local obj = env.argv[2]
   local phrases = {
      "Может мне присоединиться?", "Это вообще нормально - столько есть?", "Он вообще перестаёт кушать?", "Надеюсь ему понравилось.", "Стоп, а его еда не против?", "Хм-м-м, вкусно наверное.", "Может мне тоже стоит покушать?..", "И как он столько кушает-то...", ""
   }
   local illegal = {
      "Только не 8 лет...", "FBI OPEN UP!", "Надеюсь ты понимаешь, что в тюрьме нет аниме...", "Сенпай, будьте аккуратны!", "Только историю браузера потом почисть..."
   }
   if env.message.content:find"<@!?701634732185616450>" or 
      env.message.content:lower():find"maria" or 
      env.message.content:lower():find"arusu" or 
      env.message.content:rus_lower():find"мария" or 
      env.message.content:rus_lower():find"арусу"
   then
      env.message.channel:send("Эй, " .. env.message.author.mentionString .. "! Нельзя кушать на меня!")
      return
   end
   if env.message.content:translit_to_en():find"lol[iy]" then
      env.message.channel:send(env.message.author.mentionString .. " покушал(-а) на " .. obj ..". " .. illegal[math.random(1, #illegal)])
      return
   end
   env.message.channel:send(env.message.author.mentionString .. " покушал(-а) на " .. obj .. ". " .. phrases[math.random(1, #phrases)])
end