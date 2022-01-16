return function(fs)
   local function xf(dir)
      local list = {}
      for path, type in fs.scandirSync(dir) do
         if type == "file" then
            list[#list + 1] = dir.."/"..path
         elseif type == "directory" then
            for _, v in ipairs(xf(dir.."/"..path)) do 
               table.insert(list, v)
            end
         end
      end
      return list
   end
   return xf
end