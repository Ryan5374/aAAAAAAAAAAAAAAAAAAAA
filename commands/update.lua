command = {}

local utils = require("/app/utils.lua")

command.info = {
  Name = "Update",
  Alias = {},
  Cooldown = 5,
}

local codes = {
  ["no_group"] = "**Config Error:** There is no group setup.",
  ["not_verifed"] = "That member isn't verified with RoVer.",
  ["verify_err"] = "There was a problem checking the verification registry. Try again.",
  ["api_down"] = "There was a problem with the Roblox API. Try again.",
}

command.execute = function(message,args,client)
  local config = require("/app/config.lua")
  if utils.getPerm(message) < 1 then return {success = (config.permReply and false or "no"), msg = "You don't have permissions to use this command."} end
  if args[2] == nil then return {success = false, msg = "You must mention a member to update."} end
  local member = utils.resolveUser(message,table.concat(args," ",2))
  if member == false then return {success = false, msg = "I couldn't find the member you mentioned."} end
  if member.id == message.author.id then local command = require("/app/commands/getroles.lua").execute(message,args,client) return command end
  local getRoles = utils.getRoles(message,member)
  if type(getRoles) == "table" then
    local added = getRoles.added
    local removed = getRoles.removed
    message:reply{embed = {
      title = "Roles Changed ["..#added + #removed.."]",
      description = "The following changes were made to **"..member.tag.."**:",
      fields = {
        {name = "Added ["..#added.."]", value = (#added >= 1 and table.concat(added,", ") or "None!"), inline = true},
        {name = "Removed ["..#removed.."]", value = (#removed >= 1 and table.concat(removed,", ") or "None!"), inline = true},
      },
      color = 3066993,
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      timestamp = require("discordia").Date():toISO('T', 'Z'),
    }}
    return {success = "yes"}
  elseif getRoles == "no_changes" then
    return {success = true, msg = "**"..member.tag.."** is all caught up!"}
  elseif codes[getRoles] == nil then
    return {success = false, msg = "Unknown error."}
  else
    return {success = false, msg = codes[getRoles]}
  end
end

return command