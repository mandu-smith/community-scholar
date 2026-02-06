;; title: community-scholar
;; version:
;; summary:
;; description:

;; Community Scholarship Fund Smart Contract
;; Handles scholarship applications, funding, and disbursement

;; Constants
(define-constant CONTRACT_ADMINISTRATOR tx-sender)
(define-constant ERROR_UNAUTHORIZED_ACCESS (err u1))
(define-constant ERROR_APPLICATION_EXISTS (err u2))
(define-constant ERROR_DONATION_BELOW_MINIMUM (err u3))
(define-constant ERROR_INSUFFICIENT_BALANCE (err u4))
(define-constant ERROR_RECIPIENT_NOT_ELIGIBLE (err u5))
(define-constant ERROR_APPLICATION_PERIOD_CLOSED (err u6))
(define-constant ERROR_INVALID_INPUT (err u7))
(define-constant MINIMUM_DONATION_AMOUNT u1000000) ;; in microSTX (1 STX)
(define-constant MAXIMUM_SCHOLARSHIP_AMOUNT u1000000000) ;; 1000 STX
(define-constant MAXIMUM_GPA u400) ;; 4.00 GPA * 100
(define-constant MAXIMUM_ACADEMIC_YEAR u8)

;; Data Variables
(define-data-var scholarship-pool-balance uint u0)
(define-data-var application-submission-deadline uint u0)
(define-data-var scholarship-disbursement-period uint u0)

;; Data Maps
(define-map DonorRegistry
  principal
  {
    cumulative-donation-amount: uint,
    most-recent-donation-block: uint,
  }
)

(define-map ScholarshipRecipients
  principal
  {
    recipient-status: (string-ascii 20),
    scholarship-amount: uint,
    academic-performance: uint,
    field-of-study: (string-ascii 50),
    academic-year: uint,
  }
)

(define-map ScholarshipApplications
  principal
  {
    applicant-full-name: (string-ascii 50),
    academic-performance: uint,
    field-of-study: (string-ascii 50),
    academic-year: uint,
    requested-scholarship-amount: uint,
    application-status: (string-ascii 20),
  }
)

;; Private Functions
(define-private (is-administrator)
  (is-eq tx-sender CONTRACT_ADMINISTRATOR)
)

(define-private (validate-donation-amount (donation-amount uint))
  (>= donation-amount MINIMUM_DONATION_AMOUNT)
)

(define-private (update-donor-records
    (donor-address principal)
    (donation-amount uint)
  )
  (let ((current-donor-info (default-to {
      cumulative-donation-amount: u0,
      most-recent-donation-block: u0,
    }
      (map-get? DonorRegistry donor-address)
    )))
    (map-set DonorRegistry donor-address {
      cumulative-donation-amount: (+ (get cumulative-donation-amount current-donor-info) donation-amount),
      most-recent-donation-block: stacks-block-height,
    })
  )
)