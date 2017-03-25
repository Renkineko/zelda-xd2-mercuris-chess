local item = ...

function item:on_created()
  self:set_savegame_variable("possession_feather")
  self:set_assignable(true)
end

--[[ TODO make 2 variants
function item:on_using()

  sol.audio.play_sound("jump")
  local hero = self:get_map():get_entity("hero")
  local direction4 = hero:get_direction()
  local randdirection = math.random(4)
  local diagonal = 0

  if randdirection == 1 then
    diagonal = 1
  elseif randdirection == 4 then
    diagonal = -1
  end

  hero:start_jumping((direction4 * 2 + diagonal) % 8,
      math.random(16, 40), false)
  self:set_finished()
end
--]]


function item:on_using()
  sol.audio.play_sound("jump")
  local hero = self:get_map():get_entity("hero")
  local direction4 = hero:get_direction()
  hero:start_jumping(direction4 * 2, 32, false)
  self:set_finished()
end
