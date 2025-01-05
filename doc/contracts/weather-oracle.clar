;; contracts/weather-oracle.clar

(impl-trait .drone-traits.weather-oracle-trait)

(define-map weather-conditions
    { coordinates: (tuple (x uint) (y uint)) }
    { condition: (string-ascii 20) }
)

(define-data-var oracle-admin principal tx-sender)

(define-public (get-weather-conditions (x uint) (y uint))
    (match (map-get? weather-conditions { coordinates: { x: x, y: y } })
        condition (ok (get condition condition))
        (ok "sunny") ;; Default condition if not set
    )
)

(define-public (set-weather-conditions
    (x uint)
    (y uint)
    (condition (string-ascii 20))
)
    (begin
        (asserts! (is-eq tx-sender (var-get oracle-admin)) (err u1))
        (ok (map-set weather-conditions
            { coordinates: { x: x, y: y } }
            { condition: condition }
        ))
    )
)
