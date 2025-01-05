;; contracts/task-manager.clar

(use-trait weather-oracle-trait .drone-traits.weather-oracle-trait)

;; Constants for task status
(define-constant PENDING "pending")
(define-constant IN_PROGRESS "in-progress")
(define-constant COMPLETED "completed")
(define-constant FAILED "failed")

;; Advanced task structure
(define-map farming-tasks
    { task-id: uint }
    {
        drone-id: uint,
        task-type: (string-ascii 20),
        status: (string-ascii 20),
        field-coordinates: (tuple (x uint) (y uint)),
        completion-height: uint,
        priority: uint,
        estimated-duration: uint,
        weather-conditions: (string-ascii 20),
        payload-requirements: uint
    }
)

;; Task queue
(define-map task-queue
    { priority: uint }
    {
        task-ids: (list 20 uint)
    }
)

(define-data-var task-nonce uint u0)

(define-read-only (get-task-status (task-id uint))
    (match (map-get? farming-tasks { task-id: task-id })
        task (ok (get status task))
        (err u404)
    )
)

(define-public (assign-task-with-weather
    (task-id uint)
    (drone-id uint)
    (task-type (string-ascii 20))
    (x uint)
    (y uint)
    (priority uint)
    (weather-oracle <weather-oracle-trait>)
)
    (let
        ((caller tx-sender)
         (drone-owner-response (try! (contract-call? .drone-registry get-drone-owner drone-id)))
         (drone-status-response (try! (contract-call? .drone-registry get-drone-status drone-id)))
         (weather-response (try! (contract-call? weather-oracle get-weather-conditions x y))))
        (begin
            (asserts! (is-eq drone-status-response "active") (err u4))
            (asserts! (is-eq drone-owner-response caller) (err u6))
            (ok (map-set farming-tasks
                { task-id: task-id }
                {
                    drone-id: drone-id,
                    task-type: task-type,
                    status: PENDING,
                    field-coordinates: { x: x, y: y },
                    completion-height: (+ block-height u100),
                    priority: priority,
                    estimated-duration: u3600,
                    weather-conditions: weather-response,
                    payload-requirements: u50
                }
            ))
        )
    )
)

(define-public (update-task-status
    (task-id uint)
    (new-status (string-ascii 20))
)
    (let
        ((caller tx-sender)
         (task (unwrap! (map-get? farming-tasks { task-id: task-id }) (err u1)))
         (drone-owner (try! (contract-call? .drone-registry get-drone-owner (get drone-id task)))))
        (begin
            (asserts! (is-eq caller drone-owner) (err u2))
            (ok (map-set farming-tasks
                { task-id: task-id }
                (merge task { status: new-status })
            ))
        )
    )
)
