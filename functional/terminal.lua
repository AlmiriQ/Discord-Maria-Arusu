return function(fs, path)
   Terminal = {
      path = {
         "",
         "/userdata/application",
         "/userdata/file",
         "/bin"
      }
   }

   function Terminal.split(x)
      local data = {}
      local not_str = false
      x = " " .. x
      for x in string.gmatch(x, "[^\"]+") do
         not_str = not not_str
         x = x:trim():gsub(" +", " ")
         if not_str then x = x:split" " else x = { x } end
         for _, v in ipairs(x) do
            table.insert(data, v)
         end
      end
      return data
   end

   function Terminal.get_file(command)
      local file = nil
      for _, path_var in ipairs(Terminal.path) do
         if fs.existsSync("ARS" .. path_var .. command .. ".lua") or
         fs.existsSync("ARS" .. path_var .. command .. ".luac") or
         fs.existsSync("ARS" .. path_var .. command .. ".so")
         then
            file = "ARS" .. path_var .. command
         end
      end
      local error = file == nil
      return error, path.normalize(file)
   end

   function Terminal.execute(command, user, env)
      local cmd = Terminal.cache:get(command[1])
      if not cmd then
         -- here we are going to check if file exists
         local error, file = Terminal.get_file(command[1])
         if error then return "File not found: " .. command[1] end
         if not file:startswith"ARS/" then return "Attempt to index invalid filename: " .. command[1] end
         local res, err = pcall(require, file)
         if not res then return err else res = err end
         Terminal.cache:push(command[1], res)
         cmd = Terminal.cache:get(command[1])
      end
      env.user = user
      env.argv = command
      env.terminal = Terminal
      env.command = command
      env.env = env
      local res, err = pcall(cmd, env)
      if err then return err end
      return res
   end

   Terminal.cache = {
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

   return Terminal
end