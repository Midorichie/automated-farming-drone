;; contracts/drone-registry.clar

(use-trait nft-trait .drone-traits.nft-trait)

;; Constants for drone status
(define-constant ACTIVE "active")
(define-constant MAINTENANCE "maintenance")
(define-constant DISABLED "disabled")

;; Enhanced drone data structure
(define-map drones
    { drone-id: uint }
    {
        owner: principal,
        status: (string-ascii 20),
        tasks-completed: uint,
        maintenance-due: uint,
        drone-type: (string-ascii 20),
        efficiency-rating: uint,
        total-flight-time: uint,
        last-inspection: uint
    }
)

;; Drone type certifications
(define-map drone-certifications
    { drone-type: (string-ascii 20) }
    {
        max-payload: uint,
        battery-capacity: uint,
        certification-authority: principal,
        certification-expiry: uint
    }
)

;; Event logging
(define-map drone-events
    { drone-id: uint, event-id: uint }
    {
        event-type: (string-ascii 20),
        block-height: uint,
        details: (string-ascii 100)
    }
)

(define-data-var event-nonce uint u0)
(define-data-var admin principal tx-sender)

;; Helper function for logging drone events
(define-private (log-drone-event (drone-id uint) (event-type (string-ascii 20)) (details (string-ascii 100)))
    (let
        ((event-id (var-get event-nonce)))
        (begin
            (var-set event-nonce (+ event-id u1))
            (map-set drone-events
                { drone-id: drone-id, event-id: event-id }
                {
                    event-type: event-type,
                    block-height: block-height,
                    details: details
                }
            )
            (ok true)
        )
    )
)

(define-read-only (get-drone-owner (drone-id uint))
    (match (map-get? drones { drone-id: drone-id })
        drone (ok (get owner drone))
        (err u404)
    )
)

(define-read-only (get-drone-status (drone-id uint))
    (match (map-get? drones { drone-id: drone-id })
        drone (ok (get status drone))
        (err u404)
    )
)

;; Enhanced registration with certification check
(define-public (register-drone
    (drone-id uint)
    (drone-type (string-ascii 20))
)
    (let
        ((caller tx-sender)
         (certification (unwrap! (map-get? drone-certifications {drone-type: drone-type}) (err u3))))
        (begin
            (asserts! (is-none (map-get? drones { drone-id: drone-id })) (err u1))
            (asserts! (< block-height (get certification-expiry certification)) (err u2))
            (map-set drones
                { drone-id: drone-id }
                {
                    owner: caller,
                    status: ACTIVE,
                    tasks-completed: u0,
                    maintenance-due: (+ block-height u10000),
                    drone-type: drone-type,
                    efficiency-rating: u100,
                    total-flight-time: u0,
                    last-inspection: block-height
                }
            )
            (log-drone-event drone-id "registration" "New drone registered")
        )
    )
)

(define-public (set-drone-maintenance (drone-id uint))
    (let
        ((caller tx-sender))
        (begin
            (asserts! (is-eq (some caller) (get owner (map-get? drones { drone-id: drone-id }))) (err u1))
            (map-set drones
                { drone-id: drone-id }
                (merge (unwrap! (map-get? drones { drone-id: drone-id }) (err u404))
                    {
                        status: MAINTENANCE,
                        last-inspection: block-height
                    }
                )
            )
            (log-drone-event drone-id "maintenance" "Drone entered maintenance mode")
        )
    )
)
