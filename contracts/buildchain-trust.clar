(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_AMOUNT (err u400))
(define-constant ERR_INSUFFICIENT_FUNDS (err u402))
(define-constant ERR_ALREADY_EXISTS (err u409))
(define-constant ERR_PROJECT_COMPLETED (err u403))
(define-constant ERR_MILESTONE_NOT_READY (err u405))
(define-constant ERR_INVALID_STATUS (err u406))

(define-data-var contract-owner principal CONTRACT_OWNER)
(define-data-var total-projects uint u0)
(define-data-var total-contractors uint u0)
(define-data-var total-funding uint u0)
(define-data-var trust-fund-balance uint u0)
(define-data-var milestone-completion-bonus uint u5)

(define-map projects
    { project-id: uint }
    {
        client: principal,
        contractor: principal,
        title: (string-ascii 128),
        description: (string-ascii 256),
        total-budget: uint,
        remaining-budget: uint,
        start-height: uint,
        deadline: uint,
        status: uint,
        milestone-count: uint,
        completed-milestones: uint,
        project-type: (string-ascii 32)
    }
)

(define-map contractors
    { contractor: principal }
    {
        name: (string-ascii 64),
        specialty: (string-ascii 64),
        registration-height: uint,
        completed-projects: uint,
        trust-score: uint,
        is-verified: bool,
        total-earned: uint
    }
)

(define-map milestones
    { project-id: uint, milestone-id: uint }
    {
        title: (string-ascii 64),
        description: (string-ascii 128),
        budget-allocation: uint,
        deadline: uint,
        is-completed: bool,
        completion-height: uint,
        verified-by: principal
    }
)

(define-map project-funding
    { project-id: uint, funder: principal }
    {
        amount: uint,
        funding-height: uint,
        is-refunded: bool
    }
)

(define-map trust-ratings
    { project-id: uint, rater: principal }
    {
        contractor-rating: uint,
        quality-rating: uint,
        timeline-rating: uint,
        rating-height: uint
    }
)

(define-map infrastructure-inspections
    { project-id: uint, milestone-id: uint }
    {
        inspector: principal,
        inspection-date: uint,
        quality-score: uint,
        safety-compliance: bool,
        notes: (string-ascii 128),
        is-approved: bool
    }
)

(define-read-only (get-project (project-id uint))
    (map-get? projects { project-id: project-id })
)

(define-read-only (get-contractor (contractor principal))
    (map-get? contractors { contractor: contractor })
)

(define-read-only (get-milestone (project-id uint) (milestone-id uint))
    (map-get? milestones { project-id: project-id, milestone-id: milestone-id })
)

(define-read-only (get-project-funding (project-id uint) (funder principal))
    (map-get? project-funding { project-id: project-id, funder: funder })
)

(define-read-only (get-trust-rating (project-id uint) (rater principal))
    (map-get? trust-ratings { project-id: project-id, rater: rater })
)

(define-read-only (get-inspection (project-id uint) (milestone-id uint))
    (map-get? infrastructure-inspections { project-id: project-id, milestone-id: milestone-id })
)

(define-read-only (get-total-projects)
    (var-get total-projects)
)

(define-read-only (get-total-contractors)
    (var-get total-contractors)
)

(define-read-only (get-trust-fund-balance)
    (var-get trust-fund-balance)
)

(define-read-only (calculate-milestone-payment (budget-allocation uint) (quality-score uint))
    (+ budget-allocation (/ (* budget-allocation quality-score) u100))
)

(define-read-only (is-project-active (project-id uint))
    (match (get-project project-id)
        project (and 
            (is-eq (get status project) u1)
            (> (get deadline project) stacks-block-height)
        )
        false
    )
)

(define-public (register-contractor (name (string-ascii 64)) (specialty (string-ascii 64)))
    (let ((existing-contractor (get-contractor tx-sender)))
        (asserts! (is-none existing-contractor) ERR_ALREADY_EXISTS)
        
        (map-set contractors
            { contractor: tx-sender }
            {
                name: name,
                specialty: specialty,
                registration-height: stacks-block-height,
                completed-projects: u0,
                trust-score: u50,
                is-verified: false,
                total-earned: u0
            }
        )
        
        (var-set total-contractors (+ (var-get total-contractors) u1))
        (ok true)
    )
)

(define-public (create-project (contractor principal) (title (string-ascii 128)) (description (string-ascii 256))
                              (total-budget uint) (deadline-blocks uint) (project-type (string-ascii 32)))
    (let ((project-id (+ (var-get total-projects) u1)))
        (asserts! (is-some (get-contractor contractor)) ERR_NOT_FOUND)
        (asserts! (> total-budget u0) ERR_INVALID_AMOUNT)
        (asserts! (> deadline-blocks u0) ERR_INVALID_AMOUNT)
        
        (map-set projects
            { project-id: project-id }
            {
                client: tx-sender,
                contractor: contractor,
                title: title,
                description: description,
                total-budget: total-budget,
                remaining-budget: total-budget,
                start-height: stacks-block-height,
                deadline: (+ stacks-block-height deadline-blocks),
                status: u1,
                milestone-count: u0,
                completed-milestones: u0,
                project-type: project-type
            }
        )
        
        (var-set total-projects project-id)
        (ok project-id)
    )
)

(define-public (add-milestone (project-id uint) (title (string-ascii 64)) (description (string-ascii 128))
                             (budget-allocation uint) (deadline-blocks uint))
    (let (
        (project (unwrap! (get-project project-id) ERR_NOT_FOUND))
        (milestone-id (+ (get milestone-count project) u1))
    )
        (asserts! (is-eq (get client project) tx-sender) ERR_UNAUTHORIZED)
        (asserts! (is-project-active project-id) ERR_PROJECT_COMPLETED)
        (asserts! (> budget-allocation u0) ERR_INVALID_AMOUNT)
        (asserts! (<= budget-allocation (get remaining-budget project)) ERR_INSUFFICIENT_FUNDS)
        
        (map-set milestones
            { project-id: project-id, milestone-id: milestone-id }
            {
                title: title,
                description: description,
                budget-allocation: budget-allocation,
                deadline: (+ stacks-block-height deadline-blocks),
                is-completed: false,
                completion-height: u0,
                verified-by: tx-sender
            }
        )
        
        (map-set projects
            { project-id: project-id }
            (merge project { milestone-count: milestone-id })
        )
        
        (ok milestone-id)
    )
)

(define-public (fund-project (project-id uint) (amount uint))
    (let ((project (unwrap! (get-project project-id) ERR_NOT_FOUND)))
        (asserts! (is-project-active project-id) ERR_PROJECT_COMPLETED)
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        
        (map-set project-funding
            { project-id: project-id, funder: tx-sender }
            {
                amount: amount,
                funding-height: stacks-block-height,
                is-refunded: false
            }
        )
        
        (var-set total-funding (+ (var-get total-funding) amount))
        (var-set trust-fund-balance (+ (var-get trust-fund-balance) amount))
        (ok true)
    )
)

(define-public (complete-milestone (project-id uint) (milestone-id uint))
    (let (
        (project (unwrap! (get-project project-id) ERR_NOT_FOUND))
        (milestone (unwrap! (get-milestone project-id milestone-id) ERR_NOT_FOUND))
    )
        (asserts! (is-eq (get contractor project) tx-sender) ERR_UNAUTHORIZED)
        (asserts! (not (get is-completed milestone)) ERR_ALREADY_EXISTS)
        (asserts! (is-project-active project-id) ERR_PROJECT_COMPLETED)
        
        (map-set milestones
            { project-id: project-id, milestone-id: milestone-id }
            (merge milestone 
                {
                    is-completed: true,
                    completion-height: stacks-block-height
                }
            )
        )
        
        (map-set projects
            { project-id: project-id }
            (merge project 
                { 
                    completed-milestones: (+ (get completed-milestones project) u1),
                    remaining-budget: (- (get remaining-budget project) (get budget-allocation milestone))
                }
            )
        )
        (ok true)
    )
)

(define-public (inspect-infrastructure (project-id uint) (milestone-id uint) (quality-score uint) 
                                      (safety-compliance bool) (notes (string-ascii 128)))
    (let ((milestone (unwrap! (get-milestone project-id milestone-id) ERR_NOT_FOUND)))
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (asserts! (get is-completed milestone) ERR_MILESTONE_NOT_READY)
        (asserts! (<= quality-score u100) ERR_INVALID_AMOUNT)
        
        (map-set infrastructure-inspections
            { project-id: project-id, milestone-id: milestone-id }
            {
                inspector: tx-sender,
                inspection-date: stacks-block-height,
                quality-score: quality-score,
                safety-compliance: safety-compliance,
                notes: notes,
                is-approved: (and safety-compliance (>= quality-score u70))
            }
        )
        (ok true)
    )
)

(define-public (release-milestone-payment (project-id uint) (milestone-id uint))
    (let (
        (project (unwrap! (get-project project-id) ERR_NOT_FOUND))
        (milestone (unwrap! (get-milestone project-id milestone-id) ERR_NOT_FOUND))
        (inspection (unwrap! (get-inspection project-id milestone-id) ERR_NOT_FOUND))
        (contractor-data (unwrap! (get-contractor (get contractor project)) ERR_NOT_FOUND))
        (payment (calculate-milestone-payment (get budget-allocation milestone) (get quality-score inspection)))
    )
        (asserts! (is-eq (get client project) tx-sender) ERR_UNAUTHORIZED)
        (asserts! (get is-approved inspection) ERR_INVALID_STATUS)
        (asserts! (<= payment (var-get trust-fund-balance)) ERR_INSUFFICIENT_FUNDS)
        
        (map-set contractors
            { contractor: (get contractor project) }
            (merge contractor-data 
                {
                    total-earned: (+ (get total-earned contractor-data) payment),
                    trust-score: (if (< (+ (get trust-score contractor-data) (var-get milestone-completion-bonus)) u100)
                                   (+ (get trust-score contractor-data) (var-get milestone-completion-bonus))
                                   u100)
                }
            )
        )
        
        (var-set trust-fund-balance (- (var-get trust-fund-balance) payment))
        (ok payment)
    )
)

(define-public (rate-project (project-id uint) (contractor-rating uint) (quality-rating uint) (timeline-rating uint))
    (let ((project (unwrap! (get-project project-id) ERR_NOT_FOUND)))
        (asserts! (is-eq (get client project) tx-sender) ERR_UNAUTHORIZED)
        (asserts! (and (<= contractor-rating u100) (<= quality-rating u100) (<= timeline-rating u100)) ERR_INVALID_AMOUNT)
        
        (map-set trust-ratings
            { project-id: project-id, rater: tx-sender }
            {
                contractor-rating: contractor-rating,
                quality-rating: quality-rating,
                timeline-rating: timeline-rating,
                rating-height: stacks-block-height
            }
        )
        (ok true)
    )
)

(define-public (verify-contractor (contractor principal))
    (let ((contractor-data (unwrap! (get-contractor contractor) ERR_NOT_FOUND)))
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        
        (map-set contractors
            { contractor: contractor }
            (merge contractor-data { is-verified: true })
        )
        (ok true)
    )
)

(define-public (close-project (project-id uint))
    (let (
        (project (unwrap! (get-project project-id) ERR_NOT_FOUND))
        (contractor-data (unwrap! (get-contractor (get contractor project)) ERR_NOT_FOUND))
    )
        (asserts! (is-eq (get client project) tx-sender) ERR_UNAUTHORIZED)
        
        (map-set projects
            { project-id: project-id }
            (merge project { status: u0 })
        )
        
        (map-set contractors
            { contractor: (get contractor project) }
            (merge contractor-data 
                { completed-projects: (+ (get completed-projects contractor-data) u1) }
            )
        )
        (ok true)
    )
)

(define-public (update-milestone-bonus (new-bonus uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (asserts! (<= new-bonus u20) ERR_INVALID_AMOUNT)
        (var-set milestone-completion-bonus new-bonus)
        (ok true)
    )
)

(define-public (transfer-ownership (new-owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (var-set contract-owner new-owner)
        (ok true)
    )
)
