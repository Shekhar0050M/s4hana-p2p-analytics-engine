# ZI_ProcureOrderComp – Behavior Definition (BDEF)

**Type**: Behavior Definition (managed)  
**File**: `src/zi_procureordercomp.bdef.asbdef`  
**Last Updated**: October 12, 2026

## Purpose

Defines the full transactional behavior of the Purchase Order Business Object:
- Create / Update / Delete
- Draft handling
- Early numbering
- Determinations (defaults + calculated fields)
- Validations
- Lifecycle actions with dynamic feature control
- Side effects for real-time UI updates

## Full Source (current)

```abap
managed implementation in class zbp_i_procureordercomp unique;
strict ( 2 );
with draft;

define behavior for ZI_ProcureOrderComp alias PurchaseOrder
persistent table ztb_po_hdr
draft table zdt_po_hdr_d
lock master
total etag created_at
authorization master ( global )
etag master created_at
early numbering
{
  create ( authorization : global );
  update;
  delete;

  field ( readonly )
    po_id,
    vendor_name_upper,
    po_summary_string,
    status_text,
    order_tier,
    discount_amount;

  association _POItem { create; with draft; }

  determination SetInitialStatus on save { create; }
  determination CalculateOrderDefaults on save { create; }
  determination CalculateOrderTier on modify { field total_amount; create; update; }

  validation ValidateTotalAmount on save { field total_amount; create; update; }
  validation ValidateVendor      on save { field vendor_name; create; update; }
  validation ValidateCurrency    on save { field currency_code; create; update; }
  validation ValidateStatus      on save { field status; create; update; }

  action ( features : instance ) setComplete result [1] $self;
  action ( features : instance ) approveOrder result [1] $self;
  action ( features : instance ) rejectOrder  result [1] $self;
  action ( features : instance ) cancelOrder  result [1] $self;

  draft action Edit;
  draft action Activate optimized;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare{
    validation ValidateTotalAmount;
    validation ValidateVendor;
    validation ValidateCurrency;
    validation ValidateStatus;
  }

  mapping for ztb_po_hdr
  {
    po_id         = po_id;
    vendor_name   = vendor_name;
    total_amount  = total_amount;
    currency_code = currency_code;
    status        = status;
    created_at    = created_at;
  }

  /* Side Effects (instant UI synchronization on change/actions) */
  side effects {
    /* 1. Changing amount triggers real-time recalculation of tier & discount */
    field total_amount affects field order_tier, field order_tier_criticality, field discount_amount;
    /* 2. Executing actions immediately refreshes status and re-evaluates button permissions */
    action approveOrder affects field status, field status_text, field status_criticality,
                                permissions ( action setComplete, action cancelOrder, action approveOrder, action rejectOrder );
    action rejectOrder  affects field status, field status_text, field status_criticality,
                                permissions ( action setComplete, action cancelOrder, action approveOrder, action rejectOrder );
    action cancelOrder  affects field status, field status_text, field status_criticality,
                                permissions ( action setComplete, action cancelOrder, action approveOrder, action rejectOrder );
    action setComplete  affects field status, field status_text, field status_criticality,
                                permissions ( action setComplete, action cancelOrder, action approveOrder, action rejectOrder );
  }
}

define behavior for ZI_PoItem alias POItem
persistent table ztb_po_item
draft table zdt_po_item_d
lock dependent by _ProcureOrderComp
authorization dependent by _ProcureOrderComp
{
  update;
  delete;
  field ( readonly ) po_id, item_id;
  association _ProcureOrderComp { with draft; }

  determination CalculateTotalAmount on modify { create; update; delete; field net_amount, quantity; }

  mapping for ztb_po_item
  {
    po_id       = po_id;
    item_id     = item_id;
    material    = material;
    quantity    = quantity;
    unit        = unit;
    net_amount  = net_amount;
  }
}
```

## Key Sections Explained

### Early Numbering
```abap
early numbering
```
- `po_id` is assigned automatically from a number range object before the record is saved.
- Implemented in the behavior class (`NUMBERING` method).

### Determinations
| Name | Trigger | Purpose |
|------|---------|---------|
| `SetInitialStatus` | on save { create } | Sets status = 'N' for new documents |
| `CalculateOrderDefaults` | on save { create } | Sets default currency and other initial values |
| `CalculateOrderTier` | on modify { field total_amount } | Recalculates `order_tier`, criticality and discount whenever amount changes |
| `CalculateTotalAmount` (item) | on modify of items | Rolls up item net amounts into header `total_amount` |

### Validations
All run on save (and during Prepare):
- Total amount must be greater than zero
- Vendor is mandatory
- Currency is mandatory
- Status must be one of the allowed values / legal transitions

### Actions (with instance features)
All four actions are declared with `features : instance`.  
This means the implementation class decides at runtime (via `get_instance_features`) which buttons should be enabled/disabled depending on the current status.

### Side Effects
Critical for good UX:
- Changing the amount immediately updates the calculated fields in the UI without requiring a full save/refresh.
- After any lifecycle action the status fields and the action buttons themselves are refreshed.

## Linked Objects
- Implementation: [[17-ZBP_I_PROCUREORDERCOMP]]
- Projection BDEF: [[16-ZC_ProcureOrder-BDEF]]
- Composite CDS: [[05-ZI_ProcureOrderComp]]
- Draft tables: [[18-Draft-Tables]]
- Summary of latest work: [[21-Latest-Enhancements-Oct2026]]
