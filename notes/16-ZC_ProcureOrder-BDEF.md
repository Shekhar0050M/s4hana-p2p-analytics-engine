# ZC_ProcureOrder – Behavior Projection (BDEF)

**Type**: Behavior Definition – Projection  
**Layer**: RAP Consumption / UI  
**File**: `src/zc_procureorder.bdef.asbdef`

## Purpose
Projects the interface behavior definition onto the consumption views.  
Only the operations that should be available in the UI / OData service are exposed here.

## Full Source Code

```abap
projection;
use draft;
//strict ( 2 );

define behavior for ZC_ProcureOrder alias PurchaseOrder
{
  use create;
  use update;
  use delete;

  use association _POItem { create; with draft; }

  use action setComplete;
}

define behavior for ZC_PoItem01 alias POItem
{
  use update;
  use delete;

  use association _ProcureOrderComp { with draft; }
}
```

## Block-by-Block Explanation

### Projection Header
```abap
projection;
use draft;
```
- **`projection`** – This BDEF is a projection of another (interface) BDEF.
- **`use draft`** – Draft capabilities are enabled on the consumption layer as well.

### Root Projection
```abap
define behavior for ZC_ProcureOrder alias PurchaseOrder
{
  use create;
  use update;
  use delete;

  use association _POItem { create; with draft; }

  use action setComplete;
}
```
- **`use ...`** – Re-uses the corresponding operation defined in the interface BDEF.
- Only the operations listed here become available in the OData service / Fiori UI.
- The custom action `setComplete` is explicitly exposed so the UI button works.

### Item Projection
```abap
define behavior for ZC_PoItem01 alias POItem
{
  use update;
  use delete;
  use association _ProcureOrderComp { with draft; }
}
```
Items can be updated/deleted; create is only possible via the parent association.

## Why a separate Projection BDEF?

| Reason | Benefit |
|--------|---------|
| Separation of concerns | Interface BDEF = full business logic; Projection = what the UI is allowed to do |
| Security | You can hide create/delete/actions from certain projections |
| UI-specific actions | Different UIs can expose different subsets of actions |
| Draft support | Draft is activated independently on the projection layer |

## Linked Objects
- **Projects from**: [[15-ZI_ProcureOrderComp-BDEF]]
- **CDS Projections**: [[10-ZC_ProcureOrder]], [[11-ZC_PoItem01]]
- **Implementation**: still the same class [[17-ZBP_I_PROCUREORDERCOMP]]

## Relevance
Without this projection BDEF the OData service would not expose any transactional operations (create, update, delete, actions, draft).  
It is the final link between the RAP BO and the Fiori Elements UI.
