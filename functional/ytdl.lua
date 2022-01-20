return function(link)
   local id = link:replace{
      ["www."] = "",
      ["https?://"] = "",
      ["youtube.com/"] = "",
      ["youtu.be/"] = "",
      ["watch%?v="] = "",
      ["&feature=share"] = ""
   }
   os.execute(("yt-dlp -o ARS/userdata/application/NatsuPlayer/temp/%s.mp3 -f worstaudio https://youtu.be/%s"):format(id, id))
   return ("ARS/userdata/application/NatsuPlayer/temp/%s.mp3"):format(id)
end