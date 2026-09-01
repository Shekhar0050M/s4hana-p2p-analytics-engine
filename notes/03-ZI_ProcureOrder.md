# ZI_ProcureOrder

**Type**: CDS View Entity (Interface / Basic)  
**Layer**: Interface  
**File**: `src/zi_procureorder.ddls.asddls`

## Purpose
Clean interface view over the header table.  
Exposes only the fields that are needed by higher layers and applies basic semantic annotations.

## Full Source Code

```abap
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Header Tabl'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_ProcureOrder
  as select from ztb_po_hdr
{
  key po_id,
      vendor_name,
      
      @Semantics.amount.currencyCode: 'currency_code'
      total_amount,
      
      currency_code,
      status,
      created_at
}
```

## Block-by-Block Explanation

### Annotations at the top
```abap
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Header Tabl'
@Metadata.ignorePropagatedAnnotations: true
```
- **`viewEnhancementCategory: [#NONE]`**  
  Why: Prevents other developers from extending this view via CDS extensions.  
  Function: Locks the view structure.  
  Relevance: Interface views are usually kept stable; extensions belong in higher layers.

- **`authorizationCheck: #NOT_REQUIRED`**  
  Why: For learning / demo purposes we skip DCL.  
  Function: No authority check is generated.  
  Relevance: In productive code you would use `#CHECK` + a DCL.

- **`ignorePropagatedAnnotations: true`**  
  Why: We do not want annotations from the table (or lower views) to bubble up automatically.  
  Function: Clean slate for annotations.  
  Relevance: Gives full control to the developer of this view.

### View definition
```abap
define view entity ZI_ProcureOrder
  as select from ztb_po_hdr
```
- **`define view entity`** (instead of classic `define view`)  
  Why: Modern CDS syntax required for RAP, compositions, projections, etc.  
  Function: Creates a CDS View Entity.  
  Relevance: Mandatory for the rest of the stack (composite, projection, service).

### Field list
```abap
key po_id,
    vendor_name,
    
    @Semantics.amount.currencyCode: 'currency_code'
    total_amount,
    
    currency_code,
    status,
    created_at
```
- **`key po_id`**  
  Why: Declares the primary key of the view.  
  Function: Enables key-based navigation and uniqueness.  
  Relevance: Required for compositions and associations later.

- **`@Semantics.amount.currencyCode: 'currency_code'`**  
  Why: Tells the framework that `total_amount` is a currency amount whose currency is stored in `currency_code`.  
  Function: Enables correct formatting, currency conversion, and analytical behaviour.  
  Relevance: Without this annotation, amount fields are treated as plain decimals.

## Linked Objects
- **Source**: [[01-ZTB_PO_HDR]]
- **Used by**: [[05-ZI_ProcureOrderComp]] (the composite root)

## Relevance
This is the purest “interface” view.  
It contains **no business logic**, only a clean projection of the table + one semantic annotation.  
All calculated fields and associations live in the composite layer above it.
