local ESC = "\27[%sm"
local log = "%s | %s[%s]%s: %s\n"

local Logger = {
   reset = ESC:format"0",
   bold = ESC:format"1",
   italic = ESC:format"3",
   underline = ESC:format"4",
   strike = ESC:format"9",
   success = ESC:format"32",
   send = ESC:format"38;5;98",
   info = ESC:format"38;2;102;153;204",
   debug = ESC:format"34",
   warn = ESC:format"33;5;4",
   error = ESC:format"31",
   critical = ESC:format"31;5;1;4"
}

function Logger:log(level, message)
   io.write(log:format(os.date"%c", Logger[level:lower()], level:upper(), Logger.reset, message))
end

return Logger