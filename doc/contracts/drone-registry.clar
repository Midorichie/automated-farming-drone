;; Handles drone registration and management
(define-data-var admin principal tx-sender)

(define-map drones
    { drone-id: uint }
    {
        owner: principal,
        status: (string-ascii 20),
        tasks-completed: uint,
        maintenance-due: uint
    }
)

(define-read-only (get-drone-owner (drone-id uint))
    (match (map-get? drones { drone-id: drone-id })
        drone (ok (get owner drone))
        (err u404)
    )
)

(define-public (register-drone (drone-id uint))
    (let
        ((caller tx-sender))
        (begin
            (asserts! (is-none (map-get? drones { drone-id: drone-id })) (err u1))
            (ok (map-set drones
                { drone-id: drone-id }
                {
                    owner: caller,
                    status: "active",
                    tasks-completed: u0,
                    maintenance-due: (+ block-height u10000)
                }
            ))
        )
    )
)
