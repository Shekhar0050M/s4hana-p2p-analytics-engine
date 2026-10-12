# ZC_ProcureOrder – Consumption / Projection View

**Type**: Projection View Entity (transactional_query)  
**File**: `src/zc_procureorder.ddls.asddls`  
**Last Updated**: October 12, 2026

## Purpose

UI-facing projection of the Purchase Order Business Object.
Contains almost all Fiori Elements annotations:
- Header DataPoints / KPIs
- Charts and Presentation Variants
- Line items, facets, search
- Criticality
- Value Helps
- Action buttons

## Key Annotation Highlights (current state)

### Header DataPoints (shown in Object Page header)
```abap
@UI.facet: [
  { id: 'HeaderStatus',     purpose: #HEADER, type: #DATAPOINT_REFERENCE, targetQualifier: 'StatusHeaderDP',     position: 10 },
  { id: 'HeaderTotalSpend', purpose: #HEADER, type: #DATAPOINT_REFERENCE, targetQualifier: 'TotalSpendDataPoint', position: 20 },
  { id: 'HeaderOrderTier',  purpose: #HEADER, type: #DATAPOINT_REFERENCE, targetQualifier: 'OrderTierHeaderDP',  position: 30 },
  { id: 'HeaderCreatedOn',  purpose: #HEADER, type: #DATAPOINT_REFERENCE, targetQualifier: 'CreatedDateHeaderDP', position: 40 },
  ...
]
```

### Charts
- `POByStatus` – Column chart of total amount by status
- `POByTier`  – Column chart of total amount by order tier

### Presentation Variants
- `TableView`
- `ChartView` (by Status)
- `TierChartView` (by Tier)

### Criticality
```abap
@UI.dataPoint: {
  qualifier: 'StatusHeaderDP',
  title: 'Lifecycle Status',
  criticality: 'status_criticality'
}
status_text,

@UI.lineItem: [{ position: 70, criticality: 'order_tier_criticality' }]
@UI.dataPoint: {
  qualifier: 'OrderTierHeaderDP',
  title: 'Order Spend Tier',
  criticality: 'order_tier_criticality'
}
order_tier,
```

### Value Helps
```abap
@Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_Vendor01', element: 'vendor_id' } }]
vendor_id,

@Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
currency_code,
```

### Actions
Actions are exposed via `@UI.identification` with `#FOR_ACTION` (and controlled by instance features from the BDEF).

## Relevance

This view turns the pure business object into a rich Fiori Elements experience **without custom UI5 coding**.  
Almost every visual element the user sees (KPIs, colors, charts, value helps, buttons) is driven from annotations defined here + the app descriptor.

## Linked Objects
- Base: [[05-ZI_ProcureOrderComp]]
- Behavior Projection: [[16-ZC_ProcureOrder-BDEF]]
- Service: [[12-ZUI_PROCUREORDER_O2]]
- Latest UI work: [[21-Latest-Enhancements-Oct2026]]
- Original Chart/KPI note: [[20-UI-Chart-KPI-Changes]]
