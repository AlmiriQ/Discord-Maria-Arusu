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

function string.replace(str, retable)
   for x, rex in pairs(retable) do
      str = str:gsub(x, rex)
   end
   return str
end

function string.rus_lower(str)
   return str:replace{
      ["А"] = "а", ["Б"] = "б", ["В"] = "в", ["Г"] = "г",
      ["Д"] = "д", ["Е"] = "е", ["Ё"] = "ё", ["Ж"] = "ж",
      ["З"] = "з", ["И"] = "и", ["Й"] = "й", ["К"] = "к",
      ["Л"] = "л", ["М"] = "м", ["Н"] = "н", ["О"] = "о",
      ["П"] = "п", ["Р"] = "р", ["С"] = "с", ["Т"] = "т",
      ["У"] = "у", ["Ф"] = "ф", ["Х"] = "х", ["Ц"] = "ц",
      ["Ч"] = "ч", ["Ш"] = "ш", ["Щ"] = "щ", ["Ь"] = "ь",
      ["Ы"] = "ы", ["Ъ"] = "ъ", ["Э"] = "э", ["Ю"] = "ю",
      ["Я"] = "я"
   }
end

function string.rus_upper(str)
   return str:replace{
      ["а"] = "А", ["б"] = "Б", ["в"] = "В", ["г"] = "Г",
      ["д"] = "Д", ["е"] = "Е", ["ё"] = "Ё", ["ж"] = "Ж",
      ["з"] = "З", ["и"] = "И", ["й"] = "Й", ["к"] = "К",
      ["л"] = "Л", ["м"] = "М", ["н"] = "Н", ["о"] = "О",
      ["п"] = "П", ["р"] = "Р", ["с"] = "С", ["т"] = "Т",
      ["у"] = "У", ["ф"] = "Ф", ["х"] = "Х", ["ц"] = "Ц",
      ["ч"] = "Ч", ["ш"] = "Ш", ["щ"] = "Щ", ["ь"] = "Ь",
      ["ы"] = "Ы", ["ъ"] = "Ъ", ["э"] = "Э", ["ю"] = "Ю",
      ["я"] = "Я"
   }
end

function string.translit_to_en(str)
   return str:replace{
      ["а"] = "a", ["б"] = "b", ["в"] = "v", ["г"] = "g",
      ["д"] = "d", ["е"] ="ye", ["ё"] ="yo", ["ж"] ="zh",
      ["з"] = "z", ["и"] = "i", ["й"] = "y", ["к"] = "k",
      ["л"] = "l", ["м"] = "m", ["н"] = "n", ["о"] = "o",
      ["п"] = "p", ["р"] = "r", ["с"] = "s", ["т"] = "t",
      ["у"] = "u", ["ф"] = "f", ["х"] = "h", ["ц"] = "c",
      ["ч"] ="ch", ["ш"] ="sh", ["щ"] ="sh", ["ь"] = "'",
      ["ы"] = "i", ["ъ"] ="\"", ["э"] = "e", ["ю"] ="yu",
      ["я"] ="ya"
   }
end

function table.find(table, lf)
   for _, v in ipairs(table) do
      if lf(v) then return v end
   end
end