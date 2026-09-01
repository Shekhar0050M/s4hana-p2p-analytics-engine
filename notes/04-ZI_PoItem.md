# ZI_PoItem

**Type**: CDS View Entity (Interface)  
**Layer**: Interface  
**File**: `src/zi_poitem.ddls.asddls`

## Purpose
Interface view for PO items.  
Also declares the **parent association** that will later become part of the composition hierarchy.

## Full Source Code

```abap
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item Storage'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_PoItem 
  as select from ztb_po_item
  association to parent ZI_ProcureOrderComp as _ProcureOrderComp 
    on $projection.po_id = _ProcureOrderComp.po_id
{
    key po_id,
    key item_id,
    material,
    
    @Semantics.quantity.unitOfMeasure: 'unit'
    quantity, 
    unit,
    
    _ProcureOrderComp
}
```

## Block-by-Block Explanation

### Parent Association
```abap
association to parent ZI_ProcureOrderComp as _ProcureOrderComp 
  on $projection.po_id = _ProcureOrderComp.po_id
```
- **`association to parent`**  
  Why: Required when the child participates in a **composition**.  
  Function: Tells the RAP runtime / CDS framework that this view is a child of `ZI_ProcureOrderComp`.  
  Relevance: Without the `to parent` keyword the composition relationship cannot be established correctly.

- **`$projection.po_id`**  
  Why: Refers to the field of the *current* view (not the source table).  
  Function: Makes the join condition independent of field renaming.  
  Relevance: Best practice for maintainability.

### Semantic Annotation for Quantity
```abap
@Semantics.quantity.unitOfMeasure: 'unit'
quantity,
```
- Why: Same principle as amount/currency – quantity must know its unit.  
- Function: Enables correct UoM handling in UI and analytics.  
- Relevance: Fiori Elements and analytical engines rely on this annotation.

### Exposure of the association
```abap
_ProcureOrderComp
```
- Why: The association must be listed in the field list to be usable by higher layers.  
- Function: Makes the navigation path available.  
- Relevance: The projection view later redirects this association.

## Linked Objects
- **Source table**: [[02-ZTB_PO_ITEM]]
- **Parent**: [[05-ZI_ProcureOrderComp]]
- **Projected by**: [[11-ZC_PoItem01]]

## Relevance
This view is the technical foundation of the **item side** of the Business Object.  
The combination of `association to parent` here + `composition` in the header view creates the classic Header–Item hierarchy.
