return function(discordia, logger)
   local ClientBuilder = {
      functional = {
         build = function(this)
            local bot = { client = discordia.Client{
               logLevel = discordia.enums.logLevel.warning,
               logFile = "/dev/null"
            }, logger = logger }
            bot.client:on("ready", this.ready or function() bot.logger:log("success", "Logged in as " .. bot.user.username .. "!") end)
            
            bot.client:on("messageCreate", this.messageCreate or function(message) bot.logger:log("info", "New message from " .. tostring(message.author.username) .. ": " .. tostring(message.content)) end)
            bot.client:on("messageUpdate", this.messageUpdate or function(message) bot.logger:log("info", "Edited message from " .. tostring(message.author.username) .. ": " .. tostring(message.content)) end)
            bot.client:on("messageDelete", this.messageDelete or function(message) bot.logger:log("info", "Deleted message from " .. tostring(message.author.username) .. ": " .. tostring(message.content)) end)
            
            bot.client:on("channelCreate", this.channelCreate or function(channel) bot.logger:log("info", "New data in channel " .. tostring(channel.name)) end)
            bot.client:on("channelUpdate", this.channelUpdate or function(channel) bot.logger:log("info", "Channel " .. tostring(channel.name) .. " was updated.") end)
            bot.client:on("channelDelete", this.channelDelete or function(channel) bot.logger:log("info", "Channel " .. tostring(channel.name) .. " was deleted.") end)

            bot.client:on("guildAvailable", this.guildAvailable or function(guild) bot.logger:log("info", tostring(guild) .. " is available now.") end)
            bot.client:on("guildUnavailable", this.guildUnavailable or function(guild) bot.logger:log("info", tostring(guild) .. " is unavailable now.") end)
            bot.client:on("guildCreate", this.guildCreate or function(guild) bot.logger:log("info", "A new guild " .. tostring(guild) .. " is created.") end)
            bot.client:on("guildUpdate", this.guildUpdate or function(guild) bot.logger:log("info", tostring(guild) .. " is updated.") end)
            bot.client:on("guildDelete", this.guildDelete or function(guild) bot.logger:log("info", tostring(guild) .. " is deleted.") end)
            
            bot.client:on("userBan", this.userBan or function(user, guild) bot.logger:log("info", "User " .. tostring(user.username) .. " is now banned in guild " .. tostring(guild)) end)
            bot.client:on("userUnban", this.userUnban or function(user, guild) bot.logger:log("info", "User " .. tostring(user.username) .. " is now unbanned in guild " .. tostring(guild)) end)
            bot.client:on("userUpdate", this.userUpdate or function(user, guild) bot.logger:log("info", "User " .. tostring(user.username) .. " info in guild " .. tostring(guild) .. " was update.") end)
            
            bot.client:on("emojisUpdate", this.emojisUpdate or function(guild) bot.logger:log("info", "Emoji info in guild " .. tostring(guild) .. " was updated.") end)
            
            bot.client:on("memberJoin", this.memberJoin or function(member) bot.logger:log("info", "User " .. tostring(member.username) .. " joined the guild " .. tostring(member.guild)) end)
            bot.client:on("memberLeave", this.memberLeave or function(member) bot.logger:log("info", "User " .. tostring(member.username) .. " leaved the guild " .. tostring(member.guild)) end)
            bot.client:on("memberUpdate", this.memberUpdate or function(member) bot.logger:log("info", "User " .. tostring(member.username) .. " info was updated.") end)
            
            bot.client:on("roleCreate", this.roleCreate or function(role) bot.logger:log("info", "Role " .. tostring(role) .. " was created.") end)
            bot.client:on("roleUpdate", this.roleUpdate or function(role) bot.logger:log("info", "Role " .. tostring(role) .. " was updated.") end)
            bot.client:on("roleDelete", this.roleDelete or function(role) bot.logger:log("info", "Role " .. tostring(role) .. " was deleted.") end)

            bot.client:on("reactionAdd", this.reactionAdd or function(reaction, userId) bot.logger:log("info", "New reaction " .. tostring(reaction.emojiHash) .. " from: " .. tostring(userId)) end)
            bot.client:on("reactionRemove", this.reactionRemove or function(reaction, userId) bot.logger:log("info", "Removed reaction: " .. tostring(reaction.emojiHash)) end)
            
            bot.client:on("pinsUpdate", this.pinsUpdate or function(channel) bot.logger:log("info", "Pinned messages in channel " .. tostring(channel) .. " changed.") end)

            --bot.client:on("presenceUpdate", this.presenceUpdate or function(member) bot.logger:log("info", "User " .. member.username .. " updated their presence.") end)
            
            bot.client:on("voiceConnect", this.voiceConnect or function(member) bot.logger:log("info", "User " .. tostring(member.username) .. " connected to voice channel.") end)
            bot.client:on("voiceDisconnect", this.voiceDisconnect or function(member) bot.logger:log("info", "User " .. tostring(member.username) .. " disconnected from voice channel.") end)
            bot.client:on("voiceUpdate", this.voiceUpdate or function(member) bot.logger:log("info", "User " .. tostring(member.username) .. " voice status was updated.") end)
            bot.client:on("voiceChannelJoin", this.voiceChannelJoin or function(member, channel) bot.logger:log("info", "User " .. tostring(member.username) .. " connected to voice channel " .. tostring(channel)) end)
            bot.client:on("voiceChannelLeave", this.voiceChannelLeave or function(member, channel) bot.logger:log("info", "User " .. tostring(member.username) .. " disconnected from voice channel " .. tostring(channel)) end)
            
            bot.client:on("webhooksUpdate", this.webhooksUpdate or function(channel) bot.logger:log("info", "Webhooks in channel " .. tostring(channel) .. " were updated.") end)

            --bot.client:on("typingStart", this.typingStart or function(userId, channelId, timestamp) bot.logger:log("info", "User " .. userId .. " were typing in channel " .. channelId) end)
            
            function bot:run(token)
               bot.client:run("Bot " .. token)
            end
            setmetatable(bot, { __index = bot.client })
            bot.logger:log("success", "Bot is builded")
            return bot
         end
      }
   }

   setmetatable(ClientBuilder, {
      __call = function()
         local object = {}
         object.stdout = _G.process.stdout.handle
         setmetatable(object, {
            __index = ClientBuilder.functional,
            __tostring = function(this) return "ClientBuilder" end
         })
         return object
      end
   })

   return ClientBuilder
end