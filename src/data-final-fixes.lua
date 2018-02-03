--[[
This file is part of the mod ConfigUnderLengths that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

function modify_underpipes()
  local tiers = sort_tiers(get_underpipe_tiers())
  for n, tier in pairs(tiers) do
    n = math.min(5, n)
    local skip_dist = settings.startup["config-under-lengths-pipes-" .. n].value
    if skip_dist ~= -1 then
      for _, item in pairs(tier.items) do
        item.max_underground_distance = skip_dist + 1
      end
    end
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
          tier = {skip_dist_old=skip_dist_old, items={}}
          tiers[skip_dist_old] = tier
        end
        table.insert(tier.items, con)
      end
    end
  end
  return tiers
end

function modify_underbelts()
  local tiers = sort_tiers(get_underbelt_tiers())
  for n, tier in pairs(tiers) do
    n = math.min(8, n)
    local skip_dist = settings.startup["config-under-lengths-belts-" .. n].value
    if skip_dist ~= -1 then
      for _, item in pairs(tier.items) do
        item.max_distance = skip_dist + 1
      end
    end
  end
end

function get_underbelt_tiers()
  local tiers = {}
  for name, proto in pairs(data.raw["underground-belt"]) do
    if proto and proto.max_distance then
      local skip_dist_old = proto.max_distance - 1
      local tier = tiers[skip_dist_old]
      if not tier then
        tier = {skip_dist_old=skip_dist_old, items={}}
        tiers[skip_dist_old] = tier
      end
      table.insert(tier.items, proto)
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

modify_underpipes()
modify_underbelts()
