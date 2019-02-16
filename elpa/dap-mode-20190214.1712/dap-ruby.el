;;; dap-ruby.el --- Debug Adapter Protocol mode for Ruby      -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Ivan Yonchovski

;; Author: Ivan Yonchovski <yyoncho@gmail.com>
;; Keywords: languages

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;; URL: https://github.com/yyoncho/dap-mode
;; Package-Requires: ((emacs "25.1") (dash "2.14.1") (lsp-mode "4.0"))
;; Version: 0.2

;;; Commentary:
;; Adapter for https://github.com/rubyide/vscode-ruby

;;; Code:

(require 'dap-mode)

(defcustom dap-ruby-debug-program `("node" ,(expand-file-name "~/.extensions/ruby/out/debugger/main.js"))
  "The path to the ruby debugger."
  :group 'dap-ruby
  :type '(repeat string))

(defun dap-ruby--populate-start-file-args (conf)
  "Populate CONF with the required arguments."
  (-> conf
      (dap--put-if-absent :dap-server-path dap-ruby-debug-program)
      (dap--put-if-absent :type "Ruby")
      (dap--put-if-absent :cwd default-directory)
      (dap--put-if-absent :program (buffer-file-name))
      (dap--put-if-absent :name "Ruby Debug")))

(dap-register-debug-provider "Ruby" 'dap-ruby--populate-start-file-args)
(dap-register-debug-template "Ruby Run Configuration"
                             (list :type "Ruby"
                                   :cwd nil
                                   :request "launch"
                                   :program nil
                                   :name "Ruby::Run"))

(provide 'dap-ruby)
;;; dap-ruby.el ends here
