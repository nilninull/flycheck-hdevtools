;;; flycheck-hdevtools.el --- A flycheck checker for Haskell using hdevtools -*- lexical-binding: t -*-

;; Copyright (C) 2013  Steve Purcell

;; Author: Steve Purcell <steve@sanityinc.com>
;; URL: https://github.com/flycheck/flycheck-hdevtools
;; Keywords: convenience languages tools
;; Package-Requires: ((flycheck "0.15"))
;; Version: DEV

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Adds a Flycheck syntax checker for Haskell based on hdevtools.

;;;; Setup

;; (eval-after-load 'flycheck '(require 'flycheck-hdevtools))

;;; Code:

(require 'flycheck)

;; You may want a this package.
;; (require 'flycheck-haskell)

(defun flycheck-option-with-g-flag (opt param)
  "Return OPT and PARAM with -g frags."
  (list "-g" opt "-g" param))

(defun flycheck-concat-option-with-g-flag (opt param)
  "Return concatenated OPT and PARAM with -g frag."
  (list "-g" (concat opt param)))

(flycheck-define-checker haskell-hdevtools
  "A Haskell syntax and type checker using hdevtools.

See URL `https://github.com/bitc/hdevtools'."
  :command ("hdevtools" "check" "-g" "-Wall"

            (option-flag "-g" flycheck-ghc-no-user-package-database)
            (option-flag "-no-user-package-db" flycheck-ghc-no-user-package-database)

            (option-list "-package-db" flycheck-ghc-package-databases flycheck-option-with-g-flag)

            "-g" (eval (concat "-i" (flycheck-module-root-directory
                                     (flycheck-find-in-buffer flycheck-haskell-module-re))))

            (option-list "-i" flycheck-ghc-search-path flycheck-concat-option-with-g-flag)

            source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ":"
            (or " " "\n    ") "Warning:" (optional "\n")
            (one-or-more " ")
            (message (one-or-more not-newline)
                     (zero-or-more "\n"
                                   (one-or-more " ")
                                   (one-or-more not-newline)))
            line-end)
   (error line-start (file-name) ":" line ":" column ":"
          (or (message (one-or-more not-newline))
              (and "\n" (one-or-more " ")
                   (message (one-or-more not-newline)
                            (zero-or-more "\n"
                                          (one-or-more " ")
                                          (one-or-more not-newline)))))
          line-end))
  :modes haskell-mode
  :next-checkers ((warnings-only . haskell-hlint)))


(add-to-list 'flycheck-checkers 'haskell-hdevtools)


(provide 'flycheck-hdevtools)
;;; flycheck-hdevtools.el ends here
