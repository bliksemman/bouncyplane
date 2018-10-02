(local repl (require "lib.stdio"))

(love.graphics.setDefaultFilter "nearest" "nearest" 0)

(local WINDOW-WIDTH 720)
(local WINDOW-HEIGHT 480)
(global GAME-WIDTH 722)
(global GAME-HEIGHT 482)
(global GAME-CENTER-X (/ GAME-WIDTH 2))
(global GAP-WIDTH 70)

(global BACKGROUND-SPEED 30)
(global BACKGROUND-LOOP-POINT 800)

(global FOREGROUND-SPEED 60)

(global assets ((. (require "cargo") :init) "assets"))

(: assets.sounds.plane :setVolume 0.8)

(global mediumFont (assets.fonts.monthoers 54))
(global largeFont (assets.fonts.monthoers 64))

(global plane-img-x-offset (-> (: assets.images.plane :getWidth) (/ 2)))
(global plane-img-y-offset (-> (: assets.images.plane :getHeight) (/ 2)))
(global ground-y (- GAME-HEIGHT 40))

(global CEILING-LEVEL plane-img-y-offset)
(global GROUND-LEVEL (- ground-y plane-img-y-offset -40))

(local movie (love.graphics.newVideo "assets/movie.ogg"))
(local canvas (love.graphics.newCanvas GAME-WIDTH GAME-HEIGHT))

(local game-state {:screen (require :title)
                   :gaps {}
                   :background-pos 0})
(var plane-anim-index 0)
(var plane-anim-duration 0.1)
(local plane-images [:plane :plane2 :plane3])

(defn love.load []
  (repl.start)
  (love.window.setMode
   WINDOW-WIDTH WINDOW-HEIGHT
   {:fullscreen false
    :resizable true})
  (love.window.setTitle "Bouncy Plane")
  (love.audio.setVolume 0.6)
  (: movie :play))


(defn loop-pos [game-state position-key speed loop-point dt]
  (let [new-pos (-> (. game-state position-key)
                    (+ (* dt speed))
                    (% loop-point))]
    (tset game-state position-key new-pos))) 


(defn love.update [dt]
  (set plane-anim-duration (- plane-anim-duration dt))
  (when (< plane-anim-duration 0)
    (set plane-anim-index (% (+ 1 plane-anim-index) 3))
    (set plane-anim-duration 0.1))
  ;; Handle screen transitions
  (let [new-screen game-state.switch-screen]
    (when new-screen
      (let [screen (require new-screen)]
        (lume.call game-state.screen.exit game-state)
        (set game-state.screen screen)
        (lume.call screen.enter game-state)
        (set game-state.switch-screen nil))))
  
  ;; Update background and foreground layers
  (loop-pos game-state :background-pos BACKGROUND-SPEED BACKGROUND-LOOP-POINT dt)

  (lume.call game-state.screen.update game-state dt))
  

(defn love.keypressed [key]
  (lume.call game-state.screen.keypressed game-state key))

(defn love.joystickpressed [joystick button]
  (lume.call game-state.screen.joystickpressed game-state joystick button))

(defn love.draw []
  (global plane-img (. assets.images (. plane-images (+ 1 plane-anim-index))))
  (let [(window-width window-height flags) (love.window.getMode)
        scale-x (/ window-width WINDOW-WIDTH)     
        scale-y (/ window-height WINDOW-HEIGHT)]

    (love.graphics.clear 0 0 0)
    (love.graphics.setBlendMode :alpha)
    (love.graphics.setColor 1 1 1 1)
    (love.graphics.draw movie 0 0 0 scale-x scale-y)

    (when (not (: movie :isPlaying))
      (: movie :rewind)
      (: movie :play))

    (love.graphics.setCanvas canvas)
    (love.graphics.clear)
    (love.graphics.setBlendMode :alpha)
    (love.graphics.draw assets.images.background (- 0 game-state.background-pos) 0)
    (love.graphics.draw assets.images.background (- BACKGROUND-LOOP-POINT game-state.background-pos) 0)

    (lume.each game-state.gaps
               (fn [gap]
                 (let [gap-x (- gap.x (/ GAP-WIDTH 2))]
                   (love.graphics.setColor 1 1 1 1)
                   (love.graphics.rectangle "fill" gap-x gap.bottom GAP-WIDTH (- ground-y gap.bottom))
                   (love.graphics.rectangle "fill" gap-x 0 GAP-WIDTH gap.top))))


    (love.graphics.setColor 1 1 1 1)
    (love.graphics.rectangle "fill" 0 ground-y GAME-WIDTH GAME-HEIGHT)

    (lume.call game-state.screen.draw game-state)

    (love.graphics.setCanvas)
    (love.graphics.setBlendMode :multiply :premultiplied)

    (let [choice {-1 50 0 10 -2 10}]
      (love.graphics.draw canvas (lume.weightedchoice choice) (lume.weightedchoice choice) 0 scale-x scale-y))))
                          

