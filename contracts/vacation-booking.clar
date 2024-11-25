;; Define vacation package data structure and storage
(define-map vacation-packages
    uint
    {
        name: (string-ascii 100),
        location: (string-ascii 100),
        max-shares: uint,
        price-per-share: uint,
        available-shares: uint,
        active: bool
    }
)

(define-map bookings
    { package-id: uint, owner: principal }
    {
        shares: uint,
        purchase-date: uint
    }
)

;; Contract owner
(define-constant contract-owner tx-sender)

;; Error codes
(define-constant err-not-owner (err u100))
(define-constant err-package-exists (err u101))
(define-constant err-package-not-found (err u102))
(define-constant err-insufficient-shares (err u103))
(define-constant err-package-inactive (err u104))
(define-constant err-insufficient-payment (err u105))

;; Data variables
(define-data-var package-counter uint u0)

;; Owner only function to create new vacation package
(define-public (create-package (name (string-ascii 100)) (location (string-ascii 100)) (max-shares uint) (price-per-share uint))
    (let
        (
            (package-id (+ (var-get package-counter) u1))
        )
        (if (is-eq tx-sender contract-owner)
            (begin
                (map-set vacation-packages package-id {
                    name: name,
                    location: location,
                    max-shares: max-shares,
                    price-per-share: price-per-share,
                    available-shares: max-shares,
                    active: true
                })
                (var-set package-counter package-id)
                (ok package-id)
            )
            err-not-owner
        )
    )
)

;; Book shares in a vacation package
(define-public (book-shares (package-id uint) (share-count uint))
    (let 
        (
            (package (unwrap! (map-get? vacation-packages package-id) err-package-not-found))
            (payment (* share-count (get price-per-share package)))
        )
        (asserts! (get active package) err-package-inactive)
        (asserts! (<= share-count (get available-shares package)) err-insufficient-shares)
        (asserts! (>= (stx-get-balance tx-sender) payment) err-insufficient-payment)
        
        (try! (stx-transfer? payment tx-sender contract-owner))
        (map-set vacation-packages package-id
            (merge package {
                available-shares: (- (get available-shares package) share-count)
            })
        )
        (map-set bookings {package-id: package-id, owner: tx-sender}
            {
                shares: share-count,
                purchase-date: block-height
            }
        )
        (ok true)
    )
)

;; Read-only functions
(define-read-only (get-package (package-id uint))
    (map-get? vacation-packages package-id)
)

(define-read-only (get-booking (package-id uint) (owner principal))
    (map-get? bookings {package-id: package-id, owner: owner})
)

(define-read-only (get-available-shares (package-id uint))
    (get available-shares (unwrap! (map-get? vacation-packages package-id) err-package-not-found))
)
