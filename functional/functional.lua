function string.split(inputstr, sep)
   sep = sep or "%s"
   local t = {}
   for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
   end
   return t
end

function string.trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function string.startswith(str, start)
   return str:sub(1, #start) == start
end

function string.endswith(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

function table.add(t1, t2)
   return {table.unpack(t1), table.unpack(t2)}
end

function table.find(table, lf)
   for _, v in ipairs(table) do
      if lf(v) then return v end
   end
end