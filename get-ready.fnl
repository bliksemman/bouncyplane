(local plane-noise assets.sounds.plane)

{:enter
 (fn [game-state]
   (set game-state.score 0)
   (set game-state.flap false)
   (set game-state.plane-y (/ GAME-HEIGHT 2))
   (set game-state.plane-y-velocity 0)
   (set game-state.gaps {})
   (set game-state.next-gap-distance 0)
   (: plane-noise :setLooping true)
   (: plane-noise :play))

 :exit
 (fn [game-state]
   (: plane-noise :stop))
 
 :draw
 (fn [game-state]
   (love.graphics.setFont largeFont)
   (love.graphics.printf "Press Space" 0 64 GAME-WIDTH "center")
   (love.graphics.draw plane-img GAME-CENTER-X game-state.plane-y 0 2 2 plane-img-x-offset plane-img-y-offset))

 :keypressed
 (fn [game-state key]
  (when (= key "space")
    (set game-state.flap true)
    (set game-state.switch-screen :play)))}



