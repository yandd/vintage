;; The first three lines of this file were inserted by DrScheme. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname client-fully-success) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;;  PAIR #091
;;  AUTHORS: KINJAL MISTRY and XIAOFENG YUE
;;  CS5010 - ASSIGNMENT #9 


;                                                                          
;                                                                          
;                                                                          
;                                                                          
;                                                                   ;;;    
;                                ;                                    ;    
;                                ;                                    ;    
;   ;; ;;;    ;; ;;;    ;;;;   ;;;;;;;    ;;;;     ;;; ;    ;;;;      ;    
;    ;;   ;    ;;      ;    ;    ;       ;    ;   ;   ;;   ;    ;     ;    
;    ;    ;    ;       ;    ;    ;       ;    ;  ;         ;    ;     ;    
;    ;    ;    ;       ;    ;    ;       ;    ;  ;         ;    ;     ;    
;    ;;   ;    ;       ;    ;    ;    ;  ;    ;   ;    ;   ;    ;     ;    
;    ; ;;;    ;;;;;     ;;;;      ;;;;    ;;;;     ;;;;     ;;;;   ;;;;;;; 
;    ;                                                                     
;    ;                                                                     
;   ;;;                                                                    
;                                                                          


#|


   server 
     *         Sam         Dan 
     |          *           * 
     | i'm here |           |
     | <======= |           |
     |          | i'm here  |
     | <=================== |   actors can register anytime 
     |          |           |
     | (list "Dan" "Hi")    |   sent message to one of the user
     |<---------|           |           
     |          |           |
     |(list "Sam" "Hi")     |
     |----------|---------->|
     |          |           |
     |          | i'm here  |      Kin in order of registration 
     | <=========================== *
     |          |           |       |
     | (list "*" "Hello")   |       |
     |<---------|           |       |  message sent to everyone 
     |          |           |       |
     |(list "Sam*" "Hello") |       |
     |--------->|           |       |
     |          |           |       |
     |(list "Sam*" "Hello") |       |
     |----------|---------->|       |
     |          |           |       |
     |(list "Sam*" "Hello") |       |
     |----------|------------------>|
     |          |           |       |
     | (list "Pdp" "Hi")    |       |
     |<---------|           |       |  message send to a invalid user 
     |          |           |       |
void |          |           |       |
<----|          |           |       | 
     |          |           |       | 
     |          |           |       |  actors can leave anytime 
     |          |           |       |
     |Disconnect|           |       |
     |<=========|           |       |
     |          |           |       |
     |          +           |       |
     |           Disconnect |       |
     | <====================|       |   
     |                      |       |
     |    Disconnect        +       |   
     |<=============================|   
     |                              |
                                    +

 
World and Messages: 
;; World    = (make-world (received-msgs sent-msgs editor)
;; received-msgs = (list sender msg) 
;; where sender and msg are string
;; sent-msgs    = (list receiver msg) 
;; where receiver and msg are string

Server and Messages: 
;; ReceivedMessages = (list receiver msg) 
;; where receiver and msg are string
;; SendMessages     = (list sender msg) 
;; where sender and msg are string

For data representations of the Server and Client states, see below. 

|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 2htdp/universe)
(require "image-ops.ss")

; Assignment #9

#|

Design a "quick chat" system. This universe program allows people to "chat" 
with each other, i.e., to exchange short "one line" messages.
A participant uses a chat space, which is a window divided into two spaces:
the top half for listing the messages received and the bottom half for 
listing the messages sent plus the one message the participant is currently
entering. 
The two halves display the messages in historical order, with the most recent
message received/sent at the bottom. When either half is full of messages, 
the least recent line of the respective part is dropped. 

|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; chat server

(require 2htdp/universe)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; General specification:

;; Description of server behavior: 

;; a message is sent when the line is one character too wide for the screen 
;; or when the user hits "\r" (return).

;; New clocks are initially stopped. ??????

;; Global properties: ???????
;; At most one clock is running.
;; If no clock runs indefinitely, then no clock waits indefinitely 
;;  (ie, everybody who wants a turn will get one, unless somebody hogs the resource)

;; A clock starts running when it receives a START message from the server.
;; When a running clock is clicked on, it stops and sends a STOPPED
;; message to the server.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;                                                                 
;                                                                 
;                                                                 
;                                                                 
;                                                                 
;   ;;;;;               ;                        ;;;;;            
;    ;   ;              ;                         ;   ;           
;    ;    ;    ;;;    ;;;;;;;    ;;;              ;    ;          
;    ;    ;   ;   ;     ;       ;   ;             ;    ;          
;    ;    ;    ;;;;     ;        ;;;;             ;    ;          
;    ;    ;   ;   ;     ;       ;   ;             ;    ;          
;    ;   ;    ;   ;     ;    ;  ;   ;             ;   ;     ;;    
;   ;;;;;      ;;;;;     ;;;;    ;;;;;           ;;;;;      ;;    
;                                                                 
;                                                                 
;                                                                 
;                                                                 

;; Data Definitions:

;; The server:

;; A ServerState is a [Listof iworld]
;; where iworld repres. the connected client

;; server-rcvd-msg is (list receiver msg)
;; where receiver and msg are string  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;                                                                 
;                                                                 
;                                                                 
;                                                                 
;                                                 ;;;             
;   ;;;;;;;                                         ;             
;    ;    ;                                         ;             
;    ;  ; ;  ;;;  ;;;   ;;;   ;; ;  ;   ;; ;;;      ;       ;;;;  
;    ;;;;      ;  ;    ;   ;   ;; ;; ;   ;;   ;     ;      ;    ; 
;    ;  ;       ;;      ;;;;   ;  ;  ;   ;    ;     ;      ;;;;;; 
;    ;    ;     ;;     ;   ;   ;  ;  ;   ;    ;     ;      ;      
;    ;    ;    ;  ;    ;   ;   ;  ;  ;   ;;   ;     ;      ;    ; 
;   ;;;;;;;  ;;;  ;;;   ;;;;; ;;; ;; ;;  ; ;;;   ;;;;;;;    ;;;;  
;                                        ;                        
;                                        ;                        
;                                       ;;;                       
;                                                                 


;; sample server-states for testing:

(define server0 empty)
(define server1 (list iworld1))
(define server2 (list iworld1 iworld2))
(define server3 (list iworld1 iworld2 iworld3))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;                                                        
;                                                        
;                                                        
;                                                        
;                                                        
;     ;;;;                                               
;    ;    ;                                              
;   ;      ; ;; ;;;            ;; ;;;     ;;;;  ;;;   ;;;
;   ;      ;  ;;   ;  ;;;;;;    ;;   ;   ;    ;  ;  ;  ; 
;   ;      ;  ;    ;            ;    ;   ;;;;;;  ; ; ; ; 
;   ;      ;  ;    ;            ;    ;   ;       ; ; ; ; 
;    ;    ;   ;    ;            ;    ;   ;    ;  ; ; ; ; 
;     ;;;;   ;;;  ;;;          ;;;  ;;;   ;;;;    ;   ;  
;                                                        
;                                                        
;                                                        
;                                                        

;; on-new-fn : ServerState iworld -> Bundle
;; when a new world joins, append it to the ServerState

;; Tests
(check-expect (on-new-fn empty iworld1)
              (make-bundle
               (list iworld1)
               empty
               empty))

(check-expect (on-new-fn (list iworld1) iworld2)
              (make-bundle
               (list iworld1 iworld2)
               empty                           
               empty))

;; Implementation
(define (on-new-fn s-state new-client)
  (make-bundle (append s-state (list new-client)) empty empty))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;                                                        
;                                                        
;                                                        
;                                                        
;                                                        
;     ;;;;                    ;;;   ;;;                  
;    ;    ;                    ;;   ;;                   
;   ;      ; ;; ;;;            ; ; ; ;    ;;;;;   ;;; ;; 
;   ;      ;  ;;   ;           ; ; ; ;   ;    ;  ;   ;;  
;   ;      ;  ;    ;           ; ; ; ;    ;;;;   ;    ;  
;   ;      ;  ;    ;           ;  ;  ;        ;  ;    ;  
;    ;    ;   ;    ;           ;     ;   ;    ;  ;   ;;  
;     ;;;;   ;;;  ;;;         ;;;   ;;;  ;;;;;    ;;; ;  
;                                                     ;  
;                                                     ;  
;                                                 ;;;;   
;                                                        


;; on-msg-fn : ServerState iworld server-rcvd-msg -> Bundle
;; on receipt of message from a client, it sends message to receiver/ receivers

(check-expect (on-msg-fn server2 iworld1 (list "iworld2" "Hi Dan"))
              (make-bundle
               server2
               (list (make-mail iworld2 (list "iworld1" "Hi Dan"))) 
               empty))

(check-expect (on-msg-fn server3 iworld1 (list "*" "Hi All")) 
              (make-bundle
               server3
               (list (make-mail iworld1 (list "iworld1*" "Hi All"))
                     (make-mail iworld2 (list "iworld1*" "Hi All"))
                     (make-mail iworld3 (list "iworld1*" "Hi All")))
               empty))

(check-expect (on-msg-fn server2 iworld1 (list "invalid-user" "Hi Dan"))
              (make-bundle server2
                           empty
                           empty))


; Implementation
(define (on-msg-fn s-state sender msg)
  (make-bundle
   s-state
   (cond
     [(receiver-exist? (first msg) s-state) 
      (list (make-mail (get-iworld (first msg) s-state) (list (iworld-name sender) (first (rest msg)))))]
     [(string=? (first msg) "*") (send-to-all s-state sender msg)]
     [else empty])
   empty))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; get-iworld: string [Listof iworld] -> iworld/ Error
;; retunrs the iworld of given name from list of iworlds

; tests
(check-expect (get-iworld "iworld1" (list iworld1 iworld2)) iworld1)
(check-expect (get-iworld "iworld3" (list iworld1 iworld2)) 'Error)

; Implementation
(define (get-iworld client-name s-state)
  (cond
    [(empty? s-state) 'Error]
    [(string=? client-name (iworld-name (first s-state))) (first s-state)]
    [else (get-iworld client-name (rest s-state))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; receiver-exist?: string ServerState -> boolean
;; checks whether iworld exists in the list of iworlds

; tests
(check-expect (receiver-exist? "iworld2" server2) true)
(check-expect (receiver-exist? "invalid-client" server2) false)

; implementation
(define (receiver-exist? receiver s-state)
  (cond
    [(empty? s-state) false]
    [(string=? (iworld-name (first s-state)) receiver) true]
    [else (receiver-exist? receiver (rest s-state))]))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; send-to-all: ServerState iworld server-rcvd-msg -> (Listof mail)
;; sends message to all the clients in the s-state

; tests
(check-expect (send-to-all server3 iworld1 (list "*" "Hi All"))
              (list (make-mail iworld1 (list "iworld1*" "Hi All"))
                    (make-mail iworld2 (list "iworld1*" "Hi All"))
                    (make-mail iworld3 (list "iworld1*" "Hi All"))))

(check-expect (send-to-all server1 iworld1 (list "*" "Hi All"))
              (list (make-mail iworld1 (list "iworld1*" "Hi All"))))

; implementation
(define (send-to-all s-state sender msg)
  (cond
    [(empty? s-state) empty]
    [else (cons (make-mail (first s-state)
                           (list (string-append (iworld-name sender) "*") (first (rest msg))))
                (send-to-all (rest s-state) sender msg))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;                                                                 
;                                                                 
;                                                                 
;                                          ;                      
;                                          ;                      
;     ;;;;                     ;;;;;                              
;    ;    ;                     ;   ;                             
;   ;      ; ;; ;;;             ;    ;   ;;;       ;;;;;    ;;; ; 
;   ;      ;  ;;   ;  ;;;;;;    ;    ;     ;      ;    ;   ;   ;; 
;   ;      ;  ;    ;            ;    ;     ;       ;;;;   ;       
;   ;      ;  ;    ;            ;    ;     ;           ;  ;       
;    ;    ;   ;    ;            ;   ;      ;      ;    ;   ;    ; 
;     ;;;;   ;;;  ;;;          ;;;;;    ;;;;;;;   ;;;;;     ;;;;  
;                                                                 
;                                                                 
;                                                                 
;                                                                 


;; on-disconnect-fn : ServerState iworld -> Bundle
;; remove the client from the ServerState 

(check-expect (on-disconnect-fn server3 iworld1)
              (make-bundle (remove-world iworld1 server3) 
                           empty
                           empty))

(define (on-disconnect-fn s-state client)
  (make-bundle (remove-world client s-state)
               empty
               empty)) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; remove-world : World Worlds -> Worlds
;; return a list of worlds like the given one, except that the given world does not appear
;; ASSUMES: no duplicates in Worlds

(check-expect (remove-world iworld1 (list iworld1 iworld2)) (list iworld2))
(check-expect (remove-world iworld2 (list iworld1 iworld2)) (list iworld1))
(check-expect (remove-world iworld3 (list iworld1 iworld2)) (list iworld1 iworld2))

(define (remove-world world worlds)
  (cond
    [(empty? worlds) empty]
    [(iworld=? world (first worlds)) (rest worlds)]
    [else (cons (first worlds)
                (remove-world world (rest worlds)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;                             
;                             
;                             
;                             
;                             
;                             
;                             
;    ;; ;;;  ;;   ;;  ;; ;;;  
;     ;;      ;    ;   ;;   ; 
;     ;       ;    ;   ;    ; 
;     ;       ;    ;   ;    ; 
;     ;       ;   ;;   ;    ; 
;    ;;;;;     ;;; ;; ;;;  ;;;
;                             
;                             
;                             
;                             


;; run-server : any -> ServerState
(define (run-server d)
  (universe
   empty
   (on-new on-new-fn)
   (on-msg on-msg-fn)
   (on-disconnect on-disconnect-fn)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;                                                  
;                                                  
;                                                  
;                                                  
;     ;;;;    ;;       ;                           
;    ;   ;     ;                             ;     
;   ;          ;     ;;;     ;;;;   ;; ;;   ;;;;;  
;   ;          ;       ;    ;    ;   ;;  ;   ;     
;   ;          ;       ;    ;;;;;;   ;   ;   ;     
;   ;          ;       ;    ;        ;   ;   ;     
;    ;   ;     ;       ;    ;        ;   ;   ;   ; 
;     ;;;    ;;;;;   ;;;;;   ;;;;;  ;;; ;;;   ;;;  
;                                                  
;                                                  
;                                                  
;                                                  

;; Data Definitions for Client

(define-struct client (received-msgs sent-msgs editor))

;; received-msgs [Listof (list sender msg)]
;; where sender and msg are a string
;; sent-msgs     [Listof (list recipient msg)]
;; where recipient and msg are string

;; A LOS is one of
;; -- empty 
;; -- (cons 1-char-string LOS)
;; a 1-char-string is a string whose length is 1

(define-struct editor (receiver pre post))
;; editor is a (make-editor string LOS LOS)
;; interp.: (make-editor s t) means the text in the editor is
;; (string-append (implode s) (implode t)) with the cursor displayed 
;; between s and t

;; A Client_Result is one of
;; -- Client
;; -- (make-package ClientState sending-msg)

;; where sending-msg is (list receiver message)
;; where receiver and message are is string

;; A msgs are [Listof (list string string)]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; CONSTANTS

(define CURSOR-COLOR "red")
(define CURSOR-WIDTH 1)
(define CURSOR-RATE 0.5)

(define FONT-SIZE 12)
(define FONT-COLOR1 "black")
(define FONT-COLOR2 "red")

(define MAXLENGTH 33)
(define WIDECHAR #\W)

(define SCENEWIDTH ;; Size width is based on number of MAXLENGTH WIDECHAR
  (image-width (text (make-string MAXLENGTH WIDECHAR) FONT-SIZE FONT-COLOR1)))

(define CURSOR-HEIGHT 
  (image-height (text (make-string MAXLENGTH WIDECHAR) FONT-SIZE FONT-COLOR1)))

(define MSG-NUM 12) ;; the max number of totaol message lines

(define SCENE-HEIGHT (* MSG-NUM CURSOR-HEIGHT)) ;;the total scene height

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Cursor
(define img-cursor (rectangle CURSOR-WIDTH CURSOR-HEIGHT "solid" CURSOR-COLOR))

;; Empty string image
(define NULL-IMAGE (circle 0 'solid 'black))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Samples Examples for tests

; received messages
(define R-MSGS (list (list "TT" "It's really good weather")
                     (list "XC" "Yeah, exactly")))

; client

(define INITIAL-CLIENT (make-client empty  empty
                                    (make-editor "" empty empty)))

(define client1 (make-client (list (list "Dan" "Hi Carl")
                                   (list "Kin" "Hi Carl"))
                             (list (list "Dan" "Hi Dan")
                                   (list "Kin" "Hi Kin"))
                             (make-editor "Shary" 
                                          (list "H" "i")
                                          (list "H" "o" "w"))))

(define client2 (make-client (list empty)
                             (list empty)
                             (make-editor "Shary" 
                                          (list "H" "i")
                                          (list "H" "o" "w"))))
(define client3 (make-client empty
                             empty
                             (make-editor "Dan"
                                          (explode "This is a line for testing 
                                                    the situation for line's 
                                                    length exceeds the l")
                                          empty)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;                                                                 
;                                                                 
;                                                                 
;                                                                 
;                                  ;;                             
;                                   ;                             
;                                   ;                             
;     ;;;;   ;; ;;;             ;;; ;    ;; ;;;    ;;;   ;;;   ;;;
;    ;    ;   ;;   ;  ;;;;;;   ;   ;;     ;;      ;   ;   ;  ;  ; 
;    ;    ;   ;    ;           ;    ;     ;        ;;;;   ; ; ; ; 
;    ;    ;   ;    ;           ;    ;     ;       ;   ;   ; ; ; ; 
;    ;    ;   ;    ;           ;   ;;     ;       ;   ;   ; ; ; ; 
;     ;;;;   ;;;  ;;;           ;;; ;;   ;;;;;     ;;;;;   ;   ;  
;                                                                 
;                                                                 
;                                                                 
;                                                                 


;; on-draw-fn: client -> image
;; render the client state as an image
;; Design: Structural Design on client

; Test

(check-expect (on-draw-fn client2)
              (image-stack (empty-scene SCENEWIDTH (/ SCENE-HEIGHT 2))
                           (place-image (editor-render (client-editor client2))
                                        0
                                        0
                                        (empty-scene SCENEWIDTH (/ SCENE-HEIGHT 2)))))



(check-expect (on-draw-fn client1)
              (image-stack 
               (place-image (received-msgs-render 
                             (client-received-msgs client1)) 
                            0 
                            0
                            (empty-scene SCENEWIDTH (/ SCENE-HEIGHT 2)))
               (place-image (image-stack 
                             (editor-render (client-editor client1))
                             (sent-msgs-render (client-sent-msgs client1)))
                            0
                            0
                            (empty-scene SCENEWIDTH (/ SCENE-HEIGHT 2)))))
(check-expect (on-draw-fn INITIAL-CLIENT)
              (image-stack (empty-scene SCENEWIDTH (/ SCENE-HEIGHT 2))
                           (place-image 
                            (editor-render (client-editor INITIAL-CLIENT))
                            0
                            0
                            (empty-scene SCENEWIDTH (/ SCENE-HEIGHT 2)))))



; Implementation
(define (on-draw-fn client)
  (local ((define rm (client-received-msgs client))
          (define sm (client-sent-msgs client))
          (define ce (client-editor client))
          
          (define upper-window-initial 
            (empty-scene SCENEWIDTH (/ SCENE-HEIGHT 2)))
          (define lower-window-initial 
            (place-image (editor-render ce)
                         0
                         0
                         (empty-scene SCENEWIDTH (/ SCENE-HEIGHT 2))))
          (define upper-window2
            (place-image (received-msgs-render rm) 
                         0 
                         0
                         (empty-scene SCENEWIDTH (/ SCENE-HEIGHT 2))))
          (define lower-window2
            (place-image (image-stack (editor-render ce)
                                      (sent-msgs-render sm))
                         0
                         0
                         (empty-scene SCENEWIDTH (/ SCENE-HEIGHT 2))))
          (define (upper-select rm1) (if (empty? rm1) 
                                         upper-window-initial
                                         upper-window2))
          (define (lower-select sm1) (if (empty? sm1)
                                         lower-window-initial
                                         lower-window2)))
    (image-stack (upper-select rm) (lower-select sm))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; editor-render : editor -> scene
;; to render the editor

;Test
(define editor1 (make-editor "Shary" (list "H" "i") (list "H" "o" "w")))

(define editor2 (make-editor "" (list "H" "i") (list "H" "o" "w")))

(check-expect (editor-render editor1)
              (place-image img-cursor 
                           (image-width 
                            (text (string-append 
                                   (editor-receiver editor1)
                                   ": "
                                   (implode (editor-pre editor1)))
                                  FONT-SIZE FONT-COLOR1))
                           (/ CURSOR-HEIGHT 2) ;; y - coordinater of the cursor
                           (place-image
                            (text (string-append 
                                   (editor-receiver editor1)
                                   ": "
                                   (implode (editor-pre editor1))
                                   (implode (editor-post editor1)))
                                  FONT-SIZE FONT-COLOR1)
                            0 0 (empty-scene SCENEWIDTH CURSOR-HEIGHT))))

(check-expect (editor-render editor2)
              (place-image img-cursor 
                           (image-width 
                            (text (string-append 
                                   (editor-receiver editor2)
                                   ""
                                   (implode (editor-pre editor2)))
                                  FONT-SIZE FONT-COLOR1))
                           (/ CURSOR-HEIGHT 2) ;; y - coordinater of the cursor
                           (place-image
                            (text (string-append 
                                   (editor-receiver editor2)
                                   ""
                                   (implode (editor-pre editor2))
                                   (implode (editor-post editor2)))
                                  FONT-SIZE FONT-COLOR1)
                            0 0 (empty-scene SCENEWIDTH CURSOR-HEIGHT))))

; Implementation
(define (editor-render e)
  (local ((define (editor-render1 e str)
            (place-image img-cursor 
                         (image-width 
                          (text (string-append 
                                 (editor-receiver e)
                                 str
                                 (implode (editor-pre e)))
                                FONT-SIZE FONT-COLOR1))
                         (/ CURSOR-HEIGHT 2) ;; y - coordinater of the cursor
                         (place-image
                          (text (string-append 
                                 (editor-receiver e)
                                 str
                                 (implode (editor-pre e))
                                 (implode (editor-post e)))
                                FONT-SIZE FONT-COLOR1)
                          0 0 (empty-scene SCENEWIDTH CURSOR-HEIGHT))))) 
    (cond 
      ;; when typing receiver's name 
      [(string=? (editor-receiver e) "") (editor-render1 e "")] 
      ;;when typing message
      [else (editor-render1 e ": ")]))) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; msgs-render: msgs  string -> image  
;; renders the list of messages 
;; Design: structural design on msgs

; Tests
(define msg0 empty)

(define msg1 (list (list "Shary" "How are you")))

(define msg2 (list empty))

(define msg3 (list (list "" "How are you")))

(define msgs (list (list "Shary" "How are you")
                   (list "James" "I am good")
                   (list "Kary" "Bye")))

(check-expect (msgs-render msg1 5 'black)
              (image-append (text (string-append (first (first msg1)) ": ")
                                  FONT-SIZE
                                  'black) 
                            (text (second (first msg1))
                                  FONT-SIZE
                                  FONT-COLOR1)))

(check-expect (msgs-render msgs 1 'black)
              (msgs-render (rest msgs) 1 'black))

(check-expect (msgs-render msg0 5 'black)
              NULL-IMAGE)         

(check-expect (msgs-render msg2 5 'black)
              NULL-IMAGE)

(check-expect (msgs-render msg3 5 'black)
              NULL-IMAGE)


; Implementation
(define (msgs-render msgs lim clor)
  (local ( ;; msgs ->image
          (define (msg-render msg)
            (cond 
              [(empty? msg) NULL-IMAGE]
              [(string=? (first msg) "")
               NULL-IMAGE]
              [else
               (image-append (text (string-append (first msg) ": ")
                                   FONT-SIZE
                                   clor) 
                             (text (second msg)
                                   FONT-SIZE
                                   FONT-COLOR1))]))
          (define loi 
            (map msg-render msgs))) 
    (cond
      [(empty? msgs) NULL-IMAGE]
      [(empty? (rest msgs)) (msg-render (first msgs))]
      [(<= (length msgs) lim) (image-stack* loi)]
      [else (msgs-render (rest msgs) lim clor)])))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; received-msgs-render: msgs -> image
;; render the list of received messages

(define (received-msgs-render rm) 
  (msgs-render rm (/ MSG-NUM 2) FONT-COLOR2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; sent-msgs-render: msgs -> image
;; renders the list of sent messages

(define (sent-msgs-render sm) 
  (msgs-render sm (- (/ MSG-NUM 2) 1) FONT-COLOR1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; get-text: editor -> string
;; Joins the content of the editor

; Tests
(define editor3 (client-editor client1))

(check-expect (get-text editor3)
              (string-append (editor-receiver editor3)
                             ": "
                             (implode (editor-pre editor3))
                             (implode (editor-post editor3))))

; Implementation
(define (get-text e)
  (string-append (editor-receiver e)
                 ": "
                 (implode (editor-pre e))
                 (implode (editor-post e))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;                                                        
;                                                        
;                                                        
;                                                        
;                              ;;                        
;     ;;;;                      ;                        
;    ;    ;                     ;                        
;   ;      ; ;; ;;;             ; ;;;     ;;;;   ;;;  ;;;
;   ;      ;  ;;   ;  ;;;;;;    ;  ;     ;    ;   ;    ; 
;   ;      ;  ;    ;            ;;;      ;;;;;;    ;  ;  
;   ;      ;  ;    ;            ; ;      ;         ;  ;  
;    ;    ;   ;    ;            ;  ;     ;    ;     ;;   
;     ;;;;   ;;;  ;;;          ;;  ;;;    ;;;;      ;;   
;                                                   ;    
;                                                   ;    
;                                                 ;;;    
;                                                        


;; on-key-fn : iworld KeyEvent -> client
;; react on various ke events


; Tests
(check-expect (on-key-fn client1 "left")
              (make-client (client-received-msgs client1)
                           (client-sent-msgs client1)
                           (key-left (client-editor client1))))

(check-expect (on-key-fn client1 "right")
              (make-client (client-received-msgs client1)
                           (client-sent-msgs client1)
                           (key-right (client-editor client1))))

(check-expect (on-key-fn client1 "home")
              (make-client (client-received-msgs client1)
                           (client-sent-msgs client1)
                           (key-home (client-editor client1))))

(check-expect (on-key-fn client1 "end")
              (make-client (client-received-msgs client1)
                           (client-sent-msgs client1)
                           (key-end (client-editor client1))))

(check-expect (on-key-fn client1 "\t") client1)

(check-expect (on-key-fn client1 "\b")
              (make-client (client-received-msgs client1)
                           (client-sent-msgs client1)
                           (key-backspace (client-editor client1))))

(check-expect (on-key-fn client1 "\u007F")
              (make-client (client-received-msgs client1)
                           (client-sent-msgs client1)
                           (key-delete (client-editor client1))))
(check-expect (on-key-fn client1 "release") client1)

(check-expect (on-key-fn client1 "\r")
              (make-package
               (make-client
                (list (list "Dan" "Hi Carl") (list "Kin" "Hi Carl"))
                (list (list "Dan" "Hi Dan") (list "Kin" "Hi Kin") 
                      (list "Shary" "HiHow"))
                (make-editor "" empty empty))
               (list "Shary" "HiHow")))

#|
(check-expect (on-key-fn client3 "i")
              (make-package
               (make-client 
                empty
               (list (list "Dan" "This is a line for testing the situation for line's length exceeds the l"))
               (make-editor "" empty empty))
               (list "Dan" "This is a line for testing the situation for line's length exceeds the l")))
|#

(check-expect (on-key-fn client1 "a")
              (key-char client1 "a"))

; Implementation

(define (on-key-fn client kev)
  (local ((define rm (client-received-msgs client))
          (define sm (client-sent-msgs client))
          (define ce (client-editor client))
          (define enter-msg (list (editor-receiver ce)
                                  (string-append 
                                   (implode (editor-pre ce))
                                   (implode (editor-post ce))))))
    (if (> (string-length kev) 1)
        (cond 
          [(string=? kev "left") (make-client rm sm (key-left ce))]
          [(string=? kev "right") (make-client rm sm (key-right ce))]
          [(string=? kev "home") (make-client rm sm (key-home ce))]
          [(string=? kev "end") (make-client rm sm (key-end ce))]
          [else client])
        (cond 
          [(string=? kev "\t") client]
          [(string=? kev "\b") (make-client rm sm (key-backspace ce))]
          [(string=? kev "\u007F") (make-client rm sm (key-delete ce))]
          [(and (or (string=? kev "\r") 
                    (> (image-width (text (get-text (client-editor client)) 
                                          FONT-SIZE FONT-COLOR1))
                       SCENEWIDTH))
                (not (string=? (editor-receiver ce) ""))) 
           (make-package (make-client rm (append sm (list enter-msg))
                                      (make-editor "" empty empty))
                         enter-msg)]
          [else (key-char client kev)]))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; key-char: Client KeyEvent -> Client
;; adds the char to the editor of client

; test
(check-expect (key-char client1 "a")
              (make-client (list (list "Dan" "Hi Carl")
                                 (list "Kin" "Hi Carl"))
                           (list (list "Dan" "Hi Dan")
                                 (list "Kin" "Hi Kin"))
                           (make-editor "Shary"
                                        (list "H" "i" "a")
                                        (list "H" "o" "w"))))

(check-expect (key-char client1 "a")
              (make-client (list (list "Dan" "Hi Carl")
                                 (list "Kin" "Hi Carl"))
                           (list (list "Dan" "Hi Dan")
                                 (list "Kin" "Hi Kin"))
                           (make-editor "Shary"
                                        (list "H" "i" "a")
                                        (list "H" "o" "w"))))


(check-expect (key-char INITIAL-CLIENT ":")
              (make-client empty empty (make-editor 
                         ""    
                         (list 
                          (explode "ERROR! Please specify the receiver's name!"))
                         empty)))

(check-expect (key-char (make-client empty empty (make-editor "" (list "D" "a" "n") empty)) ":")
              (make-client empty empty (make-editor "Dan" empty empty)))

(check-expect (key-char (make-client empty empty (make-editor "Dan" empty empty)) "H")
              (make-client empty empty (make-editor "Dan" (list "H") empty)))

(check-expect (key-char (make-client empty empty (make-editor "" (list "H") empty)) "i")
              (make-client empty empty (make-editor "" (list "H" "i") empty)))

(define (key-char client kev)
  (local ((define rm (client-received-msgs client))
          (define sm (client-sent-msgs client))
          (define ce (client-editor client))
          (define (key-char2 cl kev1)
            (make-client (client-received-msgs cl)
                         (client-sent-msgs cl)
                         (make-editor (editor-receiver (client-editor cl))
                                      (append (editor-pre (client-editor cl))
                                              (list kev1))
                                      (editor-post (client-editor cl))))))
    (if (string=? (editor-receiver ce) "")   
        (cond
          [(and (string=? kev ":") 
                (string=? (implode (editor-pre ce)) "")) 
           (make-client rm
                        sm
                        (make-editor 
                         "" 
                         (list 
                          (explode "ERROR! Please specify the receiver's name!")) 
                         empty))]
          [(string=? kev ":") 
           (make-client rm
                        sm 
                        (make-editor (implode (editor-pre ce))
                                     empty
                                     (editor-post ce)))]
          [else (key-char2 client kev)])
        (key-char2 client kev))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; key-left: editor -> editor
;; 

(check-expect (key-left (make-editor "Dan" (list "a" "b") (list "c" "d")))
              (make-editor "Dan" (list "a") (list "b" "c" "d")))
(check-expect (key-left (make-editor "Kin" '() (list "a")))
              (make-editor "Kin" '() (list "a")))


(define (key-left e)
  (cond
    [(empty? (editor-pre e)) e] 
    [else
     (make-editor (editor-receiver e)
                  (reverse (rest (reverse (editor-pre e))))
                  (cons (first (reverse (editor-pre e))) (editor-post e)))]))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; key-right: editor -> editor
;;

(check-expect (key-right (make-editor "Dan" (list "a" "b") (list "c" "d")))
              (make-editor "Dan" (list "a" "b" "c") (list "d")))

(check-expect (key-right (make-editor "Kin" (list "a") '()))
              (make-editor "Kin" (list "a") '()))


(define (key-right e)
  (cond
    [(empty? (editor-post e)) e]
    [else
     (make-editor (editor-receiver e)
                  (append (editor-pre e) (list (first (editor-post e))))
                  (rest (editor-post e)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; key-backspace: editor -> editor
;; 

(check-expect (key-backspace (make-editor "Dan" (list "a" "b") (list "c" "d")))
              (make-editor "Dan" (list "a") (list "c" "d")))
(check-expect (key-backspace (make-editor "Kin" '() (list "a")))
              (make-editor "Kin" '() (list "a")))

(define (key-backspace e)
  (cond
    [(empty? (editor-pre e)) e]
    [else
     (make-editor (editor-receiver e)
                  (reverse (rest (reverse (editor-pre e))))
                  (editor-post e))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; key-delete: editor -> editor
;;

(check-expect (key-delete (make-editor "Dan" (list "a" "b") (list "c" "d")))
              (make-editor "Dan" (list "a" "b") (list "d")))
(check-expect (key-delete (make-editor "Kin" (list "a") '()))
              (make-editor "Kin" (list "a") '()))

(define (key-delete e)
  (cond
    [(empty? (editor-post e)) e]
    [else
     (make-editor (editor-receiver e)
                  (editor-pre e)
                  (rest (editor-post e)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; key-home: editor -> editor
;;

(check-expect (key-home (make-editor "Dan" (list "a" "b") (list "c" "d")))
              (make-editor "Dan" (list) (list "a" "b" "c" "d")))

(define (key-home e)
  (make-editor (editor-receiver e)
               (list)
               (append (editor-pre e) (editor-post e))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; key-end: editor -> editor
;;

(check-expect (key-end (make-editor "Dan" (list "a" "b") (list "c" "d")))
              (make-editor "Dan" (list "a" "b" "c" "d") '()))

(define (key-end e)
  (make-editor (editor-receiver e)
               (append (editor-pre e) (editor-post e)) 
               (list)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;                                                                  
;                                                                  
;                                                                  
;                                                                  
;                                                                  
;                                                                  
;    ;;;;   ;; ;;          ;; ;  ;   ;;;;   ;;  ;;   ;;;;;   ;;;;  
;   ;    ;   ;;  ;          ;; ;; ; ;    ;   ;   ;  ;    ;  ;    ; 
;   ;    ;   ;   ;  ;;;;;;  ;  ;  ; ;    ;   ;   ;   ;;;;   ;;;;;; 
;   ;    ;   ;   ;          ;  ;  ; ;    ;   ;   ;       ;  ;      
;   ;    ;   ;   ;          ;  ;  ; ;    ;   ;  ;;  ;    ;  ;      
;    ;;;;   ;;; ;;;        ;;; ;; ;  ;;;;     ;; ;; ;;;;;    ;;;;; 
;                                                                  
;                                                                  
;                                                                  
;                                                                  


;; on-mouse-fn: editor number number string -> editor 
;; to handle the MouseEvent: "button-down", ignore other MouseEvents

(check-expect (on-mouse-fn client1 2 10 "button-up") client1)
(check-expect (on-mouse-fn client1 0 10 "button-down")
              (make-client
               (list (list "Dan" "Hi Carl") (list "Kin" "Hi Carl"))
               (list (list "Dan" "Hi Dan") (list "Kin" "Hi Kin"))
               (make-editor "Shary" empty (list "H" "i" "H" "o" "w"))))
(check-expect (on-mouse-fn client1 100 10 "button-down")
              (make-client
               (list (list "Dan" "Hi Carl") (list "Kin" "Hi Carl"))
               (list (list "Dan" "Hi Dan") (list "Kin" "Hi Kin"))
               (make-editor "Shary" (list "H" "i" "H" "o" "w") empty)))



(define (on-mouse-fn client x y event)
  (local
    ((define rm (client-received-msgs client))
     (define sm (client-sent-msgs client))
     (define ce (client-editor client))
     (define (cursor-x ls)  
       (image-width (text (string-append (editor-receiver ce)
                                         ": " 
                                         (implode ls))
                          FONT-SIZE
                          FONT-COLOR1)))
     (define (check-click pre1 post1)  
       (cond
         [(or (> (cursor-x pre1) x) (empty? post1) (= x 0))
          (make-client rm sm (make-editor (editor-receiver ce) pre1 post1))]
         [else (check-click (append pre1 (list (first post1)))
                            (rest post1))])))
    (cond
      [(string=? event "button-down") 
       (check-click empty (append (editor-pre ce) 
                                  (editor-post ce)))]
      [else client])))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;                                                        
;                                                        
;                                                        
;                                                        
;                                                        
;                                                        
;                                                        
;     ;;;;   ;; ;;;             ;; ;;;    ;;; ;  ;;;  ;;;
;    ;    ;   ;;   ;  ;;;;;;     ;;      ;   ;;   ;    ; 
;    ;    ;   ;    ;             ;      ;          ;  ;  
;    ;    ;   ;    ;             ;      ;          ;  ;  
;    ;    ;   ;    ;             ;       ;    ;     ;;   
;     ;;;;   ;;;  ;;;           ;;;;;     ;;;;      ;;   
;                                                        
;                                                        
;                                                        
;                                                        

;; on-recieve-fn: iworld rcvd-msg -> client
;; on receipt of the message for a client, add it to the list of received msgs

(check-expect (on-receive-fn client1 (list "Sara" "I am good"))
              (make-client (list 
                            (list "Dan" "Hi Carl")
                            (list "Kin" "Hi Carl")
                            (list "Sara" "I am good"))
                           (list (list "Dan" "Hi Dan") 
                                 (list "Kin" "Hi Kin"))
                           (make-editor "Shary"
                                        (list "H" "i")
                                        (list "H" "o" "w"))))

(define (on-receive-fn client msg)
  (make-client (append (client-received-msgs client) (list msg))
               (client-sent-msgs client)
               (client-editor client)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;                                                                          
;                                                                          
;                                                                          
;                                                                          
;                                                 ;;;                      
;                                                   ;                ;     
;                                                   ;                ;     
;    ;; ;;;  ;;   ;;  ;; ;;;              ;;; ;     ;     ;; ;;;   ;;;;;;; 
;     ;;      ;    ;   ;;   ;  ;;;;;;    ;   ;;     ;      ;;   ;    ;     
;     ;       ;    ;   ;    ;           ;           ;      ;    ;    ;     
;     ;       ;    ;   ;    ;           ;           ;      ;    ;    ;     
;     ;       ;   ;;   ;    ;            ;    ;     ;      ;    ;    ;    ;
;    ;;;;;     ;;; ;; ;;;  ;;;            ;;;;   ;;;;;;;  ;;;  ;;;    ;;;; 
;                                                                          
;                                                                          
;                                                                          
;                                                                          


;; run-client : String -> Client
(define (run-client n)
  (big-bang INITIAL-CLIENT 
            (on-draw on-draw-fn)
            (on-key on-key-fn)
            (on-mouse on-mouse-fn)
            (on-receive on-receive-fn)
            (name n)
            (register LOCALHOST)))

(define (run-clients d)
  (launch-many-worlds
   (run-client "Dan")
   (run-client "Kin")
   (run-client "XF")
   (run-client "TT")
   ))