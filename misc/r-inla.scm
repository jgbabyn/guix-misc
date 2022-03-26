(define-module (misc r-inla)
  #:use-module (guix packages)
  #:use-module (gnu packages)
  #:use-module (gnu packages cran)
  #:use-module (gnu packages statistics)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages bootstrap)
  #:use-module (guix download)
  #:use-module (guix build-system r)
  #:use-module (guix licenses))

(define-public r-inla
  (package
  (name "r-inla")
  (version "22.03.16")
  (source
    (origin
      (method url-fetch)
      (uri (string-append "https://inla.r-inla-download.org/R/stable/src/contrib/INLA_" version ".tar.gz"))
      (sha256
        (base32 "0jr5jzgsrp7qf4sbfb9kgsxcaclw477qybn60324i9m2b8nfl02h"))))
  (properties `((upstream-name . "INLA")))
  (build-system r-build-system)
  (arguments
   `(#:phases (modify-phases %standard-phases
			     (add-after 'patch-usr-bin-file 'set-loader
			                (lambda* (#:key inputs outputs #:allow-other-keys)
					  ;;based on BIMSBbioinfo CUDA file
					  (define libc
					    (assoc-ref inputs "libc"))
					  (define ld.so
					    (string-append libc ,(glibc-dynamic-linker)))
					  
					  (define (patch-elf file)
					    (make-file-writable file)
					    (unless (string-contains file ".so")
					      (format #t "This is ld.so: '~a'" ld.so)
					      (format #t "Setting interpreter on '~a'...~%" file)
					      (invoke "patchelf" "--set-interpreter" ld.so
						      file)))
					  (for-each (lambda (file)
						      (when (elf-file? file)
							(patch-elf file)))
						    (find-files "."
								(lambda (file stat)
								  (eq? 'regular
								       (stat:type stat)))))
					    #t)))))
  (native-inputs (list pkg-config patchelf))
  (propagated-inputs (list r-matrix r-foreach r-sp))
  (home-page "https://www.r-inla.org/home")
  (synopsis "R package for approximate Bayesian inference for Latent Gaussian Models")
  (description
    "Full Bayesian analysis of latent Gaussian models using Integrated Nested Laplace Approximaxion. It is a front-end to the inla-program. This package uses precompiled binaries that must be patched.")
  (license gpl2)))
