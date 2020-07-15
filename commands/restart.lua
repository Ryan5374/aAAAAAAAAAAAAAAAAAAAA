command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Restart",
  Alias = {"r"},
}

command.execute = function(message,args,client)
  if utils.getPerm(message) < 3 then return {success = (config.permReply and false or "no"), msg = "You don't have permissions to use this command."} end
  message:reply(":ok_hand: Restarting, be right back!")
  os.exit()
  os.exit()
  os.exit()
  return {success = "stfu"}
end

return command