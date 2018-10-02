{:draw
 (fn [game-state]
   (love.graphics.setFont largeFont)
   (love.graphics.printf "bouncy plane" 0 64 GAME-WIDTH "center")
   (love.graphics.printf "press enter" 0 160 GAME-WIDTH "center"))
 
 :keypressed
 (fn [game-state key]
   (when (= key "return")
     (set game-state.switch-screen :get-ready)))}


