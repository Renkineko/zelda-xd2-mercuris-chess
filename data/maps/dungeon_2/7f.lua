local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local elevator_manager = require("scripts/maps/elevator_manager")
elevator_manager:create_elevator(map, "elevator_b", 0, 8, "vip_card")

local opera_puzzle_finished = false

function map:on_started(destination)

  map:set_doors_open("nw_room_door")
  map:set_entities_enabled("nw_room_enemy", false)

  if nw_room_chest:is_open() then
    close_loud_nw_room_door_sensor:remove()
  else
    nw_room_chest:set_enabled(false)
  end

  if destination == from_8f_s then
    map:set_doors_open("auto_door_a")
  end
end

local function nw_room_enemy_on_dead()

  if map:get_entities_count("nw_room_enemy") == 0 and
      nw_room_door:is_closed() then
    sol.audio.play_sound("chest_appears")
    nw_room_chest:set_enabled(true)
    close_loud_nw_room_door_sensor:remove()
    map:open_doors("nw_room_door")
  end
end

for enemy in map:get_entities("nw_room_enemy") do
  enemy.on_dead = nw_room_enemy_on_dead
end

function close_loud_nw_room_door_sensor:on_activated()

  getmetatable(self).on_activated(self)
  map:set_entities_enabled("nw_room_enemy", true)
end

local function opera_puzzle_wrong_piece_on_moved(piece)
  opera_puzzle_finished = true
end

local function opera_puzzle_rook_on_moved(rook)
  
  if opera_puzzle_finished then
    return
  end

  if game:get_value("opera_puzzle_piece_of_heart") then
    -- Already found.
    return
  end

  if rook:overlaps(opera_puzzle_placeholder, "containing") then
    sol.audio.play_sound("secret")
    map:create_pickable({
      x = 624,
      y = 77,
      layer = 0,
      treasure_name = "piece_of_heart",
      treasure_variant = 1,
      treasure_savegame_variable = "opera_puzzle_piece_of_heart"
    })
    opera_puzzle_finished = true
  end
end

for pawn in map:get_entities("pawn") do
  pawn.on_moved = opera_puzzle_wrong_piece_on_moved
end

bishop_1.on_moved = opera_puzzle_wrong_piece_on_moved
king.on_moved = opera_puzzle_wrong_piece_on_moved
rook_1.on_moved = opera_puzzle_rook_on_moved