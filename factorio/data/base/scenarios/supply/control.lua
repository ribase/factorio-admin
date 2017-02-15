require "util"
require "story"

time_modifier = 1.4
points_per_second_start = 5
points_per_second_level_subtract = 0.2
levels=
{
  -- 1
  {
    requirements =
    {
      { name = "stone", count = 15 }
    },
    time = 240,
  },

  -- 2
  {
    requirements =
    {
      { name ="iron-plate", count = 30}
    },
    time = 300
  },

  -- 3
  {
    requirements =
    {
      { name ="iron-plate", count = 30},
      { name ="copper-plate", count = 30}
    },
    time = 300
  },

  -- 4
  {
    requirements =
    {
      { name ="iron-plate", count = 30},
      { name ="iron-gear-wheel", count = 30},
    },
    time = 300
  },

  -- 5
  {
    requirements =
    {
      { name ="iron-plate", count = 40},
      { name ="iron-gear-wheel", count = 30},
      { name ="copper-cable", count = 40}
    },
    time = 300
  },

  -- 6
  {
    requirements =
    {
      { name ="iron-plate", count = 40},
      { name ="iron-gear-wheel", count = 30},
      { name ="electronic-circuit", count = 30},
    },
    time = 300
  },

  -- 7
  {
    requirements =
    {
      { name ="iron-plate", count = 40},
      { name ="iron-gear-wheel", count = 30},
      { name ="electronic-circuit", count = 30},
      { name ="science-pack-1", count = 10},
    },
    time = 300
  },

  -- 8
  {
    requirements =
    {
      { name ="iron-plate", count = 40},
      { name ="iron-gear-wheel", count = 30},
      { name ="electronic-circuit", count = 30},
      { name ="science-pack-1", count = 10},
      { name ="transport-belt", count = 20},
    },
    time = 300
  },

  -- 9
  {
    requirements =
    {
      { name ="iron-plate", count = 50},
      { name ="iron-gear-wheel", count = 30},
      { name ="electronic-circuit", count = 30},
      { name ="science-pack-1", count = 10},
      { name ="transport-belt", count = 20},
      { name ="inserter", count = 20},
    },
    time = 300
  },

  -- 10
  {
    requirements =
    {
      { name ="iron-plate", count = 50},
      { name ="iron-gear-wheel", count = 30},
      { name ="electronic-circuit", count = 30},
      { name ="science-pack-1", count = 10},
      { name ="science-pack-2", count = 10}
    },
    time = 300
  },

  -- 11
  {
    requirements =
    {
      { name ="iron-plate", count = 50},
      { name ="iron-gear-wheel", count = 30},
      { name ="electronic-circuit", count = 30},
      { name ="science-pack-1", count = 20},
      { name ="science-pack-2", count = 20},
      { name ="fast-transport-belt", count = 10}
    },
    time = 300
  },

  -- 12
  {
    requirements =
    {
      { name ="iron-plate", count = 50},
      { name ="iron-gear-wheel", count = 30},
      { name ="electronic-circuit", count = 30},
      { name ="science-pack-1", count = 20},
      { name ="science-pack-2", count = 20},
      { name ="steel-plate", count = 10}
    },
    time = 420
  },

  -- 13
  {
    requirements =
    {
      { name ="iron-gear-wheel", count = 30},
      { name ="electronic-circuit", count = 30},
      { name ="science-pack-1", count = 20},
      { name ="science-pack-2", count = 20},
      { name ="steel-plate", count = 15},
      { name ="piercing-rounds-magazine", count = 50}
    },
    time = 300
  },

  -- 14
  {
    requirements =
    {
      { name ="iron-gear-wheel", count = 30},
      { name ="electronic-circuit", count = 30},
      { name ="science-pack-1", count = 20},
      { name ="science-pack-2", count = 20},
      { name ="steel-plate", count = 15},
      { name ="plastic-bar", count = 5}
    },
    time = 600
  },

  -- 15
  {
    requirements =
    {
      { name ="electronic-circuit", count = 30},
      { name ="science-pack-1", count = 20},
      { name ="science-pack-2", count = 20},
      { name ="steel-plate", count = 15},
      { name ="advanced-circuit", count = 10}
    },
    time = 500
  },

  -- 16
  {
    requirements =
    {
      { name ="science-pack-1", count = 20},
      { name ="science-pack-2", count = 20},
      { name ="steel-plate", count = 15},
      { name ="advanced-circuit", count = 10},
      { name ="battery", count = 10}
    },
    time = 500
  },

  -- 17
  {
    requirements =
    {
      { name ="science-pack-1", count = 20},
      { name ="science-pack-2", count = 20},
      { name ="steel-plate", count = 15},
      { name ="advanced-circuit", count = 10},
      { name ="battery", count = 10},
      { name ="filter-inserter", count = 10}
    },
    time = 500
  },

  -- 18
  {
    requirements =
    {
      { name ="science-pack-1", count = 20},
      { name ="science-pack-2", count = 20},
      { name ="science-pack-3", count = 20}
    },
    time = 500
  },

  -- 19
  {
    requirements =
    {
      { name ="science-pack-1", count = 30},
      { name ="science-pack-2", count = 30},
      { name ="science-pack-3", count = 30},
      { name ="rocket", count = 20},
    },
    time = 500
  },

  -- 20
  {
    requirements =
    {
      { name ="science-pack-1", count = 40},
      { name ="science-pack-2", count = 40},
      { name ="science-pack-3", count = 40},
      { name ="rocket", count = 20},
      { name ="explosive-rocket", count = 20},
    },
    time = 600
  },

  -- 21
  {
    requirements =
    {
      { name ="science-pack-1", count = 50},
      { name ="science-pack-2", count = 50},
      { name ="science-pack-3", count = 50},
      { name ="alien-science-pack", count = 50}
    },
    time = 700
  }
}

function update_info(player)
  local frame = player.gui.top.frame

  local level = levels[global.level]
  local table=frame.table
  for index, item in pairs(level.requirements) do
    local accumulated = global.accumulated[item.name]
    local label = table[item.name]
    label.caption = accumulated .. "/" .. item.count
    if accumulated == item.count then
      label.style.font_color = {g=0.6}
    end
  end
  for k, player in pairs (game.players) do
    update_time_left(player, false)
  end
end

function get_time_left()
  return global.level_started_at + time_modifier * levels[global.level].time * 60 - game.tick
end

function update_time_left(player, bool)
  if (game.tick % 60 ~= 0) and bool then return end
  local time_left = get_time_left()
  if time_left < 0 then
    time_left = 0
  end
  local label = player.gui.top.frame.time_left
  label.caption = {"", {"time-left"}, ": ", util.formattime(time_left)}
  if time_left == 60 * 30 then
    label.style.font_color = {r=1}
  end
end

story_table =
{
  {
    {
      action = function()
        game.show_message_dialog{text = {"welcome"}}
        game.show_message_dialog{text = {"rules1"}}
        game.show_message_dialog{text = {"rules2"}}
        game.show_message_dialog{text = {"rules3"}}
        game.show_message_dialog{text = {"rules4"}}
        game.show_message_dialog{text = {"rules5"}}
      end
    },
    {},
    {
      name = "level-start",
      init = function(event)
        global.accumulated = {}
        global.required = {}
        global.labels = {}
        local level = levels[global.level]
        for k, player in pairs (game.players) do
          make_frame(player)
        end
        for index, item in pairs(levels[global.level].requirements) do
          global.accumulated[item.name] = 0
          global.required[item.name] = item.count
        end
        if global.level < #levels then
          for k, player in pairs (game.players) do
            update_frame(player, levels[global.level + 1])
          end
          local item_prototypes = game.item_prototypes
          for index, item in pairs(levels[global.level + 1].requirements) do
            local diff
            if global.required[item.name] ~= nil then
              diff = item.count - global.required[item.name]
            else
              diff = item.count
            end
            for k, player in pairs (game.players) do
              update_table(player, diff, item)
            end
          end
        end
        global.level_started_at = event.tick
        for k, player in pairs (game.players) do
          update_info(player)
        end
      end,
    },
    {
      name = "level-progress",
      update =
      function(event)
        local update_info_needed = false
        local level = levels[global.level]
        for index, chest in pairs(global.chests) do
          local inventory = chest.get_inventory(defines.inventory.chest)
          local contents = inventory.get_contents()
          for itemname, count in pairs(contents) do
            if global.accumulated[itemname] == nil then
              goto continue
            end
            local counttoconsume = global.required[itemname] - global.accumulated[itemname]
            if counttoconsume > count then
              counttoconsume = count
            end
            if counttoconsume ~= 0 then
              inventory.remove{name = itemname, count = counttoconsume}
              global.accumulated[itemname] = global.accumulated[itemname] + counttoconsume
              update_info_needed = true
            end
            ::continue::
          end
        end
        if update_info_needed then
          for k, player in pairs (game.players) do
            update_info(player)
          end
        end
        for k, player in pairs (game.players) do
          update_time_left(player, true)
        end
      end,

      condition = function(event)
        local level = levels[global.level]
        local time_left = get_time_left()

        if event.name == defines.events.on_gui_click and
           event.element.name == "next_level" then
          local seconds_left = math.floor(time_left / 60)
          local points_addition = math.floor(seconds_left * (points_per_second_start - global.level * points_per_second_level_subtract))
          game.print({"time-bonus", points_addition, seconds_left})
          global.points = global.points + points_addition
          return true
        end

        local result = true
        for index, item in pairs(level.requirements) do
          local accumulated = global.accumulated[item.name]
          if accumulated < item.count then
            result = false
          end
        end

        if result then
          for k, player in pairs (game.players) do
            if player.gui.top.next_level == nil then
              player.gui.top.add{type = "button", name = "next_level", caption={"next-level"}}
            end
          end
        end

        if time_left <= 0 then
          if result == false then
            for k, player in pairs (game.players) do
              player.set_ending_screen_data({"points-achieved", global.points})
            end
            game.set_game_state{game_finished=true, player_won=false}
            return false
          else
            return true
          end
        end

        return false
      end,
      action = function(event, story)
        for k, player in pairs (game.players) do
          if player.gui.top.next_level ~= nil then
            player.gui.top.next_level.destroy()
          end
        end
        global.level = global.level + 1
        local points_addition = (global.level - 1) * 10
        game.print({"level-completed", global.level - 1, points_addition})
        global.points = global.points + points_addition

        if global.level < #levels + 1 then
          for k, player in pairs (game.players) do
            player.gui.top.frame.destroy()
          end
          story_jump_to(story, "level-start")
        end
      end
    },
    {
      action = function()
        for k, player in pairs (game.players) do
          player.set_ending_screen_data({"points-achieved", global.points})
        end
      end
    }
  }
}

story_init_helpers(story_table)

script.on_init(function()
  global.story = story_init(story_table)
  game.map_settings.pollution.enabled = false
  game.evolution_factor = 0
  global.chests = {}
  for i=1,6,1 do
    local chest = game.get_entity_by_tag("chest" .. i)
    chest.minable = false
    chest.destructible = false 
    global.chests[i] = chest
  end
  global.level = 1
  global.points = 0
  if game.players[1] == nil then return end
  game.players[1].insert{name = "iron-plate", count = 8}
end)

script.on_event(defines.events, function(event)
  on_joined(event)
  story_update(global.story, event, "")
end)

function on_joined(event)
  if event.name ~= defines.events.on_player_created then return end
  local player = game.players[event.player_index]
  player.insert{name = "iron-plate", count = 8}
  make_frame(player)
  if global.level < #levels then
    update_frame(player, levels[global.level + 1])
    for index, item in pairs(levels[global.level + 1].requirements) do
      local diff
      if global.required[item.name] ~= nil then
        diff = item.count - global.required[item.name]
      else
        diff = item.count
      end
      update_table(player,diff,item)
    end
  end
end

function make_frame(player)
  local frame = player.gui.top.add{type="frame", name="frame", direction="vertical", caption = {"", {"level"}, " ", global.level}}
  frame.add{type="label", name="time_left"}
  frame.add{type="label", caption={"", {"points-per-second"}, ": ", points_per_second_start - global.level * points_per_second_level_subtract}}
  frame.add{type="label", caption={"", {"points"}, ": ", math.floor(global.points)}}
  frame.add{type="label", caption={"", {"required-items"}, ":"}, style="caption_label_style"}
  local table = frame.add{type="table", name="table", colspan=2}
  for index, item in pairs(levels[global.level].requirements) do
    table.add{type="label", caption=game.item_prototypes[item.name].localised_name}
    table.add{type="label", caption="0/" .. item.count, name=item.name}
  end
end

function update_frame(player, next_level)
  local frame = player.gui.top.frame
  if not frame then game.print ("No frame for update frame") return end
  frame.add{type="label", caption={"", {"next-level"}, ":"}, style="caption_label_style"}
  frame.add{type="table", colspan=2, name = "next_level_table"}
end

function update_table(player, diff, item)
  local table = player.gui.top.frame.next_level_table
  if not table then game.print("No table for update_table function") return end
  if diff ~= 0 then
    table.add{type="label", caption=game.item_prototypes[item.name].localised_name}
  end
  if diff > 0 then
    table.add{type="label", caption="+" .. diff}
    return
  end
  if diff < 0 then
    table.add{type="label", caption=diff}
    return
  end
end