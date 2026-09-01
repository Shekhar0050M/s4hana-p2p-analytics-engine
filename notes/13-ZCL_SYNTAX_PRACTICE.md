# ZCL_SYNTAX_PRACTICE

**Type**: ABAP Class (Executable via ADT Class Run)  
**Layer**: Learning / Practice  
**File**: `src/zcl_syntax_practice.clas.abap`

## Purpose
A playground class that demonstrates many modern ABAP language features (7.40+ / 7.50+ / 7.54+).  
Almost all statements are commented out – it is meant for experimentation.

## Key Topics Covered (from the commented code)

| Topic | Example Syntax | Why it is useful |
|-------|----------------|------------------|
| Inline Declaration | `DATA(l_v_name) = '...'` | No need to declare variables at the top |
| Inline in SELECT | `INTO @DATA(l_wa_...)` | Cleaner SELECT statements |
| Field Symbols | `ASSIGNING FIELD-SYMBOL(<fs>)` | Avoid unnecessary data copies |
| String Templates | `\|Hello { var }\|` | Modern string building |
| ALPHA conversion | `\|{ value ALPHA = OUT }\|` | Easy conversion of leading zeros |
| CONV operator | `CONV string( ... )` | Explicit type conversion |
| VALUE operator | `VALUE #( ( ... ) ( ... ) )` | Construct internal tables & structures |
| FOR operator | `VALUE #( FOR ... IN ... WHERE ... )` | Functional-style filtering / mapping |
| REDUCE operator | `REDUCE i( INIT x = 0 FOR ... NEXT ... )` | Aggregate without LOOP |
| COND operator | `COND #( WHEN ... THEN ... )` | Expression-based IF |
| CORRESPONDING | `CORRESPONDING ... ( ... MAPPING ... )` | Powerful structure mapping |
| NEW operator | `NEW classname( ... )` | Object creation without CREATE OBJECT |

## Relevance in this project
This class is **not part of the productive P2P engine**.  
It was used by the developer (Shekhar) to practice and internalise modern ABAP syntax while building the rest of the objects.  
It is kept in the repository as a learning artefact.

## Linked Objects
None (standalone practice class).
