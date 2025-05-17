;; Access Control Contract
;; Manages permissions for sharing knowledge assets

;; Map to store access permissions for each asset
(define-map asset-permissions
  { asset-id: uint, accessor: principal }
  {
    granted-by: principal,
    granted-at: uint,
    expires-at: uint,
    access-level: (string-utf8 20) ;; "read", "edit", "full"
  }
)

;; Public function to grant access to an asset
(define-public (grant-access
                (asset-id uint)
                (accessor principal)
                (access-level (string-utf8 20))
                (duration uint))
  (let
    (
      (caller tx-sender)
      (expiry (+ block-height duration))
    )
    (begin
      ;; Verify caller owns the asset (would call knowledge-asset contract)
      ;; For simplicity, we're not implementing the contract call here

      ;; Grant access
      (ok (map-set asset-permissions
        { asset-id: asset-id, accessor: accessor }
        {
          granted-by: caller,
          granted-at: block-height,
          expires-at: expiry,
          access-level: access-level
        }))
    )
  )
)

;; Public function to revoke access to an asset
(define-public (revoke-access (asset-id uint) (accessor principal))
  (let ((caller tx-sender))
    (begin
      ;; Verify caller owns the asset or is the accessor
      ;; For simplicity, we're not implementing the contract call here

      ;; Revoke access
      (ok (map-delete asset-permissions { asset-id: asset-id, accessor: accessor }))
    )
  )
)

;; Read-only function to check if an entity has access to an asset
(define-read-only (check-access (asset-id uint) (accessor principal))
  (let ((access-data (map-get? asset-permissions { asset-id: asset-id, accessor: accessor })))
    (match access-data
      data (if (> (get expires-at data) block-height)
              (ok data)
              (err u1)) ;; Access expired
      (err u2) ;; No access found
    )
  )
)
