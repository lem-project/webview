## Usage

```common-lisp
(ql:quickload :webview)

(float-features:with-float-traps-masked t
  (let ((w (webview:webview-create 0 (cffi:null-pointer))))
    (webview:webview-set-title w "Hello World")
    (webview:webview-set-size w 1000 800 0)
    (webview:webview-set-html w "<h1>Hello World</h1>")
    (webview:webview-run w)
    (webview:webview-destroy w)))
```
