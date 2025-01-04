;; Manages farming tasks and assignments

(define-map farming-tasks
    { task-id: uint }
    {
        drone-id: uint,
        task-type: (string-ascii 20),
        status: (string-ascii 20),
        field-coordinates: (tuple (x uint) (y uint)),
        completion-height: uint
    }
)

(define-public (assign-task 
    (task-id uint) 
    (drone-id uint) 
    (task-type (string-ascii 20))
    (x uint)
    (y uint)
)
    (let
        ((caller tx-sender)
         (drone-owner-response (contract-call? .drone-registry get-drone-owner drone-id)))
        (begin
            (asserts! (is-ok drone-owner-response) (err u1))
            (asserts! (is-eq (unwrap-panic drone-owner-response) caller) (err u2))
            (ok (map-set farming-tasks
                { task-id: task-id }
                {
                    drone-id: drone-id,
                    task-type: task-type,
                    status: "pending",
                    field-coordinates: { x: x, y: y },
                    completion-height: (+ block-height u100)
                }
            ))
        )
    )
)
