
;; title: EquityVote
;; version: 1.0.0
;; summary: A blockchain-based system for shareholder proposals and board member nominations
;; description: This contract enables shareholders to create proposals, nominate board members,
;;              and vote on various corporate governance matters in a transparent and immutable way.

;; traits
;;

;; token definitions
;;

;; constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-SHAREHOLDER (err u101))
(define-constant ERR-PROPOSAL-NOT-FOUND (err u102))
(define-constant ERR-VOTING-ENDED (err u103))
(define-constant ERR-ALREADY-VOTED (err u104))
(define-constant ERR-INSUFFICIENT-SHARES (err u105))
(define-constant ERR-INVALID-NOMINEE (err u106))
(define-constant ERR-NOMINATION-NOT-FOUND (err u107))

;; Voting periods (in blocks)
(define-constant PROPOSAL-VOTING-PERIOD u1440) ;; ~10 days assuming 10 min blocks
(define-constant NOMINATION-VOTING-PERIOD u2160) ;; ~15 days

;; Minimum shares required to create proposals
(define-constant MIN-SHARES-FOR-PROPOSAL u1000)

;; data vars
(define-data-var proposal-nonce uint u0)
(define-data-var nomination-nonce uint u0)

;; data maps
;; Track shareholder ownership
(define-map shareholders principal uint)

;; Proposal structure
(define-map proposals uint {
    creator: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    proposal-type: (string-ascii 20), ;; "general", "financial", "governance"
    votes-for: uint,
    votes-against: uint,
    created-at: uint,
    voting-ends: uint,
    executed: bool
})

;; Board member nomination structure
(define-map board-nominations uint {
    nominator: principal,
    nominee: principal,
    position: (string-ascii 50),
    qualifications: (string-ascii 300),
    votes: uint,
    created-at: uint,
    voting-ends: uint
})

;; Track who voted on which proposal
(define-map proposal-votes {proposal-id: uint, voter: principal} bool)

;; Track who voted on which nomination
(define-map nomination-votes {nomination-id: uint, voter: principal} bool)

;; public functions

;; Register shares for a shareholder (only contract owner can do this)
(define-public (register-shareholder (shareholder principal) (shares uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (ok (map-set shareholders shareholder shares))
    )
)

;; Create a new proposal
(define-public (create-proposal (title (string-ascii 100))
                              (description (string-ascii 500))
                              (proposal-type (string-ascii 20)))
    (let (
        (current-nonce (var-get proposal-nonce))
        (creator-shares (default-to u0 (map-get? shareholders tx-sender)))
        (current-block block-height)
    )
        (asserts! (>= creator-shares MIN-SHARES-FOR-PROPOSAL) ERR-INSUFFICIENT-SHARES)
        (map-set proposals current-nonce {
            creator: tx-sender,
            title: title,
            description: description,
            proposal-type: proposal-type,
            votes-for: u0,
            votes-against: u0,
            created-at: current-block,
            voting-ends: (+ current-block PROPOSAL-VOTING-PERIOD),
            executed: false
        })
        (var-set proposal-nonce (+ current-nonce u1))
        (ok current-nonce)
    )
)

;; Vote on a proposal
(define-public (vote-on-proposal (proposal-id uint) (vote-for bool))
    (let (
        (proposal (unwrap! (map-get? proposals proposal-id) ERR-PROPOSAL-NOT-FOUND))
        (voter-shares (unwrap! (map-get? shareholders tx-sender) ERR-NOT-SHAREHOLDER))
        (vote-key {proposal-id: proposal-id, voter: tx-sender})
        (current-block block-height)
    )
        (asserts! (<= current-block (get voting-ends proposal)) ERR-VOTING-ENDED)
        (asserts! (is-none (map-get? proposal-votes vote-key)) ERR-ALREADY-VOTED)

        ;; Record the vote
        (map-set proposal-votes vote-key true)

        ;; Update proposal vote counts
        (if vote-for
            (map-set proposals proposal-id
                (merge proposal {votes-for: (+ (get votes-for proposal) voter-shares)}))
            (map-set proposals proposal-id
                (merge proposal {votes-against: (+ (get votes-against proposal) voter-shares)}))
        )
        (ok true)
    )
)

;; Nominate a board member
(define-public (nominate-board-member (nominee principal)
                                    (position (string-ascii 50))
                                    (qualifications (string-ascii 300)))
    (let (
        (current-nonce (var-get nomination-nonce))
        (nominator-shares (unwrap! (map-get? shareholders tx-sender) ERR-NOT-SHAREHOLDER))
        (current-block block-height)
    )
        (asserts! (>= nominator-shares MIN-SHARES-FOR-PROPOSAL) ERR-INSUFFICIENT-SHARES)
        (map-set board-nominations current-nonce {
            nominator: tx-sender,
            nominee: nominee,
            position: position,
            qualifications: qualifications,
            votes: u0,
            created-at: current-block,
            voting-ends: (+ current-block NOMINATION-VOTING-PERIOD)
        })
        (var-set nomination-nonce (+ current-nonce u1))
        (ok current-nonce)
    )
)

;; Vote for a board nomination
(define-public (vote-for-nomination (nomination-id uint))
    (let (
        (nomination (unwrap! (map-get? board-nominations nomination-id) ERR-NOMINATION-NOT-FOUND))
        (voter-shares (unwrap! (map-get? shareholders tx-sender) ERR-NOT-SHAREHOLDER))
        (vote-key {nomination-id: nomination-id, voter: tx-sender})
        (current-block block-height)
    )
        (asserts! (<= current-block (get voting-ends nomination)) ERR-VOTING-ENDED)
        (asserts! (is-none (map-get? nomination-votes vote-key)) ERR-ALREADY-VOTED)

        ;; Record the vote
        (map-set nomination-votes vote-key true)

        ;; Update nomination vote count
        (map-set board-nominations nomination-id
            (merge nomination {votes: (+ (get votes nomination) voter-shares)}))
        (ok true)
    )
)

;; read only functions

;; Get shareholder information
(define-read-only (get-shareholder-shares (shareholder principal))
    (map-get? shareholders shareholder)
)

;; Get proposal details
(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals proposal-id)
)

;; Get nomination details
(define-read-only (get-nomination (nomination-id uint))
    (map-get? board-nominations nomination-id)
)

;; Check if a user has voted on a proposal
(define-read-only (has-voted-on-proposal (proposal-id uint) (voter principal))
    (is-some (map-get? proposal-votes {proposal-id: proposal-id, voter: voter}))
)

;; Check if a user has voted on a nomination
(define-read-only (has-voted-on-nomination (nomination-id uint) (voter principal))
    (is-some (map-get? nomination-votes {nomination-id: nomination-id, voter: voter}))
)

;; Get current proposal nonce (total number of proposals created)
(define-read-only (get-proposal-count)
    (var-get proposal-nonce)
)

;; Get current nomination nonce (total number of nominations created)
(define-read-only (get-nomination-count)
    (var-get nomination-nonce)
)

;; Check if proposal voting is still active
(define-read-only (is-proposal-voting-active (proposal-id uint))
    (match (map-get? proposals proposal-id)
        proposal (< block-height (get voting-ends proposal))
        false
    )
)

;; Check if nomination voting is still active
(define-read-only (is-nomination-voting-active (nomination-id uint))
    (match (map-get? board-nominations nomination-id)
        nomination (< block-height (get voting-ends nomination))
        false
    )
)

;; private functions
;;

;; Helper function to calculate voting results
(define-read-only (get-proposal-result (proposal-id uint))
    (match (map-get? proposals proposal-id)
        proposal
        (if (> (get votes-for proposal) (get votes-against proposal))
            "passed"
            "failed"
        )
        "not-found"
    )
)

