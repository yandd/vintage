#lang scheme
(require 2htdp/universe)
(require 2htdp/universe test-engine/scheme-tests)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ---Graphcial constants---

(define SCENE-WIDTH 400) ;; Scene width
(define SCENE-HEIGHT 400) ;; Scene height
(define CENTER-X (/ SCENE-WIDTH 2)) ;; The initial x coordinate of tank

(define SPEED-UFO 2) ;; UFO SPEED px/tick
(define SPEED-TANK 5) ;; TANK SPEED px/tick
(define SPEED-MISSILE (* SPEED-UFO 2)) ;; MISSILE SPEED px/tick
(define SPEED-BOMB (* SPEED-UFO 2)) ;; BOMB SPEED px/tick

(define BACKGROUND (empty-scene SCENE-WIDTH SCENE-HEIGHT)) ;; Initial scene
(define IMG-TANK (rectangle 30 20 "solid" "black")) ;; Tank's image
(define IMG-UFO  (circle 10 "solid" "yellow")) ;; UFO's image
(define IMG-MISSILE (triangle 5 "solid" "red")) ;; Missile's image
(define IMG-BOMB (circle 4 "solid" "blue")) ;; Bomb's image

;; The explode distance of UFO and missile
(define EXPLODE-DISTANCE1 (/ (+ (image-width IMG-UFO)  
                                (image-width IMG-MISSILE)) 2)) 
;; The explode distance of Bomb and tank
(define EXPLODE-DISTANCE2 (/ (+ (image-width IMG-BOMB)  
                                (image-width IMG-TANK)) 2))
;; The initial y coordinate of new missiles
(define MISSILE-Y (- SCENE-HEIGHT (image-height IMG-TANK))) 

;; Tank's y coordinate
(define TANK-Y (- SCENE-HEIGHT (/ (image-height IMG-TANK) 2))) 

;; Tank's left boundary
(define TANK-LEFT-BOUNDARY (/ (image-width IMG-TANK) 2))

;; Tank's right boundary
(define TANK-RIGHT-BOUNDARY (- SCENE-WIDTH (/ (image-width IMG-UFO) 2)))

;; UFO's left boundary
(define UFO-LEFT-BOUNDARY (/ (image-width IMG-TANK) 2))

;; UFO's right boundary
(define UFO-RIGHT-BOUNDARY (- SCENE-WIDTH (/ (image-width IMG-UFO) 2)))

(define UFO-Y (/ (image-height IMG-UFO) 2)) ;; UFO appears at this y-coordinate

;; The y coordinate of ground
(define GROUND-Y (- SCENE-HEIGHT (image-height IMG-TANK))) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;                                  
;                                  
;                                  
;                                  
;                      ;           
;                                  
;  ;; ;  ;   ;;;;    ;;;    ;; ;;  
;   ;; ;; ; ;    ;     ;     ;;  ; 
;   ;  ;  ;  ;;;;;     ;     ;   ; 
;   ;  ;  ; ;    ;     ;     ;   ; 
;   ;  ;  ; ;   ;;     ;     ;   ; 
;  ;;; ;; ;  ;;; ;;  ;;;;;  ;;; ;;;
;                                  
;                                  
;                                  
;                                  


;; space-invader-state% -> Nat
;; launch a space invader game, use sis0 as initial state
;; space-invader-state% -> Nat
;; launch a space invader game, use sis0 as initial state

(define (main sis0)
  (big-bang 0
            (on-tick (lambda (x) 
                       (begin
                         (send sis0 move)
                         (+ 1 x))))
            (on-key (lambda (x ke)
                      (begin
                        (send sis0 react ke)
                        (+ 1 x))))
            (on-draw (lambda (x) (send sis0 render)))
            (stop-when (lambda (x) (send sis0 win-or-lose?)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;                          
;                          
;                          
;                          
;    ;;; ;   ;;;;;   ;;; ; 
;   ;   ;;     ;    ;   ;; 
;   ;          ;    ;      
;    ;;;;      ;     ;;;;  
;        ;     ;         ; 
;        ;     ;         ; 
;   ;;   ;     ;    ;;   ; 
;   ; ;;;    ;;;;;  ; ;;;  
;                          
;                          
;                          
;                          


;; a space-invader-state% consists of tank, LOM and UFO
(define space-invader-state% 
  (class object% 
    (init-field tank ;; tank%
                LOB ;; [Listof bomb%]
                LOM ;; [Listof missle%]
                UFO) ;; UFO%
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;; move: -> VOID
    ;; handles the on-tick
    (define/public (move) 
      (begin
        (send tank tank-moved)
        (send this lob-after-tick LOB)
        (send this lom-after-tick LOM)
        (send UFO UFO-moved)
        (send this state-after-tick)))
    
    ;; lob-after-tick: LOB -> VOID
    ;; to deal with the on-tick event of LOB
    (define/public (lob-after-tick lob)
      (local 
        ((define lob2
           (filter (lambda (b) 
                     (send b bomb-in-bound?)
                     (send b bomb-moved)) lob))
         (define lob3 (map (lambda (b) (send b bomb-moved)) lob2))
         (define new-missile-posn (send UFO get-UFO-posn))
         (define random-1/10? (= (random 10) 3))
         (define lob4 (if random-1/10?
                          (append lob3 (list (new bomb%
                                                  [posn new-missile-posn])))
                          lob3)))
        (set! LOB lob4)))
    
    ;; lom-after-tick: LOM -> VOID
    ;; to deal with the on-tick event of LOM
    (define/public (lom-after-tick lom)
      (local 
        ((define lom2
           (filter (lambda (m) 
                     (send m missile-in-bound?)
                     (send m missile-moved)) lom))
         (define lom3
           (map (lambda (m) (send m missile-moved)) lom2)))
        (set! LOM lom3)))
        
    ;; state-after-tick: -> VOID
    ;; to decide the current-state<%> of the space-invader-state%
    (define/public (state-after-tick)
      (cond
        [(send this lom-explode? LOM) 
         (send UFO current-state-converter win%)]
        [(or (send UFO UFO-landed?) (send this lob-explode? LOB))
         (send UFO current-state-converter lose%)]  
        [else (send UFO current-state-converter playing%)]))
   
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;; react: KeyEvent -> VOID
    ;; to generate a new space-invader-state% according to given KeyEvent
    (define/public (react kev)
      (local ((define new-LOM 
                (append LOM 
                        (list (new missile% 
                                   [posn (new posn%
                                              [x (send tank get-tank-x)]
                                              [y MISSILE-Y])])))))
        (cond
          [(string=? kev "left") 
           (send tank tank-key-direction left%)]
          [(string=? kev "right")
           (send tank tank-key-direction right%)]
          [(string=? kev " ") 
           (begin (set! LOM new-LOM))]
          [else void])))
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;; render: -> SCENE
    ;; render the space-invader-state% into image
    (define/public (render)
      (local ((define scn
                (send this render-lob LOB
                      (send this render-lom LOM
                            (send UFO render-UFO 
                                  (send tank render-tank BACKGROUND))))))
        (send UFO render-state scn)))
    
    
    ;; render-lob: LOB Image -> SCENE
    ;; render LOB into image
    (define/public (render-lob lob scene)
      (foldr (lambda (b scene) (send b render-bomb scene)) scene lob))
    
    ;; render-lom: LOM Image -> SCENE
    ;; render LOM into image
    (define/public (render-lom lom scene)
      (foldr (lambda (m scene) (send m render-missile scene)) scene lom))
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;; win-or-lose?: -> Boolean
    ;; to decide when to stop the world
    (define/public (win-or-lose?)
      (or (send this lob-explode? LOB) 
          (send this lom-explode? LOM)
          (send UFO UFO-landed?)))
    
    ;; lob-explode?: LOB -> Boolean
    ;; to check if one bomb% of LOB explodes
    (define/public (lob-explode? lob)
      (local ((define tank-posn 
                (new posn%
                     [x (send tank get-tank-x)]
                     [y TANK-Y])))
        (ormap (lambda (b) (send b bomb-explode? tank-posn)) lob)))
    
    ;; lom-explode?: LOM -> Boolean
    ;; to check if one missile% of LOM explodes
    (define/public (lom-explode? lom)
      (ormap (lambda (m) (send m missile-explode? UFO)) lom))
    
    (super-new)))   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;                                  
;                                  
;                                  
;                                  
;                                  
;                                  
;   ;; ;;    ;;;;    ;;;;;  ;; ;;  
;    ;;  ;  ;    ;  ;    ;   ;;  ; 
;    ;   ;  ;    ;   ;;;;    ;   ; 
;    ;   ;  ;    ;       ;   ;   ; 
;    ;   ;  ;    ;  ;    ;   ;   ; 
;    ;;;;    ;;;;   ;;;;;   ;;; ;;;
;    ;                             
;   ;;;                            
;                                  
;                                  

;; posn% means the position of the 2D canvas

(define posn% 
  (class object%
    (init-field x ;; Number, x coordinate of posn%
                y) ;; Number, y coordinate of posn%
    
    ;; get-x: -> posn%
    ;; to get the x out of posn%
    (define/public (get-x) x)
    
    ;; get-y: -> posn%
    ;; to get the y out of posn%
    (define/public (get-y) y)
    
    ;; posn+: Number Number-> VOID
    ;; to get the sum of two posns pointwisely
    
    (define/public (posn+ dx dy)
      (begin
        (set! x (+ x dx))
        (set! y (+ y dy))))
    
    ;; distance: posn% -> Number
    ;; compute the distance of two posns
    (define/public (distance p1)
      (sqrt (+ (sqr (- x (send p1 get-x))) 
               (sqr (- y (send p1 get-y))))))
    
    (super-new)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;                                                                          
;                                                                          
;                                                                          
;                                                                          
;                           ;;                  ;;                         
;    ;                       ;                   ;                         
;   ;;;;;    ;;;;   ;; ;;    ; ;;;;          ;;; ;  ;; ;;;   ;;; ;  ;; ;;  
;    ;      ;    ;   ;;  ;   ;  ;           ;   ;;   ;;     ;   ;;   ;;  ; 
;    ;       ;;;;;   ;   ;   ;;;    ;;;;;;  ;    ;   ;      ;        ;   ; 
;    ;      ;    ;   ;   ;   ; ;            ;    ;   ;      ;        ;   ; 
;    ;   ;  ;   ;;   ;   ;   ;  ;           ;   ;;   ;      ;    ;   ;   ; 
;     ;;;    ;;; ;; ;;; ;;; ;;  ;;;          ;;; ;; ;;;;;    ;;;;   ;;; ;;;
;                                                                          
;                                                                          
;                                                                          
;                                                                          


;; a tank-direction<%> is the current direction of the tank, 
;; which has left% and right%

(define tank-direction<%>
  (interface ()))

;; left% means the current direction of the tank is left
(define left%
  (class* object% (tank-direction<%>)
    
    (super-new)))

;; right% means the current direction of the tank is right
(define right%
  (class* object% (tank-direction<%>)
    
    (super-new)))  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;                                  
;                                  
;                                  
;                                  
;                           ;;     
;    ;                       ;     
;   ;;;;;    ;;;;   ;; ;;    ; ;;;;
;    ;      ;    ;   ;;  ;   ;  ;  
;    ;       ;;;;;   ;   ;   ;;;   
;    ;      ;    ;   ;   ;   ; ;   
;    ;   ;  ;   ;;   ;   ;   ;  ;  
;     ;;;    ;;; ;; ;;; ;;; ;;  ;;;
;                                  
;                                  
;                                  
;                                  


;; a tank% consists of a tank-direction<%> and tank-x
(define tank%
  (class object%
    (init-field tank-direction ;; tank-direction<%>, the current direction of tank
                ;; which is either left% of right%
                tank-x) ;; Number, the current x-coordinate of the tank
    
    ;; get-tank-x: -> Number
    ;; to get the tank-x out of tank%
    (define/public (get-tank-x) tank-x)
    
    ;; tank-moved: -> VOID
    (define/public (tank-moved)
      (local ((define tank-offset
                (if (is-a? tank-direction left%) 
                                      (- SPEED-TANK) SPEED-TANK)))
        (begin 
          (set! tank-x (+ tank-x tank-offset))
          (send this tank-in-bound))))
    
    
    ;; tank-in-bound: -> VOID
    ;; to confine the tank in bound
    (define/public (tank-in-bound)
      (local ((define d
                (cond
                  [(< tank-x TANK-LEFT-BOUNDARY) (new right%)]
                  [(> tank-x TANK-RIGHT-BOUNDARY) (new left%)]
                  [else tank-direction]))
              (define tx
                (if (object=? d tank-direction)
                    tank-x
                    (cond
                      [(is-a? d right%) TANK-LEFT-BOUNDARY]
                      [(is-a? d left%) TANK-RIGHT-BOUNDARY]))))
        (begin
          (set! tank-direction d)
          (set! tank-x tx))))
    
    ;; tank-key-direction: -> VOID
    ;; to generate new tank% according to given tank-direction<%>
    (define/public (tank-key-direction tr)
      (set! tank-direction (new tr)))
    
    ;; render-tank: Scene -> SCENE
    ;; to render the tank as image
    (define/public (render-tank scene)
      (place-image IMG-TANK tank-x TANK-Y scene))
    
    (super-new)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;                                                          
;                                                          
;                                                          
;                                                          
;              ;                       ;      ;;           
;                                              ;           
;  ;; ;  ;   ;;;     ;;;;;   ;;;;;   ;;;       ;     ;;;;  
;   ;; ;; ;    ;    ;    ;  ;    ;     ;       ;    ;    ; 
;   ;  ;  ;    ;     ;;;;    ;;;;      ;       ;    ;;;;;; 
;   ;  ;  ;    ;         ;       ;     ;       ;    ;      
;   ;  ;  ;    ;    ;    ;  ;    ;     ;       ;    ;      
;  ;;; ;; ;  ;;;;;  ;;;;;   ;;;;;    ;;;;;   ;;;;;   ;;;;; 
;                                                          
;                                                          
;                                                          
;                                                          

;; a missile% of the LOM
(define missile%
  (class object%
    (init-field posn);; posn%, the position of the missile
    
    ;; get-missile-posn: -> posn%
    ;; to get the posn field out of missile%
    (define/public (get-missile-posn) posn)
    
    ;; missile-moved: -> missile%
    ;; to move the missile%
    (define/public (missile-moved)
      (new missile%
           [posn (new posn%
                      [x (send posn get-x)]
                      [y (- (send posn get-y)
                            SPEED-MISSILE)])]))
    
    ;; missile-in-bound? -> Boolean
    ;; to check if missile is in bound 
    (define/public (missile-in-bound?)
      (>= (send posn get-y) 0))
    
    ;; missile-explode?: UFO% -> Boolean
    ;; to check if missile% explodes
    (define/public (missile-explode? uf)
      (<= (send posn distance (send uf get-UFO-posn))
          EXPLODE-DISTANCE1))
    
    ;; render-missile: Image -> SCENE
    ;; to render the missile as image
    (define/public (render-missile scene)
      (place-image IMG-MISSILE (send posn get-x) (send posn get-y) scene))
    
    (super-new)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;                                  
;                                  
;                                  
;                                  
;  ;;                      ;;      
;   ;                       ;      
;   ; ;;;    ;;;;  ;; ;  ;  ; ;;;  
;   ;;   ;  ;    ;  ;; ;; ; ;;   ; 
;   ;    ;  ;    ;  ;  ;  ; ;    ; 
;   ;    ;  ;    ;  ;  ;  ; ;    ; 
;   ;;   ;  ;    ;  ;  ;  ; ;;   ; 
;  ;; ;;;    ;;;;  ;;; ;; ;;; ;;;  
;                                  
;                                  
;                                  
;                                  
;; a bomb% of the LOB
(define bomb%
  (class object%
    (init-field posn);; posn%, the position of the bomb
    
    ;; get-bomb-posn: -> posn%
    ;; to get the posn field out of bomb%
    (define/public (get-bomb-posn) posn)
    
    ;; bomb-moved: -> bomb%
    ;; to move the bomb%
    (define/public (bomb-moved)
      (new bomb%
           [posn (new posn%
                      [x (send posn get-x)]
                      [y (+ (send posn get-y)
                            SPEED-BOMB)])]))
    
    ;; bomb-in-bound? -> Boolean
    ;; to check if bomb is in bound 
    (define/public (bomb-in-bound?)
      (<= (send posn get-y) GROUND-Y))
    
    ;; bomb-explode?: posn% -> Boolean
    ;; to check if bomb% explodes
    (define/public (bomb-explode? tp)
      (<= (send posn distance tp) ;; check distance with tank position
          EXPLODE-DISTANCE2))
    
    ;; render-bomb: Image -> SCENE
    ;; to render the bomb as image
    (define/public (render-bomb scene)
      (place-image IMG-BOMB (send posn get-x) (send posn get-y) scene))
    
    (super-new)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;                                                                          
;                                                                          
;                                                                          
;                                                                          
;                                                                          
;                    ;                       ;               ;             
;    ;;; ;  ;; ;;;  ;;;;;            ;;;;;  ;;;;;    ;;;;   ;;;;;    ;;;;  
;   ;   ;;   ;;      ;              ;    ;   ;      ;    ;   ;      ;    ; 
;   ;        ;       ;      ;;;;;;   ;;;;    ;       ;;;;;   ;      ;;;;;; 
;   ;        ;       ;                   ;   ;      ;    ;   ;      ;      
;   ;    ;   ;       ;   ;          ;    ;   ;   ;  ;   ;;   ;   ;  ;      
;    ;;;;   ;;;;;     ;;;           ;;;;;     ;;;    ;;; ;;   ;;;    ;;;;; 
;                                                                          
;                                                                          
;                                                                          
;                                                                          

;; current-state<%> stores the current state of the world, 
;; which has win%, lose% and playing%
(define current-state<%>
  (interface ()))

;; win% state means the game is over, player wins
(define win% 
  (class* object% (current-state<%>)
    (super-new))) ;; takes no init-field

;; lose% state means the game is over, player loses
(define lose% 
  (class* object% (current-state<%>)
    (super-new)))

;; playing% state means the game is still going
(define playing% 
  (class* object% (current-state<%>)
    (super-new)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;                          
;                          
;                          
;                          
;   ;;; ;;; ;;;;;;    ;;;  
;    ;   ;   ;   ;   ;   ; 
;    ;   ;   ; ;    ;     ;
;    ;   ;   ;;;    ;     ;
;    ;   ;   ; ;    ;     ;
;    ;   ;   ;      ;     ;
;    ;   ;   ;       ;   ; 
;     ;;;   ;;;       ;;;  
;                          
;                          
;                          
;                          

;; a UFO consists of a current-state<%>
(define UFO%
  (class object%
    (init-field current-state ;; current-state<%>, represents the current state
                ;; which is win%, lose% or playing%
                posn) ;; posn%, the position of UFO
    
    ;; get-UFO-posn: -> posn%
    ;; to get the posn out of the UFO%
    (define/public (get-UFO-posn) posn)
    
    ;; get-current-state: -> current-state<%>
    ;; to get the current-state out of UFO%
    (define/public (get-current-state) current-state)
    
    ;; UFO-moved: -> VOID
    ;; to give UFO a random posn
    (define/public (UFO-moved)
      (local ((define offset-x
                (if (= (random 2) 0) ;; random direction, left or right
                    (- (random 20)) ;; random offset 
                    (random 20))))
        (begin
          (send posn posn+ offset-x SPEED-UFO)
          (send this UFO-in-bound))))
  
    ;; UFO-in-bound: UFO% -> VOID
    ;; to confine UFO in bound
    (define/public (UFO-in-bound)
      (local
        ((define x (send posn get-x))
         (define y (send posn get-y))
         (define offset 
           (cond
             [(< x UFO-LEFT-BOUNDARY) UFO-LEFT-BOUNDARY]
             [(> x UFO-RIGHT-BOUNDARY) UFO-RIGHT-BOUNDARY]
             [else 0])))
        (send posn posn+ offset 0)))
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;; current-state-converter: UFO% -> VOID
    (define/public (current-state-converter cs)
      (set! current-state (new cs)))
    
    ;; UFO-landed? UFO% -> Boolean
    ;; to check if UFO landed
    (define/public (UFO-landed?)
      (>= (send posn get-y) GROUND-Y))
    
    ;; render-UFO: Image -> SCENE
    ;; to render UFO as image
    (define/public (render-UFO scene)
      (place-image IMG-UFO (send posn get-x) (send posn get-y) scene))
    
    ;; place-text: String Image -> SCENE
    ;; to place text in the given image
    (define/public (place-text txt scene)
      (place-image (text txt 16 "red") 
                   0
                   0
                   scene))
    
    ;; render-state: Image -> SCENE
    ;; to render "WIN!" or "LOST" in the given image
    (define/public (render-state scene)
      (cond
        [(is-a? current-state win%) 
         (place-text "CONGRATULATIONS! YOU WIN!" scene)]
        [(is-a? current-state lose%) 
         (place-text "SORRY, YOU LOST! TRY AGAIN!" scene)]
        [else scene]))
    
    (super-new)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;                                               
;                                               
;                                               
;                                               
;                                               
;   ;;;;;;;                      ;              
;   ;  ;  ;                      ;              
;   ;  ;  ;    ;;;;     ;;;;;  ;;;;;;;    ;;;;; 
;   ;  ;  ;   ;    ;   ;    ;    ;       ;    ; 
;      ;      ;;;;;;    ;;;;     ;        ;;;;  
;      ;      ;             ;    ;            ; 
;      ;      ;    ;   ;    ;    ;    ;  ;    ; 
;    ;;;;;     ;;;;    ;;;;;      ;;;;   ;;;;;  
;                                               
;                                               
;                                               
;                                               

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TESTS EXAMPLES FOR posn%
(define POSN1 (new posn% 
                   [x 9]
                   [y 1]))
(define POSN2 (new posn% 
                   [x 6]
                   [y 5]))
;; TESTS FOR get-x
(check-expect (send POSN1 get-x) 9)

;; TESTS FOR get-y
(check-expect (send POSN1 get-y) 1)

;; TESTS FOR distance
(check-expect (send POSN1 distance POSN2) 5)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TESTS EXPAMLES FOR tank%
(define TANK1 (new tank% [tank-direction (new left%)] [tank-x CENTER-X]))
(define TANK2 (new tank% [tank-direction (new right%)] [tank-x CENTER-X]))
(define TANK-L (new tank% 
                    [tank-direction (new left%)] 
                    [tank-x (- TANK-LEFT-BOUNDARY 1)]))
(define TANK-R (new tank% 
                    [tank-direction (new right%)] 
                    [tank-x (+ 1 TANK-RIGHT-BOUNDARY)]))

;; TESTS FOR get-tank-x
(check-expect (send TANK1 get-tank-x) CENTER-X)

;; TESTS FOR tank-moved
(check-expect (send (send TANK1 tank-moved) get-tank-x) 195)
(check-expect (send (send TANK2 tank-moved) get-tank-x) 205)

;; TESTS FOR tank-in-bound
(check-expect (send (send TANK1 tank-in-bound) get-tank-x) 200)
(check-expect (send (send TANK-L tank-in-bound) get-tank-x) TANK-LEFT-BOUNDARY)
(check-expect (send (send TANK-R tank-in-bound) get-tank-x) TANK-RIGHT-BOUNDARY)

;; TESTS FOR render-tank
(check-expect (send TANK1 render-tank BACKGROUND)
              (place-image IMG-TANK (send TANK1 get-tank-x) TANK-Y BACKGROUND))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TESTS EXPAMLES FOR missile%
(define MISSILE1
  (new missile%
       [posn (new posn%
                  [x CENTER-X]
                  [y TANK-Y])]))
(define MISSILE2
  (new missile%
       [posn (new posn%
                  [x CENTER-X]
                  [y (- TANK-Y SPEED-MISSILE)])]))
(define MISSILE3
  (new missile%
       [posn (new posn%
                  [x CENTER-X]
                  [y -1])]))
(define MISSILE-MID
  (new missile%
       [posn (new posn%
                  [x CENTER-X]
                  [y (/ GROUND-Y 2)])]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TESTS FOR get-missile-posn
(check-expect (send (send MISSILE1 get-missile-posn) get-x) CENTER-X)
(check-expect (send (send MISSILE1 get-missile-posn) get-y) TANK-Y)


;; TESTS FOR missile-moved

(check-expect (send (send (send MISSILE1 missile-moved) get-missile-posn) get-y)
              (send (send MISSILE2 get-missile-posn) get-y))

;; TESTS FOR missile-in-bound?

(check-expect (send MISSILE1 missile-in-bound?) true)
(check-expect (send MISSILE3 missile-in-bound?) false)

;; TESTS FOR missile-explode?

(check-expect (send MISSILE-MID missile-explode? UFO3) true)
(check-expect (send MISSILE-MID missile-explode? UFO4) false)

;; TESTS FOR render-missile

(check-expect (send MISSILE1 render-missile BACKGROUND)
              (place-image IMG-MISSILE 
                           (send (send MISSILE1 get-missile-posn) get-x)
                           (send (send MISSILE1 get-missile-posn) get-y)
                           BACKGROUND))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TESTS FOR UFO%
(define UFO1 (new UFO%
                  [current-state (new playing%)]
                  [posn (new posn%
                             [x CENTER-X]
                             [y UFO-Y])]))
(define UFO2 (new UFO%
                  [current-state (new playing%)]
                  [posn (new posn%
                             [x CENTER-X]
                             [y GROUND-Y])]))
(define UFO3 (new UFO%
                  [current-state (new win%)]
                  [posn (new posn%
                             [x CENTER-X]
                             [y (/ GROUND-Y 2)])]))
(define UFO4 (new UFO%
                  [current-state (new lose%)]
                  [posn (new posn%
                             [x CENTER-X]
                             [y GROUND-Y])]))
;; TESTS FOR get-UFO-posn
(check-expect (send (send UFO1 get-UFO-posn) get-x) CENTER-X)
(check-expect (send (send UFO1 get-UFO-posn) get-y) UFO-Y)

;; TESTS FOR UFO-landed?
(check-expect (send UFO1 UFO-landed?) false) 
(check-expect (send UFO2 UFO-landed?) true)

;; TESTS FOR render-UFO
(check-expect (send UFO1 render-UFO BACKGROUND)
              (place-image IMG-UFO (send (send UFO1 get-UFO-posn) get-x) 
                           (send (send UFO1 get-UFO-posn) get-y) 
                           BACKGROUND))
;; TESTS FOR place-text
(check-expect (send UFO1 place-text "WIN!" BACKGROUND)
              (place-image (text "WIN!" 16 "red") 0 0 BACKGROUND))

;; TESTS FOR render-state
(check-expect (send UFO1 render-state BACKGROUND) BACKGROUND)
(check-expect (send UFO3 render-state BACKGROUND)
              (send UFO3 place-text "CONGRATULATIONS! YOU WIN!" BACKGROUND))
(check-expect (send UFO4 render-state BACKGROUND)
              (send UFO4 place-text "SORRY, YOU LOST! TRY AGAIN!" BACKGROUND))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; INITIAL SIS

(define INIT-SIS (new space-invader-state%
                      [tank (new tank%
                                 [tank-direction (new right%)]
                                 [tank-x CENTER-X])]
                      [LOB empty]
                      [LOM empty]
                      [UFO (new UFO%
                                [current-state (new playing%)]
                                [posn (new posn%
                                           [x CENTER-X]
                                           [y UFO-Y])])]))                      
;(test)