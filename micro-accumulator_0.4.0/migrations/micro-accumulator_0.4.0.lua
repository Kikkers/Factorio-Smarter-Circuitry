for i, player in ipairs(game.players) do 
  player.force.reset_technologies() 
  if player.force.technologies["electric-energy-accumulators-1"].researched then 
    player.force.recipes["micro-accumulator"].enabled = true
  end
end