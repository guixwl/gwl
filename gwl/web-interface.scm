(define-module (gwl web-interface)
  #:use-module (web server)
  #:use-module (web request)
  #:use-module (web response)
  #:use-module (web uri)
  #:use-module (ice-9 rdelim)
  #:use-module (rnrs bytevectors)
  #:use-module (rnrs io ports)
  #:use-module (sxml simple)
  #:use-module (commonmark)
  #:use-module (gwl www util)
  #:use-module (gwl www config)
  #:use-module (gwl www pages)
  #:use-module (gwl www pages error)
  #:use-module (gwl www pages welcome)

  #:export (run-web-interface))

(define (string-replace-occurrence str occurrence alternative)
  (string-map (lambda (x) (if (eq? x occurrence) alternative x)) str))

(define (request-markdown-handler request-path)
  (format #t "Request path inside handler: ~s~%" request-path)
  (let ((file (string-append %www-root "/www/pages" request-path ".md")))
    (values
     '((content-type . (text/html)))
     (call-with-output-string
       (lambda (port)
         (set-port-encoding! port "utf8")
         (format port "<!DOCTYPE html>~%")
         (sxml->xml (page-root-template
                     (string-capitalize
                      (string-replace-occurrence
                       (basename request-path) #\- #\ ))
                     request-path
                     (call-with-input-file file
                       (lambda (port) (commonmark->sxml port)))
                     ;; Pages may contain code samples, so we have to
                     ;; include the syntax-highlighting library.
                     #:dependencies '(highlight)) port))))))

(define (request-file-handler path)
  "This handler takes data from a file and sends that as a response."

  (define (response-content-type path)
    "This function returns the content type of a file based on its extension."
    (let ((extension (substring path (1+ (string-rindex path #\.)))))
      (cond [(string= extension "css")  '(text/css)]
            [(string= extension "js")   '(application/javascript)]
            [(string= extension "json") '(application/javascript)]
            [(string= extension "html") '(text/html)]
            [(string= extension "png")  '(image/png)]
            [(string= extension "svg")  '(image/svg+xml)]
            [(string= extension "ico")  '(image/x-icon)]
            [(string= extension "pdf")  '(application/pdf)]
            [(string= extension "ttf")  '(application/font-sfnt)]
            [(#t '(text/plain))])))

  (format #t "Using static file handler for ~s~%" path)

  (let ((full-path (string-append %www-static-root "/" path)))
    (if (not (file-exists? full-path))
        (values '((content-type . (text/html)))
                (with-output-to-string (lambda _ (sxml->xml (page-error-404 path)))))
        ;; Do not handle files larger than %maximum-file-size.
        ;; Please increase the file size if your server can handle it.
        (let ((file-stat (stat full-path)))
          (if (> (stat:size file-stat) %www-max-file-size)
              (values '((content-type . (text/html)))
                      (with-output-to-string 
                        (lambda _ (sxml->xml (page-error-filesize path)))))
              (values `((content-type . ,(response-content-type full-path)))
                      (with-input-from-file full-path
                        (lambda _
                          (get-bytevector-all (current-input-port))))))))))

(define (request-scheme-page-handler request request-body request-path)

  (define (module-path prefix elements)
    "Returns the module path so it can be loaded."
    (if (> (length elements) 1)
        (module-path
         (append prefix (list (string->symbol (car elements))))
         (cdr elements))
        (append prefix (list (string->symbol (car elements))))))
  
  (values '((content-type . (text/html)))
          (call-with-output-string
            (lambda (port)
              (set-port-encoding! port "utf8")
              (format port "<!DOCTYPE html>~%")
              (if (< (string-length request-path) 2)
                  (sxml->xml (page-welcome "/") port)
                  (let* ((function-symbol (string->symbol
                                           (string-map
                                            (lambda (x)
                                              (if (eq? x #\/) #\- x))
                                            (substring request-path 1))))
                         (module (resolve-module
                                  (module-path
                                   '(gwl www pages)
                                   (string-split (substring request-path 1) #\/))
                                  #:ensure #f))
                         (page-symbol (symbol-append 'page- function-symbol)))
                    (if module
                        (let ((display-function
                               (module-ref module page-symbol)))
                          (if (eq? (request-method request) 'POST)
                              (sxml->xml (display-function
                                          request-path
                                          #:post-data
                                          (utf8->string
                                           request-body)) port)
                              (sxml->xml (display-function request-path) port)))
                        (sxml->xml (page-error-404 request-path) port))))))))


(define (request-handler request request-body)
  (let ((request-path (uri-path (request-uri request))))
    (format #t "~a ~a~%" (request-method request) request-path)
    (cond
     ((and (> (string-length request-path) 7)
           (string= (string-take request-path 8) "/static/"))
      (request-file-handler request-path))
     ((and (not (string= "/" request-path))
           (access? (string-append %www-root "/www/pages" request-path ".md") F_OK))
      (request-markdown-handler request-path))
     (else
      (request-scheme-page-handler request request-body request-path)))))

(define (run-web-interface)
  (format #t "GWL web service is running at http://127.0.0.1:~a~%"
          %www-listen-port)
  (display "Press C-c C-c to quit.")
  (newline)
  (run-server request-handler 'http
              `(#:port ,%www-listen-port
                #:addr ,INADDR_ANY)))
