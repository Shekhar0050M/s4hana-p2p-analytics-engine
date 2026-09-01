# ZC_PoItem01

**Type**: CDS View Entity (Projection)  
**Layer**: Consumption / UI  
**File**: `src/zc_poitem01.ddls.asddls`

## Purpose
UI projection for Purchase Order items.  
Adds line-item annotations and correctly redirects the parent association back to the header projection.

## Full Source Code

```abap
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define view entity ZC_PoItem01
  as projection on ZI_PoItem
{
  key po_id,

  @UI.lineItem: [{ position: 10, label: 'Item' }]
  key item_id,

  @UI.lineItem: [{ position: 20, label: 'Material' }]
  material,

  @Semantics.quantity.unitOfMeasure: 'unit'
  @UI.lineItem: [{ position: 30, label: 'Quantity' }]
  quantity,

  @UI.lineItem: [{ position: 40, label: 'Unit' }]
  unit,

  /* MUST point to the parent projection */
  _ProcureOrderComp: redirected to parent ZC_ProcureOrder
}
```

## Block-by-Block Explanation

### Projection
```abap
as projection on ZI_PoItem
```
Same principle as the header – keep UI annotations out of the interface layer.

### Line Item Annotations
```abap
@UI.lineItem: [{ position: 10, label: 'Item' }]
```
- **Why**: Controls the order and label of columns when the items are shown as a table (inside the Object Page facet).  
- **Function**: Pure UI metadata.  
- **Relevance**: Without these annotations the table would still appear, but with technical field names.

### Critical Parent Redirect
```abap
_ProcureOrderComp: redirected to parent ZC_ProcureOrder
```
- **Why**: The original association in `ZI_PoItem` points to `ZI_ProcureOrderComp`.  
  In the UI layer we must redirect it to the *projection* of the parent.  
- **Function**: Maintains the composition navigation path on the consumption layer.  
- **Relevance**: If you forget this redirect, the framework cannot correctly navigate from item back to header (and vice-versa) in the UI.

## Linked Objects
- **Projection on**: [[04-ZI_PoItem]]
- **Parent**: [[10-ZC_ProcureOrder]]
- **Exposed by**: [[12-ZUI_PROCUREORDER_O2]]

## Relevance
Completes the Header–Item hierarchy on the UI layer.  
Together with the redirect in `ZC_ProcureOrder` it forms a consistent RAP projection tree.
