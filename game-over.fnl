{:draw
 (fn [game-state]
   (love.graphics.setFont largeFont)
   (love.graphics.printf "game over" 0 64 GAME-WIDTH "center")

   (love.graphics.printf game-state.score 0 140 GAME-WIDTH "center")
   (love.graphics.setFont mediumFont)
   (love.graphics.printf "press enter" 0 340 GAME-WIDTH "center"))
 :keypressed
 (fn [game-state key]
   (when (= key "return")
     (set game-state.switch-screen :get-ready)))}



