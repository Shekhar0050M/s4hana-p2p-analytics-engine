@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item Storage'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_PoItem 
  as select from ztb_po_item
  association to parent ZI_ProcureOrderComp as _ProcureOrderComp on $projection.po_id = _ProcureOrderComp.po_id
{
    key po_id,
    key item_id,
    material,
    
    @Semantics.quantity.unitOfMeasure: 'unit'
    quantity, 
    unit,
    
    _ProcureOrderComp
}
