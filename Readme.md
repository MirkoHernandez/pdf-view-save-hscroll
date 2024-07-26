# pdf-view-save-hscroll

A minor mode that saves the horizontal scroll position for each page
when using pdf-view. Moving between pages restores the previously
stored position.

# Installation

## Manual

pdf-view-save-hscroll is not available on MELPA. To install manually,
download `pdf-view-save-hscroll`, then the package can be loaded using
`(load <path-to-the-package> t)` or installed using M-x
`package-install-file`. 

M-x `package-initialize` may be required to recognize the package
after installation (just once after the installation).

## Requirements

pdf-tools 1.0.0 or above is required (it can probably work with
earlier versions).

# Configuration

After loading the package just enable the mode in pdf-view.

``` emacs-lisp
(defun my/pdf-view-config ()
  (pdf-view-save-hscroll t))
  
(add-hook 'pdf-view-mode-hook 'my/pdf-view-config)
```
