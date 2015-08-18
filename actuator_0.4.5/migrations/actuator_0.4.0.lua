for i, player in ipairs(game.players) do 
  player.force.reset_technologies() 
  if player.force.technologies["circuit-network"].researched then 
    player.force.recipes["directional-actuator"].enabled = true
  end
end