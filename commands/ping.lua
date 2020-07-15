command = {}

local function parse(num)
num = math.max(num)
local str = tostring(num)
local pos, tables, done = 1, {}, false
repeat
    if string.sub(str,pos,pos) ~= "." then tables[pos] = string.sub(str,pos,pos) pos = pos+1 else done = true end
    require("timer").sleep(1)
until pos >= string.len(num) or done == true
  num = table.concat(tables,"")
  return num
end

command.info = {
  Name = "Ping",
  Alias = {},
}

command.execute = function(message,args,client)
  local m = message:reply(":ping_pong: Ping")
  if m == nil then return {success = "nope'd"} end
  local latency = require("discordia").Date.fromISO(m.timestamp):toMilliseconds() - require("discordia").Date.fromISO(message.timestamp):toMilliseconds()
  m:setContent(":ping_pong: Pong! `"..(string.sub(parse(latency),1,1) == "-" and "1" or parse(latency)).."ms`")
  return {success = "Don't", msg = "PONG!!", emote = ":ping_pong:"}
end

return command