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
