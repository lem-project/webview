(defpackage :webview
  (:use :cl :cffi)
  (:export #:webview-t
           #:webview-error-t
           #:webview-hint-t
           #:webview-native-handle-kind-t
           #:webview-version-info-t
           #:webview-create
           #:webview-destroy
           #:webview-run
           #:webview-terminate
           #:webview-dispatch
           #:webview-get-window
           #:webview-get-native-handle
           #:webview-set-title
           #:webview-set-size
           #:webview-navigate
           #:webview-set-html
           #:webview-init
           #:webview-eval
           #:webview-bind
           #:webview-unbind
           #:webview-return
           #:webview-version))
(in-package :webview)

(define-foreign-library (libwebview 
                         :search-path (asdf:system-relative-pathname 
                                       :webview
                                       (format nil
                                               "~(lib/~A/~A/~)"
                                               (uiop:operating-system)
                                               (uiop:architecture))))
  (:unix "libwebview.so.0.12.0")
  (:windows "webview.dll")
  (:darwin "libwebview.dylib")
  (t (:default "libwebview")))

(use-foreign-library libwebview)

(defctype webview-t :pointer)
(defctype webview-error-t :int)
(defctype webview-hint-t :int)
(defctype webview-native-handle-kind-t :int)

(defcstruct webview-version-info
  (major :uint)
  (minor :uint)
  (patch :uint)
  (pre-release :string)
  (build-metadata :string))

(defctype webview-version-info-t (:struct webview-version-info))

(defcfun ("webview_create" webview-create) webview-t
  (debug :int)
  (window :pointer))

(defcfun ("webview_destroy" webview-destroy) webview-error-t
  (w webview-t))

(defcfun ("webview_run" webview-run) webview-error-t
  (w webview-t))

(defcfun ("webview_terminate" webview-terminate) webview-error-t
  (w webview-t))

(defcfun ("webview_dispatch" webview-dispatch) webview-error-t
  (w webview-t)
  (fn :pointer)
  (arg :pointer))

(defcfun ("webview_get_window" webview-get-window) :pointer
  (w webview-t))

(defcfun ("webview_get_native_handle" webview-get-native-handle) :pointer
  (w webview-t)
  (kind webview-native-handle-kind-t))

(defcfun ("webview_set_title" webview-set-title) webview-error-t
  (w webview-t)
  (title :string))

(defcfun ("webview_set_size" webview-set-size) webview-error-t
  (w webview-t)
  (width :int)
  (height :int)
  (hints webview-hint-t))

(defcfun ("webview_navigate" webview-navigate) webview-error-t
  (w webview-t)
  (url :string))

(defcfun ("webview_set_html" webview-set-html) webview-error-t
  (w webview-t)
  (html :string))

(defcfun ("webview_init" webview-init) webview-error-t
  (w webview-t)
  (js :string))

(defcfun ("webview_eval" webview-eval) webview-error-t
  (w webview-t)
  (js :string))

(defcfun ("webview_bind" webview-bind) webview-error-t
  (w webview-t)
  (name :string)
  (fn :pointer)
  (arg :pointer))

(defcfun ("webview_unbind" webview-unbind) webview-error-t
  (w webview-t)
  (name :string))

(defcfun ("webview_return" webview-return) webview-error-t
  (w webview-t)
  (id :string)
  (status :int)
  (result :string))

(defcfun ("webview_version" webview-version) (:pointer webview-version-info-t))
