-- Lua script of map dungeon_1/1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local water_delay = 500

-- Create the boss
function chicken_boss_switch:on_activated()
  local x, y, layer = self:get_position()
  local prop = {x = x, y = y, layer = layer, direction = 3, breed = "oclero/chicken_giant"}
  map:create_enemy(prop)
end

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  map:set_doors_open("boss_door")
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished(destination)
  if destination == from_outside then
    game:start_dialog("dungeon_1.welcome")
  end
end

function mario_voice_1:on_interaction()
  sol.audio.play_sound("mk64_mario_yeah")
end

function mario_voice_2:on_interaction()
  sol.audio.play_sound("sm64_heehee")
end

function mario_voice_3:on_interaction()
  sol.audio.play_sound("sm64_memario")
end

function mario_switch_1:on_activated()
  map:get_entity("mario_reset_switch"):set_activated(false)
end

function mario_switch_2:on_activated()
  map:get_entity("mario_reset_switch"):set_activated(false)
end

function mario_switch_3:on_activated()
  map:get_entity("mario_reset_switch"):set_activated(false)
end

function mario_reset_switch:on_activated()
  local switches = map:get_entities("mario_switch")
  for switch in switches do
    switch:set_activated(false)
  end
end

-- Pool switch mechanism
-- The switch fills up the champagne swimming pool
function pool_switch:on_activated()
  sol.audio.play_sound("water_fill_begin")
  sol.audio.play_sound("water_fill")
  local water_tile_index = 5
  sol.timer.start(water_delay, function()
    local next_tile = map:get_entity("pool_" .. water_tile_index)
    local previous_tile = map:get_entity("pool_" .. water_tile_index + 1)
    if next_tile == nil then
      return false
    end
    next_tile:set_enabled(true)
    if previous_tile ~= nil then
      previous_tile:set_enabled(false)
    end
    water_tile_index = water_tile_index - 1
    return true
  end)
end

-- Library Labyrinth
local function timer_finished()
  map:close_doors("library_door")
  map:get_entity("library_door_switch"):set_activated(false)
end

local old_man_blocks = true

local function old_man_moves_quickly()
  if not old_man_blocks then
    local movement = sol.movement.create("path")
    movement:set_speed(50)
    movement:set_path{4,4,4,4,2,2,2,2,2,2,4,4,4,4}
    local old_man = map:get_entity("library_old_man") 
    movement:start(old_man)
    sol.audio.play_sound("metallizer/trolololol")
  end
end

function library_door_switch:on_activated()
  map:open_doors("library_door")
  local timer = sol.timer.start(map, 5000, timer_finished)
  timer:set_with_sound(true)
  old_man_moves_quickly()
  old_man_blocks = true
end

function sensor_old_man_move_back:on_activated()
  map:get_entity("library_old_man"):set_position(1768, 349)
  old_man_blocks = true
end

function sensor_old_man_move_away:on_activated()
  map:get_entity("library_old_man"):set_position(1832, 397)
  old_man_blocks = false
end

-- River switch mechanism
-- The switch fills up the champagne river (yummy!)
function river_switch:on_activated()
  sol.audio.play_sound("water_drain_begin")
  sol.audio.play_sound("water_drain")
  local water_tile_index = 1
  sol.timer.start(water_delay, function()
    local next_tiles = map:get_entities("animated_river_" .. water_tile_index + 1)
    local previous_tiles = map:get_entities("animated_river_" .. water_tile_index)
    if next_tiles == nil then
      return false
    end
    for tile in next_tiles do
      tile:set_enabled(true)
    end
    for tile in previous_tiles do
      tile:set_enabled(false)
    end
    water_tile_index = water_tile_index + 1
    return true
  end)
  for tile in map:get_entities("static_river_") do
    tile:set_enabled(false)
  end
end