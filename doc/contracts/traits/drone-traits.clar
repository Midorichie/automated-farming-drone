;; contracts/traits/drone-traits.clar

(define-trait nft-trait
    (
        (get-last-token-id () (response uint uint))
        (get-token-uri (uint) (response (optional (string-ascii 256)) uint))
        (get-owner (uint) (response (optional principal) uint))
        (transfer (uint principal principal) (response bool uint))
    )
)

(define-trait weather-oracle-trait
    (
        (get-weather-conditions (uint uint) (response (string-ascii 20) uint))
    )
)
