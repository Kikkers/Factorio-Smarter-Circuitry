for i, player in ipairs(game.players) do 
  player.force.reset_technologies() 
  if player.force.technologies["concrete"].researched then 
    player.force.recipes["pressure-floor"].enabled = true
  end
end