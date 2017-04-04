local item = ...

function item:on_created()
  self:set_savegame_variable("possession_feather")
  self:set_assignable(true)
end

function item:on_using()

  local hero = self:get_map():get_entity("hero")
  local direction4 = hero:get_direction()

  if item:get_variant() == 1 then
    -- Broken feather.
    sol.audio.play_sound("jump")
    local rand_direction = math.random(4)
    local diagonal = 0

    if rand_direction == 1 then
      diagonal = 1
    elseif rand_direction == 4 then
      diagonal = -1
    end

    hero:start_jumping((direction4 * 2 + diagonal) % 8,
        math.random(16, 40), false)

  else
    -- iFeather.
    sol.audio.play_sound("jump")
    local hero = self:get_map():get_entity("hero")
    local direction4 = hero:get_direction()
    hero:start_jumping(direction4 * 2, 32, false)
    self:set_finished()
  end

  item:set_finished()
end
