#lang scheme 

(define-for-syntax x (if (string=? (version) "4.2.1") #t (error 'image-ops "you must run version 4.2.1")))

(require 2htdp/universe test-engine/scheme-tests)
(require (only-in lang/private/imageeq image?))

(provide/contract
 [image-stack (-> image? image? image?)]
 ;; stack images vertically along left-most line 
 [image-append (-> image? image? image?)]
 ;; append images horizontally along top-most line 
 [image-stack* (-> (and/c cons? (listof image?)) image?)]
 ;; stack non-empty list of images vertically along left-most line 
 [image-append* (-> (and/c cons? (listof image?)) image?)]
 ;; append non-empty list of images horizontally along top-most line 
 [image-top (-> image? image? image?)]
 ;; append images horizontally along top-most line 
 [image-bottom (-> image? image? image?)]
 ;; append images horizontally along bottom-most line  
 )

;; -----------------------------------------------------------------------------
;; stacking 

(define red-20x10 (nw:rectangle 20 10 'solid 'red))
(define red-40x10 (nw:rectangle 40 10 'solid 'red))
(define red-10x20 (nw:rectangle 10 20 'solid 'red))
(define red-10x10 (nw:rectangle 10 10 'solid 'red))
(define blu-40x10 (nw:rectangle 40 10 'solid 'blue))
(define yel-40x10 (nw:rectangle 40 10 'solid 'yellow))

(define (image-stack i j)
  (overlay/xy (put-pinhole i 0 0) 0 (image-height i) j))

(define (image-stack* loi)
  (foldr image-stack (circle 0 'solid 'white) loi))

;; -----------------------------------------------------------------------------
;; appending

(define (image-append i j)
  (overlay/xy (put-pinhole i 0 0) (image-width i) 0 (put-pinhole j 0 0)))

;; (cons Image [Listof Image]) -> Image 

(define (image-append* loi)
  (foldr image-append (circle 0 'solid 'white) loi))

;; -----------------------------------------------------------------------------
;; bottom 

(define (image-bottom i j)
  (overlay/xy (put-pinhole i 0 0) 
              (image-width i) (abs (- (image-height i) (image-height j)))
              (put-pinhole j 0 0)))

;; -----------------------------------------------------------------------------
;; top

(define (image-top i j)
  (overlay/xy (put-pinhole i 0 0) 
              (image-width i) 0 #; (abs (- (image-height i) (image-height j)))
              (put-pinhole j 0 0)))

;; -----------------------------------------------------------------------------
;; TESTING 

#|
(check-expect (image-stack red-10x20 red-10x10)
              (nw:rectangle 10 30 'solid 'red))

(check-expect (image-stack* (list red-10x20 red-10x10))
              (nw:rectangle 10 30 'solid 'red))

(check-expect (image-append red-20x10 red-40x10)
              (nw:rectangle 60 10 'solid 'red))

(check-expect (image-append* (list red-20x10 blu-40x10 red-20x10 yel-40x10))
              (image-append red-20x10
                            (image-append blu-40x10
                                          (image-append red-20x10 yel-40x10))))

(check-expect (image-bottom (nw:rectangle 10 20 'solid 'red) 
                            (nw:rectangle 10  5 'solid 'red))
              (overlay/xy (nw:rectangle 10 20 'solid 'red)
                          10 15
                          (nw:rectangle 10  5 'solid 'red)))

(check-expect (image-top (nw:rectangle 10 20 'solid 'red) 
                         (nw:rectangle 10  5 'solid 'red))
              (overlay/xy (nw:rectangle 10 20 'solid 'red)
                          10 0
                          (nw:rectangle 10  5 'solid 'red)))

(test)
|#