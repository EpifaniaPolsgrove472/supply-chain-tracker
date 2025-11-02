;; Product Registry Contract
;; Registers products with unique identifiers and tracks custody chain

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-product-not-found (err u101))
(define-constant err-product-already-exists (err u102))
(define-constant err-invalid-transfer (err u103))
(define-constant err-invalid-status (err u104))
(define-constant err-not-current-owner (err u105))

;; Status constants
(define-constant status-registered u1)
(define-constant status-in-transit u2)
(define-constant status-delivered u3)
(define-constant status-verified u4)
(define-constant status-retired u5)

;; Data Variables
(define-data-var product-id-nonce uint u0)

;; Data Maps
(define-map products
  { product-id: uint }
  {
    name: (string-ascii 100),
    description: (string-ascii 500),
    manufacturer: principal,
    current-owner: principal,
    status: uint,
    registered-at: uint,
    last-updated: uint,
    origin: (string-ascii 100),
    category: (string-ascii 50)
  }
)

(define-map custody-history
  { product-id: uint, sequence: uint }
  {
    from-owner: principal,
    to-owner: principal,
    transferred-at: uint,
    location: (string-ascii 100),
    notes: (string-ascii 200)
  }
)

(define-map product-transfer-count
  { product-id: uint }
  { count: uint }
)

(define-map authorized-operators
  { operator: principal, product-id: uint }
  { authorized: bool }
)

(define-map product-metadata
  { product-id: uint }
  {
    batch-number: (string-ascii 50),
    expiry-date: uint,
    weight: uint,
    dimensions: (string-ascii 50),
    certifications: (string-ascii 200)
  }
)

;; Private Functions
(define-private (is-product-owner (product-id uint) (caller principal))
  (match (map-get? products { product-id: product-id })
    product (is-eq (get current-owner product) caller)
    false
  )
)

(define-private (is-authorized-operator (product-id uint) (caller principal))
  (default-to false
    (get authorized (map-get? authorized-operators { operator: caller, product-id: product-id }))
  )
)

(define-private (increment-product-id)
  (let ((current-id (var-get product-id-nonce)))
    (var-set product-id-nonce (+ current-id u1))
    current-id
  )
)

(define-private (get-transfer-count (product-id uint))
  (default-to u0
    (get count (map-get? product-transfer-count { product-id: product-id }))
  )
)

(define-private (increment-transfer-count (product-id uint))
  (let ((current-count (get-transfer-count product-id)))
    (map-set product-transfer-count
      { product-id: product-id }
      { count: (+ current-count u1) }
    )
    (+ current-count u1)
  )
)

;; Public Functions

;; Register a new product
(define-public (register-product
    (name (string-ascii 100))
    (description (string-ascii 500))
    (origin (string-ascii 100))
    (category (string-ascii 50))
  )
  (let
    (
      (new-product-id (increment-product-id))
    )
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (map-set products
      { product-id: new-product-id }
      {
        name: name,
        description: description,
        manufacturer: tx-sender,
        current-owner: tx-sender,
        status: status-registered,
        registered-at: stacks-block-height,
        last-updated: stacks-block-height,
        origin: origin,
        category: category
      }
    )
    (map-set product-transfer-count
      { product-id: new-product-id }
      { count: u0 }
    )
    (ok new-product-id)
  )
)

;; Transfer product custody
(define-public (transfer-product
    (product-id uint)
    (new-owner principal)
    (location (string-ascii 100))
    (notes (string-ascii 200))
  )
  (let
    (
      (product (unwrap! (map-get? products { product-id: product-id }) err-product-not-found))
      (current-owner (get current-owner product))
      (sequence (increment-transfer-count product-id))
    )
    (asserts! (or (is-eq tx-sender current-owner)
                  (is-authorized-operator product-id tx-sender))
              err-not-current-owner)
    (asserts! (not (is-eq current-owner new-owner)) err-invalid-transfer)
    
    (map-set custody-history
      { product-id: product-id, sequence: sequence }
      {
        from-owner: current-owner,
        to-owner: new-owner,
        transferred-at: stacks-block-height,
        location: location,
        notes: notes
      }
    )
    
    (map-set products
      { product-id: product-id }
      (merge product {
        current-owner: new-owner,
        status: status-in-transit,
        last-updated: stacks-block-height
      })
    )
    (ok true)
  )
)

;; Update product status
(define-public (update-product-status (product-id uint) (new-status uint))
  (let
    (
      (product (unwrap! (map-get? products { product-id: product-id }) err-product-not-found))
    )
    (asserts! (is-product-owner product-id tx-sender) err-not-current-owner)
    (asserts! (and (>= new-status status-registered) (<= new-status status-retired)) err-invalid-status)
    
    (map-set products
      { product-id: product-id }
      (merge product {
        status: new-status,
        last-updated: stacks-block-height
      })
    )
    (ok true)
  )
)

;; Authorize operator for a product
(define-public (authorize-operator (product-id uint) (operator principal))
  (begin
    (asserts! (is-product-owner product-id tx-sender) err-not-current-owner)
    (map-set authorized-operators
      { operator: operator, product-id: product-id }
      { authorized: true }
    )
    (ok true)
  )
)

;; Revoke operator authorization
(define-public (revoke-operator (product-id uint) (operator principal))
  (begin
    (asserts! (is-product-owner product-id tx-sender) err-not-current-owner)
    (map-set authorized-operators
      { operator: operator, product-id: product-id }
      { authorized: false }
    )
    (ok true)
  )
)

;; Set product metadata
(define-public (set-product-metadata
    (product-id uint)
    (batch-number (string-ascii 50))
    (expiry-date uint)
    (weight uint)
    (dimensions (string-ascii 50))
    (certifications (string-ascii 200))
  )
  (begin
    (asserts! (is-product-owner product-id tx-sender) err-not-current-owner)
    (asserts! (is-some (map-get? products { product-id: product-id })) err-product-not-found)
    
    (map-set product-metadata
      { product-id: product-id }
      {
        batch-number: batch-number,
        expiry-date: expiry-date,
        weight: weight,
        dimensions: dimensions,
        certifications: certifications
      }
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get product information
(define-read-only (get-product (product-id uint))
  (map-get? products { product-id: product-id })
)

;; Get custody history entry
(define-read-only (get-custody-record (product-id uint) (sequence uint))
  (map-get? custody-history { product-id: product-id, sequence: sequence })
)

;; Get transfer count for a product
(define-read-only (get-product-transfer-count (product-id uint))
  (ok (get-transfer-count product-id))
)

;; Check if operator is authorized
(define-read-only (is-operator-authorized (product-id uint) (operator principal))
  (ok (is-authorized-operator product-id operator))
)

;; Get product metadata
(define-read-only (get-product-metadata (product-id uint))
  (map-get? product-metadata { product-id: product-id })
)

;; Get current product ID nonce
(define-read-only (get-current-product-id)
  (ok (var-get product-id-nonce))
)

;; Verify product ownership
(define-read-only (verify-ownership (product-id uint) (claimed-owner principal))
  (ok (is-product-owner product-id claimed-owner))
)

;; Get product status
(define-read-only (get-product-status (product-id uint))
  (match (map-get? products { product-id: product-id })
    product (ok (get status product))
    err-product-not-found
  )
)

;; Get product current owner
(define-read-only (get-product-owner (product-id uint))
  (match (map-get? products { product-id: product-id })
    product (ok (get current-owner product))
    err-product-not-found
  )
)


