script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  local character = player.character
  player.character = nil
  if character then
    character.destroy()
  end
  player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
  create_technologies_frame(player)
  if (#game.players <= 1) then
    game.show_message_dialog{text = {"msg-introduction"}}
  else
    player.print({"msg-introduction"})
  end
end)

script.on_event(defines.events.on_rocket_launched, function(event)
  local force = event.rocket.force
  if event.rocket.get_item_count("satellite") == 0 then
    if (#game.players <= 1) then
      game.show_message_dialog{text = {"gui-rocket-silo.rocket-launched-without-satellite"}}
    else
      for index, player in pairs(force.players) do
        player.print({"gui-rocket-silo.rocket-launched-without-satellite"})
      end
    end
    return
  end
  if not global.satellite_sent then
    global.satellite_sent = {}
  end
  if global.satellite_sent[force.name] then
    global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1   
  else
    game.set_game_state{game_finished=true, player_won=true, can_continue=true}
    global.satellite_sent[force.name] = 1
  end
  for index, player in pairs(force.players) do
    if player.gui.left.rocket_score then
      player.gui.left.rocket_score.rocket_count.caption = tostring(global.satellite_sent[force.name])
    else
      local frame = player.gui.left.add{name = "rocket_score", type = "frame", direction = "horizontal", caption={"score"}}
      frame.add{name="rocket_count_label", type = "label", caption={"", {"rockets-sent"}, ":"}}
      frame.add{name="rocket_count", type = "label", caption=tostring(global.satellite_sent[force.name])}
    end
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]
  local gui = event.element
  if gui.name == "button_technologies_researched" then
    player.force.research_all_technologies()
    gui.parent.destroy()
    create_item_frame(player)
    return
  end
  if gui.name == "button_technologies_normal" then
    gui.parent.destroy()
    create_item_frame(player)
    return
  end
  if gui.name == "button_yes_items" then
    give_items(player)
    gui.parent.destroy()
    create_cheat_frame(player)
    return
  end
  if gui.name =="button_no_items" then
    gui.parent.destroy()
    create_cheat_frame(player)
    return
  end
  if gui.name == "button_use_cheat_mode" then
    player.cheat_mode = true
    gui.parent.destroy()
    create_day_frame(player)
    return
  end
  if gui.name == "button_no_cheat_mode" then
    gui.parent.destroy()
    create_day_frame(player)
    return
  end
  if gui.name == "button_yes_day" then
    player.surface.always_day = true
    gui.parent.destroy()
    return
  end
  if gui.name =="button_no_day" then
    gui.parent.destroy()
    return
  end
end)

function give_items(player)
  local items = 
  {
    {name="raw-wood", count="100"},
    {name="coal", count="100"},
    {name="stone", count="100"},
    {name="iron-plate", count="400"},
    {name="copper-plate", count="400"},
    {name="steel-plate", count="100"},
    {name="iron-gear-wheel", count="200"},
    {name="electronic-circuit", count="200"},
    {name="advanced-circuit", count="200"},
    {name="offshore-pump", count="20"},
    {name="pipe", count="50"},
    {name="boiler", count="50"},
    {name="electric-mining-drill", count="50"},
    {name="steam-engine", count="10"},
    {name="stone-furnace", count="50"},
    {name="transport-belt", count="200"},
    {name="underground-belt", count="50"},
    {name="splitter", count="20"},
    {name="fast-transport-belt", count="50"},
    {name="express-transport-belt", count="50"},
    {name="inserter", count="50"},
    {name="fast-inserter", count="50"},
    {name="long-handed-inserter", count="50"},
    {name="filter-inserter", count="50"},
    {name="small-electric-pole", count="50"},
    {name="assembling-machine-1", count="50"},
    {name="assembling-machine-2", count="30"},
    {name="rail", count="200"},
    {name="train-stop", count="10"},
    {name="rail-signal", count="50"},
    {name="diesel-locomotive", count="5"},
    {name="cargo-wagon", count="10"}
  }
  for k, item in pairs (items) do
    if game.item_prototypes[item.name] then
      player.insert{name = item.name, count = item.count}
    else 
      game.print(item.name.." is not a valid item") --More useful than an assert
    end
  end
end

function create_item_frame(player)
  local frame = player.gui.left.add{name = "items_frame", type = "frame", direction = "horizontal", caption={"msg-give-items"}}
  frame.add{type = "button", name="button_yes_items", caption={"button-yes-items"}}
  frame.add{type = "button", name="button_no_items", caption={"button-no-items"}}
end

function create_technologies_frame(player)
  local frame = player.gui.left.add{name = "technologies_frame", type = "frame", direction = "horizontal", caption={"msg-ask-technologies"}}
  frame.add{type = "button", name = "button_technologies_researched", caption = {"button-technologies-researched"}}
  frame.add{type = "button", name = "button_technologies_normal", caption = {"button-technologies-normal"}}
end

function create_cheat_frame(player)
  local frame = player.gui.left.add{name = "cheat_frame", type = "frame", direction = "horizontal", caption={"msg-ask-cheat-mode"}}
  frame.add{type = "button", name="button_use_cheat_mode", caption={"button-use-cheat-mode"}}
  frame.add{type = "button", name="button_no_cheat_mode", caption={"button-no-cheat-mode"}}
end

function create_day_frame(player)
  local frame = player.gui.left.add{name = "day_frame", type = "frame", direction = "horizontal", caption={"msg-ask-always-day"}}
  frame.add{type = "button", name="button_yes_day", caption={"button-yes-day"}}
  frame.add{type = "button", name="button_no_day", caption={"button-no-day"}}
end
