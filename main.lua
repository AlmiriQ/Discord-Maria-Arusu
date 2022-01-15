require"functional/functional"
local discordia = require"discordia"
local BotBuilder = require"functional/bot builder"(discordia, require"functional/logger")
local recursive_scan = require"functional/rscan"(require"fs")
local Emitter = require"core".Emitter
local sql = require "sqlite3"


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
      Maria_Arusu.musicPlayer:emit("nya", message)
      return
   elseif message.content == "AEsir" or message.content == "Æsir" then
      Maria_Arusu.musicPlayer:emit("aesir", message)
      return
   end
   if message.content:startswith(Maria_Arusu.prefix) then
      print(pcall(function()
         local command = Maria_Arusu.cache:get(message.content)
         if not command then
            Maria_Arusu.cache:push(message.content, require("ARS"..message.content))
            command = Maria_Arusu.cache:get(message.content)
         end
         command(Maria_Arusu, message)
      end))
   end
end


Maria_Arusu = Maria_Arusu_builder:build()
Maria_Arusu.connection = nil
Maria_Arusu.user_db = sql.open("database/users.db")
Maria_Arusu.cache = {
   keys = {},
   data = {},
   maxv = 10,
   push = function(cache, key, data)
      cache:collect()
      if cache.keys[key] then return end
      cache.keys[key] = {
         usages = 0,
         cdata = data
      }
      table.insert(cache.data, cache.keys[key])
   end,
   get = function(cache, key)
      local re_value = cache.keys[key]
      if re_value then
         re_value.usages = re_value.usages + 1
         return re_value.cdata
      end
   end,
   clear = function(cache)
      cache.data = {}
      cache.keys = {}
      collectgarbage"collect"
   end,
   collect = function(cache)
      if #cache.data < cache.maxv then return end
      local c_data = {}
      local sum_usages = 0
      for _, dt in ipairs(cache.data) do sum_usages = sum_usages + dt.usages end
      for k, dt in ipairs(cache.keys) do
         if dt.usages / sum_usages > (1 / cache.maxv / 1.5) then
            c_data[k] = dt
         end
      end
      cache:clear()
      for k, v in pairs(c_data) do
         cache:push(k, v)
      end
   end
}
Maria_Arusu.user_db:exec[[
CREATE TABLE IF NOT EXISTS user(id INTEGER PRIMARY KEY, level UNSIGNED TINYINT);
INSERT OR IGNORE INTO user VALUES
   ("928003461684023346", 128), 
   ("415453831724400641", 64),
   ("822440442460110858", 64);
]]
Maria_Arusu.musicPlayer = Emitter:new()
Maria_Arusu.prefix = "/"
Maria_Arusu.bitwise = require"bitwise"

function Maria_Arusu.musicPlayer.connect(message)
   if message.member and message.member.voiceChannel then
      if Maria_Arusu.connection == nil then
         Maria_Arusu.connection = message.member.voiceChannel:join()
      elseif Maria_Arusu.connection.channel.id ~= message.member.voiceChannel.id then
         Maria_Arusu.connection:close()
         Maria_Arusu.connection = message.member.voiceChannel:join()
      end
   end
end

Maria_Arusu.musicPlayer:on("nya", function(message)
   Maria_Arusu.musicPlayer.connect(message)
   pcall(coroutine.wrap(function()
      Maria_Arusu.connection:playFFmpeg('sound/Maria_Meow_' .. tostring(math.random(1, 8)) .. '.opus')
   end))
   message:addReaction"🐱"
   message.channel:send("Nya, " .. message.author.mentionString .. " <3"):addReaction"🐱"
end)

Maria_Arusu.musicPlayer:on("aesir", function(message)
   Maria_Arusu.musicPlayer.connect(message)
   pcall(coroutine.wrap(function()
      Maria_Arusu.connection:playFFmpeg('sound/Chaos.mp3')
   end))
end)

Maria_Arusu.commands = {}
for _, file in pairs(recursive_scan"ARS") do
   print(file:sub(5, #file - 4))
end


do
   local token_file = io.open"token"
   local token = token_file:read"*a"
   token_file:close()
   Maria_Arusu:run(token)
   token = nil
end