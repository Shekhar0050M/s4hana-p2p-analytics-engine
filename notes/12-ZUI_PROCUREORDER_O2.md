# ZUI_PROCUREORDER_O2

**Type**: Service Definition (SRVD)  
**Layer**: Service / OData  
**File**: `src/zui_procureorder_o2.srvd.srvdsrv` (+ .xml)

## Purpose
Exposes the consumption views as an **OData V4** service that can be consumed by Fiori Elements, SAP Build, or any OData client.

## Full Source Code

```abap
@EndUserText.label: 'Odata service for Purchase order'
define service ZUI_PROCUREORDER_O2 {
  expose ZC_ProcureOrder    as PurchaseOrder;
  expose ZC_PoItem01        as PurchaseOrderitem;
  expose ZC_VendorAnalytics as VendorAnalytics;
}
```

## Block-by-Block Explanation

```abap
define service ZUI_PROCUREORDER_O2 {
```
- **Why**: Modern replacement for the old SEGW / Service Builder projects.  
- **Function**: Declares a service that will be bound later (Service Binding).  
- **Relevance**: Clean, code-based definition of the OData service.

```abap
expose ZC_ProcureOrder    as PurchaseOrder;
expose ZC_PoItem01        as PurchaseOrderitem;
expose ZC_VendorAnalytics as VendorAnalytics;
```
- **Why**: Only the consumption views should be exposed (never the interface or composite views directly).  
- **Function**:  
  - `expose` makes the entity available in the service.  
  - `as <Alias>` gives a nice, business-friendly name in the OData metadata.  
- **Relevance**: The alias becomes the EntitySet name that UI developers see.

## Linked Objects
- **Exposes**:
  - [[10-ZC_ProcureOrder]]
  - [[11-ZC_PoItem01]]
  - [[09-ZC_VendorAnalytics]]

## Relevance
This is the final “publish” step.  
Once a **Service Binding** (usually of type OData V4 – UI) is created on top of this definition, the service is ready to be used by a Fiori Elements application.
