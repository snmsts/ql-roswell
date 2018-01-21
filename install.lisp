(uiop/package:define-package :roswell/install (:use :cl))
(in-package :roswell/install)
;;;don't edit above

(defvar *prefix-path* (merge-pathnames ".roswell/" (user-homedir-pathname)))
(defvar *src-path* (merge-pathnames "src/" *prefix-path*))

(defun depends ()
  (or
   (ignore-errors (mapc (lambda (x) (trivial-package-manager:do-install :yum x))
                        '("git" "automake" "gcc" "gcc-c++" "make" "openssl-devel" "curl-devel" "bzip2")) :yum)
   (ignore-errors (mapc (lambda (x) (trivial-package-manager:do-install :apt x))
                        '("git" "build-essential" "automake" "libcurl4-openssl-dev" "zlib1g-dev")) :apt)))

(defun checkout ()
  (unless (probe-file (merge-pathnames "roswell/" *src-path*))
    (uiop:run-program (format nil "~{~A~^ ~}" `("git" "-C" ,(uiop:native-namestring *src-path*) "clone" "-b" "release" "https://github.com/roswell/roswell.git"))
                      :output :interactive
                      :error-output :interactive
                      :input :interactive)))

(defun build ()
  (depends)
  (checkout)
  (uiop:run-program (format nil "cd ~A;./bootstrap" (uiop:native-namestring (merge-pathnames "roswell/" *src-path*))))
  (uiop:run-program (format nil "cd ~A;./configure --prefix=~A"
                            (uiop:native-namestring (merge-pathnames "roswell/" *src-path*))
                            (uiop:native-namestring *prefix-path*)))
  (uiop:run-program (format nil "cd ~A;make;make install" (uiop:native-namestring (merge-pathnames "roswell/" *src-path*)))))
