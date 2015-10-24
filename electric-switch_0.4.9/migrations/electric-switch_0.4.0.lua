for i, player in ipairs(game.players) do 
  player.force.reset_technologies() 
  if player.force.technologies["electric-energy-distribution-1"].researched then 
    player.force.recipes["electric-switch"].enabled = true
  end
end