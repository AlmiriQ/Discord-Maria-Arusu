require"functional/functional"
local Terminal = require"functional/terminal"
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
   local content = message.content
   local author = message.author
   if (content:startswith(Maria_Arusu.prefix) == content:startswith('"' .. Maria_Arusu.prefix)) then return end
   print(content)
   print(Terminal.execute(
      Terminal.split(content), -- command 
      { -- user
         name = author.tag,
         id = author.id,
         level = Maria_Arusu.get_user_level(author), 
         ref = author
      }, 
      { -- env
         Maria = Maria_Arusu,
         message = message
      }
   ))
end


Maria_Arusu = Maria_Arusu_builder:build()
Maria_Arusu.connection = nil
Maria_Arusu.user_db = sql.open("database/users.db")
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
   if not (message.member and message.member.voiceChannel) then return end
   if Maria_Arusu.connection == nil then
      Maria_Arusu.connection = message.member.voiceChannel:join()
   elseif Maria_Arusu.connection.channel.id ~= message.member.voiceChannel.id then
      Maria_Arusu.connection:close()
      Maria_Arusu.connection = message.member.voiceChannel:join()
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

function Maria_Arusu.get_default_level(user)
   if user.bot then return 1 end
   return 2
end

function Maria_Arusu.get_user_level(user)
   return Maria_Arusu.user_db:exec(
      (([[
         INSERT OR IGNORE INTO user VALUES(%s, %s);
         SELECT level FROM user WHERE id == %s;
      ]])):format(user.id, Maria_Arusu.get_default_level(user), user.id)
   )[1][1]
end

function Maria_Arusu.level_to_string(n)
   n = tonumber(n)
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

function Maria_Arusu.ltsgul(user) -- combination of level_to_string & get_user_level
   return Maria_Arusu.level_to_string(Maria_Arusu.get_user_level(user))
end

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