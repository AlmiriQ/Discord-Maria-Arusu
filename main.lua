local discordia = require"discordia"
local BotBuilder = require"functional/bot builder"(discordia, require"functional/logger")
local recursive_scan = require"functional/rscan"(require"fs")
local Emitter = require('core').Emitter


local Maria_Arusu_builder = BotBuilder()
local Maria_Arusu


function Maria_Arusu_builder.ready()
   Maria_Arusu.logger:log("success", 'Logged in as ' .. Maria_Arusu.client.user.username)
   Maria_Arusu.client:setGame"Fraxinus Ex Terminal"
end

function Maria_Arusu_builder.messageCreate(message)
   if message.author.id == Maria_Arusu.client.user.id then return end
   local message_text = message.content:lower()
   if message_text:gsub("Н", "н"):gsub("Я", "я") == "ня" or message_text == "nya" then
      if Maria_Arusu.connection == nil then
         if message.member and message.member.voiceChannel:join() then
            Maria_Arusu.connection = message.member.voiceChannel:join()
         end
      end
      coroutine.wrap(function()
         if Maria_Arusu.connection then
            Maria_Arusu.connection:playFFmpeg('sound/Maria_Meow_' .. tostring(math.random(1, 8)) .. '.opus')
         end
      end)()
      message:addReaction"🐱"
      message.channel:send("Nya, " .. message.author.mentionString .. " <3"):addReaction"🐱"
   elseif message.content == "AEsir" or message.content == "Æsir" then
      coroutine.wrap(function()
         if Maria_Arusu.connection then
            Maria_Arusu.connection:playFFmpeg('sound/Chaos.mp3')
         end
      end)()
   end
   local prefixes = { "a:", "A:", "ARS::" }
end


Maria_Arusu = Maria_Arusu_builder:build()
Maria_Arusu.connection = nil
Maria_Arusu.musicPlayer = Emitter:new()


Maria_Arusu.commands = {}
for _, file in pairs(recursive_scan"ARS") do
   --print(file:sub(5, file))
end


local token_file = io.open"token"
local token = token_file:read"*a"
token_file:close()
Maria_Arusu:run(token)
token = nil