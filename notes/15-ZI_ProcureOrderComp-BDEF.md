# ZI_ProcureOrderComp – Behavior Definition (BDEF)

**Type**: Behavior Definition (BDEF)  
**Layer**: RAP Business Object – Interface / Managed  
**File**: `src/zi_procureordercomp.bdef.asbdef`

## Purpose
Defines the **transactional behaviour** of the Purchase Order Business Object:
- Which operations are allowed (CRUD)
- Draft handling
- Determinations, Validations, Actions
- Field control (readonly)
- Mapping to persistent + draft tables
- Locking & ETag strategy

This is the core RAP contract for the BO.

## Full Source Code

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
  validation ValidateTotalAmount on save { create; update; }
  action setComplete result [1] $self;

  draft action Edit;
  draft action Activate optimized;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare{
    validation ValidateTotalAmount;
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
}
```

## Block-by-Block Explanation

### Header
```abap
managed implementation in class zbp_i_procureordercomp unique;
strict ( 2 );
with draft;
```
- **`managed`** – RAP manages the transactional buffer and persistence. You only implement determinations, validations, actions, etc.
- **`implementation in class zbp_i_procureordercomp unique`** – Points to the behavior implementation class.
- **`strict ( 2 )`** – Enables stricter syntax checks (recommended).
- **`with draft`** – Activates draft handling for the whole BO.

### Root Entity Behavior
```abap
define behavior for ZI_ProcureOrderComp alias PurchaseOrder
persistent table ztb_po_hdr
draft table zdt_po_hdr_d
lock master
total etag created_at
authorization master ( global )
etag master created_at
```
| Clause | Why used | Function | Relevance |
|--------|----------|----------|-----------|
| `persistent table` | Links BO to real DB table | Where final data is stored | Required for managed scenario |
| `draft table` | Temporary storage while editing | Enables Edit → Activate flow | Draft feature |
| `lock master` | This entity owns the lock | Prevents concurrent changes | Standard for root |
| `total etag` / `etag master` | Optimistic locking using `created_at` | Detects concurrent modifications | Data integrity |
| `authorization master ( global )` | Central authority check | Global auth for the BO | Can be refined later |

### Operations
```abap
create ( authorization : global );
update;
delete;
```
Standard CUD. Create has an explicit global authorization check.

### Field Control
```abap
field ( readonly )
  po_id,
  vendor_name_upper,
  po_summary_string,
  status_text,
  order_tier,
  discount_amount;
```
- **Why**: Calculated / technical fields must not be editable by the user.
- **Function**: RAP UI automatically makes these fields non-editable.
- **Relevance**: Protects derived values (upper, case, cast expressions).

### Association with create + draft
```abap
association _POItem { create; with draft; }
```
Allows creating items from the header **and** supports draft for the child.

### Determination
```abap
determination SetInitialStatus on save { create; }
```
- **When**: On save, only for newly created instances.
- **What**: Sets default status = `'N'`.
- **Why**: Business rule – every new PO starts as “New / Pending”.

### Validation
```abap
validation ValidateTotalAmount on save { create; update; }
```
- **When**: On every save (create + update).
- **What**: Rejects POs whose `total_amount <= 0`.
- **Why**: Simple but important business rule.

### Custom Action
```abap
action setComplete result [1] $self;
```
- **Why**: Business action “Mark as Completed”.
- **Function**: Changes status to `'C'` and returns the updated instance.
- **Relevance**: Demonstrates non-standard operations beyond CRUD.

### Draft Actions
```abap
draft action Edit;
draft action Activate optimized;
draft action Discard;
draft action Resume;
draft determine action Prepare { validation ValidateTotalAmount; }
```
Standard draft lifecycle. `Prepare` re-runs the validation before activation.

### Mapping
```abap
mapping for ztb_po_hdr { ... }
```
Explicit field mapping between CDS entity and database table (good practice, especially when names differ).

### Child Entity (ZI_PoItem)
- `lock dependent` / `authorization dependent` – inherits from parent.
- Only `update` + `delete` (no independent create – create is done via parent association).
- Keys (`po_id`, `item_id`) are readonly.

## Linked Objects
- **Behavior Implementation**: [[17-ZBP_I_PROCUREORDERCOMP]]
- **Projection Behavior**: [[16-ZC_ProcureOrder-BDEF]]
- **Persistent tables**: [[01-ZTB_PO_HDR]], [[02-ZTB_PO_ITEM]]
- **Draft tables**: [[18-Draft-Tables]]
- **Root CDS**: [[05-ZI_ProcureOrderComp]]

## Relevance
This file turns the pure CDS data model into a full **RAP Business Object** with draft, validations, determinations and actions – the foundation of modern S/4HANA transactional applications.
