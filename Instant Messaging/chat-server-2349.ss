;; The first three lines of this file were inserted by DrScheme. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname chat-server-2349) (read-case-sensitive #t) (teachpacks ((lib "universe.ss" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.ss" "teachpack" "2htdp")))))
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