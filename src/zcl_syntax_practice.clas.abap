CLASS zcl_syntax_practice DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_syntax_practice IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

* Inline declaration
    DATA(l_v_name) = 'Shekhar Suman'.
    out->write( l_v_name ).

* Select Statement with Inline declaration
    SELECT SINGLE currency,
                  decimals
           FROM i_currency
           WHERE currency = 'USD'
           INTO @DATA(l_wa_currency).

    out->write( |Select output { l_wa_currency-Currency } { l_wa_currency-Decimals } | ).

* Select Statement with Inline declaration
    SELECT SINGLE currency AS money,
                  decimals AS value
           FROM i_currency
           WHERE currency = 'USD'
           INTO @DATA(l_wa_icurrency).

    out->write( |Select output { l_wa_icurrency-money } { l_wa_icurrency-value } | ).

******************************************************************************************
* 01+practiceCode

    SELECT *
        FROM i_currency
        INTO TABLE @DATA(l_i_ekko)
        UP TO 10 ROWS.

    LOOP AT l_i_ekko ASSIGNING FIELD-SYMBOL(<l_fs_ekko>).
      out->write( |{ <l_fs_ekko>-Currency } { <l_fs_ekko>-CurrencyISOCode } { <l_fs_ekko>-Decimals } | ).
    ENDLOOP.

******************************************************************************************

* Reading a row from internal table

    DATA(idx) = sy-tabix.
    IF line_exists( l_i_ekko[ idx ] ).
      DATA(wa1) = l_i_ekko[ 1 ].
      out->write( |{ wa1-Currency } { wa1-CurrencyISOCode }| ).
    ENDIF.

* Concatenate of string

    DATA(l_v_string) = |Sample String concatenate | && wa1-Currency && | The return code is { sy-subrc } |.
    out->write( l_v_string ).

* Alpha formatting

    DATA(value1) = '00000012345'.
    DATA(outvalue1) = | { value1 ALPHA = OUT } |.
    DATA(outvalue2) = | { outvalue1 ALPHA = IN } |.

    CONDENSE outvalue1.
    out->write( | { outvalue1 } is getting converted to  { outvalue2 } | ).

* Conversion Operator

    DATA: cust_name TYPE c LENGTH 30 VALUE 'Shekhar Suman'.

    DATA(str1) = CONV string( cust_name ).

    out->write( | The value is { str1 } and it's type is { cl_abap_typedescr=>describe_by_data( str1 )->type_kind } | ).

* Casting

*    DATA(components) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( 'ZBP_STRUCT' ) )->components.

* Value operator

    TYPES: l_r_tab TYPE RANGE OF STRing.
    DATA: l_r_tabtype TYPE l_r_tab.

    l_r_tabtype = VALUE #( ( sign = 'I' option = 'EQ' low = 'Hello' )
                       ( sign = 'I' option = 'GT' low = 'World' ) ).

    LOOP AT l_r_tabtype ASSIGNING FIELD-SYMBOL(<l_fs_tab>).
      out->write( | { <l_fs_tab>-low } | ).
    ENDLOOP.

* FOR operator

    DATA(l_i_tablevalues) = VALUE L_r_tab( FOR l_wa_tab IN l_r_tabtype WHERE ( low EQ 'Hello' ) ( l_wa_tab ) ).

    LOOP AT l_i_tablevalues ASSIGNING FIELD-SYMBOL(<l_fs_tablevalues>).
      out->write( | { <l_fs_tablevalues>-low } | ).
    ENDLOOP.

* Reduce operator
    DATA(l_v_lines) = REDUCE i( INIT x = 0 FOR l_wa_tab IN l_r_tabtype NEXT x = x + 1 ).
    out->write( | { l_v_lines } | ).

* Conditional operator
    DATA(l_v_cond) = COND #( WHEN <l_fs_tablevalues>-low EQ 'Hello'
                             THEN | It is hello. |
                             WHEN <l_fs_tablevalues>-low EQ 'World'
                             THEN | World is ending. |
                           ).

    out->write( |{ l_v_cond }| ).

* Corresponding Operator

    TYPES: BEGIN OF l_ty_type,
             val1 TYPE c LENGTH 2,
             val2 TYPE c LENGTH 2,
             val3 TYPE c LENGTH 2,
           END OF l_ty_type,
           l_ty_t_type TYPE STANDARD TABLE OF l_ty_type WITH EMPTY KEY.
    DATA: l_wa_tp1 TYPE l_ty_type,
          l_wa_tp2 TYPE l_ty_type,
          l_i_tp   TYPE l_ty_t_type.

    l_wa_tp1-val1 = 'AB'.
    l_wa_tp1-val2 = 'BC'.
    l_wa_tp1-val3 = 'CD'.

    l_wa_tp2-val1 = 'EF'.
    l_wa_tp2-val2 = 'GH'.

    l_i_tp = VALUE l_ty_t_type( ( l_wa_tp1 ) ( l_wa_tp2 ) ).

    DATA(l_i_ftp2) = CORRESPONDING l_ty_t_type( l_i_tp MAPPING val1 = val1 ).

    LOOP AT l_i_ftp2 ASSIGNING FIELD-SYMBOL(<l_fs_ftp2>).
      out->write( | { <l_fs_ftp2>-val1 } :: { <l_fs_ftp2>-val2 } :: { <l_fs_ftp2>-val3 } | ).
    ENDLOOP.

    DATA(l_wa_ftp1) = CORRESPONDING l_ty_type( BASE ( l_wa_tp1 ) l_wa_tp2 EXCEPT val3 ).

    out->write( | { l_wa_ftp1-val1 } :: { l_wa_ftp1-val2 } :: { l_wa_ftp1-val3 } | ).

* Object creation using new syntax

    DATA: l_o_obj TYPE REF TO zcl_0001_flight.
    TRY.
        l_o_obj = NEW #( carrier_id = 'AA'
                         connection_id = '0017'
                         plane_type = '747-400' ).
        DATA(l_o_obj2) = NEW zcl_0001_flight( carrier_id = 'AA'
                         connection_id = '0017'
                         plane_type = '747-400' ).
        NEW zcl_0001_flight( carrier_id = 'AA'
                         connection_id = '0017'
                         plane_type = '747-400' ).
      CATCH cx_root.
    ENDTRY.

* Select statement for modern abap

*    SELECT FROM i_table
*    FIELDS field1,
*           field2,
*           field3
*    INTO TABLE @DATA(l_i_table)
*    UP TO 10 ROWS.

  ENDMETHOD.
ENDCLASS.
