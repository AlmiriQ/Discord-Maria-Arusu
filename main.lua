require"functional/functional"
local Terminal = require"functional/terminal"(require"fs", require"path")
local discordia = require"discordia"
local BotBuilder = require"functional/bot builder"(discordia, require"functional/logger")
local recursive_scan = require"functional/rscan"(require"fs")
local Emitter = require"core".Emitter
local sql = require "sqlite3"
local timer = require"timer"
local uv = require"uv"
local sleep = require"functional/sleep"(uv)
local ytdl = require"functional/ytdl"


local Maria_Arusu_builder = BotBuilder()
local Maria_Arusu


function Maria_Arusu_builder.ready()
   Maria_Arusu.logger:log("success", 'Logged in as ' .. Maria_Arusu.client.user.username)
   Maria_Arusu.client:setGame"Fraxinus Ex Terminal"
   Maria_Arusu.musicPlayer:emit("queue")
end

function Maria_Arusu_builder.messageCreate(message)
   if message.author.id == Maria_Arusu.client.user.id then return end
   local content = message.content
   local author = message.author
   if (content:startswith(Maria_Arusu.prefix) == content:startswith('"' .. Maria_Arusu.prefix)) then return end
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

function Maria_Arusu_builder.voiceChannelJoin(member, channel)
   if member.id == Maria_Arusu.client.user.id then return end
   Maria_Arusu.musicPlayer:emit("nya-connect", member, channel)
end

function Maria_Arusu_builder.voiceChannelLeave(member, channel)
   if member.id == Maria_Arusu.client.user.id then return end
   Maria_Arusu.musicPlayer:emit("nya-disconnect", member, channel)
end

Maria_Arusu = Maria_Arusu_builder:build()
Maria_Arusu.connection = nil
Maria_Arusu.user_db = sql.open("ARS/admin/system/database/users.db")
Maria_Arusu.user_db:exec[[
CREATE TABLE IF NOT EXISTS user(id INTEGER PRIMARY KEY, level UNSIGNED TINYINT);
INSERT OR IGNORE INTO user VALUES
   ("928003461684023346", 128),
   ("415453831724400641", 64),
   ("822440442460110858", 64);
]]
Maria_Arusu.musicPlayer = Emitter:new()
Maria_Arusu.queue = discordia.Deque()
Maria_Arusu.infNya = false
Maria_Arusu.musicPlayer.playing = false
Maria_Arusu.prefix = "/"

function Maria_Arusu.musicPlayer.connect(message)
   if not (message.member and message.member.voiceChannel) then return end
   if Maria_Arusu.connection == nil then
      Maria_Arusu.connection = message.member.voiceChannel:join()
   elseif Maria_Arusu.connection.channel.id ~= message.member.voiceChannel.id then
      Maria_Arusu.connection:close()
      Maria_Arusu.connection = message.member.voiceChannel:join()
   end
end

function Maria_Arusu.musicPlayer.reconnect()
   local channel = Maria_Arusu.connection.channel
   Maria_Arusu.connection:close()
   Maria_Arusu.connection = channel:join()
end

Maria_Arusu.musicPlayer:on("nya-connect", function(user)
   Maria_Arusu.musicPlayer.connect({member = user})
   pcall(coroutine.wrap(function()
      sleep(1000)
      if Maria_Arusu.connection then
         Maria_Arusu.connection:playFFmpeg('System??/data/sound/Maria_Meow_' .. tostring(math.random(1, 4)) .. '.opus')
      end
   end))
end)

Maria_Arusu.musicPlayer:on("nya-disconnect", function(user)
   Maria_Arusu.musicPlayer.connect({member = user})
   pcall(coroutine.wrap(function()
      Maria_Arusu.connection:playFFmpeg('System??/data/sound/Maria_Meow_' .. tostring(math.random(5, 7)) .. '.opus')
   end))
end)

Maria_Arusu.musicPlayer:on("infinite-nya", function(message)
   Maria_Arusu.connection:playFFmpeg('System??/data/sound/Maria_Meow_' .. tostring(math.random(1, 8)) .. '.opus')
   sleep(math.random(333, 1000))
   print(Maria_Arusu.infNya)
   if Maria_Arusu.infNya then
      Maria_Arusu.musicPlayer:emit("infinite-nya", message)
   end
end)

Maria_Arusu.musicPlayer:on("infinite-nya-start", function(message)
   Maria_Arusu.musicPlayer.connect(message)
   Maria_Arusu.infNya = true
   Maria_Arusu.musicPlayer:emit("infinite-nya", message)
end)

Maria_Arusu.musicPlayer:on("infinite-nya-break", function(message)
   Maria_Arusu.infNya = false
end)

Maria_Arusu.musicPlayer:on("nya", function(message)
   Maria_Arusu.musicPlayer.connect(message)
   pcall(coroutine.wrap(function()
      Maria_Arusu.connection:playFFmpeg('System??/data/sound/Maria_Meow_' .. tostring(math.random(1, 8)) .. '.opus')
   end))
   message:addReaction"????"
   message.channel:send("Nya, " .. message.author.mentionString .. " <3"):addReaction"????"
end)

Maria_Arusu.musicPlayer:on("aesir", function(message)
   Maria_Arusu.musicPlayer.connect(message)
   pcall(coroutine.wrap(function()
      Maria_Arusu.connection:playFFmpeg('System??/data/sound/Chaos.mp3')
   end))
end)

Maria_Arusu.musicPlayer:on("queue", function(message)
   Maria_Arusu.queue = discordia.Deque()
   Maria_Arusu.musicPlayer.playing = false
   os.execute"rm -rf /home/maria/Maria\\ Arusu/ARS/userdata/application/NatsuPlayer/temp/*"
end)

Maria_Arusu.musicPlayer:on("queue-play", function(message)
   local file = Maria_Arusu.queue:popLeft()
   Maria_Arusu.musicPlayer.connect(message)
   Maria_Arusu.logger:log("debug", "file?: " .. tostring(file))
   if not file then Maria_Arusu.musicPlayer:emit"queue" return end
   Maria_Arusu.connection:playFFmpeg(file)
   Maria_Arusu.musicPlayer:emit"queue-play"
end)

Maria_Arusu.musicPlayer:on("queue-skip", function()
   Maria_Arusu.connection:stopStream()
end)

Maria_Arusu.musicPlayer:on("queue-stop", function()
   Maria_Arusu.musicPlayer:emit"queue"
   Maria_Arusu.connection:stopStream()
end)

function Maria_Arusu.musicPlayer.queue_push(link)
   Maria_Arusu.queue:pushRight(ytdl(link))
   Maria_Arusu.logger:log("debug", "pushRight successfull")
end

Maria_Arusu.musicPlayer:on("queue-start", function(message)
   Maria_Arusu.musicPlayer.connect(message)
   if Maria_Arusu.musicPlayer.playing then return end
   Maria_Arusu.logger:log("debug", "maria.mp.playing == false")
   Maria_Arusu.musicPlayer:emit"queue"
   Maria_Arusu.logger:log("debug", "queue emitted")
   Maria_Arusu.musicPlayer.playing = true
   Maria_Arusu.logger:log("debug", "maria.mp.playing == true")
   Maria_Arusu.musicPlayer:emit"queue-play"
   Maria_Arusu.logger:log("debug", "queue-play emitted")
end)

function Maria_Arusu.get_default_level(user)
   if user.bot then return 1 end
   return 2
end

function Maria_Arusu.get_user_level(user)
   return Maria_Arusu.user_db:exec(
      ([[INSERT OR IGNORE INTO user VALUES(%s, %s);
         SELECT level FROM user WHERE id == %s;]])
      :format(user.id, Maria_Arusu.get_default_level(user), user.id)
   )[1][1]
end

function Maria_Arusu.set_user_level(user, level, flag)
   local lvl2set = tonumber(Maria_Arusu.get_user_level(user))
   print("[1]", lvl2set)
   if flag then
      lvl2set = bit.bor(lvl2set, level)
   else
      if lvl2set > bit.bxor(lvl2set, level) then
         lvl2set = bit.bxor(lvl2set, level)
      end
   end
   print("[2]", lvl2set)
   return Maria_Arusu.user_db:exec(
      ([[INSERT OR REPLACE INTO user VALUES(%s, %s)]])
      :format(user.id, lvl2set)
   )
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

function Maria_Arusu.string_to_level(str)
   str = tostring(str):lower()
   return ({
      maria = 128,
      god = 64,
      overprotected = 32,
      protection = 16,
      admin = 8,
      system = 4,
      user = 2,
      application = 1,
      file = 0,
   })[str]
end

function Maria_Arusu.ltsgul(user) -- combination of level_to_string & get_user_level
   return Maria_Arusu.level_to_string(Maria_Arusu.get_user_level(user))
end

do
   local token_file = io.open"System??/token"
   local token = token_file:read"*a"
   token_file:close()
   Maria_Arusu:run(token)
   token = nil
end
