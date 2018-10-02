(local GRAVITY 8)
(local FLAP-VELOCITY -4)
(local GAP-DISTANCE 200)
(local GAP-HEIGHT 120)
(local MAX-GAP-DELTA-STEP 8)
(local GAP-DELTA-FACTOR 20)
(local GAP-BOTTOM-LIMIT (- GROUND-LEVEL GAP-HEIGHT))
(local GAP-TOP-LIMIT GAP-HEIGHT)
(local PLANE-HIT-OFFSETS {:bottom 10 :top -8 :left -35 :right 35})

(local screen {})

(local plane-noise assets.sounds.plane)

(defn screen.enter [game-state]
  (: plane-noise :setLooping true)
  (: plane-noise :play))

(defn end-game [game-state]
  (: assets.sounds.crash :play)
  (: assets.sounds.hit :play)
  (set game-state.switch-screen :game-over))

(defn screen.exit [game-state]
  (set game-state.gaps {})
  (: plane-noise :stop))
 

(defn screen.update [game-state dt]
  (local frame-distance (* dt FOREGROUND-SPEED))

  ;; Update gap offsets
  (lume.each game-state.gaps
             (fn [gap] (set gap.x (- gap.x frame-distance))))
  (set game-state.gaps
       (lume.filter game-state.gaps (fn [gap] (> gap.x (- GAP-WIDTH)))))

  ;; Add new gap if needed
  (set game-state.next-gap-distance (- game-state.next-gap-distance frame-distance))
  (when (<= game-state.next-gap-distance 0)
    (let [last-gap (lume.last game-state.gaps)
          previous-y (if last-gap
                         (-> last-gap (and last-gap.y) (or GAME-HEIGHT / 2))
                         (/ GAME-HEIGHT 2))
          height GAP-HEIGHT
          height-offset (/ height 2)
          half-delta (/ MAX-GAP-DELTA-STEP 2)
          y (-> (lume.random (- half-delta) half-delta)
                (math.floor)
                (* GAP-DELTA-FACTOR)
                (+ previous-y)
                (lume.clamp GAP-TOP-LIMIT GAP-BOTTOM-LIMIT))]
      (table.insert game-state.gaps {:x (+ GAME-WIDTH GAP-WIDTH)
                                     :y y
                                     :height height
                                     :top (- y height-offset)
                                     :bottom (+ y height-offset)}))
    (set game-state.next-gap-distance GAP-DISTANCE))

  ;; Update plane
  (set game-state.plane-y-velocity (+ game-state.plane-y-velocity (* dt GRAVITY)))
  
  (when game-state.flap
    (: assets.sounds.flap :play)
    (set game-state.plane-y-velocity FLAP-VELOCITY)
    (set game-state.flap false))

  (set game-state.plane-y (+ game-state.plane-y game-state.plane-y-velocity))

                       
  ;; Check if plane collides with ground
  (when (> (+ game-state.plane-y PLANE-HIT-OFFSETS.bottom) GROUND-LEVEL)
    (end-game game-state))
  
  ;; Clamp plane to ceiling
  (when (< game-state.plane-y CEILING-LEVEL)
    (set game-state.plane-y CEILING-LEVEL))

  ;; Check if plane goes through gap
  (let [gap-radius (/ GAP-WIDTH 2)
        is-within-gap-column (fn [gap]
                               (or
                                (<= (- gap.x gap-radius) (+ GAME-CENTER-X PLANE-HIT-OFFSETS.left) (+ gap.x gap-radius))
                                (<= (- gap.x gap-radius) (+ GAME-CENTER-X PLANE-HIT-OFFSETS.right) (+ gap.x gap-radius))))
        gaps (lume.filter game-state.gaps is-within-gap-column)]
    (lume.each gaps
      (fn [gap]
        (let [plane-top (+ game-state.plane-y PLANE-HIT-OFFSETS.top)
              plane-bottom (+ game-state.plane-y PLANE-HIT-OFFSETS.bottom)]
          ;; Check if plane is outside of gap (if so it hits the pipes).
          (when (or (< plane-top gap.top)
                    (> plane-bottom gap.bottom))
            (end-game game-state))))))

                                      
  ;; Update score if needed
  (lume.each game-state.gaps
             (fn [gap]
               (when (and (not gap.has-been-scored)
                          (< (+ gap.x (/ GAP-WIDTH 2)) GAME-CENTER-X))
                 (: assets.sounds.point :play)
                 (set gap.has-been-scored true)
                 (set game-state.score (+ game-state.score 1))))))


(defn screen.draw [game-state]
  (love.graphics.setFont largeFont)
  (love.graphics.print game-state.score 20 20)
  (let [angle (lume.angle 0 0 FOREGROUND-SPEED game-state.plane-y-velocity)]
    (love.graphics.draw plane-img GAME-CENTER-X game-state.plane-y angle 2 2 plane-img-x-offset plane-img-y-offset)))
  ;; Debug hit box
  ;; (love.graphics.setColor 1 0 0)
  ;; (love.graphics.rectangle "line"
  ;;                          (+ GAME-CENTER-X PLANE-HIT-OFFSETS.left)
  ;;                          (+ game-state.plane-y PLANE-HIT-OFFSETS.top)
  ;;                          (* 2 PLANE-HIT-OFFSETS.right)
  ;;                          (* 2 PLANE-HIT-OFFSETS.bottom))
  ;; (love.graphics.setColor 1 1 1 1))

(defn screen.keypressed [game-state key]
  (when (= key "space")
    (set game-state.flap true)))

(defn screen.joystickpressed [game-state joystick button]
  (set game-state.flap true))

screen
