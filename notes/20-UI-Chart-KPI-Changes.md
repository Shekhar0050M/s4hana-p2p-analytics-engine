# UI Chart + KPI Enhancements (Sep 14, 2026)

## What was added

The Fiori Elements List Report was enhanced with **analytical chart visualization** and a **KPI tile** for total purchase spend. This turns the transactional RAP app into a hybrid analytical + transactional experience without custom UI5 coding.

| Capability | Where | Status |
|------------|-------|--------|
| Column Chart by Status | `@UI.chart` on `ZC_ProcureOrder` | ✅ |
| Chart / Table toggle | `@UI.presentationVariant` + `quickVariantSelectionX` | ✅ |
| DataPoint for KPI | `@UI.dataPoint` on `total_amount` | ✅ |
| KPI tile on List Report | `kpis` section in `manifest.json` | ✅ |

## Changed Files

```
src/
└── zc_procureorder.ddls.asddls          ← @UI.chart, @UI.presentationVariant, @UI.dataPoint

app/procureorderanalysis/webapp/
└── manifest.json                        ← quickVariantSelectionX + kpis configuration
```

## CDS Annotations (ZC_ProcureOrder)

### 1. Chart Definition
```abap
@UI.chart: [{
    qualifier: 'POByStatus',
    chartType: #COLUMN,
    dimensions: [ 'status_text' ],
    measures: [ 'total_amount' ],
    dimensionAttributes: [{
        dimension: 'status_text',
        role: #CATEGORY
    }],
    measureAttributes: [{
        measure: 'total_amount',
        role: #AXIS_1
    }]
}]
```
- **Qualifier** `POByStatus` is the key used later by the presentation variant.
- **Chart type** `#COLUMN` → classic column/bar chart.
- **Dimension** `status_text` becomes the X-axis categories (Approved / New / Rejected / Completed …).
- **Measure** `total_amount` is aggregated on the Y-axis.

### 2. Presentation Variants (Chart vs Table)
```abap
@UI.presentationVariant: [{
    qualifier: 'ChartView',
    text: 'Chart',
    visualizations: [{ type: #AS_CHART, qualifier: 'POByStatus' }]
},
{
    qualifier: 'TableView',
    text: 'Table',
    visualizations: [{ type: #AS_LINEITEM }]
}]
```
- Two named variants the user can switch between.
- `ChartView` points to the chart qualifier defined above.
- `TableView` falls back to the standard line-item table.

### 3. DataPoint (KPI source)
```abap
@UI.dataPoint: {
    qualifier: 'TotalSpendDataPoint',
    title: 'Total Purchase Spend'
}
total_amount,
```
- Marks the field as a KPI-capable value.
- The qualifier is referenced from the app descriptor.

## App Descriptor (manifest.json)

### quickVariantSelectionX – Chart / Table toggle
```json
"quickVariantSelectionX": {
  "showTablePersonalisation": true,
  "enableAutoBinding": true,
  "variants": {
    "1": {
      "key": "TableView",
      "annotationPath": "com.sap.vocabularies.UI.v1.PresentationVariant#TableView"
    },
    "2": {
      "key": "ChartView",
      "annotationPath": "com.sap.vocabularies.UI.v1.PresentationVariant#ChartView"
    }
  }
}
```
- Renders a segmented button / variant selector on the List Report.
- User can instantly switch between Table and Chart views of the same entity set.
- `enableAutoBinding: true` ensures data is loaded automatically when the variant changes.

### KPI Configuration
```json
"kpis": {
  "TotalSpendKPI": {
    "model": "",
    "entitySet": "PurchaseOrder",
    "qualifier": "TotalSpendDataPoint",
    "id": "TotalSpendKPI",
    "navigation": "toDetails"
  }
}
```
- Creates a KPI tile titled **“Total Purchase Spend”**.
- Bound to the DataPoint annotation on `total_amount`.
- Clicking the KPI navigates into the details (Object Page).

## How it works at runtime

1. Fiori Elements reads the `@UI.chart` and `@UI.presentationVariant` annotations from the OData metadata of `ZC_ProcureOrder`.
2. The List Report renders either the responsive table or the column chart depending on the selected presentation variant.
3. The KPI tile aggregates / displays the total spend value using the DataPoint definition.
4. No custom controller or view coding is required – pure annotation + manifest driven.

## Key Learning Points Demonstrated

1. **@UI.chart** – declarative chart definition on a CDS projection.
2. **@UI.presentationVariant** – multiple visualizations for the same entity set.
3. **quickVariantSelectionX** – user-facing Chart ↔ Table switcher in List Report.
4. **@UI.dataPoint** + **kpis** in manifest – KPI tile without Smart Chart or custom coding.
5. Hybrid **transactional + analytical** List Report on top of a RAP Business Object.

## Related Notes
- [[10-ZC_ProcureOrder]] – full updated source of the consumption view
- [[12-ZUI_PROCUREORDER_O2]] – service that exposes the entity
- [[19-RAP-Changes-Summary]] – previous RAP transactional enhancements

## Updated Architecture Snapshot (UI layer)

```
Consumption / UI Layer
└── ZC_ProcureOrder
    ├── Facets + LineItems + Search (existing)
    ├── Action button “Set Complete” (existing)
    ├── @UI.chart #POByStatus          ← NEW
    ├── @UI.presentationVariant        ← NEW (ChartView / TableView)
    └── @UI.dataPoint TotalSpendDataPoint ← NEW

Fiori App (manifest.json)
└── ListReport|PurchaseOrder
    ├── quickVariantSelectionX         ← NEW (Table ↔ Chart)
    └── kpis.TotalSpendKPI             ← NEW
```
