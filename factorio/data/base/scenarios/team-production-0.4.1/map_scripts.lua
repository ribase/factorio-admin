function create_grid()
  global.placement_grid = {}
  for y = -1, 2 do
    for x = -2, 1 do
      local offset = {x, y}
      table.insert(global.placement_grid, offset)
    end
  end
end

simple_entities = 
  {
  ["tree"] = true,
  ["doodad"] = true,
  ["fish"] = true,
  ["decorative"] = true
  }

function save_map_data(distance)

local data = "{\n  map_set_tiles = \n    {\n[0] = "..distance..","
  for X = -distance, distance-1 do
    for Y = -distance, distance-1 do
      local tile = game.surfaces[1].get_tile(X, Y)
      local name = tile.name
      local position = tile.position
      data = data.." \""..name.."\","
    end
  end
  
  data = data.."\n    },\n  map_set_entities = \n  {\n"
  for k, entity in pairs (game.surfaces[1].find_entities({{-distance, -distance}, {distance-1, distance-1}})) do
    local name = entity.name
    local position = entity.position
    local direction = entity.direction
    local force = entity.force
    if entity.name == "express-loader" then
      local loader_type = entity.loader_type
      data = data.."    {name = \""..name.."\", position = {"..position.x..", "..position.y.."}, force = \""..force.name.."\", direction = "..direction..", type = \""..loader_type.."\"}, \n"
    elseif entity.type == "resource" then
      local amount = entity.amount
      data = data.."    {name = \""..name.."\", position = {"..position.x..", "..position.y.."}, amount = "..amount.."}, \n"
    elseif simple_entities[entity.type] then
      data = data.."    {name = \""..name.."\", position = {"..position.x..", "..position.y.."}}, \n"
    else
      data = data.."    {name = \""..name.."\", position = {"..position.x..", "..position.y.."}, force = \""..force.name.."\", direction = "..direction.."}, \n"
    end
  end
  data = data.."  }\n}"
  game.write_file("tile_data.lua", data)
end

function clear_map(surface, area)
  if area then
    for k, entity in pairs (surface.find_entities(area)) do
      entity.destroy()
    end
  else
    for k, entity in pairs (surface.find_entities()) do
      entity.destroy()
    end
  end
end

function create_tiles(tiles, offset_x, offset_y, bool)

  if not tiles then return end
  
  local offset_tiles = {}
  local distance = tiles[0]
  local gap = global.distance_between_areas
  local index = 1
  local tile
  for X = -(distance+gap), (distance+gap)-1 do
    for Y = -(distance+gap), (distance+gap)-1 do
      if X < distance and X >= -distance then 
        if Y < distance and Y >= -distance then 
          if tiles[index] then
            tile = {name = tiles[index], position = {X+offset_x,Y+offset_y}}
            index = index + 1
          end
        else 
          tile = {name = "out-of-map", position = {X+offset_x,Y+offset_y}}
        end
      else 
        tile = {name = "out-of-map", position = {X+offset_x,Y+offset_y}}
      end
      table.insert(offset_tiles, tile)
    end
  end
  
  game.surfaces[1].set_tiles(offset_tiles, bool)
end

function recreate_entities(entities, offset_x, offset_y, force, duration)
  if not global.chests then global.chests = {} end
  if not global.input_chests then global.input_chests = {} end

  if not entities or not force or not offset_x or not duration or not offset_y then return end

  for k, entity in pairs (entities) do
    if k % global.ticks_to_generate_entities == game.tick % global.ticks_to_generate_entities then
      if entity.amount then
        game.surfaces[1].create_entity({name = entity.name, position = {entity.position[1]+offset_x, entity.position[2]+offset_y}, amount = entity.amount})
      elseif entity.name == "express-loader" then
        local v = game.surfaces[1].create_entity({force = force, direction = entity.direction, name = entity.name, position = {entity.position[1]+offset_x, entity.position[2]+offset_y}, type = entity.type})
        v.destructible = false
        v.minable = false
        v.rotatable = false
      elseif entity.name == "logistic-chest-passive-provider" then
        local v = game.surfaces[1].create_entity({force = force, name = entity.name, position = {entity.position[1]+offset_x, entity.position[2]+offset_y}})
        v.destructible = false
        v.minable = false
        v.rotatable = false
        table.insert(global.chests, v)
      elseif entity.name == "logistic-chest-requester" then
        local v = game.surfaces[1].create_entity({force = force, name = entity.name, position = {entity.position[1]+offset_x, entity.position[2]+offset_y}})
        v.destructible = false
        v.minable = false
        v.rotatable = false
        v.operable = false
        table.insert(global.input_chests, v)
      elseif entity.name == "electric-energy-interface" then
        local v = game.surfaces[1].create_entity({force = force, name = entity.name, position = {entity.position[1]+offset_x, entity.position[2]+offset_y}})
        v.destructible = false
        v.minable = false
        v.rotatable = false
        v.power_production = 5 * 10^9
        v.power_usage = 0
        v.electric_buffer_size = 5 * 10^9
        v.energy = 2.55 * 10^9
        v.electric_output_flow_limit = 50000000
        v.electric_input_flow_limit = 50000000
      elseif entity.name == "big-electric-pole" then
        local v = game.surfaces[1].create_entity({force = force, name = entity.name, position = {entity.position[1]+offset_x, entity.position[2]+offset_y}})
        v.destructible = false
        v.minable = false
        v.rotatable = false

      else
        game.surfaces[1].create_entity({name = entity.name, position = {entity.position[1]+offset_x, entity.position[2]+offset_y}, force = force})
      end
    end
  end
end