local module = {}
local config = require("/app/config.lua")

module.getPerm = function(message,id)
  if id == nil then id = message.author.id end
  if message.guild.owner.id == id then return 3 end
  if message.guild.roles:get(config.perms.adminRole) ~= nil and message.guild.members:get(id).roles:get(config.perms.adminRole) ~= nil then
    return 2
  elseif message.guild.roles:get(config.perms.modRole) ~= nil and message.guild.members:get(id).roles:get(config.perms.modRole) ~= nil then
    return 1
  else
    for _,users in pairs(config.perms.users) do
      if users[1] == id then
        if users[2]:lower() == "admin" then return 2 end
        if users[2]:lower() == "mod" then return 1 end
        return 0
      end
    end
    return 0
  end
end

module.getRoles = function(message,member)
  if member == nil then member = message.member end
  local config = require("/app/config.lua")
  if config.groupId == nil or config.groupId == 0 then return "no_group" end
  local res, body = require("coro-http").request("GET","https://verify.eryn.io/api/user/"..member.id)
  if res.code ~= 200 then return (res.code == 404 and "not_verifed" or "verify_err") end
  body = require("json").decode(body)
  local userId, name = body.robloxId, body.robloxUsername
  res, body = require("coro-http").request("GET","https://api.roblox.com/users/"..userId.."/groups")
  if res.code ~= 200 then return "api_down" else body = require("json").decode(body) end
  local groupInfo
  if #body >= 1 then
    for a,b in pairs(body) do
      if b.Id == config.groupId then
        groupInfo = b
        break
      end
    end
  end
  if groupInfo == nil then groupInfo = {Rank = 0, Role = "Guest"} end
  local changes = {added = {}, removed = {}}
  local internal = {}
  local bindings = config.bindings
  for a,b in pairs(bindings) do --// Give any and all roles that the user should have.
    local role = message.guild.roles:get(b)
    if role then
      if a == groupInfo.Rank and member.roles:get(b) == nil then
        local success, msg = member:addRole(b)
        if (success) then changes.added[1+#changes.added] = role.name internal[role.id] = a require("timer").sleep(250) end
      elseif a == groupInfo.Rank then
        internal[role.id] = a
      end
    end
  end
  for a,b in pairs(bindings) do --// Remove roles that weren't added.
    if internal[b] == nil then --// The role wasn't added or shouldn't have been.
      local role = message.guild.roles:get(b)
      if role and member.roles:get(b) ~= nil then
        local success, msg = member:removeRole(b)
        if (success) then changes.removed[1+#changes.removed] = role.name require("timer").sleep(250) end 
      end
    end
  end
  if member.roles:get(config.verifiedRole) == nil and message.guild.roles:get(config.verifiedRole) ~= nil then
    local success, msg = member:addRole(config.verifiedRole)
    if (success) then changes.added[1+#changes.added] = message.guild.roles:get(config.verifiedRole).name end
  end
  if member.name:lower() ~= name:lower() then
    member:setNickname(name)
  end
  if #changes.added + #changes.removed == 0 then return "no_changes" end
  return changes
end

module.resolveUser = function(message,user)
  if #message.mentionedUsers >= 1 then
    if user == "<@"..message.mentionedUsers[1][1]..">" then
      return message.guild:getMember(message.mentionedUsers[1][1])
    elseif user == "<@!"..message.mentionedUsers[1][1]..">" then
      return message.guild:getMember(message.mentionedUsers[1][1])
    end
  end
  if tonumber(user) ~= nil then
    for _,items in pairs(message.guild.members) do
      if items.id == user then
        return items
      end
    end
  end
  for _,items in pairs(message.guild.members) do
    if string.sub(items.name,1,string.len(user)):lower() == user:lower() then
      return items
    end
  end
  for _,items in pairs(message.guild.members) do
    if string.sub(items.username,1,string.len(user)):lower() == user:lower() then
      return items
    end
  end
  return false
end

return module