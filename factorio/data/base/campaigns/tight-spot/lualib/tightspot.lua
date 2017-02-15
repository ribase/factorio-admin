
tightspot_prices =
{
  ["coal"]=5,
  ["transport-belt"]=5,
  ["underground-belt"]=20,
  ["fast-transport-belt"]=50,
  ["fast-underground-belt"]=200,
  ["splitter"]=25,
  ["fast-splitter"]=50,
  ["burner-inserter"]=10,
  ["inserter"]=10,
  ["long-handed-inserter"]=15,
  ["fast-inserter"]=20,
  ["filter-inserter"]=35,
  ["red-wire"]=2,
  ["green-wire"]=2,
  ["wooden-chest"]=5,
  ["iron-chest"]=10,
  ["stone-furnace"]=10,
  ["steel-furnace"]=50,
  ["electric-furnace"]=70,
  ["offshore-pump"]=10,
  ["pipe"]=5,
  ["pipe-to-ground"]=20,
  ["boiler"]=15,
  ["steam-engine"]=50,
  ["small-electric-pole"]=10,
  ["medium-electric-pole"]=50,
  ["big-electric-pole"]=100,
  ["substation"]=150,
  ["assembling-machine-1"]=30,
  ["assembling-machine-2"]=50,
  ["assembling-machine-3"]=100,
  ["electric-mining-drill"]=50,
  ["burner-mining-drill"]=10,
  ["pumpjack"]=50,
  ["oil-refinery"]=100,
  ["chemical-plant"]=50,
  ["storage-tank"]=40,
  ["small-pump"]=20,
  ["logistic-robot"]=150,
  ["logistic-chest-passive-provider"]=50,
  ["logistic-chest-requester"]=50,
}

function tightspot_make_offer(item)
  if not tightspot_prices[item] then game.print(item.." price is not defined. Please report this on the factorio bug forum") return end
  return { price={{"coin", tightspot_prices[item]}}, offer={type="give-item", item=item}}
end

function tightspot_init(level)
  game.players[1].disable_recipe_groups()
  game.players[1].disable_recipe_subgroups()
  game.players[1].minimap_enabled = false
  game.map_settings.pollution.enabled = false
  local result = {}
  result.level = level
  result.demand = {}
  for index, item in pairs(level.demand) do
    result.demand[item.item] = item.price
  end
  return result
end

function tightspot_get_required_balance()
  if game.difficulty == defines.difficulty.easy then
    return level.required_balance.easy
  elseif game.difficulty == defines.difficulty.normal then
    return level.required_balance.normal
  else
    return level.required_balance.hard
  end
end

function tightspot_init_level(tightspot)
  local player = game.players[1]
  local character = player.character
  player.set_controller{type=defines.controllers.god}
  if character then character.destroy() end
  local playerforce = player.force
  playerforce.manual_mining_speed_modifier = 1000

  local level = tightspot.level
  tightspot.debt = level.money
  tightspot.income = 0
  local surface = player.surface
  local wallCollisionBox = game.entity_prototypes["stone-wall"].collision_box

  for x=level.area[1][1],level.area[2][1],1 do
    for y=level.area[1][2],level.area[2][2],1 do
      local entities = game.players[1].surface.find_entities{{x + 0.1, y + 0.1}, {x + 0.9, y + 0.9}}
      local shouldcover = true;
      for index, item in pairs(entities) do
        if item.type == "resource" or
           item.type == "tree" then
          item.minable = false
          if item.type ~= "tree" then
            shouldcover = false;
          end
        end
      end
      if shouldcover and surface.can_place_entity{name = "stone-wall", position = {x + 0.5, y + 0.5}} then
        surface.create_entity{name = "stone-wall", position = {x, y}, force=playerforce}
      end
    end
  end
  local market = game.get_entity_by_tag("market")
  for index, item in pairs(level.offers) do
    market.add_market_item(item)
  end
  game.players[1].insert{name= "steel-axe", count=1}
  game.players[1].insert{name = "coin", count = level.money}
  game.players[1].force.disable_all_prototypes()
  local recipe_list = game.players[1].force.recipes
  for index, item in pairs(level.recipes) do
    recipe_list[item].enabled = true
  end
  tightspot_init_spending_frame(tightspot)
  tightspot_update_spending(tightspot)
end

function tightspot_init_spending_frame(tightspot)
  local frame = game.players[1].gui.top.add{type="frame", name="tightspot_frame", caption = "Level " .. tightspot.level.level_number, direction="vertical"}
  local table = frame.add{type="table", name="table", colspan=2}
  local available = game.players[1].get_item_count("coin")
  local debt = tightspot.debt
  table.add{type="label", caption={"", {"money"}, ":"}, style="caption_label_style"}
  table.add{type="label", caption=""}
  table.add{type="label", caption={"", {"balance"}, ":"}}
  table.add{type="label", caption=debt - available, name="balance"}
  table.add{type="label", caption={"", {"required"}, ":"}}
  table.add{type="label", caption=tightspot_get_required_balance(), name="required"}

  local level = tightspot.level
  --local timeflow = frame.add{type="flow", name="timeflow"}
  table.add{type="label", caption={"", {"time"}, ":"}}
  table.add{type="label", caption=util.formattime(level.time)}

  frame.add{type="label", caption={"", {"demand"}, ":"}, style="caption_label_style"}
  local demandtable = game.players[1].gui.top.tightspot_frame.add{type="table", name="demandtable", colspan=2}

  local item_prototypes = game.item_prototypes
  for index, item in pairs(level.demand) do
    demandtable.add{type="label", caption=item_prototypes[item.item].localised_name}
    demandtable.add{type="label", caption=item.price}
  end

  game.players[1].gui.top.add{type = "button", name="tightspot_start", caption={"start"}}
end

function tightspot_init_progress_frame(tightspot)
  local progressframe = game.players[1].gui.top.add{type = "frame", name="tightspot_progress_frame", caption={"progress"}, direction="vertical"}
  progressframe.direction = "vertical"
  progressframe.add{type="progressbar", size="10", name="tightspot_progressbar"}
  local table = progressframe.add{type="table", colspan="2", name="table"}
  table.add{type="label", caption={"", {"time"}, ":"}}
  table.add{type="label", name="time"}
  table.add{type="label", caption={"", {"speed"}, ":"}}
  table.add{type="label", name="speed"}
  local controlflow = progressframe.add{type="flow"}
  controlflow.add{type="button", caption="+", name="faster"}
  controlflow.add{type="button", caption="-", name="slower"}
  tightspot_update_speed_label()
end

function tightspot_update_progress(tightspot)
  if (game.tick - tightspot.simulation_started_at) % 60 ~= 0 then
    return
  end
  local tightspot_progress_frame = game.players[1].gui.top.tightspot_progress_frame
  local time = game.tick - tightspot.simulation_started_at
  tightspot_progress_frame.tightspot_progressbar.value = time / level.time
  tightspot_progress_frame.table.time.caption = util.formattime(time)
end

function tightspot_update_spending(tightspot)
  local table = game.players[1].gui.top.tightspot_frame.table
  local available
  if game.players[1].controller_type == defines.controllers.god then
    available = game.players[1].get_item_count("coin")
   else
    available = tightspot.available
  end
  local debt = tightspot.debt
  table.balance.caption = available - debt + tightspot.income
end

function tightspot_get_missing_to_win(tightspot)
  local available = tightspot.available
  local debt = tightspot.debt
  local required = tightspot_get_required_balance(tightspot)
  return required + debt - tightspot.income - available
end

function tightspot_sell_back(tightspot)
  local level = tightspot.level
  local player = game.players[1]
  local addition = 0
  coinsleft = player.get_item_count("coin")
  if coinsleft > 0 then
    player.remove_item{name = "coin", count = coinsleft}
  end
  for index, item in pairs(level.offers) do
    local count = player.get_item_count(item.offer.item)
    addition = addition + count * item.price[1][2]
  end
  game.players[1].surface.create_entity{name = "flying-text", position = player.position, text = "+" .. addition, color = {g = 1}}
  tightspot.debt = tightspot.debt - addition - coinsleft
  player.clear_items_inside()
end

function tightspot_start_level(tightspot)
  game.save("before-run")
  game.players[1].gui.top.tightspot_start.destroy()
  tightspot_sell_back(tightspot)
  game.speed = 32
  tightspot_init_progress_frame(tightspot)
  game.players[1].gui.top.add{type = "button", name="tightspot_reload", caption={"reload"}}
  tightspot.available = game.players[1].get_item_count("coin")
  game.players[1].set_controller{type=defines.controllers.ghost}
  tightspot.simulation_started_at = game.tick
  local level = tightspot.level
  local entities = game.players[1].surface.find_entities(level.area)
  for index, item in pairs(entities) do
    item.active = true
  end
  tightspot_update_spending(tightspot)
end

function tightspot_show_level_description(tightspot)
  local level = tightspot.level
  if level.description ~= nil then
    game.show_message_dialog(level.description)
  end
end

function tightspot_update_speed_label()
  game.players[1].gui.top.tightspot_progress_frame.table.speed.caption = game.speed
end

function tightspot_check_level(tightspot, event)
  if event.name == defines.events.on_gui_click then
    if event.element.name == "slower" and game.speed > 1 then
      game.speed = game.speed / 2
      tightspot_update_speed_label(tightspot)
    elseif event.element.name == "faster" and game.speed < 64 then
      game.speed = game.speed * 2
      tightspot_update_speed_label(tightspot)
    elseif event.element.name == "tightspot_reload" then
      game.load("before-run")
      return false
    end
    return false
   end

  local result_chest = game.get_entity_by_tag("result-chest")
  local contents = result_chest.get_inventory(defines.inventory.chest).get_contents()
  local addition = 0
  for item_name, count in pairs(contents) do
    local price = tightspot.demand[item_name]
    if price ~= nil then
      addition = addition + price * count
    end
  end
  if addition ~= 0 then
    game.players[1].surface.create_entity{name = "flying-text", position = result_chest.position, text = "+" .. addition, color = {g = 1}}
    tightspot.income = tightspot.income + addition
    tightspot_update_spending(tightspot)
  end
  tightspot_update_progress(tightspot)
  result_chest.clear_items_inside()
  return (game.tick - tightspot.simulation_started_at) >= level.time
end

function land_price(level, position)
  return math.abs(position.x - level.center.x) + math.abs(position.y - level.center.y)
end

story_table =
{
  {
    {
      action = function()
        tightspot_init_level(global.tightspot)
      end
    },
    {
      action = function()
        if level.showrules ~= nil then
          game.show_message_dialog{text={"welcome"}}
          game.show_message_dialog{text={"rules1"}}
          game.show_message_dialog{text={"rules2"}}
          game.show_message_dialog{text={"rules3"}}
        end
      end
    },
    {
      action = function()
        tightspot_show_level_description(global.tightspot)
      end
    },
    {
      update =
      function(event)
        tightspot_update_spending(global.tightspot)
        if event.name == defines.events.on_built_entity then
          if event.created_entity.name == "stone-wall" then
            if #game.players[1].surface.find_entities_filtered{area = {{event.created_entity.position.x - 0.4,
                                                                  event.created_entity.position.y - 0.4},
                                                                 {event.created_entity.position.x + 0.4,
                                                                  event.created_entity.position.y + 0.4}},
                                                         type = "resource"} ~= 0 then
              event.created_entity.destroy()
              game.players[1].insert{name = "stone-wall", count = 1}
              game.players[1].print("This area is not resellable")
              return
            end
            local price = land_price(level, event.created_entity.position)
            game.players[1].surface.create_entity{name = "flying-text", position = event.created_entity.position, text = "+" .. price, color = {g = 1}}
            game.players[1].insert{name = "coin", count = price}
          else
            event.created_entity.active = false
          end
        end
        if event.name == defines.events.on_preplayer_mined_item and
           event.entity.name == "stone-wall" then
          local position = event.entity.position
          local price = land_price(level, event.entity.position)
          game.players[1].surface.create_entity{name = "flying-text", position = event.entity.position, text = "-" .. price, color = {r = 1}}
          local available = game.players[1].get_item_count("coin")
          game.players[1].remove_item{name = "coin", count = price}
          if available < price then
            global.tightspot.debt = global.tightspot.debt + 5000
            game.players[1].insert{name = "coin", count = 5000 - price + available}
            game.players[1].print("Borrowed 5000 coins to pay for the land")
          end
        end
      end,
      condition =
      function(event)
        return event.name == defines.events.on_gui_click and event.element.name == "tightspot_start"
      end,
      action =
      function()
        tightspot_start_level(global.tightspot)
      end
    },
    {
      condition =
      function(event)
        return tightspot_check_level(global.tightspot, event)
      end,
      action =
      function()
        local missing = tightspot_get_missing_to_win(global.tightspot)
        if missing > 0 then
          game.show_message_dialog{text={"lost-message", missing}}
        else
          game.show_message_dialog{text={"won-message", -missing}}
        end
      end
    },
    {
      condition =
      function()
        if tightspot_get_missing_to_win(global.tightspot) > 0 then
          game.load("before-run")
          return false
        end
        return true
      end,
      action = function() end
    }
  }
}

story_init_helpers(story_table)
