 <PROG NAME="ZPM_CRT_FILE_TK_STATIC_GHZ" VARCL="X" SUBC="1" APPL="I" RSTAT="K" RMAND="101" RLOAD="R" FIXPT="X" UCCHECK="X">
  <textPool>
   <language SPRAS="R">
    <textElement ID="R" ENTRY="Формирование файлов для загрузки ТК по статике ГХЗ" LENGTH="50 "/>
    <textElement ID="S" KEY="FILE1" ENTRY="        Выберите файл заголовков ТК:" LENGTH="36 "/>
    <textElement ID="S" KEY="FILE1_1" ENTRY="        Выберите файл заголовков ТК 1:" LENGTH="38 "/>
    <textElement ID="S" KEY="FILE1_2" ENTRY="        Выберите файл заголовков ТК 2:" LENGTH="38 "/>
    <textElement ID="S" KEY="FILE1_3" ENTRY="        Выберите файл заголовков ТК 3:" LENGTH="38 "/>
    <textElement ID="S" KEY="FILE1_4" ENTRY="        Выберите файл заголовков ТК 4:" LENGTH="38 "/>
    <textElement ID="S" KEY="FILE2" ENTRY="        Выберите файл операций ТК:" LENGTH="34 "/>
    <textElement ID="S" KEY="FILE2_1" ENTRY="        Выберите файл операций ТК 1:" LENGTH="36 "/>
    <textElement ID="S" KEY="FILE2_2" ENTRY="        Выберите файл операций ТК 2:" LENGTH="36 "/>
    <textElement ID="S" KEY="FILE2_3" ENTRY="        Выберите файл операций ТК 3:" LENGTH="36 "/>
    <textElement ID="S" KEY="FILE2_4" ENTRY="        Выберите файл операций ТК 4" LENGTH="35 "/>
    <textElement ID="S" KEY="FILE3" ENTRY="        Выберите файл МиМ операц. ТК:" LENGTH="37 "/>
    <textElement ID="S" KEY="FILE3_1" ENTRY="        Выберите файл МиМ операц. ТК 1" LENGTH="38 "/>
    <textElement ID="S" KEY="FILE3_2" ENTRY="        Выберите файл МиМ операц. ТК 2" LENGTH="38 "/>
    <textElement ID="S" KEY="FILE3_3" ENTRY="        Выберите файл МиМ операц. ТК 3" LENGTH="38 "/>
    <textElement ID="S" KEY="FILE3_4" ENTRY="        Выберите файл МиМ операц. ТК 4" LENGTH="38 "/>
    <textElement ID="S" KEY="PNAMEFM" ENTRY="        Выберите файл материал. опер" LENGTH="36 "/>
    <textElement ID="S" KEY="PNAMEF_1" ENTRY="        Выберите файл материал. опер 1" LENGTH="38 "/>
    <textElement ID="S" KEY="PNAMEF_2" ENTRY="        Выберите файл материал. опер 2" LENGTH="38 "/>
    <textElement ID="S" KEY="PNAMEF_3" ENTRY="        Выберите файл материал. опер 3" LENGTH="38 "/>
    <textElement ID="S" KEY="PNAMEF_4" ENTRY="        Выберите файл материал. опер 4" LENGTH="38 "/>
   </language>
  </textPool>
  <source>*&amp;---------------------------------------------------------------------*
*&amp; Report  ZPM_CRT_FILE_TK_STATIC_GHZ
*&amp;
*&amp;---------------------------------------------------------------------*
*&amp;
*&amp;
*&amp;---------------------------------------------------------------------*

REPORT  ZPM_CRT_FILE_TK_STATIC_GHZ.

TYPES: BEGIN OF head_stat_ghz_table_type,
  number_tk(10) TYPE c,&quot;НОМЕР ТЕХНОЛОГИЧЕСКОЙ КАРТЫ
  marka(60) TYPE c,&quot;МАРКА
  name_tk(65) TYPE c,&quot;НАИМЕНОВАНИЕ ТЕХНОЛОГИЧЕСКОЙ КАРТЫ
  opisanie_tk(2500) TYPE c,&quot;ПОЛНОЕ ОПИСАНИЕ ТЕХНОЛОГИЧЕСКОЙ КАРТЫ
  kod_str TYPE string,&quot;КОД СТРАТЕГИИ ТОРО
  eo TYPE string,&quot;ЕДИНИЦА ОБОРУДОВАНИЯ
  gr_pl(3) TYPE  C,
  x,
END OF head_stat_ghz_table_type,


BEGIN OF oper_stat_ghz_table_type,
  eo(50) TYPE c,&quot;ЕДИНИЦА ОБОРУДОВАНИЯ
  number_tk(10) TYPE c,&quot;НОМЕР ТЕХ КАРТЫ
  number_oper(4) TYPE c,&quot;НОМЕР ОПЕРАЦИИ
  kod_vd_oper(2) TYPE c,&quot; КОД ВИДА ОПЕРАЦИИ
  num_first_oper(4) TYPE c,&quot; НОМЕР ПЕРВОЙ ОПЕРАЦИИ
  type_alt_pos(11) TYPE c,&quot; ТИП АЛЬТЕРНАТИВНОЙ ПОЗИЦИИ
  num_komp_op(4) TYPE c, &quot; НОМЕР КОМПЛЕКСНОЙ ОПЕРАЦИИ
  zzito_io TYPE string,&quot;ИСТОЧНИК ОБОСНОВАНИЯ НОРМАТИВА
  name_oper(40) TYPE c,&quot;НАИМЕНОВАНИЕ ОПЕРАЦИИ
  full_name_oper(500) TYPE c,&quot; ПОЛНОЕ НАИМЕНОВАНИЕ ОПЕРАЦИИ
  specialnost TYPE string,&quot;СПЕЦИАЛЬНОСТЬ
  kol_rab TYPE string,&quot;КОЛИЧЕСТВО РАБОТЫ ПО ОПЕРАЦИИ
  ei_rab TYPE string,&quot;ЕДИНИЦА ИЗМЕРЕНИЯ РАБОТЫ
  trudoemkost TYPE string,&quot;ТРУДОЕМКОСТЬ НА 1 ЕДИНИЦУ РАБОТЫ
  ei_trud TYPE string,&quot;ЕДИНИЦА ИЗМЕРЕНИЯ ТРУДОЕМКОСТИ
  zzito_kpr TYPE string,&quot;КОЭФФИЦИЕНТ ПРОИЗВОДСТВА РАБОТ
  zzito_ob_kpr(60) TYPE c, &quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА ПРОИЗВОДСТВА РАБОТ
  zzito_kur TYPE string, &quot;КОЭФФИЦИЕНТ УСЛОВИЯ РАБОТ
  zzito_ob_kur TYPE string, &quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА УСЛОВИЙ РАБОТ
  rab_mesto TYPE string,&quot;ВЫПОЛНЯЮЩЕЕ РАБОЧЕЕ МЕСТО
  opis_oper(3000) TYPE c,&quot;ПОЛНОЕ ОПИСАНИЕ ОПЕРАЦИИ
  kol_ispoln TYPE string,&quot;КОЛИЧЕСТВО ИСПОЛНИТЕЛЕЙ
  znachimost_oper TYPE string,&quot;ЗНАЧИМОСТЬ ОПЕРАЦИИ ДЛЯ ПАКЕТОВ СТАТЕГИИ ТОРО
  zzito_kr TYPE string, &quot;КВАЛИФИКАЦИОННЫЙ РАЗРЯД ПОДРЯДНЫХ РАБОТ
  x,
*FAIL1 TYPE STRING, &quot;ДЛЯ ЛИШНИХ ЗНАКОВ ТАБУЛЯЦИИ
END OF oper_stat_ghz_table_type,

&quot;ТИП ТАБЛИЦЫ МиМ ОПЕРАЦИИ ТЕХ КАРТЫ
BEGIN OF mim_table_type,
  eo(50) TYPE c,&quot;ЕДИНИЦА ОБОРУДОВАНИЯ
  number_tk(10) TYPE c,&quot;НОМЕР ТЕХНОЛОГИЧЕСКОЙ КАРТЫ
  number_oper(4) TYPE c,&quot;НОМЕР ОПЕРАЦИИ
  kod_mim TYPE string,&quot;КОД МиМ
  kolvo TYPE string,&quot;КОЛИЧЕСТВО
  eo_mim TYPE string,&quot;ЕДИНИЦА ИЗМЕРЕНИЯ МиМ
END OF mim_table_type,
BEGIN OF error_table_type,
  text TYPE string,
END OF error_table_type,


BEGIN OF gts_material,
  eo(50)                    TYPE c,
  number_tk(10) TYPE c,&quot;НОМЕР ТЕХ КАРТЫ
  number_oper(4) TYPE c,&quot;НОМЕР ОПЕРАЦИИ
  id_mat(18)                TYPE c,&quot; НОМЕР МАТЕРИАЛА
  name_tk(40)             TYPE c, &quot; НАИМЕНОВАНИЕ МАТЕРИАЛА
  quant(4)             TYPE c, &quot; КОЛИЧЕСТВО
  ei(3)               TYPE c,&quot; ЕДИНИЦА ИЗМЕРЕНИЯ
  x,
END OF gts_material.




ranges: number_tk1 for BIPPO-USR08,
        number_tk2 for BIPPO-USR08,
        number_tk3 for BIPPO-USR08,
        number_tk4 for BIPPO-USR08.


data: BEGIN OF oper_stat_ghz_1 OCCURS 500000,
eo(50) TYPE c,&quot;ЕДИНИЦА ОБОРУДОВАНИЯ
  number_tk(10) TYPE c,&quot;НОМЕР ТЕХ КАРТЫ
  number_oper(4) TYPE c,&quot;НОМЕР ОПЕРАЦИИ
  kod_vd_oper(2) TYPE c,&quot; КОД ВИДА ОПЕРАЦИИ
  num_first_oper(4) TYPE c,&quot; НОМЕР ПЕРВОЙ ОПЕРАЦИИ
  type_alt_pos(11) TYPE c,&quot; ТИП АЛЬТЕРНАТИВНОЙ ПОЗИЦИИ
  num_komp_op(4) TYPE c, &quot; НОМЕР КОМПЛЕКСНОЙ ОПЕРАЦИИ
  zzito_io TYPE string,&quot;ИСТОЧНИК ОБОСНОВАНИЯ НОРМАТИВА
  name_oper(40) TYPE c,&quot;НАИМЕНОВАНИЕ ОПЕРАЦИИ
  full_name_oper(500) TYPE c,&quot; ПОЛНОЕ НАИМЕНОВАНИЕ ОПЕРАЦИИ
  specialnost TYPE string,&quot;СПЕЦИАЛЬНОСТЬ
  kol_rab TYPE string,&quot;КОЛИЧЕСТВО РАБОТЫ ПО ОПЕРАЦИИ
  ei_rab TYPE string,&quot;ЕДИНИЦА ИЗМЕРЕНИЯ РАБОТЫ
  trudoemkost TYPE string,&quot;ТРУДОЕМКОСТЬ НА 1 ЕДИНИЦУ РАБОТЫ
  ei_trud TYPE string,&quot;ЕДИНИЦА ИЗМЕРЕНИЯ ТРУДОЕМКОСТИ
  zzito_kpr TYPE string,&quot;КОЭФФИЦИЕНТ ПРОИЗВОДСТВА РАБОТ
  zzito_ob_kpr(60) TYPE c, &quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА ПРОИЗВОДСТВА РАБОТ
  zzito_kur TYPE string, &quot;КОЭФФИЦИЕНТ УСЛОВИЯ РАБОТ
  zzito_ob_kur TYPE string, &quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА УСЛОВИЙ РАБОТ
  rab_mesto TYPE string,&quot;ВЫПОЛНЯЮЩЕЕ РАБОЧЕЕ МЕСТО
  opis_oper(3000) TYPE c,&quot;ПОЛНОЕ ОПИСАНИЕ ОПЕРАЦИИ
  kol_ispoln TYPE string,&quot;КОЛИЧЕСТВО ИСПОЛНИТЕЛЕЙ
  znachimost_oper TYPE string,&quot;ЗНАЧИМОСТЬ ОПЕРАЦИИ ДЛЯ ПАКЕТОВ СТАТЕГИИ ТОРО
  zzito_kr TYPE string, &quot;КВАЛИФИКАЦИОННЫЙ РАЗРЯД ПОДРЯДНЫХ РАБОТ
  x.
  data: end of oper_stat_ghz_1.


data: BEGIN OF oper_stat_ghz_2 OCCURS 500000,
eo(50) TYPE c,&quot;ЕДИНИЦА ОБОРУДОВАНИЯ
  number_tk(10) TYPE c,&quot;НОМЕР ТЕХ КАРТЫ
  number_oper(4) TYPE c,&quot;НОМЕР ОПЕРАЦИИ
  kod_vd_oper(2) TYPE c,&quot; КОД ВИДА ОПЕРАЦИИ
  num_first_oper(4) TYPE c,&quot; НОМЕР ПЕРВОЙ ОПЕРАЦИИ
  type_alt_pos(11) TYPE c,&quot; ТИП АЛЬТЕРНАТИВНОЙ ПОЗИЦИИ
  num_komp_op(4) TYPE c, &quot; НОМЕР КОМПЛЕКСНОЙ ОПЕРАЦИИ
  zzito_io TYPE string,&quot;ИСТОЧНИК ОБОСНОВАНИЯ НОРМАТИВА
  name_oper(40) TYPE c,&quot;НАИМЕНОВАНИЕ ОПЕРАЦИИ
  full_name_oper(500) TYPE c,&quot; ПОЛНОЕ НАИМЕНОВАНИЕ ОПЕРАЦИИ
  specialnost TYPE string,&quot;СПЕЦИАЛЬНОСТЬ
  kol_rab TYPE string,&quot;КОЛИЧЕСТВО РАБОТЫ ПО ОПЕРАЦИИ
  ei_rab TYPE string,&quot;ЕДИНИЦА ИЗМЕРЕНИЯ РАБОТЫ
  trudoemkost TYPE string,&quot;ТРУДОЕМКОСТЬ НА 1 ЕДИНИЦУ РАБОТЫ
  ei_trud TYPE string,&quot;ЕДИНИЦА ИЗМЕРЕНИЯ ТРУДОЕМКОСТИ
  zzito_kpr TYPE string,&quot;КОЭФФИЦИЕНТ ПРОИЗВОДСТВА РАБОТ
  zzito_ob_kpr(60) TYPE c, &quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА ПРОИЗВОДСТВА РАБОТ
  zzito_kur TYPE string, &quot;КОЭФФИЦИЕНТ УСЛОВИЯ РАБОТ
  zzito_ob_kur TYPE string, &quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА УСЛОВИЙ РАБОТ
  rab_mesto TYPE string,&quot;ВЫПОЛНЯЮЩЕЕ РАБОЧЕЕ МЕСТО
  opis_oper(3000) TYPE c,&quot;ПОЛНОЕ ОПИСАНИЕ ОПЕРАЦИИ
  kol_ispoln TYPE string,&quot;КОЛИЧЕСТВО ИСПОЛНИТЕЛЕЙ
  znachimost_oper TYPE string,&quot;ЗНАЧИМОСТЬ ОПЕРАЦИИ ДЛЯ ПАКЕТОВ СТАТЕГИИ ТОРО
  zzito_kr TYPE string, &quot;КВАЛИФИКАЦИОННЫЙ РАЗРЯД ПОДРЯДНЫХ РАБОТ
  x.
  data: end of oper_stat_ghz_2.


data: BEGIN OF oper_stat_ghz_3 OCCURS 500000,
eo(50) TYPE c,&quot;ЕДИНИЦА ОБОРУДОВАНИЯ
  number_tk(10) TYPE c,&quot;НОМЕР ТЕХ КАРТЫ
  number_oper(4) TYPE c,&quot;НОМЕР ОПЕРАЦИИ
  kod_vd_oper(2) TYPE c,&quot; КОД ВИДА ОПЕРАЦИИ
  num_first_oper(4) TYPE c,&quot; НОМЕР ПЕРВОЙ ОПЕРАЦИИ
  type_alt_pos(11) TYPE c,&quot; ТИП АЛЬТЕРНАТИВНОЙ ПОЗИЦИИ
  num_komp_op(4) TYPE c, &quot; НОМЕР КОМПЛЕКСНОЙ ОПЕРАЦИИ
  zzito_io TYPE string,&quot;ИСТОЧНИК ОБОСНОВАНИЯ НОРМАТИВА
  name_oper(40) TYPE c,&quot;НАИМЕНОВАНИЕ ОПЕРАЦИИ
  full_name_oper(500) TYPE c,&quot; ПОЛНОЕ НАИМЕНОВАНИЕ ОПЕРАЦИИ
  specialnost TYPE string,&quot;СПЕЦИАЛЬНОСТЬ
  kol_rab TYPE string,&quot;КОЛИЧЕСТВО РАБОТЫ ПО ОПЕРАЦИИ
  ei_rab TYPE string,&quot;ЕДИНИЦА ИЗМЕРЕНИЯ РАБОТЫ
  trudoemkost TYPE string,&quot;ТРУДОЕМКОСТЬ НА 1 ЕДИНИЦУ РАБОТЫ
  ei_trud TYPE string,&quot;ЕДИНИЦА ИЗМЕРЕНИЯ ТРУДОЕМКОСТИ
  zzito_kpr TYPE string,&quot;КОЭФФИЦИЕНТ ПРОИЗВОДСТВА РАБОТ
  zzito_ob_kpr(60) TYPE c, &quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА ПРОИЗВОДСТВА РАБОТ
  zzito_kur TYPE string, &quot;КОЭФФИЦИЕНТ УСЛОВИЯ РАБОТ
  zzito_ob_kur TYPE string, &quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА УСЛОВИЙ РАБОТ
  rab_mesto TYPE string,&quot;ВЫПОЛНЯЮЩЕЕ РАБОЧЕЕ МЕСТО
  opis_oper(3000) TYPE c,&quot;ПОЛНОЕ ОПИСАНИЕ ОПЕРАЦИИ
  kol_ispoln TYPE string,&quot;КОЛИЧЕСТВО ИСПОЛНИТЕЛЕЙ
  znachimost_oper TYPE string,&quot;ЗНАЧИМОСТЬ ОПЕРАЦИИ ДЛЯ ПАКЕТОВ СТАТЕГИИ ТОРО
  zzito_kr TYPE string, &quot;КВАЛИФИКАЦИОННЫЙ РАЗРЯД ПОДРЯДНЫХ РАБОТ
  x.
  data: end of oper_stat_ghz_3.



data: BEGIN OF oper_stat_ghz_4 OCCURS 500000,
eo(50) TYPE c,&quot;ЕДИНИЦА ОБОРУДОВАНИЯ
  number_tk(10) TYPE c,&quot;НОМЕР ТЕХ КАРТЫ
  number_oper(4) TYPE c,&quot;НОМЕР ОПЕРАЦИИ
  kod_vd_oper(2) TYPE c,&quot; КОД ВИДА ОПЕРАЦИИ
  num_first_oper(4) TYPE c,&quot; НОМЕР ПЕРВОЙ ОПЕРАЦИИ
  type_alt_pos(11) TYPE c,&quot; ТИП АЛЬТЕРНАТИВНОЙ ПОЗИЦИИ
  num_komp_op(4) TYPE c, &quot; НОМЕР КОМПЛЕКСНОЙ ОПЕРАЦИИ
  zzito_io TYPE string,&quot;ИСТОЧНИК ОБОСНОВАНИЯ НОРМАТИВА
  name_oper(40) TYPE c,&quot;НАИМЕНОВАНИЕ ОПЕРАЦИИ
  full_name_oper(500) TYPE c,&quot; ПОЛНОЕ НАИМЕНОВАНИЕ ОПЕРАЦИИ
  specialnost TYPE string,&quot;СПЕЦИАЛЬНОСТЬ
  kol_rab TYPE string,&quot;КОЛИЧЕСТВО РАБОТЫ ПО ОПЕРАЦИИ
  ei_rab TYPE string,&quot;ЕДИНИЦА ИЗМЕРЕНИЯ РАБОТЫ
  trudoemkost TYPE string,&quot;ТРУДОЕМКОСТЬ НА 1 ЕДИНИЦУ РАБОТЫ
  ei_trud TYPE string,&quot;ЕДИНИЦА ИЗМЕРЕНИЯ ТРУДОЕМКОСТИ
  zzito_kpr TYPE string,&quot;КОЭФФИЦИЕНТ ПРОИЗВОДСТВА РАБОТ
  zzito_ob_kpr(60) TYPE c, &quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА ПРОИЗВОДСТВА РАБОТ
  zzito_kur TYPE string, &quot;КОЭФФИЦИЕНТ УСЛОВИЯ РАБОТ
  zzito_ob_kur TYPE string, &quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА УСЛОВИЙ РАБОТ
  rab_mesto TYPE string,&quot;ВЫПОЛНЯЮЩЕЕ РАБОЧЕЕ МЕСТО
  opis_oper(3000) TYPE c,&quot;ПОЛНОЕ ОПИСАНИЕ ОПЕРАЦИИ
  kol_ispoln TYPE string,&quot;КОЛИЧЕСТВО ИСПОЛНИТЕЛЕЙ
  znachimost_oper TYPE string,&quot;ЗНАЧИМОСТЬ ОПЕРАЦИИ ДЛЯ ПАКЕТОВ СТАТЕГИИ ТОРО
  zzito_kr TYPE string, &quot;КВАЛИФИКАЦИОННЫЙ РАЗРЯД ПОДРЯДНЫХ РАБОТ
  x.
  data: end of oper_stat_ghz_4.


DATA: put TYPE char255, &quot;ПУТЬ ФАЙЛА
      put2 TYPE string,
      results TYPE match_result_tab,
      head_stat_ghz TYPE STANDARD TABLE OF head_stat_ghz_table_type WITH HEADER LINE,&quot;ТАБЛИЦА ЗАГОЛОВКОВ
      head_stat_ghz_LINE LIKE LINE OF head_stat_ghz,
      head_stat_ghz_1 TYPE STANDARD TABLE OF head_stat_ghz_table_type WITH HEADER LINE,&quot;ТАБЛИЦА ЗАГОЛОВКОВ 1
      head_stat_ghz_2 TYPE STANDARD TABLE OF head_stat_ghz_table_type WITH HEADER LINE,&quot;ТАБЛИЦА ЗАГОЛОВКОВ 2
      head_stat_ghz_3 TYPE STANDARD TABLE OF head_stat_ghz_table_type WITH HEADER LINE,&quot;ТАБЛИЦА ЗАГОЛОВКОВ 3
      head_stat_ghz_4 TYPE STANDARD TABLE OF head_stat_ghz_table_type WITH HEADER LINE,&quot;ТАБЛИЦА ЗАГОЛОВКОВ 4
      oper_stat_ghz TYPE STANDARD TABLE OF oper_stat_ghz_table_type WITH HEADER LINE,&quot;ТАБЛИЦА ОПЕРАЦИЙ
*      oper_stat_ghz_1 TYPE STANDARD TABLE OF oper_stat_ghz_table_type WITH HEADER LINE,&quot;ТАБЛИЦА ОПЕРАЦИЙ 1
*      oper_stat_ghz_2 TYPE STANDARD TABLE OF oper_stat_ghz_table_type WITH HEADER LINE,&quot;ТАБЛИЦА ОПЕРАЦИЙ 2
*      oper_stat_ghz_3 TYPE STANDARD TABLE OF oper_stat_ghz_table_type WITH HEADER LINE,&quot;ТАБЛИЦА ОПЕРАЦИЙ 3
*      oper_stat_ghz_4 TYPE STANDARD TABLE OF oper_stat_ghz_table_type WITH HEADER LINE,&quot;ТАБЛИЦА ОПЕРАЦИЙ 4
      oper_stat_ghz_line LIKE LINE OF oper_stat_ghz,&quot; СТРОКА ТАБЛИЦЫ ЗАГОЛОВОВ
      mim_table TYPE STANDARD TABLE OF mim_table_type WITH HEADER LINE,&quot;ТАБЛИЦА МиМ
      mim_table_1 TYPE STANDARD TABLE OF mim_table_type WITH HEADER LINE,&quot;ТАБЛИЦА МиМ 1
      mim_table_2 TYPE STANDARD TABLE OF mim_table_type WITH HEADER LINE,&quot;ТАБЛИЦА МиМ 2
      mim_table_3 TYPE STANDARD TABLE OF mim_table_type WITH HEADER LINE,&quot;ТАБЛИЦА МиМ 3
      mim_table_4 TYPE STANDARD TABLE OF mim_table_type WITH HEADER LINE,&quot;ТАБЛИЦА МиМ 4
      gt_materials  TYPE TABLE OF gts_material, &quot; ТАБЛИЦА МАТЕРИАЛОВ
      gt_materials_1  TYPE TABLE OF gts_material, &quot; ТАБЛИЦА МАТЕРИАЛОВ 1
      gt_materials_2  TYPE TABLE OF gts_material, &quot; ТАБЛИЦА МАТЕРИАЛОВ 2
      gt_materials_3  TYPE TABLE OF gts_material, &quot; ТАБЛИЦА МАТЕРИАЛОВ 3
      gt_materials_4  TYPE TABLE OF gts_material, &quot; ТАБЛИЦА МАТЕРИАЛОВ 4
      gs_materials LIKE LINE OF gt_materials.

DATA: BEGIN OF TABfields OCCURS 10,
      col(20),
END OF  TABfields.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001. &quot;С ЗАГОЛОВКОМ
PARAMETERS:file1 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ЗАГОЛОВКОВ ТК
file2 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ОПЕРАЦИЙ ТК
file3 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ МиМ ОПЕРАЦИЙ ТК

pnamefm LIKE rlgrap-filename OBLIGATORY.


*file4 LIKE rlgrap-filename OBLIGATORY. &quot;ФАЙЛ ДЛЯ ВЫВОДА ОШИБОК

SELECTION-SCREEN END OF BLOCK b1.

*
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-001. &quot;С ЗАГОЛОВКОМ
PARAMETERS:

file1_1 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ЗАГОЛОВКОВ ТК
file1_2 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ЗАГОЛОВКОВ ТК
file1_3 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ЗАГОЛОВКОВ ТК
file1_4 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ЗАГОЛОВКОВ ТК
file2_1 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ОПЕРАЦИЙ ТК
file2_2 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ОПЕРАЦИЙ ТК
file2_3 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ОПЕРАЦИЙ ТК
file2_4 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ОПЕРАЦИЙ ТК
file3_1 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ МиМ ОПЕРАЦИЙ ТК
file3_2 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ МиМ ОПЕРАЦИЙ ТК
file3_3 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ МиМ ОПЕРАЦИЙ ТК
file3_4 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ МиМ ОПЕРАЦИЙ ТК
pnamef_1 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ДЛЯ МАТЕРИАЛОВ
pnamef_2 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ДЛЯ МАТЕРИАЛОВ
pnamef_3 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ДЛЯ МАТЕРИАЛОВ
pnamef_4 LIKE rlgrap-filename OBLIGATORY. &quot;ФАЙЛ ДЛЯ МАТЕРИАЛОВ

SELECTION-SCREEN END OF BLOCK b2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR file1.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 1
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.XLSX,*.XLSX.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file1
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR file2.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 2
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
*     mask             = &apos;,*.TXT,*.TXT.&apos;
      mask             = &apos;,*.XLSX,*.XLSX.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file2
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR file3.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 3
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.XLSX,*.XLSX.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file3
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pnamefm.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.XLSX,*.XLSX.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = pnamefm
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.


  AT SELECTION-SCREEN ON VALUE-REQUEST FOR file1_1.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file1_1
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR file1_2.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file1_2
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.


  AT SELECTION-SCREEN ON VALUE-REQUEST FOR file1_3.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file1_3
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR file1_4.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file1_4
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.


  AT SELECTION-SCREEN ON VALUE-REQUEST FOR file2_1.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file2_1
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR file2_2.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file2_2
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.


  AT SELECTION-SCREEN ON VALUE-REQUEST FOR file2_3.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file2_3
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR file2_4.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file2_4
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR file4.
*  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 4
*  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
*    EXPORTING
*      def_filename     = &apos; &apos;
*      mask             = &apos;,*.TXT,*.TXT.&apos;
*      mode             = &apos;O&apos;
*      title            = &apos;ВЫБОР ФАЙЛА&apos;
*    IMPORTING
*      filename         = file4
*    EXCEPTIONS
*      inv_winsys       = 01
*      no_batch         = 02
*      selection_cancel = 03
*      selection_error  = 04.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR file3_1.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file3_1
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR file3_2.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file3_2
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.


  AT SELECTION-SCREEN ON VALUE-REQUEST FOR file3_3.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file3_3
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR file3_4.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file3_4
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.


  AT SELECTION-SCREEN ON VALUE-REQUEST FOR PNAMEF_1.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = PNAMEF_1
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR PNAMEF_2.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = PNAMEF_2
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.


  AT SELECTION-SCREEN ON VALUE-REQUEST FOR PNAMEF_3.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = PNAMEF_3
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR PNAMEF_4.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = PNAMEF_4
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.



START-OF-SELECTION.
  put = file1.


  CALL FUNCTION &apos;Z_LOAD_XLS_TO_SAP&apos;
    EXPORTING
      p_file_name = put
    CHANGING
      pt_itab     = head_stat_ghz[]
    EXCEPTIONS
      p_error     = 1.

  IF sy-subrc &lt;&gt; 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  put = file2.

  CALL FUNCTION &apos;Z_LOAD_XLS_TO_SAP&apos;
    EXPORTING
      p_file_name = put
    CHANGING
      pt_itab     = oper_stat_ghz[]
    EXCEPTIONS
      p_error     = 1.

  IF sy-subrc &lt;&gt; 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


*  CALL FUNCTION &apos;GUI_UPLOAD&apos;
*    EXPORTING
*      FILENAME            = PUT2
*      HAS_FIELD_SEPARATOR = cl_abap_char_utilities=&gt;horizontal_tab
*    TABLES
*      DATA_TAB            = OPER_STAT_GHZ
*    EXCEPTIONS
*      FILE_OPEN_ERROR     = 1
*      OTHERS              = 2.
*  IF sy-subrc &lt;&gt; 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

  put = file3.

  CALL FUNCTION &apos;Z_LOAD_XLS_TO_SAP&apos;
    EXPORTING
      p_file_name = put
    CHANGING
      pt_itab     = mim_table[]
    EXCEPTIONS
      p_error     = 1.

  IF sy-subrc &lt;&gt; 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  put = pnamefm.
  MESSAGE &apos;Идет обработка файла подопераций...&apos; TYPE &apos;S&apos;.

  CALL FUNCTION &apos;Z_LOAD_XLS_TO_SAP&apos;
    EXPORTING
      p_file_name = put
    CHANGING
      pt_itab     = gt_materials[]
    EXCEPTIONS
      p_error     = 1.

  IF sy-subrc &lt;&gt; 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

sort head_stat_ghz by number_tk.
sort OPER_STAT_GHZ by number_tk number_oper.
sort MIM_TABLE by number_tk number_oper.
SORT gt_materials BY eo number_tk number_oper id_mat.



APPEND LINES OF head_stat_ghz[] FROM 1 TO 955 TO head_stat_ghz_1[].
APPEND LINES OF head_stat_ghz[] FROM 956 TO 1910 TO head_stat_ghz_2[].
APPEND LINES OF head_stat_ghz[] FROM 1911 TO 2865 TO head_stat_ghz_3[].
APPEND LINES OF head_stat_ghz[] FROM 2866 TO 3820 TO head_stat_ghz_4[].

LOOP AT head_stat_ghz_1.
number_tk1-sign = &apos;I&apos;.
number_tk1-OPTION = &apos;EQ&apos;.
number_tk1-LOW = head_stat_ghz_1-number_tk.
APPEND number_tk1.
CLEAR number_tk1.
ENDLOOP.


LOOP AT head_stat_ghz_2.
number_tk2-sign = &apos;I&apos;.
number_tk2-OPTION = &apos;EQ&apos;.
number_tk2-LOW = head_stat_ghz_2-number_tk.
APPEND number_tk2.
CLEAR number_tk2.
ENDLOOP.


LOOP AT head_stat_ghz_3.
number_tk3-sign = &apos;I&apos;.
number_tk3-OPTION = &apos;EQ&apos;.
number_tk3-LOW = head_stat_ghz_3-number_tk.
APPEND number_tk3.
CLEAR number_tk3.
ENDLOOP.

LOOP AT head_stat_ghz_4.
number_tk4-sign = &apos;I&apos;.
number_tk4-OPTION = &apos;EQ&apos;.
number_tk4-LOW = head_stat_ghz_4-number_tk.
APPEND number_tk4.
CLEAR number_tk4.
ENDLOOP.

APPEND LINES OF OPER_STAT_GHZ to OPER_STAT_GHZ_1.
APPEND LINES OF OPER_STAT_GHZ to OPER_STAT_GHZ_2.
APPEND LINES OF OPER_STAT_GHZ to OPER_STAT_GHZ_3.
APPEND LINES OF OPER_STAT_GHZ to OPER_STAT_GHZ_4.


APPEND LINES OF MIM_TABLE to MIM_TABLE_1.
APPEND LINES OF MIM_TABLE to MIM_TABLE_2.
APPEND LINES OF MIM_TABLE to MIM_TABLE_3.
APPEND LINES OF MIM_TABLE to MIM_TABLE_4.

APPEND LINES OF gt_materials to gt_materials_1.
APPEND LINES OF gt_materials to gt_materials_2.
APPEND LINES OF gt_materials to gt_materials_3.
APPEND LINES OF gt_materials to gt_materials_4.

delete OPER_STAT_GHZ_1[]  WHERE number_tk NOT IN number_tk1.
DELETE MIM_TABLE_1[] WHERE number_tk  NOT IN number_tk1.
DELETE gt_materials_1[] WHERE number_tk  NOT IN number_tk1.

delete OPER_STAT_GHZ_2[] WHERE number_tk NOT IN number_tk2.
DELETE  MIM_TABLE_2[] WHERE number_tk  NOT IN number_tk2.
DELETE  gt_materials_2[] WHERE number_tk  NOT IN number_tk2.

delete OPER_STAT_GHZ_3[] WHERE number_tk NOT IN number_tk3.
DELETE MIM_TABLE_3[] WHERE number_tk  NOT IN number_tk3.
DELETE gt_materials_3[] WHERE number_tk  NOT IN number_tk3.

delete OPER_STAT_GHZ_4[] WHERE number_tk NOT IN number_tk4.
DELETE MIM_TABLE_4[] WHERE number_tk  NOT IN number_tk4.
DELETE gt_materials_4[] WHERE number_tk  NOT IN number_tk4.
*

sort head_stat_ghz_1 by number_tk.
sort head_stat_ghz_2 by number_tk.
sort head_stat_ghz_3 by number_tk.
sort head_stat_ghz_4 by number_tk.
sort OPER_STAT_GHZ_1 by number_tk number_oper.
sort OPER_STAT_GHZ_2 by number_tk number_oper.
sort OPER_STAT_GHZ_3 by number_tk number_oper.
sort OPER_STAT_GHZ_4 by number_tk number_oper.

sort MIM_TABLE_1 by number_tk number_oper.
sort MIM_TABLE_2 by number_tk number_oper.
sort MIM_TABLE_3 by number_tk number_oper.
sort MIM_TABLE_4 by number_tk number_oper.

SORT gt_materials_1 BY eo number_tk number_oper id_mat.
SORT gt_materials_2 BY eo number_tk number_oper id_mat.
SORT gt_materials_3 BY eo number_tk number_oper id_mat.
SORT gt_materials_4 BY eo number_tk number_oper id_mat.

IF head_stat_ghz_1[] IS NOT INITIAL AND OPER_STAT_GHZ_1[] IS NOT INITIAL.
 PERFORM PRINT_FILE1_1.  &quot; Выгрузка файла заголовков 1.
 PERFORM PRINT_FILE2_1.  &quot; Выгрузка файла операций 1.
 PERFORM PRINT_FILE3_1.  &quot; Выгрузка файла МиМ 1
 PERFORM PRINT_pnamef_1. &quot; Выгрузка материалов 1
ENDIF.

IF head_stat_ghz_2[] IS NOT INITIAL AND OPER_STAT_GHZ_2[] IS NOT INITIAL.
 PERFORM PRINT_FILE1_2.&quot; Выгрузка файла заголовков 2.
 PERFORM PRINT_FILE2_2.  &quot; Выгрузка файла операций 2.
 PERFORM PRINT_FILE3_2.  &quot; Выгрузка файла МиМ 2.
 PERFORM PRINT_pnamef_2. &quot; Выгрузка материалов 2.

ENDIF.
*
IF head_stat_ghz_3[] IS NOT INITIAL AND OPER_STAT_GHZ_3[] IS NOT INITIAL.
 PERFORM PRINT_FILE1_3.  &quot; Выгрузка файла заголовков 3.
 PERFORM PRINT_FILE2_3.  &quot; Выгрузка файла операций 3.
 PERFORM PRINT_FILE3_3.  &quot; Выгрузка файла МиМ 3
 PERFORM PRINT_pnamef_3. &quot; Выгрузка материалов 3
ENDIF.

IF head_stat_ghz_4[] IS NOT INITIAL AND OPER_STAT_GHZ_4[] IS NOT INITIAL.
 PERFORM PRINT_FILE1_4.&quot; Выгрузка файла заголовков 4.
 PERFORM PRINT_FILE2_4.  &quot; Выгрузка файла операций 4.
 PERFORM PRINT_FILE3_4.  &quot; Выгрузка файла МиМ 4.
 PERFORM PRINT_pnamef_4. &quot; Выгрузка материалов 4.

ENDIF.
IF SY-SUBRC = 0.

ENDIF.


*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_FILE1
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_FILE1_1 .
PERFORM SET_TITLE_1.
put2 = FILE1_1.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  FILE1_1
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        = head_stat_ghz_1    &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.

CLEAR: TABfields, TABfields[].

ENDFORM.                    &quot; PRINT_FILE1



*&amp;---------------------------------------------------------------------*
*&amp;      Form  SET_TITLE_1
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM SET_TITLE_1 .
  TABfields-col = &apos;№ техкарты&apos;.
  append TABfields.

  TABfields-col = &apos;Марка&apos;.
  append TABfields.

  TABfields-col = &apos;Наименован.техкарты&apos;.
  append TABfields.


  TABfields-col = &apos;Подр.опис.техкарты&apos;.
  append TABfields.


  TABfields-col = &apos;Код стратегии ТОРО&apos;.
  append TABfields.


  TABfields-col = &apos;Единица оборудования&apos;.
  append TABfields.


  TABfields-col = &apos;Группа плановиков&apos;.
  append TABfields.
*

ENDFORM.                    &quot; SET_TITLE_1
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_FILE1_2
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_FILE1_2 .
PERFORM SET_TITLE_1.
put2 = FILE1_2.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  FILE1_2
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        = head_stat_ghz_2    &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.
CLEAR: TABfields, TABfields[].
ENDFORM.                    &quot; PRINT_FILE1_2
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_FILE1_3
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_FILE1_3 .
PERFORM SET_TITLE_1.
put2 = FILE1_3.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  FILE1_3
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        = head_stat_ghz_3    &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.
CLEAR: TABfields, TABfields[].
ENDFORM.                    &quot; PRINT_FILE1_3
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_FILE1_4
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_FILE1_4 .
PERFORM SET_TITLE_1.
put2 = FILE1_4.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  FILE1_4
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        = head_stat_ghz_4    &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.
CLEAR: TABfields, TABfields[].
ENDFORM.                    &quot; PRINT_FILE1_4
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_FILE2_1
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_FILE2_1 .
PERFORM SET_TITLE_2.

put2 = FILE2_1.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  FILE2_1
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        =  OPER_STAT_GHZ_1  &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.

CLEAR: TABfields, TABfields[].

ENDFORM.                    &quot; PRINT_FILE2_1
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_FILE3_1
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_FILE3_1 .
PERFORM SET_TITLE_3.
put2 = FILE3_1.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  FILE3_1
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        =  mim_table_1   &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.

CLEAR: TABfields, TABfields[].

ENDFORM.                    &quot; PRINT_FILE3_1
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_PNAMEF_1
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_PNAMEF_1 .
PERFORM SET_TITLE_4.
put2 = pnamef_1.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  pnamef_1
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        =  gt_materials_1  &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.

CLEAR: TABfields, TABfields[].

ENDFORM.                    &quot; PRINT_PNAMEF_1
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_FILE2_2
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_FILE2_2 .
PERFORM SET_TITLE_2.
put2 = FILE2_2.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  FILE2_2
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        =  OPER_STAT_GHZ_2  &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.

CLEAR: TABfields, TABfields[].

ENDFORM.                    &quot; PRINT_FILE2_2
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_FILE3_2
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_FILE3_2 .
PERFORM SET_TITLE_3.
put2 = FILE3_1.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  FILE3_1
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        =  mim_table_2   &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.

CLEAR: TABfields, TABfields[].
ENDFORM.                    &quot; PRINT_FILE3_2
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_PNAMEF_2
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_PNAMEF_2 .
PERFORM SET_TITLE_4.
put2 = pnamef_2.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  pnamef_2
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        =  gt_materials_2  &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.

CLEAR: TABfields, TABfields[].
ENDFORM.                    &quot; PRINT_PNAMEF_2
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_FILE2_3
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_FILE2_3 .
PERFORM SET_TITLE_2.
put2 = FILE2_3.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  FILE2_3
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        =  OPER_STAT_GHZ_3  &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.

CLEAR: TABfields, TABfields[].


ENDFORM.                    &quot; PRINT_FILE2_3
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_FILE3_3
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_FILE3_3 .
PERFORM SET_TITLE_3.
put2 = FILE3_3.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  FILE3_3
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        =  mim_table_3   &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.

CLEAR: TABfields, TABfields[].
ENDFORM.                    &quot; PRINT_FILE3_3
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_PNAMEF_3
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_PNAMEF_3 .
PERFORM SET_TITLE_4.
put2 = pnamef_3.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  pnamef_3
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        =  gt_materials_3  &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.

CLEAR: TABfields, TABfields[].
ENDFORM.                    &quot; PRINT_PNAMEF_3
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_FILE2_4
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_FILE2_4 .
PERFORM SET_TITLE_2.

put2 = FILE2_4.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  FILE2_4
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        =  OPER_STAT_GHZ_4  &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.

CLEAR: TABfields, TABfields[].

ENDFORM.                    &quot; PRINT_FILE2_4
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_FILE3_4
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_FILE3_4 .
PERFORM SET_TITLE_3.
put2 = FILE3_4.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  FILE3_4
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        =  mim_table_4   &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.

CLEAR: TABfields, TABfields[].
ENDFORM.                    &quot; PRINT_FILE3_4
*&amp;---------------------------------------------------------------------*
*&amp;      Form  PRINT_PNAMEF_4
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_PNAMEF_4 .

PERFORM SET_TITLE_4.
put2 = pnamef_4.
  &quot;ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;DOWNLOAD&apos;                             &quot;#EC FB_OLDED
  EXPORTING
      FILENAME        =  pnamef_4
*        &apos;D:\Users\10man\Desktop\Protoc.xls&apos;   &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
      FILETYPE              = &apos;DAT&apos;
*        WRITE_FIELD_SEPARATOR = &apos;X&apos;
  TABLES
      DATA_TAB        =  gt_materials_4  &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
      FIELDNAMES      = TABfields
  EXCEPTIONS
      FILE_OPEN_ERROR = 1
  OTHERS              = 2.

CLEAR: TABfields, TABfields[].
ENDFORM.                    &quot; PRINT_PNAMEF_4
*&amp;---------------------------------------------------------------------*
*&amp;      Form  SET_TITLE_2
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM SET_TITLE_2 .
  TABfields-col = &apos;ЕО&apos;.
  append TABfields.

  TABfields-col = &apos;№ Техкарты&apos;.
  append TABfields.

  TABfields-col = &apos;№ операции&apos;.
  append TABfields.


  TABfields-col = &apos;Код вида операции&apos;.
  append TABfields.


  TABfields-col = &apos;№ первой операции&apos;.
  append TABfields.


  TABfields-col = &apos;Тип альт.позиции&apos;.
  append TABfields.

  TABfields-col = &apos;№ компл. операции&apos;.
  append TABfields.



  TABfields-col = &apos;Источник обос.нормат&apos;.
  append TABfields.


  TABfields-col = &apos;Наименов. операции&apos;.
  append TABfields.


  TABfields-col = &apos;Полн.наимен. операции&apos;.
  append TABfields.


  TABfields-col = &apos;Специальность&apos;.
  append TABfields.


  TABfields-col = &apos;Кол-во работы по опер&apos;.
  append TABfields.

  TABfields-col = &apos;Ед.изм.работы&apos;.
  append TABfields.

  TABfields-col = &apos;Труд. на 1 ед.работы&apos;.
  append TABfields.

  TABfields-col = &apos;Ед.изм.труд-сти&apos;.
  append TABfields.

  TABfields-col = &apos;Коэф.пр-ва работ&apos;.
  append TABfields.

  TABfields-col = &apos;Об.прим.коэф.пр-ва раб&apos;.
  append TABfields.

  TABfields-col = &apos;Коэф-т условия работ&apos;.
  append TABfields.


  TABfields-col = &apos;Об.прим.коэф.усл.раб&apos;.
  append TABfields.


  TABfields-col = &apos;Выпол.раб.место&apos;.
  append TABfields.

  TABfields-col = &apos;Подр.описан.операции&apos;.
  append TABfields.

    TABfields-col = &apos;Кол-во исполнителей&apos;.
  append TABfields.

    TABfields-col = &apos;Зн.опер.для пак.страт. &apos;.
  append TABfields.

    TABfields-col = &apos;Кв.раз.исп.подр.Раб.&apos;.
  append TABfields.


ENDFORM.                    &quot; SET_TITLE_2
*&amp;---------------------------------------------------------------------*
*&amp;      Form  SET_TITLE_3
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM SET_TITLE_3 .

TABfields-col = &apos;ЕО&apos;.
  append TABfields.

  TABfields-col = &apos;№ Техкарты&apos;.
  append TABfields.

  TABfields-col = &apos;№ операции&apos;.
  append TABfields.


  TABfields-col = &apos;Код ВПС&apos;.
  append TABfields.


  TABfields-col = &apos;Количество&apos;.
  append TABfields.


  TABfields-col = &apos;Ед. изм. для ВПС/МиМ&apos;.
  append TABfields.



ENDFORM.                    &quot; SET_TITLE_3
*&amp;---------------------------------------------------------------------*
*&amp;      Form  SET_TITLE_4
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  --&gt;  p1        text
*  &lt;--  p2        text
*----------------------------------------------------------------------*
FORM SET_TITLE_4 .
TABfields-col = &apos;ЕО&apos;.
  append TABfields.

  TABfields-col = &apos;№ Техкарты&apos;.
  append TABfields.

  TABfields-col = &apos;№ операции&apos;.
  append TABfields.


  TABfields-col = &apos;Код материала&apos;.
  append TABfields.

  TABfields-col = &apos;Наименование&apos;.
  append TABfields.

  TABfields-col = &apos;Кол-во мат. для опер&apos;.
  append TABfields.

   TABfields-col = &apos;Ед.изм.материала&apos;.
  append TABfields.

ENDFORM.                    &quot; SET_TITLE_4</source>
 </PROG>
