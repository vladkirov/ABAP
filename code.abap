      SELECT DISTINCT
          equnr,
          zztype01
        FROM ztpm_equip_plan AS plan
        WHERE equnr IN @lr_equnr
          AND datab > @iv_date
        INTO TABLE @lt_eq_plan.

      DATA(lt_eq_plan_wo_zztype) =
        filter tt_tpo_eq_plan( lt_eq_plan EXCEPT in mt_data WHERE equnr  = equnr
                                                              and zztype = zztype01 ).
      
      DATA(lt_equnr_type) = CORRESPONDING tt_r_equnr( mt_data from lt_equnr_type USING ).
=========
   DATA(lr_equnr) =  VALUE tt_r_equnr( FOR <lv_equnr> IN iht_equnr
                                          sign = 'I' option = 'EQ' ( low = <lv_equnr> ) ).

=========
    SELECT DISTINCT
        'I' AS sign,
        'EQ' AS option,
        equnr AS low,
        @abap_false AS high
      FROM ztpm_equip_plan AS plan
      WHERE equnr IN @lr_equnr
        AND datab > @iv_date
      INTO TABLE @er_equnr.

=========
        lr_packs = VALUE #( FOR <ls_auf> IN lt_afvgd
                            WHERE ( packno IS NOT INITIAL )
                            sign = 'I' option = 'EQ' ( low = <ls_auf>-packno ) ).
        SORT lr_packs BY low ASCENDING.
        DELETE ADJACENT DUPLICATES FROM lr_packs.

=========		
      lr_objnr = VALUE #( FOR <ls_resb> IN mst_resb ( sign = 'I'
                                                      option = 'EQ'
                                                      low = <ls_resb>-objnr ) ).		
													  
========
    DATA lr_matnr TYPE RANGE OF matnr.

    lr_matnr = VALUE #( FOR <ls_bseg> IN it_bseg
                        ( sign   = 'I'
                          option = 'EQ'
                          low    = <ls_bseg>-matnr  ) ).

    DELETE ADJACENT DUPLICATES FROM lr_matnr COMPARING low.
    
========	
1)	count lines in internal table with where condition
SELECT *
 FROM mara
 INTO TABLE @DATA(lt_mara)
 UP TO 10 ROWS.

DATA(lv_count) = REDUCE i( INIT i = 0 FOR wa IN lt_mara WHERE ( aenam EQ 'MARSLAN' ) NEXT i = i + 1 ).

TYPES:
  BEGIN OF ty_material,
    matnr TYPE char40,
    maktx     TYPE char40,
    matkl     TYPE char9,
  END   OF ty_material.
DATA: lt_materials TYPE STANDARD TABLE OF ty_material.
TYPES: tt_mara TYPE TABLE OF mara WITH EMPTY KEY.
DATA(count) = lines( VALUE tt_mara( FOR line IN lt_mara WHERE ( matnr = 'XXX' ) ( line ) ) ).
========

2)	get the unique material groups, use WITHOUT MEMBERS
LOOP AT lt_materials INTO DATA(ls_materials)
     GROUP BY  ( matkl = ls_materials-matkl size = GROUP SIZE )
      ASCENDING
      WITHOUT MEMBERS
      REFERENCE INTO DATA(matkl_group).
 
  WRITE: / matkl_group->matkl, matkl_group->size.
========

3)	    " Сгруппировать по ключу, создать новую строку в таблице экспортной и суммировать количество
    LOOP AT lst_orders_cleared ASSIGNING FIELD-SYMBOL(<ls_order_clear>)
        GROUP BY ( matnr   = <ls_order_clear>-matnr
                   werks   = <ls_order_clear>-werks
                   umwrk   = <ls_order_clear>-umwrk
                   umlgo   = <ls_order_clear>-umlgo )
        ASSIGNING FIELD-SYMBOL(<ls_clear_group>).

      DATA(ls_order_pm) = REDUCE lts_orders_pm_raw(
        INIT ls_sum = CORRESPONDING lts_orders_pm_raw( <ls_clear_group> )
        FOR <ls_member> IN GROUP <ls_clear_group>
        NEXT ls_sum-vmeng = ls_sum-vmeng + <ls_member>-vmeng - <ls_member>-enmng ).

      INSERT CORRESPONDING #( ls_order_pm MAPPING menge = vmeng ) INTO TABLE est_orders_pm.
    ENDLOOP.
========

4)   DATA(lst_obj_stat) =
        VALUE ltt_obj_stat(
          FOR <ls_os> IN CORRESPONDING ltt_obj_stat_h( lst_orders_pm_raw DISCARDING DUPLICATES ) (
            objnr = COND #( WHEN check_order_finish_status( iv_objnr = <ls_os>-objnr
                                                            iv_stsma = <ls_os>-stsma )
                            THEN <ls_os>-objnr
                            ELSE abap_true )
            stsma = <ls_os>-stsma
          )
        ).
========

5)	lr_matnr = VALUE #( ( sign   = 'E' option = 'CP' low = '*' )  ).
zcl_generic=>add2range( exporting i_sign = 'E' i_option = 'CP' i_low = '*' changing ct_range = <lt_table> ).
========

6)	Поиск максимума в структуре:
  DATA(ls_maximum) = REDUCE lts_kurztext(
                       INIT ls_max = VALUE lts_kurztext( )
                       FOR <ls_text> IN lt_texts
                       NEXT ls_max = nmax( val1 = <ls_text>-version
   val2 = ls_max-version ) ).
