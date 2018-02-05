--[[
This file is part of the mod ConfigUnderLengths that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

function modify_underpipes(debugOutputEnabled)
  if debugOutputEnabled then
    print("ConfigUnderLengths: Processing underground pipes...")
  end
  local tiers = sort_tiers(get_underpipe_tiers())
  for tier_n, tier in pairs(tiers) do
    local n = math.min(5, tier_n)
    local skip_dist = settings.startup["config-under-lengths-pipes-" .. n].value
    local tier_s = "" .. tier_n
    if tier_n ~= n then
      tier_s = tier_s .. " (treated as tier " .. n .. ")"
    end
    for _, proto in pairs(tier.protos) do
      local con = proto.fluid_box.pipe_connections[2]
      local old_skip_dist = con.max_underground_distance - 1
      if skip_dist == -1 then
        if debugOutputEnabled then
          print(" Not changing underground pipe \"" .. proto.name
          .. "\" of tier " .. tier_s .. " with skip distance " .. old_skip_dist)
        end
      else
        if debugOutputEnabled then
          print(" Changing underground pipe \"" .. proto.name
          .. "\" of tier " .. tier_s)
          print("  old skip distance: " .. old_skip_dist)
          print("  new skip distance: " .. skip_dist)
        end
        con.max_underground_distance = skip_dist + 1
      end
    end
  end
  if debugOutputEnabled then
    print("Done.")
  end
end

function get_underpipe_tiers()
  local tiers = {}
  for name, proto in pairs(data.raw["pipe-to-ground"]) do
    local fluid_box = proto.fluid_box
    local pipe_cons = fluid_box and fluid_box.pipe_connections
    if pipe_cons and # pipe_cons == 2 then
      local con = pipe_cons[2]
      if con and con.max_underground_distance then
        local skip_dist_old = con.max_underground_distance - 1
        local tier = tiers[skip_dist_old]
        if not tier then
          tier = {skip_dist_old=skip_dist_old, protos={}}
          tiers[skip_dist_old] = tier
        end
        table.insert(tier.protos, proto)
      end
    end
  end
  return tiers
end

function modify_underbelts(debugOutputEnabled)
  if debugOutputEnabled then
    print("ConfigUnderLengths: Processing underground belts...")
  end
  local tiers = sort_tiers(get_underbelt_tiers())
  for tier_n, tier in pairs(tiers) do
    local n = math.min(8, tier_n)
    local skip_dist = settings.startup["config-under-lengths-belts-" .. n].value
    local tier_s = "" .. tier_n
    if tier_n ~= n then
      tier_s = tier_s .. " (treated as tier " .. n .. ")"
    end
    for _, proto in pairs(tier.protos) do
      local old_skip_dist = proto.max_distance - 1
      if skip_dist == -1 then
        if debugOutputEnabled then
          print(" Not changing underground belt \"" .. proto.name
          .. "\" of tier " .. tier_s .. " with skip distance " .. old_skip_dist)
        end
      else
        if debugOutputEnabled then
          print(" Changing underground belt \"" .. proto.name
          .. "\" of tier " .. tier_s)
          print("  old skip distance: " .. old_skip_dist)
          print("  new skip distance: " .. skip_dist)
        end
        proto.max_distance = skip_dist + 1
      end
    end
  end
  if debugOutputEnabled then
    print("Done.")
  end
end

function get_underbelt_tiers()
  local tiers = {}
  for name, proto in pairs(data.raw["underground-belt"]) do
    if proto and proto.max_distance then
      local skip_dist_old = proto.max_distance - 1
      local tier = tiers[skip_dist_old]
      if not tier then
        tier = {skip_dist_old=skip_dist_old, protos={}}
        tiers[skip_dist_old] = tier
      end
      table.insert(tier.protos, proto)
    end
  end
  return tiers
end

function tier_lt(a, b)
  return a.skip_dist_old < b.skip_dist_old
end

function sort_tiers(tiers)
  tiers_sorted = {}
  for _, tier in pairs(tiers) do
    table.insert(tiers_sorted, tier)
  end
  table.sort(tiers_sorted, tier_lt)
  return tiers_sorted
end

local debugOutputEnabled = settings.startup["config-under-lengths-debug"].value
modify_underpipes(debugOutputEnabled)
modify_underbelts(debugOutputEnabled)
