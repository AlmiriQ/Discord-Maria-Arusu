Terminal = {}

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

function Terminal.execute(command, user, env)
   local cmd = Terminal.cache:get(command[1])
   if not cmd then
      local res, err = pcall(require, "ARS" .. command[1])
      if not res then return err else res = err end
      Terminal.cache:push(command[1], res)
      cmd = Terminal.cache:get(command[1])
   end
   env.user = user
   env.argv = command
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