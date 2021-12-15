 <PROG NAME="ZPM_DOWNLOAD_TK_STATIC_GHZ" VARCL="X" SUBC="1" APPL="I" RSTAT="K" RMAND="101" RLOAD="R" FIXPT="X" UCCHECK="X">
  <textPool>
   <language SPRAS="R">
    <textElement ID="I" KEY="001" ENTRY="Выбор файлов" LENGTH="12 "/>
    <textElement ID="I" KEY="002" ENTRY="Выбор файлов единиц измерения" LENGTH="29 "/>
    <textElement ID="I" KEY="003" ENTRY="Выбор режима работы программы" LENGTH="29 "/>
    <textElement ID="I" KEY="E00" ENTRY="Ошибка при открытии набора данных, КВ:" LENGTH="38 "/>
    <textElement ID="I" KEY="I01" ENTRY="Имя сеанса" LENGTH="10 "/>
    <textElement ID="I" KEY="I02" ENTRY="Открытие сеанса" LENGTH="15 "/>
    <textElement ID="I" KEY="I03" ENTRY="Вставка транзакции" LENGTH="18 "/>
    <textElement ID="I" KEY="I04" ENTRY="Закрытие сеанса" LENGTH="15 "/>
    <textElement ID="I" KEY="I05" ENTRY="КодВозврата=" LENGTH="12 "/>
    <textElement ID="I" KEY="I06" ENTRY="Создан ошиб. сеанс" LENGTH="18 "/>
    <textElement ID="I" KEY="S01" ENTRY="Имя сеанса" LENGTH="10 "/>
    <textElement ID="I" KEY="S02" ENTRY="Пользователь" LENGTH="12 "/>
    <textElement ID="I" KEY="S03" ENTRY="Сохранить сеанс" LENGTH="15 "/>
    <textElement ID="I" KEY="S04" ENTRY="Дата блокирования" LENGTH="17 "/>
    <textElement ID="I" KEY="S05" ENTRY="Режим выполнения" LENGTH="16 "/>
    <textElement ID="I" KEY="S06" ENTRY="Режим обновления" LENGTH="16 "/>
    <textElement ID="I" KEY="S07" ENTRY="Создать сеанс" LENGTH="13 "/>
    <textElement ID="I" KEY="S08" ENTRY="Call Transaction" LENGTH="16 "/>
    <textElement ID="I" KEY="S09" ENTRY="ОшибСеанс" LENGTH="9 "/>
    <textElement ID="I" KEY="S10" ENTRY="ИндОтсутствияДанн" LENGTH="17 "/>
    <textElement ID="I" KEY="S11" ENTRY="КратЖурнал" LENGTH="10 "/>
    <textElement ID="R" ENTRY="Создание ТК по статике для ГХЗ" LENGTH="30 "/>
    <textElement ID="S" KEY="DATE_TK" ENTRY="        Дата создания техкарты" LENGTH="30 "/>
    <textElement ID="S" KEY="FILE1" ENTRY="        Выберите файл заголовков ТК:" LENGTH="36 "/>
    <textElement ID="S" KEY="FILE2" ENTRY="        Выберите файл операций ТК:" LENGTH="34 "/>
    <textElement ID="S" KEY="FILE3" ENTRY="        Выберите файл МиМ операций ТК:" LENGTH="38 "/>
    <textElement ID="S" KEY="FILE4" ENTRY="        Выберите файл для ошибок:" LENGTH="33 "/>
    <textElement ID="S" KEY="PNAMEFM" ENTRY="        Выберите файл материалов опер." LENGTH="38 "/>
    <textElement ID="S" KEY="R1" ENTRY="        Создание ТК" LENGTH="19 "/>
    <textElement ID="S" KEY="R2" ENTRY="        Загрузка подробных текстов" LENGTH="34 "/>
   </language>
  </textPool>
  <source>*  *&amp; Создание ТК по статике для ГХЗ
*&amp;---------------------------------------------------------------------*
*&amp; Создано:     2017.11.20
*&amp; Автор:       10man
*&amp;
*&amp; Изменено:
*&amp;    1) 2018.06.21 - 10man - Удаление из программы  анализа файлов с обоснованием Ед.Изм. и без обоснования
*&amp;    2) 2018.09.24 - 10man - Корректировка продпрограммы обработки подробных текстов в соответствии с проектным решением по календарному планированию
*&amp;    3) 2019.02.26 - 10kvu - Перенос в SLE
*     4) 2019.03.26 - 10man - Доработка по причине изменения подхода формирования техкарт - в техкарте должно быть столько счетчиков,
*       сколько пакетов работ в стратегии ТОРО, на которую ссылается техкарта.
*&amp;---------------------------------------------------------------------*

REPORT  zpm_download_tk_static_ghz.

INCLUDE bdcrecx1.
TABLES: plko, plpo, mara, eapl, eqkt, t351, T351X, plas.
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

&quot;ТИП ТАБЛИЦЫ ЕИ С ОБОСНОВАНИЯМИ
BEGIN OF ei_s_obos_table_type,
  obosnovanie TYPE string, &quot;ОБОСНОВАНИЕ
  ei_rab TYPE string,
  gs_drugoe TYPE string,
  ei_gs TYPE string,
  ei_sap TYPE string, &quot;ЕДИНИЦА ИЗМЕРЕНИЯ В SAP
  koeffic TYPE string,
END OF ei_s_obos_table_type,
&quot;ТИП ТАБЛИЦЫ ИЕ БЕЗ ОБОСНОВАНИЙ
BEGIN OF ei_bez_obos_table_type,
  ei_tk TYPE string, &quot;ЕДИНИЦА ИЗМЕРЕНИЯ В ТК
  ei_sap TYPE string, &quot;ЕДИНИЦА ИЗМЕРЕНИЯ В SAP
END OF ei_bez_obos_table_type,

BEGIN OF gts_material,
  eo(50)                    TYPE c,
  number_tk(10) TYPE c,&quot;НОМЕР ТЕХ КАРТЫ
  number_oper(4) TYPE c,&quot;НОМЕР ОПЕРАЦИИ
  id_mat(18)                TYPE c,&quot; НОМЕР МАТЕРИАЛА
  name_tk(40)             TYPE c, &quot; НАИМЕНОВАНИЕ МАТЕРИАЛА
  quant(4)             TYPE c, &quot; КОЛИЧЕСТВО
  ei(3)               TYPE c,&quot; ЕДИНИЦА ИЗМЕРЕНИЯ
  x,
END OF gts_material,



BEGIN OF gts_mat_tot,
  eo(50)                    TYPE c,
  number_tk(10) TYPE c,&quot;НОМЕР ТЕХ КАРТЫ
  number_oper(4) TYPE c,&quot;НОМЕР ОПЕРАЦИИ
  id_mat(18)                TYPE c,&quot; НОМЕР МАТЕРИАЛА
  name_tk(40)             TYPE c, &quot; НАИМЕНОВАНИЕ МАТЕРИАЛА
  quant_tt(8)             TYPE c, &quot; КОЛИЧЕСТВО
  ei(3)               TYPE c,&quot; ЕДИНИЦА ИЗМЕРЕНИЯ

END OF gts_mat_tot.

DATA: BEGIN OF TABfields OCCURS 10,
      col(2),
END OF  TABfields.

DATA: BEGIN OF TABfields2 OCCURS 10,
      col(2),
END OF  TABfields2.

DATA: a TYPE i,
      S type p LENGTH 6 DECIMALS 2 .

DATA: lit_return    TYPE bapiret2 OCCURS 0,
      lt_characteristicvalues  TYPE bapi1003_alloc_values_char OCCURS 0,
*         lt_char  LIKE LINE OF lt_characteristicvalues,
      lt_classallocations TYPE bapi1003_alloc_list OCCURS 0.

DATA: gt_materials  TYPE TABLE OF gts_material,
      del_materials TYPE TABLE OF gts_material,
      gs_materials LIKE LINE OF gt_materials,
      gts_mat TYPE TABLE OF GTS_MAT_TOT,
      gts_mat_line like LINE OF  gts_mat.

DATA: z_dd07t LIKE dd07t OCCURS 0 WITH HEADER LINE.


DATA: fs_materials TYPE gts_material,
      lt_raw_data TYPE truxs_t_text_data, &quot;ВСПОМОГАТЕЛЬНАЯ ТАБЛИЦА
      head_stat_ghz TYPE STANDARD TABLE OF head_stat_ghz_table_type WITH HEADER LINE,&quot;ТАБЛИЦА ЗАГОЛОВКОВ
      oper_stat_ghz TYPE STANDARD TABLE OF oper_stat_ghz_table_type WITH HEADER LINE,&quot;ТАБЛИЦА ОПЕРАЦИЙ
      oper_stat_ghz_line LIKE LINE OF oper_stat_ghz,&quot; СТРОКА ТАБЛИЦЫ ЗАГОЛОВОВ
      mim_table TYPE STANDARD TABLE OF mim_table_type WITH HEADER LINE,&quot;ТАБЛИЦА МиМ
      oper_stat_ghz_1 TYPE STANDARD TABLE OF oper_stat_ghz_table_type WITH HEADER LINE,&quot;ТАБЛИЦА ОПЕРАЦИЙ 1
      error_table TYPE STANDARD TABLE OF error_table_type WITH HEADER LINE,&quot;ТАБЛИЦА ОШИБОК
      ei_s_obos_table TYPE STANDARD TABLE OF ei_s_obos_table_type WITH HEADER LINE, &quot;ТАБЛИЦА ЕДИНИЦ ИЗМЕРЕНИЯ С ОБОСНОВАНИЕМ
      ei_bez_obos_table TYPE STANDARD TABLE OF ei_bez_obos_table_type WITH HEADER LINE, &quot;ТАБЛИЦА ЕДИНИЦ ИЗМЕРЕНИЯ БЕЗ ОБОСНОВАНИЯ
      put TYPE string, &quot;ПУТЬ ФАЙЛА
      per_str TYPE string VALUE cl_abap_char_utilities=&gt;horizontal_tab. &quot;ЗНАК ПЕРЕВОДА СТРОКИ

DATA:
      nomer_eo TYPE equi-equnr,&quot;Номер ЕО
      zapis TYPE string,&quot;Номер строки (через sy-tabix)
      class_eo TYPE string,&quot;Класс ЕО
      under_class_eo TYPE string, &quot;Подкласс ЕО
      model TYPE string, &quot;Марка (модель) ЕО
      name_eo TYPE eqkt-eqktx, &quot;Наименование ЕО
      datex TYPE rn1datum-datex,
      ktext type plkod-ktext,
      z(3) TYPE n,
      zmarka TYPE zpm_marka-marka,&quot;Текущая дата
      zcode TYPE zpm_calc_eu-code, &quot; Код источника обоснования
      zobjnr TYPE equi-objnr.

DATA: ei_flag TYPE i VALUE 0, &quot;ФЛАГ СООТВЕТСТВИЯ ЕИ И КОДА ОБОСНОВАНИЯ
      strateg_flag TYPE i VALUE 0, &quot;ФЛАГ СООТВЕТСТВИЯ СТРАТЕГИИ, НАИМЕНОВАНИЯ ПАКЕТА, ЗНАЧИМОСТИ
      nalichie_tk_flag TYPE i VALUE 0, &quot;ФЛАГ НАЛИЧИЯ ТК ДЛЯ ОПЕРАЦИИ (ПО КОДУ ТК)
      trud2 TYPE p DECIMALS 2, &quot;ВСПОМОГАТЕЛЬНАЯ ПЕРЕМЕННАЯ ДЛЯ УМНОЖЕНИЯ ТРУДОЕМКОСТИ
      trud1 TYPE p DECIMALS 1, &quot;ВСПОМОГАТЕЛЬНАЯ ПЕРЕМЕННАЯ ДЛЯ УМНОЖЕНИЯ ТРУДОЕМКОСТИ
      trud_str(9) TYPE c, &quot;ВСПОМОГАТЕЛЬНАЯ ПЕРЕМЕННАЯ ДЛЯ УМНОЖЕНИЯ ТРУДОЕМКОСТИ
      nom_pak(2) TYPE c,&quot;ВСПОМОГАТЕЛЬНАЯ ПЕРЕМЕННАЯ (пакеты)
      kol_sm LIKE sy-fdpos,&quot;ВСПОМОГАТЕЛЬНАЯ ПЕРЕМЕННАЯ
      str LIKE sy-fdpos,&quot;ВСПОМОГАТЕЛЬНАЯ ПЕРЕМЕННАЯ
      str2(1) TYPE c,
      help TYPE string, &quot;ВСПОМОГАТЕЛЬНАЯ ПЕРЕМЕННАЯ
      naim_podop(40) TYPE c, &quot;Вспомогательная переменная для записи наименования подопераций
      naim_oper(40) TYPE c, &quot;Вспомогательная переменная для записи наименования операций
      mim_flag TYPE i VALUE 0, &quot;Флаг наличия МиМ операции
      paket TYPE string. &quot;ПЕРЕМЕННАЯ ДЛЯ ПАКЕТА ОПЕРАЦИИ

DATA: Z_T351P TYPE STANDARD TABLE OF T351P WITH HEADER LINE,
      Z_T351P2 TYPE STANDARD TABLE OF T351P WITH HEADER LINE.
DATA:
      ls_inob             TYPE inob,
      ls_kssk             TYPE kssk,
      ls_klah             TYPE klah.
DATA: ZLINE TYPE BSVX-STTXT,
      ZUSER_LINE TYPE BSVX-STTXT.

&quot; } 10kvu 2016.09.26 - Загрузка материалов
***************************************************************************************************************************
*Задание экрана выбора И ОПЕРАЦИИ ВЫБОРА ФАЙЛА
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001. &quot;С ЗАГОЛОВКОМ
PARAMETERS:file1 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ЗАГОЛОВКОВ ТК
file2 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ ОПЕРАЦИЙ ТК
file3 LIKE rlgrap-filename OBLIGATORY, &quot;ФАЙЛ МиМ ОПЕРАЦИЙ ТК

pnamefm LIKE rlgrap-filename OBLIGATORY,
date_tk                   LIKE sy-datum OBLIGATORY DEFAULT sy-datum,&quot;Дата создания техкарты

file4 LIKE rlgrap-filename OBLIGATORY. &quot;ФАЙЛ ДЛЯ ВЫВОДА ОШИБОК
SELECTION-SCREEN END OF BLOCK b1.
*SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002. &quot;С ЗАГОЛОВКОМ
*PARAMETERS:FILE5 LIKE RLGRAP-FILENAME OBLIGATORY, &quot;ФАЙЛ ЕИ С ОБОСНОВАНИЯМИ
*           FILE6 LIKE RLGRAP-FILENAME OBLIGATORY. &quot;ФАЙЛ ЕИ БЕЗ ОБОСНОВАНИЙ
*SELECTION-SCREEN END OF BLOCK B2.
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003. &quot;С ЗАГОЛОВКОМ
PARAMETERS:r1 RADIOBUTTON GROUP r_1 DEFAULT &apos;X&apos;,
r2 RADIOBUTTON GROUP r_1.
SELECTION-SCREEN END OF BLOCK b3.
&quot;СОБЫТИЕ - ОБРАБОТКА F4 ДЛЯ ИМЕНИ ФАЙЛА



AT SELECTION-SCREEN ON VALUE-REQUEST FOR file1.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 1
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
*     mask             = &apos;,*.XLSX,*.XLSX.&apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
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
*     mask             = &apos;,*.XLSX,*.XLSX.&apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
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
*     mask             = &apos;,*.XLSX,*.XLSX.&apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
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
*     mask             = &apos;,*.XLSX,*.XLSX.&apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = pnamefm
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR file4.
  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 4
  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
    EXPORTING
      def_filename     = &apos; &apos;
      mask             = &apos;,*.TXT,*.TXT.&apos;
      mode             = &apos;O&apos;
      title            = &apos;ВЫБОР ФАЙЛА&apos;
    IMPORTING
      filename         = file4
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR FILE5.
*  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 5
*  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
*    EXPORTING
*      DEF_FILENAME     = &apos; &apos;
*      MASK             = &apos;,*.xlsx,*.xlsx.&apos;
*      MODE             = &apos;O&apos;
*      TITLE            = &apos;ВЫБОР ФАЙЛА&apos;
*    IMPORTING
*      FILENAME         = FILE5
*    EXCEPTIONS
*      INV_WINSYS       = 01
*      NO_BATCH         = 02
*      SELECTION_CANCEL = 03
*      SELECTION_ERROR  = 04.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR FILE6.
*  &quot;ЗАПРОС ИМЕНИ ФАЙЛА 6
*  CALL FUNCTION &apos;WS_FILENAME_GET&apos;
*    EXPORTING
*      DEF_FILENAME     = &apos; &apos;
*      MASK             = &apos;,*.xlsx,*.xlsx.&apos;
*      MODE             = &apos;O&apos;
*      TITLE            = &apos;ВЫБОР ФАЙЛА&apos;
*    IMPORTING
*      FILENAME         = FILE6
*    EXCEPTIONS
*      INV_WINSYS       = 01
*      NO_BATCH         = 02
*      SELECTION_CANCEL = 03
*      SELECTION_ERROR  = 04.


START-OF-SELECTION.
  put = file1.

  &quot;     *СЧИТЫВАНИЕ ФАЙЛА ЗАГОЛОВКОВ
  CALL FUNCTION &apos;GUI_UPLOAD&apos;
    EXPORTING
      FILENAME            = PUT
      HAS_FIELD_SEPARATOR = cl_abap_char_utilities=&gt;horizontal_tab
    TABLES
      DATA_TAB            = HEAD_STAT_GHZ
    EXCEPTIONS
      FILE_OPEN_ERROR     = 1
      OTHERS              = 2.

*  CALL FUNCTION &apos;Z_LOAD_XLS_TO_SAP&apos;
*    EXPORTING
*      p_file_name = put
*    CHANGING
*      pt_itab     = head_stat_ghz[]
*    EXCEPTIONS
*      p_error     = 1.
*
*  IF sy-subrc &lt;&gt; 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.




  put = file2.

*СЧИТЫВАНИЕ ФАЙЛА ОПЕРАЦИЙ

  CALL FUNCTION &apos;GUI_UPLOAD&apos;
    EXPORTING
      FILENAME            = PUT
      HAS_FIELD_SEPARATOR = cl_abap_char_utilities=&gt;horizontal_tab
    TABLES
      DATA_TAB            = OPER_STAT_GHZ
    EXCEPTIONS
      FILE_OPEN_ERROR     = 1
      OTHERS              = 2.


*  CALL FUNCTION &apos;Z_LOAD_XLS_TO_SAP&apos;
*    EXPORTING
*      p_file_name = put
*    CHANGING
*      pt_itab     = oper_stat_ghz[]
*    EXCEPTIONS
*      p_error     = 1.
*
*  IF sy-subrc &lt;&gt; 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.





  put = file3.
*  IF R1 = &apos;X&apos;.
*СЧИТЫВАНИЕ ФАЙЛА МиМ
  CALL FUNCTION &apos;GUI_UPLOAD&apos;
    EXPORTING
      FILENAME            = PUT
      HAS_FIELD_SEPARATOR = cl_abap_char_utilities=&gt;horizontal_tab
    TABLES
      DATA_TAB            = MIM_TABLE
    EXCEPTIONS
      FILE_OPEN_ERROR     = 1
      OTHERS              = 2.

*
*  CALL FUNCTION &apos;Z_LOAD_XLS_TO_SAP&apos;
*    EXPORTING
*      p_file_name = put
*    CHANGING
*      pt_itab     = mim_table[]
*    EXCEPTIONS
*      p_error     = 1.
*
*  IF sy-subrc &lt;&gt; 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.







**Считывание .xls файла ЕИ С ОБОСНОВАНИЯМИ
*    CALL FUNCTION &apos;TEXT_CONVERT_XLS_TO_SAP&apos;
*        EXPORTING
*          i_filename = FILE5
*          i_tab_raw_data = lt_raw_data
*        TABLES
*          I_TAB_CONVERTED_DATA = EI_S_OBOS_TABLE
**Проверка на наличие ошибок считывания
*        EXCEPTIONS
*          conversion_failed = 1
*        OTHERS = 2.
**Считывание .xls файла ЕИ БЕЗ ОБОСНОВАНИЙ
*    CALL FUNCTION &apos;TEXT_CONVERT_XLS_TO_SAP&apos;
*        EXPORTING
*          i_filename = FILE6
*          i_tab_raw_data = lt_raw_data
*        TABLES
*          I_TAB_CONVERTED_DATA = EI_BEZ_OBOS_TABLE
**Проверка на наличие ошибок считывания
*         EXCEPTIONS
*          conversion_failed = 1
*        OTHERS = 2.

  &quot;Загрузка материалов
  &quot; Считывание файла материалов во внутреннюю таблицу
  put = pnamefm.
*  MESSAGE &apos;Идет обработка файла подопераций...&apos; TYPE &apos;S&apos;.
  CALL FUNCTION &apos;GUI_UPLOAD&apos;
    EXPORTING
      FILENAME = PUT
      FILETYPE = &apos;DAT&apos;
    TABLES
      DATA_TAB = GT_MATERIALS.


*  CALL FUNCTION &apos;Z_LOAD_XLS_TO_SAP&apos;
*    EXPORTING
*      p_file_name = put
*    CHANGING
*      pt_itab     = gt_materials[]
*    EXCEPTIONS
*      p_error     = 1.
*
*  IF sy-subrc &lt;&gt; 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.


  DELETE GT_MATERIALS INDEX 1.
  SORT gt_materials BY eo number_tk number_oper id_mat.

* 10man 04.04.2018 15:33 Удаление несуществующих материалов из списка компонентов в техкарте заявка 1,067,296

  IF syst-sysid = &apos;T01&apos;.
    LOOP AT gt_materials INTO gs_materials.

      a = strlen( gs_materials-id_mat ).
      IF a &lt; 18.
        a = 18 - a.
        WHILE a  &gt; 0.
          CONCATENATE &apos;0&apos; gs_materials-id_mat INTO gs_materials-id_mat.
          a = a - 1.
        ENDWHILE.
        MODIFY gt_materials FROM gs_materials.
      ENDIF.


      SELECT SINGLE * FROM mara WHERE matnr = gs_materials-id_mat.
      IF sy-subrc NE 0.
        gs_materials-x = &apos;X&apos;.
        MODIFY gt_materials FROM gs_materials.
      ELSE.
        IF mara-lvorm = &apos;X&apos;.
          gs_materials-x = &apos;X&apos;.
          MODIFY gt_materials FROM gs_materials.
        ENDIF.
      ENDIF.
    ENDLOOP.

    DELETE gt_materials WHERE x = &apos;X&apos;.

* 10man 04.04.2018 15:33 Удаление несуществующих материалов из списка компонентов в техкарте заявка 1,067,296

  ENDIF.

  &quot; Вызов функции преобразования текущей даты в необходимый формат
  CALL FUNCTION &apos;FORMAT_DATE_4_OUTPUT&apos;
    EXPORTING
      datin  = date_tk
      format = &apos;DD.MM.YYYY&apos;
    IMPORTING
      datex  = datex.

  SELECT * FROM dd07t INTO CORRESPONDING FIELDS OF TABLE z_dd07t WHERE
  domname = &apos;ZPMDOB_KUR&apos;.


* Загрузка ТК
******************************************Загрузка заголовков ТК**********************************************************************************
**************************************************************************************************************************************************
**************************************************************************************************************************************************
  DATA flag TYPE i VALUE 0.&quot;Флаг наличия ТК для операции
* - наличие ТК для операции
  LOOP AT  oper_stat_ghz.&quot;Проверка наличия ТК для операции
    flag = 0.
    IF  oper_stat_ghz-type_alt_pos IS NOT INITIAL.
      oper_stat_ghz-x = &apos;X&apos;.
      MODIFY oper_stat_ghz.
    ENDIF.
    LOOP AT head_stat_ghz.
      IF head_stat_ghz-number_tk = oper_stat_ghz-number_tk.
        flag = 1.
        IF oper_stat_ghz-type_alt_pos IS NOT INITIAL.
          head_stat_ghz-x = &apos;X&apos;.
          MODIFY head_stat_ghz.
        ENDIF.
      ENDIF.

    ENDLOOP.
    IF flag NE 1.&quot;Запись ошибки
      CONCATENATE &apos;Отсутствует ТК для операции &apos; oper_stat_ghz-number_oper &apos; ТК&apos; oper_stat_ghz-number_tk INTO error_table-text.
      APPEND error_table.&quot;Запись в файл ошибок


    ENDIF.
  ENDLOOP.
  DELETE HEAD_STAT_GHZ INDEX 1.
  DELETE OPER_STAT_GHZ INDEX 1.
  DELETE MIM_TABLE INDEX 1.
sort GT_MATERIALS by NUMBER_TK NUMBER_OPER id_mat.
delete ADJACENT DUPLICATES FROM GT_MATERIALS.


  IF r1 = &apos;X&apos;.


    PERFORM open_group.


    LOOP AT head_stat_ghz WHERE x = &apos;&apos;.
      FREE: nomer_eo, zapis, class_eo, under_class_eo, model, name_eo, zmarka, Z_T351P,  Z_T351P[], ZLINE, ZUSER_LINE, zobjnr,
      OPER_STAT_GHZ_1, OPER_STAT_GHZ_1[].&quot;Очищение переменных
      zapis = sy-tabix.&quot;Номер строки заголовков
      SELECT equnr objnr INTO (nomer_eo, zobjnr) FROM equi WHERE zzito_tk_eo = head_stat_ghz-eo.&quot;Выбор номера ЕО по тех коду
      ENDSELECT.
      IF nomer_eo NE &apos;&apos;.&quot;Если номер ЕО найден

        CALL FUNCTION &apos;STATUS_TEXT_EDIT&apos;
          EXPORTING
            CLIENT            = SY-MANDT
            FLG_USER_STAT     = &apos;X&apos;
            OBJNR             = zobjnr
            ONLY_ACTIVE       = &apos;X&apos;
            SPRAS             = SY-LANGU
*           BYPASS_BUFFER     = &apos; &apos;
          IMPORTING
*           ANW_STAT_EXISTING =
*           E_STSMA           =
            LINE              = ZLINE
            USER_LINE         = ZUSER_LINE
*           STONR             =
          EXCEPTIONS
            OBJECT_NOT_FOUND  = 1
            OTHERS            = 2.
        IF SY-SUBRC &lt;&gt; 0.
* Implement suitable error handling here
        ELSE.

          IF ZLINE CP &apos;*МТКУ*&apos;.

          ELSE.
            IF head_stat_ghz-kod_str IS NOT INITIAL .

              SELECT SINGLE * FROM T351 WHERE STRAT = head_stat_ghz-kod_str.
              SELECT * FROM T351P INTO CORRESPONDING FIELDS OF TABLE Z_T351P2 WHERE  STRAT = head_stat_ghz-kod_str.

              APPEND LINES OF OPER_STAT_GHZ to OPER_STAT_GHZ_1 .
              delete OPER_STAT_GHZ_1[]  WHERE number_tk ne HEAD_STAT_GHZ-number_tk and znachimost_oper IS initial.
              LOOP AT OPER_STAT_GHZ_1.
                CLEAR: TABFIELDS, TABFIELDS[].
                paket = oper_stat_ghz_1-znachimost_oper.
                SEARCH paket FOR &apos;/&apos;.&quot;Разделение по знаку &quot;/&quot;
                IF sy-subrc = 0.
                  split paket at &apos;/&apos; into table TABfields.
                  APPEND LINES OF TABFIELDS TO TABFIELDS2.
                ELSE.
                  TABFIELDS2-COL = paket.
                  APPEND TABFIELDS2.
                ENDIF.
              ENDLOOP.
              SORT TABFIELDS2.
              DELETE ADJACENT DUPLICATES FROM TABFIELDS2.

              LOOP AT TABFIELDS2.
                READ TABLE Z_T351P2 WITH KEY ZAEHL+1(1) = TABFIELDS2-COL.
                IF SY-SUBRC = 0.
                  CLEAR Z_T351P.
                  MOVE-CORRESPONDING Z_T351P2 TO Z_T351P.
                  APPEND Z_T351P.
                ENDIF.
              ENDLOOP.
              SORT Z_T351P.
              LOOP AT Z_T351P.

                CALL FUNCTION &apos;TH_REDISPATCH&apos;
                  EXPORTING
                    CHECK_RUNTIME = 0.

* *Выбор наименования единицы оборудования

                SELECT eqktx INTO name_eo FROM eqkt WHERE equnr = nomer_eo.
                ENDSELECT.

                SELECT SINGLE marka FROM zpm_marka INTO zmarka WHERE marka = head_stat_ghz-marka.
*READ TABLE lt_characteristicvalues WITH KEY VALUE_CHAR = HEAD_STAT_GHZ-MARKA INTO lt_char.
                IF sy-subrc = 0.

                ELSE.
                  CONCATENATE &apos;Ошибка заголовка.&apos; per_str &apos; Строка№&apos; zapis per_str&apos; Неверная марка &apos; head_stat_ghz-marka per_str&apos; Единицы оборудования:&apos; nomer_eo INTO error_table-text.
                  APPEND error_table.&quot;Запись в файл ошибок
                ENDIF.
*
                IF sy-tabix = 1.
*                  Z_T351P-ZAEHL = &apos;01&apos;.
*Запись заголовка тех карты
                  PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3010&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RC27E-EQUNR&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
                  PERFORM bdc_field       USING &apos;RC27E-EQUNR&apos; nomer_eo.&quot;Номер ЕО
                  PERFORM bdc_field       USING &apos;RC271-STTAG&apos; datex.&quot;Текущая дата
                  PERFORM bdc_dynpro      USING &apos;SAPLCPDA&apos; &apos;3010&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                        &apos;=ALCA&apos;.
                  PERFORM bdc_field       USING &apos;PLKOD-PLNAL&apos; Z_T351P-ZAEHL.&quot;Константа
                  PERFORM bdc_field       USING &apos;PLKOD-VERWE&apos; &apos;GNS&apos;.&quot;Константа
                  PERFORM bdc_field       USING &apos;PLKOD-VAGRP&apos; head_stat_ghz-gr_pl.&quot;Группа планирования
                  PERFORM bdc_field       USING &apos;PLKOD-STATU&apos; &apos;4&apos;.&quot;Константа
                  PERFORM bdc_field       USING &apos;PLKOD-STRAT&apos; head_stat_ghz-kod_str.&quot;Код стратегии ТК
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLKO-ZZITO_TK&apos;.
                  PERFORM bdc_field       USING &apos;PLKO-ZZITO_TK&apos; head_stat_ghz-number_tk.&quot;Номер ТК
                  SELECT SINGLE * FROM  T351X WHERE SPRAS = SY-LANGU AND STRAT = head_stat_ghz-kod_str AND PAKET = Z_T351P-ZAEHL.
                  perform bdc_field       using &apos;PLKO-ZZITO_ILART&apos;
                                       T351X-KTXHI.

                  perform bdc_dynpro      using &apos;SAPLCLCA&apos; &apos;0602&apos;.
                  perform bdc_field       using &apos;BDC_CURSOR&apos;
                                                &apos;RMCLF-KLART&apos;.
                  perform bdc_field       using &apos;BDC_OKCODE&apos;
                                                &apos;=ENTE&apos;.
                  perform bdc_field       using &apos;RMCLF-KLART&apos;
                                &apos;018&apos;.

                  PERFORM bdc_dynpro      USING &apos;SAPLCLFM&apos; &apos;0500&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                        &apos;RMCLF-CLASS(01)&apos;.
*                PERFORM bdc_field       USING &apos;RMCLF-CLASS(01)&apos;
*                      &apos;018&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                        &apos;/00&apos;.


                  PERFORM bdc_field       USING &apos;RMCLF-CLASS(01)&apos;
                        &apos;MARKA_TK&apos;.
                  PERFORM bdc_dynpro      USING &apos;SAPLCTMS&apos; &apos;0109&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                        &apos;RCTMS-MWERT(01)&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                        &apos;=BACK&apos;.
                  PERFORM bdc_field       USING &apos;RCTMS-MNAME(01)&apos;
                        &apos;MARKA_TK&apos;.
                  PERFORM bdc_field       USING &apos;RCTMS-MWERT(01)&apos;
                        head_stat_ghz-marka.
                  PERFORM bdc_dynpro      USING &apos;SAPLCLFM&apos; &apos;0500&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                        &apos;RMCLF-CLASS(01)&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                        &apos;=ENDE&apos;.
                  PERFORM bdc_field       USING &apos;RMCLF-PAGPOS&apos;
                        &apos;1&apos;.
                  PERFORM bdc_dynpro      USING &apos;SAPLCPDA&apos; &apos;3010&apos;.
                  ktext = name_eo+0(37).
                  CONCATENATE  T351X-KTXHI &apos;_&apos; ktext INTO ktext.

                  perform bdc_field       using &apos;BDC_CURSOR&apos;
                                      &apos;PLKOD-KTEXT&apos;.

                  PERFORM bdc_field       USING &apos;PLKOD-KTEXT&apos;
                        ktext.
*        perform bdc_field       using &apos;PLKOD-KTEXT&apos;
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                        &apos;=VOUE&apos;.
                else.
                  perform bdc_dynpro      using &apos;SAPLCPDI&apos; &apos;3400&apos;.
                  perform bdc_field       using &apos;BDC_CURSOR&apos;
                                                &apos;PLPOD-VORNR(01)&apos;.
                  perform bdc_field       using &apos;BDC_OKCODE&apos;
                                                &apos;=ALUE&apos;.
                  perform bdc_field       using &apos;RC27X-ENTRY_ACT&apos;
                                                &apos;1&apos;.
                  perform bdc_dynpro      using &apos;SAPLCPDI&apos; &apos;3200&apos;.
                  perform bdc_field       using &apos;BDC_CURSOR&apos;
                                                &apos;PLKOD-KTEXT(01)&apos;.
                  perform bdc_field       using &apos;BDC_OKCODE&apos;
                                                &apos;=ANLG&apos;.
                  perform bdc_dynpro      using &apos;SAPLCPDA&apos; &apos;3010&apos;.
                  perform bdc_field       using &apos;BDC_OKCODE&apos;
                                                &apos;=VOUE&apos;.
                  perform bdc_field       using &apos;PLKOD-PLNAL&apos;
                                                Z_T351P-ZAEHL.
                  SELECT SINGLE * FROM  T351X WHERE SPRAS = SY-LANGU AND STRAT = head_stat_ghz-kod_str AND PAKET = Z_T351P-ZAEHL.

                  ktext = name_eo+0(37).
                  CONCATENATE  T351X-KTXHI &apos;_&apos; ktext INTO ktext.

                  perform bdc_field       using &apos;BDC_CURSOR&apos;
                                      &apos;PLKOD-KTEXT&apos;.

                  PERFORM bdc_field       USING &apos;PLKOD-KTEXT&apos;
                        ktext.
                  perform bdc_field       using &apos;PLKOD-VERWE&apos;
                                                &apos;GNS&apos;.
                  PERFORM bdc_field       USING &apos;PLKOD-VAGRP&apos;
                        head_stat_ghz-gr_pl.&quot;Группа планирования
                  perform bdc_field       using &apos;PLKOD-STATU&apos;
                                                &apos;4&apos;.
                  perform bdc_field       using &apos;PLKOD-STRAT&apos;
                                                head_stat_ghz-kod_str.
                  perform bdc_field       using &apos;PLKO-ZZITO_ILART&apos;
                                                       T351X-KTXHI.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLKO-ZZITO_TK&apos;.
                  PERFORM bdc_field       USING &apos;PLKO-ZZITO_TK&apos; head_stat_ghz-number_tk.&quot;Номер ТК

                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                             &apos;=VOUE&apos;.

                ENDIF.
                z = 0.
*perform open_group.
                LOOP AT oper_stat_ghz WHERE number_tk = head_stat_ghz-number_tk .
                  FREE: zapis, ei_flag, nalichie_tk_flag, nomer_eo, trud1, trud2, trud_str, paket, nom_pak, kol_sm, naim_oper, naim_podop, mim_flag, zcode, TABfields, TABfields[],
                  GTS_MAT_line, GTS_MAT[].
                  zapis = sy-tabix.&quot;Номер строки файла операций
                  paket = oper_stat_ghz-znachimost_oper.

                  if paket is initial.

                    z = z + 1.
                    SELECT equnr INTO nomer_eo FROM equi WHERE zzito_tk_eo = oper_stat_ghz-eo.&quot;Поиск номера ЕО по тех коду
                    ENDSELECT.
                    PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                    PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
                    PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=EINF&apos;.
                    PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.

                    PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
*            PERFORM bdc_field       USING &apos;RC27X-ENTRY_ACT&apos; &apos;1&apos;.
                    PERFORM bdc_field       USING &apos;RC27X-FLG_SEL(01)&apos; &apos;X&apos;.




                    PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOEL&apos;.




                    PERFORM bdc_field       USING &apos;PLPOD-VORNR(01)&apos; oper_stat_ghz-number_oper.&quot;Номер операции
                    PERFORM bdc_field       USING &apos;PLPOD-KTSCH(01)&apos; oper_stat_ghz-kod_vd_oper.
                    PERFORM bdc_field       USING &apos;PLPOD-ARBPL(01)&apos; oper_stat_ghz-rab_mesto. &quot;Выполняющее рабочее место
                    PERFORM bdc_field       USING &apos;PLPOD-LTXA1(01)&apos; oper_stat_ghz-name_oper.&quot;Наименование операции (обрезанное)
                    PERFORM bdc_field       USING &apos;PLPOD-BMVRG(01)&apos; oper_stat_ghz-kol_rab.&quot;Кол-во работ
                    PERFORM bdc_field       USING &apos;PLPOD-BMEIH(01)&apos; oper_stat_ghz-ei_rab.&quot;Единица измерения
                    IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.&quot;Если работы на Р (сторонней орг.)
                      PERFORM bdc_field       USING &apos;PLPOD-SAKTO(01)&apos; &apos;39-0000000&apos;.&quot;Константа
                      PERFORM bdc_field       USING &apos;PLPOD-MATKL(01)&apos; &apos;TTK&apos;.&quot;Константа
                      PERFORM bdc_field       USING &apos;PLPOD-EKGRP(01)&apos; &apos;TTK&apos;.&quot;Константа
                    ENDIF.



                    &quot; { 10kvu 2016.10.24 Загрузка материалов (компоненты)
                    &quot; Если вводится операция (НЕ подоперация) - Перейти на экран ввода Компонентов и ввести материалы в цикле.

                    READ TABLE gt_materials WITH KEY  number_tk = oper_stat_ghz-number_tk number_oper = oper_stat_ghz-number_oper

                    eo = oper_stat_ghz-eo INTO gs_materials.

                    IF sy-subrc = 0.


                     LOOP AT gt_materials into fs_materials WHERE number_tk = oper_stat_ghz-number_tk AND
                      number_oper = oper_stat_ghz-number_oper AND
                      eo = oper_stat_ghz-eo.
                    MOVE-CORRESPONDING fs_materials to GTS_MAT_line.
                    APPEND GTS_MAT_line to GTS_MAT.
                      ENDLOOP.
        sort GTS_MAT by NUMBER_TK NUMBER_OPER id_mat.
        delete ADJACENT DUPLICATES FROM GTS_mat.

        LOOP AT GTS_mat into GTS_MAT_line.
    LOOP AT gt_materials into fs_materials WHERE eo = oper_stat_ghz-eo and
                    number_tk = GTS_MAT_line-number_tk AND
                      number_oper = GTS_MAT_line-number_oper AND id_mat = GTS_MAT_line-id_mat.
  if fs_materials-quant is NOT INITIAL.
TRANSLATE fs_materials-quant USING &apos;,.&apos;.
           S = GTS_MAT_line-quant_tt + fs_materials-quant.
GTS_MAT_line-quant_tt = S.
endif.
      endloop.
  TRANSLATE  GTS_MAT_line-quant_tt USING &apos;.,&apos;.
      modify GTS_mat from GTS_MAT_line.
        ENDLOOP.


*                      ASSIGN   gs_materials  TO &lt;fs_materials&gt;.
*
                      DATA:
                           lv_countstr           TYPE i VALUE 0,
                           lv_tmpstr(4)          TYPE c,
                            lv_oldoper           LIKE oper_stat_ghz-number_oper VALUE 0,
                            lv_intostrval         TYPE bdcdata-fval,
                            lv_intostrnam         TYPE bdcdata-fnam.




                      PERFORM bdc_dynpro     USING &apos;SAPLCPDO&apos; &apos;3370&apos;.
                      PERFORM bdc_field      USING &apos;BDC_CURSOR&apos; &apos;PLPOD-QUALF&apos;.
                      PERFORM bdc_field      USING &apos;BDC_OKCODE&apos; &apos;=MAPM&apos;.

                      LOOP AT GTS_mat into GTS_MAT_line WHERE number_tk = oper_stat_ghz-number_tk AND
                      number_oper = oper_stat_ghz-number_oper AND
                      eo = oper_stat_ghz-eo.

                        IF lv_oldoper &lt;&gt; oper_stat_ghz-number_oper.
                          lv_countstr = 1.
                        ELSE.
                          lv_countstr = lv_countstr + 1.
                        ENDIF.
                        lv_oldoper = oper_stat_ghz-number_oper.

                        lv_tmpstr = `(` &amp;&amp; lv_countstr &amp;&amp; `)`.
                        IF  lv_countstr MOD 10 = 0.

                          &quot; IF lv_oldOper &lt;&gt; DAN_OPER-N_OPER.
                          lv_countstr = 1.
                          &quot; ELSE.
                          &quot;lv_countSTR = lv_countSTR + 1.
                          &quot;ENDIF.

                          lv_tmpstr = `(` &amp;&amp; lv_countstr &amp;&amp; `)`.

                          lv_tmpstr = `(` &amp;&amp; lv_countstr &amp;&amp; `)`.
                          PERFORM bdc_dynpro      USING &apos;SAPLCMDI&apos; &apos;3500&apos;.
                          lv_intostrval = `RIHSTPX-IDNRK` &amp;&amp; lv_tmpstr.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                                lv_intostrval.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                                &apos;=P+&apos;.
                        ENDIF.
                        PERFORM bdc_dynpro      USING &apos;SAPLCMDI&apos; &apos;3500&apos;.

                        lv_intostrval = `RIHSTPX-IDNRK` &amp;&amp; lv_tmpstr.
                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                              lv_intostrval.
*                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
*                              &apos;/00&apos;.
                        lv_intostrnam = `RIHSTPX-IDNRK` &amp;&amp; lv_tmpstr.
                        PERFORM bdc_field       USING lv_intostrnam
                              GTS_MAT_line-id_mat.
                        lv_intostrnam = `RIHSTPX-MENGE` &amp;&amp; lv_tmpstr.
                        IF  GTS_MAT_line-quant_tt is INITIAL.
                          GTS_MAT_line-quant_tt = 0.
                        ENDIF.
                        PERFORM bdc_field       USING lv_intostrnam
                              GTS_MAT_line-quant_tt.
                        lv_intostrnam = `RIHSTPX-MEINS` &amp;&amp; lv_tmpstr.
                        PERFORM bdc_field       USING lv_intostrnam
                              GTS_MAT_line-ei.
*                        CLEAR: fs_materials.
                      ENDLOOP.

                      PERFORM bdc_dynpro        USING &apos;SAPLCMDI&apos; &apos;3500&apos;.
*              PERFORM BDC_FIELD         USING &apos;BDC_CURSOR&apos; &apos;PLPOD-LTXA1&apos;.
*              perform bdc_field       using &apos;PLPOD-LTXA1(01)&apos; OPER_STAT_GHZ-NAME_OPER.&quot;Наименование операции (обрезанное)
                      PERFORM bdc_field         USING &apos;BDC_OKCODE&apos;
                            &apos;=SVEL&apos;.

                    ENDIF.
                    &quot; } 10kvu 2016.10.24 Загрузка материалов (компоненты)



                    PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3370&apos;.
                    PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-QUALF&apos;.

                    &quot;Умножение трудоемкости на 10 (ограничение в количестве знаков после запятой)
                    TRANSLATE oper_stat_ghz-trudoemkost USING &apos;,.&apos;.
                    trud2 = oper_stat_ghz-trudoemkost.
                    trud1 = trud2.
                    trud_str = trud1.
                    TRANSLATE trud_str USING &apos;.,&apos;.
                    PERFORM bdc_field       USING &apos;PLPOD-ARBEI&apos; trud_str.&quot;Трудоемкость
                    PERFORM bdc_field       USING &apos;PLPOD-ARBEH&apos; &apos;Ч/Ч&apos;.&quot;Константа
                    PERFORM bdc_field       USING &apos;PLPOD-ANZZL&apos; oper_stat_ghz-kol_ispoln.&quot;Количество исполнителей
                    PERFORM bdc_field       USING &apos;PLPOD-QUALF&apos; oper_stat_ghz-specialnost.&quot;Специальность
                    PERFORM bdc_field       USING &apos;PLPOD-VORNR&apos; oper_stat_ghz-number_oper.&quot;Номер операции
                    PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.&quot;Наименование операции
                    PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.&quot;Рабочее место
                    PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                    IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.&quot;Если работы на Р (сторонней орг.)
                      PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                    ELSE.
                      PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                    ENDIF.
                    PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                    PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOFL&apos;.

                    PERFORM bdc_dynpro      USING &apos;ZPM_POLE_OPER_TK&apos; &apos;1000&apos;.
                    PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
                    SELECT SINGLE code FROM zpm_calc_eu INTO zcode WHERE source_justification = oper_stat_ghz-zzito_io.
                    IF oper_stat_ghz-zzito_kpr = &apos;1&apos;.
                      CLEAR oper_stat_ghz-zzito_ob_kpr.
                    ENDIF.
                    IF oper_stat_ghz-zzito_kur = &apos;1&apos;.
                      CLEAR oper_stat_ghz-zzito_ob_kur.
                    ENDIF.
                    IF oper_stat_ghz-zzito_ob_kur IS NOT INITIAL.
                      READ TABLE z_dd07t WITH  KEY ddtext = oper_stat_ghz-zzito_ob_kur.
                      IF  sy-subrc = 0.
                        oper_stat_ghz-zzito_ob_kur = z_dd07t-valpos+3(1).
                      ENDIF.
                    ENDIF.
                    PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD_IMP_POLZ-ZZITO_OB_KPR&apos;.
                    PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_IO&apos; zcode.&quot;Код обоснования
                    PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_KPR&apos; oper_stat_ghz-zzito_kpr.&quot;КОЭФФИЦИЕНТ ПРОИЗВОДСТВА РАБОТ
                    PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_OB_KPR&apos; oper_stat_ghz-zzito_ob_kpr.&quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА ПРОИЗВОДСТВА РАБОТ
                    PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_KUR&apos; oper_stat_ghz-zzito_kur.&quot;КОЭФФИЦИЕНТ УСЛОВИЯ РАБОТ
                    PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_OB_KUR&apos; oper_stat_ghz-zzito_ob_kur.&quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА УСЛОВИЙ РАБОТ
                    PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_KR&apos; oper_stat_ghz-zzito_kr.&quot;Квалификационный разряд
                    PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=BACK&apos;.


                    PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3380&apos;.
                    PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOUE&apos;.
                    PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                    PERFORM bdc_field       USING &apos;PLPOD-BMVRG&apos; oper_stat_ghz-kol_rab.
                    PERFORM bdc_field       USING &apos;PLPOD-BMEIH&apos; oper_stat_ghz-ei_rab.
                    IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                      PERFORM bdc_field       USING &apos;PLPOD-SAKTO&apos; &apos;39-0000000&apos;.
                      PERFORM bdc_field       USING &apos;PLPOD-MATKL&apos; &apos;TTK&apos;.
                      PERFORM bdc_field       USING &apos;PLPOD-EKGRP&apos; &apos;TTK&apos;.
                    ENDIF.
                    PERFORM bdc_field       USING &apos;PLPOD-WAERS&apos; &apos;RUB&apos;.
                    PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR&apos;.
                    PERFORM bdc_field       USING &apos;PLPOD-VORNR&apos; oper_stat_ghz-number_oper.
                    PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                    PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.
                    PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                    IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                      PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                    ELSE.
                      PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                    ENDIF.
                    PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                    IF head_stat_ghz-kod_str IS NOT INITIAL AND oper_stat_ghz-znachimost_oper IS NOT INITIAL.
                      PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(02)&apos;.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=WPLT&apos;.
                      PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3600&apos;.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=IWPZ&apos;.
                      PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
*                  paket = oper_stat_ghz-znachimost_oper.
* Подсчет количества пакетов
*                  DO.
*                    SEARCH paket FOR &apos;/&apos;.&quot;Разделение по знаку &quot;/&quot;
*                    IF sy-subrc &lt;&gt; 0.&quot;Последний пакет
*                      MOVE paket(1) TO nom_pak.
*                      if nom_pak = Z_T351P-ZAEHL+1(1).
*                        CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
*                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=WPLZ&apos;.
*                        PERFORM bdc_dynpro      USING &apos;SAPLIPM5&apos; &apos;0100&apos;.
*                        CONCATENATE &apos;PAKET_TAB-KZYK1(0&apos; nom_pak &apos;)&apos; INTO help.
*                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; help.
*                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=ENTR&apos;.
*                        FREE help.
*                        CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
*                        PERFORM bdc_field       USING help &apos;X&apos;.
*                        PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
*                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
*                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
*                        EXIT.
*                      ENDIF.
*                    ELSE.
*                      if nom_pak = Z_T351P-ZAEHL+1(1).
*                        kol_sm = sy-fdpos + 1.
*                        MOVE paket(1) TO nom_pak.
*                        MOVE paket+kol_sm TO paket.
*                        CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
*                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=WPLZ&apos;.
*                        PERFORM bdc_dynpro      USING &apos;SAPLIPM5&apos; &apos;0100&apos;.
*                        CONCATENATE &apos;PAKET_TAB-KZYK1(0&apos; nom_pak &apos;)&apos; INTO help.
*                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; help.
*                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=ENTR&apos;.
*                        FREE help.
*                        CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
*                        PERFORM bdc_field       USING help &apos;X&apos;.
*                        PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
*                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
*                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
*                      ENDIF.
*                    ENDIF.
*                  ENDDO.
                      PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=SVUE&apos;.
                    ENDIF.
                    IF head_stat_ghz-kod_str IS NOT INITIAL .
*              AND OPER_STAT_GHZ-NAME_PAK NE &apos;&apos;.
                      PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(02)&apos;.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOUS&apos;.
                      PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3100&apos;.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-SLWID&apos;.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
                      PERFORM bdc_field       USING &apos;PLPOD-SLWID&apos; &apos;PM00005&apos;.

*
                      PERFORM bdc_field       USING &apos;PLPOD-USR02&apos; oper_stat_ghz-num_first_oper.
                      PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                      PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.

                      PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                      IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                        PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                      ELSE.
                        PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                      ENDIF.
                      PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                      PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3100&apos;.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-USR02&apos;.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOUE&apos;.
                      PERFORM bdc_field       USING &apos;PLPOD-SLWID&apos; &apos;PM00005&apos;.
                      IF oper_stat_ghz-num_komp_op IS NOT INITIAL.
                        PERFORM bdc_field       USING &apos;PLPOD-USR02&apos; oper_stat_ghz-num_komp_op.
                      ENDIF.

                      PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                      PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.

                      PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                      IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                        PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                      ELSE.
                        PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                      ENDIF.
                      PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                    ENDIF.
                    mim_flag = 0.
                    LOOP AT mim_table.&quot;Поиск МиМ у операции
                      IF mim_table-number_oper = oper_stat_ghz-number_oper AND mim_table-number_tk = oper_stat_ghz-number_tk.
                        mim_flag = 1.&quot;Фиксирование наличия МиМ
                      ENDIF.
                    ENDLOOP.
                    IF mim_flag = 1.&quot;Если МиМ найдено
                      PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(02)&apos;.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=FHUE&apos;.
                      PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0200&apos;.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/EFIS&apos;.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-PSNFH&apos;.
                      LOOP AT mim_table.&quot;Проходим по всем МиМ
                        IF mim_table-number_oper = oper_stat_ghz-number_oper AND mim_table-number_tk = oper_stat_ghz-number_tk.
                          PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0210&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-STEUF&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=EINF&apos;.
                          PERFORM bdc_field       USING &apos;PLFHD-SFHNR&apos; mim_table-kod_mim.&quot;Код МиМ
                          PERFORM bdc_field       USING &apos;PLFHD-MGVGW&apos; mim_table-kolvo.&quot;Количество
                          PERFORM bdc_field       USING &apos;PLFHD-MGEINH&apos; &apos;М-Ч&apos;.
                          PERFORM bdc_field       USING &apos;PLFHD-STEUF&apos; &apos;1&apos;.
                        ENDIF.
                      ENDLOOP.
                      PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0210&apos;.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/EESC&apos;.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-PSNFH&apos;.
                      PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0102&apos;.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-STEUF(01)&apos;.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=SVUE&apos;.
                    ENDIF.

                    PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                    PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=MALO&apos;.
                  else.
                    SEARCH paket FOR &apos;/&apos;.&quot;Разделение по знаку &quot;/&quot;
                    IF sy-subrc = 0.
                      split paket at &apos;/&apos; into table TABfields.
                      read  TABLE  TABfields with key col = Z_T351P-ZAEHL+1(1).

                      IF sy-subrc = 0.



                        z = z + 1.
                        SELECT equnr INTO nomer_eo FROM equi WHERE zzito_tk_eo = oper_stat_ghz-eo.&quot;Поиск номера ЕО по тех коду
                        ENDSELECT.
                        PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=EINF&apos;.
                        PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.

                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
*            PERFORM bdc_field       USING &apos;RC27X-ENTRY_ACT&apos; &apos;1&apos;.
                        PERFORM bdc_field       USING &apos;RC27X-FLG_SEL(01)&apos; &apos;X&apos;.




                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOEL&apos;.




                        PERFORM bdc_field       USING &apos;PLPOD-VORNR(01)&apos; oper_stat_ghz-number_oper.&quot;Номер операции
                        PERFORM bdc_field       USING &apos;PLPOD-KTSCH(01)&apos; oper_stat_ghz-kod_vd_oper.
                        PERFORM bdc_field       USING &apos;PLPOD-ARBPL(01)&apos; oper_stat_ghz-rab_mesto. &quot;Выполняющее рабочее место
                        PERFORM bdc_field       USING &apos;PLPOD-LTXA1(01)&apos; oper_stat_ghz-name_oper.&quot;Наименование операции (обрезанное)
                        PERFORM bdc_field       USING &apos;PLPOD-BMVRG(01)&apos; oper_stat_ghz-kol_rab.&quot;Кол-во работ
                        PERFORM bdc_field       USING &apos;PLPOD-BMEIH(01)&apos; oper_stat_ghz-ei_rab.&quot;Единица измерения
                        IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.&quot;Если работы на Р (сторонней орг.)
                          PERFORM bdc_field       USING &apos;PLPOD-SAKTO(01)&apos; &apos;39-0000000&apos;.&quot;Константа
                          PERFORM bdc_field       USING &apos;PLPOD-MATKL(01)&apos; &apos;TTK&apos;.&quot;Константа
                          PERFORM bdc_field       USING &apos;PLPOD-EKGRP(01)&apos; &apos;TTK&apos;.&quot;Константа
                        ENDIF.



                        &quot; { 10kvu 2016.10.24 Загрузка материалов (компоненты)
                        &quot; Если вводится операция (НЕ подоперация) - Перейти на экран ввода Компонентов и ввести материалы в цикле.

                        READ TABLE gt_materials WITH KEY  number_tk = oper_stat_ghz-number_tk number_oper = oper_stat_ghz-number_oper

                        eo = oper_stat_ghz-eo INTO gs_materials.

                        IF sy-subrc = 0.

                     LOOP AT gt_materials into fs_materials WHERE number_tk = oper_stat_ghz-number_tk AND
                      number_oper = oper_stat_ghz-number_oper AND
                      eo = oper_stat_ghz-eo.
                    MOVE-CORRESPONDING fs_materials to GTS_MAT_line.
                    APPEND GTS_MAT_line to GTS_MAT.
                      ENDLOOP.
        sort GTS_MAT by NUMBER_TK NUMBER_OPER id_mat.
        delete ADJACENT DUPLICATES FROM GTS_mat.

        LOOP AT GTS_mat into GTS_MAT_line.
    LOOP AT gt_materials into fs_materials WHERE eo = oper_stat_ghz-eo and
                    number_tk = GTS_MAT_line-number_tk AND

                      number_oper = GTS_MAT_line-number_oper AND id_mat = GTS_MAT_line-id_mat.
      if fs_materials-quant is NOT INITIAL.
TRANSLATE fs_materials-quant USING &apos;,.&apos;.
           S = GTS_MAT_line-quant_tt + fs_materials-quant.
GTS_MAT_line-quant_tt = S.
endif.
      endloop.
  TRANSLATE  GTS_MAT_line-quant_tt USING &apos;.,&apos;.

      modify GTS_mat from GTS_MAT_line.
        ENDLOOP.



*                          ASSIGN   gs_materials  TO &lt;fs_materials&gt;.

                          &quot;DATA:
                          &quot;lv_countstr           TYPE i VALUE 0,
                          &quot;lv_tmpstr(4)          TYPE c,
                          &quot;lv_oldoper           LIKE oper_stat_ghz-number_oper VALUE 0,
                          &quot;lv_intostrval         TYPE bdcdata-fval,
                          &quot;lv_intostrnam         TYPE bdcdata-fnam.




                          PERFORM bdc_dynpro     USING &apos;SAPLCPDO&apos; &apos;3370&apos;.
                          PERFORM bdc_field      USING &apos;BDC_CURSOR&apos; &apos;PLPOD-QUALF&apos;.
                          PERFORM bdc_field      USING &apos;BDC_OKCODE&apos; &apos;=MAPM&apos;.

                          LOOP AT GTS_mat into GTS_MAT_line WHERE number_tk = oper_stat_ghz-number_tk AND
                          number_oper = oper_stat_ghz-number_oper AND
                          eo = oper_stat_ghz-eo.

                            IF lv_oldoper &lt;&gt; oper_stat_ghz-number_oper.
                              lv_countstr = 1.
                            ELSE.
                              lv_countstr = lv_countstr + 1.
                            ENDIF.
                            lv_oldoper = oper_stat_ghz-number_oper.

                            lv_tmpstr = `(` &amp;&amp; lv_countstr &amp;&amp; `)`.
                            IF  lv_countstr MOD 10 = 0.

                              &quot; IF lv_oldOper &lt;&gt; DAN_OPER-N_OPER.
                              lv_countstr = 1.
                              &quot; ELSE.
                              &quot;lv_countSTR = lv_countSTR + 1.
                              &quot;ENDIF.

                              lv_tmpstr = `(` &amp;&amp; lv_countstr &amp;&amp; `)`.

                              lv_tmpstr = `(` &amp;&amp; lv_countstr &amp;&amp; `)`.
                              PERFORM bdc_dynpro      USING &apos;SAPLCMDI&apos; &apos;3500&apos;.
                              lv_intostrval = `RIHSTPX-IDNRK` &amp;&amp; lv_tmpstr.
                              PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                                    lv_intostrval.
                              PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                                    &apos;=P+&apos;.
                            ENDIF.
                            PERFORM bdc_dynpro      USING &apos;SAPLCMDI&apos; &apos;3500&apos;.

                            lv_intostrval = `RIHSTPX-IDNRK` &amp;&amp; lv_tmpstr.
                            PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                                  lv_intostrval.
                            PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                                  &apos;/00&apos;.
                            lv_intostrnam = `RIHSTPX-IDNRK` &amp;&amp; lv_tmpstr.
                            PERFORM bdc_field       USING lv_intostrnam
                                  GTS_MAT_line-id_mat.
                            lv_intostrnam = `RIHSTPX-MENGE` &amp;&amp; lv_tmpstr.
                            IF  GTS_MAT_line-quant_tt is INITIAL.
                              GTS_MAT_line-quant_tt = 0.
                            ENDIF.
                            PERFORM bdc_field       USING lv_intostrnam
                                  GTS_MAT_line-quant_tt.
                            lv_intostrnam = `RIHSTPX-MEINS` &amp;&amp; lv_tmpstr.
                            PERFORM bdc_field       USING lv_intostrnam
                                  GTS_MAT_line-ei.
*                            CLEAR: &lt;fs_materials&gt;.
                          ENDLOOP.

                          PERFORM bdc_dynpro        USING &apos;SAPLCMDI&apos; &apos;3500&apos;.
*              PERFORM BDC_FIELD         USING &apos;BDC_CURSOR&apos; &apos;PLPOD-LTXA1&apos;.
*              perform bdc_field       using &apos;PLPOD-LTXA1(01)&apos; OPER_STAT_GHZ-NAME_OPER.&quot;Наименование операции (обрезанное)
                          PERFORM bdc_field         USING &apos;BDC_OKCODE&apos;
                                &apos;=SVEL&apos;.

                        ENDIF.
                        &quot; } 10kvu 2016.10.24 Загрузка материалов (компоненты)



                        PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3370&apos;.
                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-QUALF&apos;.

                        &quot;Умножение трудоемкости на 10 (ограничение в количестве знаков после запятой)
                        TRANSLATE oper_stat_ghz-trudoemkost USING &apos;,.&apos;.
                        trud2 = oper_stat_ghz-trudoemkost.
                        trud1 = trud2.
                        trud_str = trud1.
                        TRANSLATE trud_str USING &apos;.,&apos;.
                        PERFORM bdc_field       USING &apos;PLPOD-ARBEI&apos; trud_str.&quot;Трудоемкость
                        PERFORM bdc_field       USING &apos;PLPOD-ARBEH&apos; &apos;Ч/Ч&apos;.&quot;Константа
                        PERFORM bdc_field       USING &apos;PLPOD-ANZZL&apos; oper_stat_ghz-kol_ispoln.&quot;Количество исполнителей
                        PERFORM bdc_field       USING &apos;PLPOD-QUALF&apos; oper_stat_ghz-specialnost.&quot;Специальность
                        PERFORM bdc_field       USING &apos;PLPOD-VORNR&apos; oper_stat_ghz-number_oper.&quot;Номер операции
                        PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.&quot;Наименование операции
                        PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.&quot;Рабочее место
                        PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                        IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.&quot;Если работы на Р (сторонней орг.)
                          PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                        ELSE.
                          PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                        ENDIF.
                        PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOFL&apos;.

                        PERFORM bdc_dynpro      USING &apos;ZPM_POLE_OPER_TK&apos; &apos;1000&apos;.
                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
                        SELECT SINGLE code FROM zpm_calc_eu INTO zcode WHERE source_justification = oper_stat_ghz-zzito_io.
                        IF oper_stat_ghz-zzito_kpr = &apos;1&apos;.
                          CLEAR oper_stat_ghz-zzito_ob_kpr.
                        ENDIF.
                        IF oper_stat_ghz-zzito_kur = &apos;1&apos;.
                          CLEAR oper_stat_ghz-zzito_ob_kur.
                        ENDIF.
                        IF oper_stat_ghz-zzito_ob_kur IS NOT INITIAL.
                          READ TABLE z_dd07t WITH  KEY ddtext = oper_stat_ghz-zzito_ob_kur.
                          IF  sy-subrc = 0.
                            oper_stat_ghz-zzito_ob_kur = z_dd07t-valpos+3(1).
                          ENDIF.
                        ENDIF.
                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD_IMP_POLZ-ZZITO_OB_KPR&apos;.
                        PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_IO&apos; zcode.&quot;Код обоснования
                        PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_KPR&apos; oper_stat_ghz-zzito_kpr.&quot;КОЭФФИЦИЕНТ ПРОИЗВОДСТВА РАБОТ
                        PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_OB_KPR&apos; oper_stat_ghz-zzito_ob_kpr.&quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА ПРОИЗВОДСТВА РАБОТ
                        PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_KUR&apos; oper_stat_ghz-zzito_kur.&quot;КОЭФФИЦИЕНТ УСЛОВИЯ РАБОТ
                        PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_OB_KUR&apos; oper_stat_ghz-zzito_ob_kur.&quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА УСЛОВИЙ РАБОТ
                        PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_KR&apos; oper_stat_ghz-zzito_kr.&quot;Квалификационный разряд
                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=BACK&apos;.


                        PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3380&apos;.
                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOUE&apos;.
                        PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                        PERFORM bdc_field       USING &apos;PLPOD-BMVRG&apos; oper_stat_ghz-kol_rab.
                        PERFORM bdc_field       USING &apos;PLPOD-BMEIH&apos; oper_stat_ghz-ei_rab.
                        IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                          PERFORM bdc_field       USING &apos;PLPOD-SAKTO&apos; &apos;39-0000000&apos;.
                          PERFORM bdc_field       USING &apos;PLPOD-MATKL&apos; &apos;TTK&apos;.
                          PERFORM bdc_field       USING &apos;PLPOD-EKGRP&apos; &apos;TTK&apos;.
                        ENDIF.
                        PERFORM bdc_field       USING &apos;PLPOD-WAERS&apos; &apos;RUB&apos;.
                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR&apos;.
                        PERFORM bdc_field       USING &apos;PLPOD-VORNR&apos; oper_stat_ghz-number_oper.
                        PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                        PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.
                        PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                        IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                          PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                        ELSE.
                          PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                        ENDIF.
                        PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                        IF head_stat_ghz-kod_str IS NOT INITIAL AND oper_stat_ghz-znachimost_oper IS NOT INITIAL.
                          PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(02)&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=WPLT&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3600&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=IWPZ&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
*                  paket = oper_stat_ghz-znachimost_oper.
* Подсчет количества пакетов
*                  DO.
*                    SEARCH paket FOR &apos;/&apos;.&quot;Разделение по знаку &quot;/&quot;
*                    IF sy-subrc &lt;&gt; 0.&quot;Последний пакет
                          MOVE Z_T351P-ZAEHL+1(1) TO nom_pak.
*                      if nom_pak = Z_T351P-ZAEHL+1(1).
                          CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=WPLZ&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLIPM5&apos; &apos;0100&apos;.
                          CONCATENATE &apos;PAKET_TAB-KZYK1(0&apos; nom_pak &apos;)&apos; INTO help.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; help.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=ENTR&apos;.
                          FREE help.
                          CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
                          PERFORM bdc_field       USING help &apos;X&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
*                        EXIT.
*                      ENDIF.
*                    ELSE.
*                      if nom_pak = Z_T351P-ZAEHL+1(1).
*                        kol_sm = sy-fdpos + 1.
*                        MOVE paket(1) TO nom_pak.
*                        MOVE paket+kol_sm TO paket.
*                        CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
*                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=WPLZ&apos;.
*                        PERFORM bdc_dynpro      USING &apos;SAPLIPM5&apos; &apos;0100&apos;.
*                        CONCATENATE &apos;PAKET_TAB-KZYK1(0&apos; nom_pak &apos;)&apos; INTO help.
*                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; help.
*                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=ENTR&apos;.
*                        FREE help.
*                        CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
*                        PERFORM bdc_field       USING help &apos;X&apos;.
*                        PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
*                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
*                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
*                      ENDIF.
*                    ENDIF.
*                  ENDDO.
                          PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=SVUE&apos;.
                        ENDIF.
                        IF head_stat_ghz-kod_str IS NOT INITIAL .
*              AND OPER_STAT_GHZ-NAME_PAK NE &apos;&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(02)&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOUS&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3100&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-SLWID&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
                          PERFORM bdc_field       USING &apos;PLPOD-SLWID&apos; &apos;PM00005&apos;.

*
                          PERFORM bdc_field       USING &apos;PLPOD-USR02&apos; oper_stat_ghz-num_first_oper.
                          PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                          PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.

                          PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                          IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                            PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                          ELSE.
                            PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                          ENDIF.
                          PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3100&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-USR02&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOUE&apos;.
                          PERFORM bdc_field       USING &apos;PLPOD-SLWID&apos; &apos;PM00005&apos;.
                          IF oper_stat_ghz-num_komp_op IS NOT INITIAL.
                            PERFORM bdc_field       USING &apos;PLPOD-USR02&apos; oper_stat_ghz-num_komp_op.
                          ENDIF.

                          PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                          PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.

                          PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                          IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                            PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                          ELSE.
                            PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                          ENDIF.
                          PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                        ENDIF.
                        mim_flag = 0.
                        LOOP AT mim_table.&quot;Поиск МиМ у операции
                          IF mim_table-number_oper = oper_stat_ghz-number_oper AND mim_table-number_tk = oper_stat_ghz-number_tk.
                            mim_flag = 1.&quot;Фиксирование наличия МиМ
                          ENDIF.
                        ENDLOOP.
                        IF mim_flag = 1.&quot;Если МиМ найдено
                          PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(02)&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=FHUE&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0200&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/EFIS&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-PSNFH&apos;.
                          LOOP AT mim_table.&quot;Проходим по всем МиМ
                            IF mim_table-number_oper = oper_stat_ghz-number_oper AND mim_table-number_tk = oper_stat_ghz-number_tk.
                              PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0210&apos;.
                              PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-STEUF&apos;.
                              PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=EINF&apos;.
                              PERFORM bdc_field       USING &apos;PLFHD-SFHNR&apos; mim_table-kod_mim.&quot;Код МиМ
                              PERFORM bdc_field       USING &apos;PLFHD-MGVGW&apos; mim_table-kolvo.&quot;Количество
                              PERFORM bdc_field       USING &apos;PLFHD-MGEINH&apos; &apos;М-Ч&apos;.
                              PERFORM bdc_field       USING &apos;PLFHD-STEUF&apos; &apos;1&apos;.
                            ENDIF.
                          ENDLOOP.
                          PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0210&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/EESC&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-PSNFH&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0102&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-STEUF(01)&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=SVUE&apos;.
                        ENDIF.

                        PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=MALO&apos;.
                      ENDIF.



                    else.

                      SEARCH paket FOR  Z_T351P-ZAEHL+1(1).

                      IF sy-subrc = 0.

                        z = z + 1.
                        SELECT equnr INTO nomer_eo FROM equi WHERE zzito_tk_eo = oper_stat_ghz-eo.&quot;Поиск номера ЕО по тех коду
                        ENDSELECT.
                        PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=EINF&apos;.
                        PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.

                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
*            PERFORM bdc_field       USING &apos;RC27X-ENTRY_ACT&apos; &apos;1&apos;.
                        PERFORM bdc_field       USING &apos;RC27X-FLG_SEL(01)&apos; &apos;X&apos;.




                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOEL&apos;.




                        PERFORM bdc_field       USING &apos;PLPOD-VORNR(01)&apos; oper_stat_ghz-number_oper.&quot;Номер операции
                        PERFORM bdc_field       USING &apos;PLPOD-KTSCH(01)&apos; oper_stat_ghz-kod_vd_oper.
                        PERFORM bdc_field       USING &apos;PLPOD-ARBPL(01)&apos; oper_stat_ghz-rab_mesto. &quot;Выполняющее рабочее место
                        PERFORM bdc_field       USING &apos;PLPOD-LTXA1(01)&apos; oper_stat_ghz-name_oper.&quot;Наименование операции (обрезанное)
                        PERFORM bdc_field       USING &apos;PLPOD-BMVRG(01)&apos; oper_stat_ghz-kol_rab.&quot;Кол-во работ
                        PERFORM bdc_field       USING &apos;PLPOD-BMEIH(01)&apos; oper_stat_ghz-ei_rab.&quot;Единица измерения
                        IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.&quot;Если работы на Р (сторонней орг.)
                          PERFORM bdc_field       USING &apos;PLPOD-SAKTO(01)&apos; &apos;39-0000000&apos;.&quot;Константа
                          PERFORM bdc_field       USING &apos;PLPOD-MATKL(01)&apos; &apos;TTK&apos;.&quot;Константа
                          PERFORM bdc_field       USING &apos;PLPOD-EKGRP(01)&apos; &apos;TTK&apos;.&quot;Константа
                        ENDIF.



                        &quot; { 10kvu 2016.10.24 Загрузка материалов (компоненты)
                        &quot; Если вводится операция (НЕ подоперация) - Перейти на экран ввода Компонентов и ввести материалы в цикле.

                        READ TABLE gt_materials WITH KEY  number_tk = oper_stat_ghz-number_tk number_oper = oper_stat_ghz-number_oper

                        eo = oper_stat_ghz-eo INTO gs_materials.

                        IF sy-subrc = 0.

          LOOP AT gt_materials into fs_materials WHERE number_tk = oper_stat_ghz-number_tk AND
                      number_oper = oper_stat_ghz-number_oper AND
                      eo = oper_stat_ghz-eo.
                    MOVE-CORRESPONDING fs_materials to GTS_MAT_line.
                    APPEND GTS_MAT_line to GTS_MAT.
                      ENDLOOP.
        sort GTS_MAT by NUMBER_TK NUMBER_OPER id_mat.
        delete ADJACENT DUPLICATES FROM GTS_mat.

        LOOP AT GTS_mat into GTS_MAT_line.
    LOOP AT gt_materials into fs_materials WHERE eo = oper_stat_ghz-eo and
                    number_tk = GTS_MAT_line-number_tk AND
                      number_oper = GTS_MAT_line-number_oper AND id_mat = GTS_MAT_line-id_mat.
    if fs_materials-quant is NOT INITIAL.
TRANSLATE fs_materials-quant USING &apos;,.&apos;.
           S = GTS_MAT_line-quant_tt + fs_materials-quant.
GTS_MAT_line-quant_tt = S.
endif.
      endloop.
  TRANSLATE  GTS_MAT_line-quant_tt USING &apos;.,&apos;.
      modify GTS_mat from GTS_MAT_line.
        ENDLOOP.



*                          ASSIGN   gs_materials  TO &lt;fs_materials&gt;.

*                        DATA:
*                              lv_countstr           TYPE i VALUE 0,
*                              lv_tmpstr(4)          TYPE c,
*                              lv_oldoper           LIKE oper_stat_ghz-number_oper VALUE 0,
*                              lv_intostrval         TYPE bdcdata-fval,
*                              lv_intostrnam         TYPE bdcdata-fnam.




                          PERFORM bdc_dynpro     USING &apos;SAPLCPDO&apos; &apos;3370&apos;.
                          PERFORM bdc_field      USING &apos;BDC_CURSOR&apos; &apos;PLPOD-QUALF&apos;.
                          PERFORM bdc_field      USING &apos;BDC_OKCODE&apos; &apos;=MAPM&apos;.

                          LOOP AT GTS_mat into GTS_MAT_line WHERE number_tk = oper_stat_ghz-number_tk AND
                          number_oper = oper_stat_ghz-number_oper AND
                          eo = oper_stat_ghz-eo.

                            IF lv_oldoper &lt;&gt; oper_stat_ghz-number_oper.
                              lv_countstr = 1.
                            ELSE.
                              lv_countstr = lv_countstr + 1.
                            ENDIF.
                            lv_oldoper = oper_stat_ghz-number_oper.

                            lv_tmpstr = `(` &amp;&amp; lv_countstr &amp;&amp; `)`.
                            IF  lv_countstr MOD 10 = 0.

                              &quot; IF lv_oldOper &lt;&gt; DAN_OPER-N_OPER.
                              lv_countstr = 1.
                              &quot; ELSE.
                              &quot;lv_countSTR = lv_countSTR + 1.
                              &quot;ENDIF.

                              lv_tmpstr = `(` &amp;&amp; lv_countstr &amp;&amp; `)`.

                              lv_tmpstr = `(` &amp;&amp; lv_countstr &amp;&amp; `)`.
                              PERFORM bdc_dynpro      USING &apos;SAPLCMDI&apos; &apos;3500&apos;.
                              lv_intostrval = `RIHSTPX-IDNRK` &amp;&amp; lv_tmpstr.
                              PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                                    lv_intostrval.
                              PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                                    &apos;=P+&apos;.
                            ENDIF.
                            PERFORM bdc_dynpro      USING &apos;SAPLCMDI&apos; &apos;3500&apos;.

                            lv_intostrval = `RIHSTPX-IDNRK` &amp;&amp; lv_tmpstr.
                            PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                                  lv_intostrval.
                            PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                                  &apos;/00&apos;.
                            lv_intostrnam = `RIHSTPX-IDNRK` &amp;&amp; lv_tmpstr.
                            PERFORM bdc_field       USING lv_intostrnam
                                   GTS_MAT_line-id_mat.
                            lv_intostrnam = `RIHSTPX-MENGE` &amp;&amp; lv_tmpstr.
                            IF   GTS_MAT_line-quant_tt is INITIAL.
                               GTS_MAT_line-quant_tt = 0.
                            ENDIF.

                            PERFORM bdc_field       USING lv_intostrnam
                                   GTS_MAT_line-quant_tt.
                            lv_intostrnam = `RIHSTPX-MEINS` &amp;&amp; lv_tmpstr.
                            PERFORM bdc_field       USING lv_intostrnam
                                   GTS_MAT_line-ei.
*                            CLEAR: fs_materials.
                          ENDLOOP.

                          PERFORM bdc_dynpro        USING &apos;SAPLCMDI&apos; &apos;3500&apos;.
*              PERFORM BDC_FIELD         USING &apos;BDC_CURSOR&apos; &apos;PLPOD-LTXA1&apos;.
*              perform bdc_field       using &apos;PLPOD-LTXA1(01)&apos; OPER_STAT_GHZ-NAME_OPER.&quot;Наименование операции (обрезанное)
                          PERFORM bdc_field         USING &apos;BDC_OKCODE&apos;
                                &apos;=SVEL&apos;.

                        ENDIF.
                        &quot; } 10kvu 2016.10.24 Загрузка материалов (компоненты)



                        PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3370&apos;.
                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-QUALF&apos;.

                        &quot;Умножение трудоемкости на 10 (ограничение в количестве знаков после запятой)
                        TRANSLATE oper_stat_ghz-trudoemkost USING &apos;,.&apos;.
                        trud2 = oper_stat_ghz-trudoemkost.
                        trud1 = trud2.
                        trud_str = trud1.
                        TRANSLATE trud_str USING &apos;.,&apos;.
                        PERFORM bdc_field       USING &apos;PLPOD-ARBEI&apos; trud_str.&quot;Трудоемкость
                        PERFORM bdc_field       USING &apos;PLPOD-ARBEH&apos; &apos;Ч/Ч&apos;.&quot;Константа
                        PERFORM bdc_field       USING &apos;PLPOD-ANZZL&apos; oper_stat_ghz-kol_ispoln.&quot;Количество исполнителей
                        PERFORM bdc_field       USING &apos;PLPOD-QUALF&apos; oper_stat_ghz-specialnost.&quot;Специальность
                        PERFORM bdc_field       USING &apos;PLPOD-VORNR&apos; oper_stat_ghz-number_oper.&quot;Номер операции
                        PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.&quot;Наименование операции
                        PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.&quot;Рабочее место
                        PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                        IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.&quot;Если работы на Р (сторонней орг.)
                          PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                        ELSE.
                          PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                        ENDIF.
                        PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOFL&apos;.

                        PERFORM bdc_dynpro      USING &apos;ZPM_POLE_OPER_TK&apos; &apos;1000&apos;.
                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
                        SELECT SINGLE code FROM zpm_calc_eu INTO zcode WHERE source_justification = oper_stat_ghz-zzito_io.
                        IF oper_stat_ghz-zzito_kpr = &apos;1&apos;.
                          CLEAR oper_stat_ghz-zzito_ob_kpr.
                        ENDIF.
                        IF oper_stat_ghz-zzito_kur = &apos;1&apos;.
                          CLEAR oper_stat_ghz-zzito_ob_kur.
                        ENDIF.
                        IF oper_stat_ghz-zzito_ob_kur IS NOT INITIAL.
                          READ TABLE z_dd07t WITH  KEY ddtext = oper_stat_ghz-zzito_ob_kur.
                          IF  sy-subrc = 0.
                            oper_stat_ghz-zzito_ob_kur = z_dd07t-valpos+3(1).
                          ENDIF.
                        ENDIF.
                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD_IMP_POLZ-ZZITO_OB_KPR&apos;.
                        PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_IO&apos; zcode.&quot;Код обоснования
                        PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_KPR&apos; oper_stat_ghz-zzito_kpr.&quot;КОЭФФИЦИЕНТ ПРОИЗВОДСТВА РАБОТ
                        PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_OB_KPR&apos; oper_stat_ghz-zzito_ob_kpr.&quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА ПРОИЗВОДСТВА РАБОТ
                        PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_KUR&apos; oper_stat_ghz-zzito_kur.&quot;КОЭФФИЦИЕНТ УСЛОВИЯ РАБОТ
                        PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_OB_KUR&apos; oper_stat_ghz-zzito_ob_kur.&quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА УСЛОВИЙ РАБОТ
                        PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_KR&apos; oper_stat_ghz-zzito_kr.&quot;Квалификационный разряд
                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=BACK&apos;.


                        PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3380&apos;.
                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOUE&apos;.
                        PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                        PERFORM bdc_field       USING &apos;PLPOD-BMVRG&apos; oper_stat_ghz-kol_rab.
                        PERFORM bdc_field       USING &apos;PLPOD-BMEIH&apos; oper_stat_ghz-ei_rab.
                        IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                          PERFORM bdc_field       USING &apos;PLPOD-SAKTO&apos; &apos;39-0000000&apos;.
                          PERFORM bdc_field       USING &apos;PLPOD-MATKL&apos; &apos;TTK&apos;.
                          PERFORM bdc_field       USING &apos;PLPOD-EKGRP&apos; &apos;TTK&apos;.
                        ENDIF.
                        PERFORM bdc_field       USING &apos;PLPOD-WAERS&apos; &apos;RUB&apos;.
                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR&apos;.
                        PERFORM bdc_field       USING &apos;PLPOD-VORNR&apos; oper_stat_ghz-number_oper.
                        PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                        PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.
                        PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                        IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                          PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                        ELSE.
                          PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                        ENDIF.
                        PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                        IF head_stat_ghz-kod_str IS NOT INITIAL AND oper_stat_ghz-znachimost_oper IS NOT INITIAL.
                          PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(02)&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=WPLT&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3600&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=IWPZ&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
                          paket = oper_stat_ghz-znachimost_oper.
* Подсчет количества пакетов
*                  DO.
*                    SEARCH paket FOR &apos;/&apos;.&quot;Разделение по знаку &quot;/&quot;
*                    IF sy-subrc &lt;&gt; 0.&quot;Последний пакет
                          MOVE Z_T351P-ZAEHL+1(1) TO nom_pak.
*                      if nom_pak = Z_T351P-ZAEHL+1(1).
                          CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=WPLZ&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLIPM5&apos; &apos;0100&apos;.
                          CONCATENATE &apos;PAKET_TAB-KZYK1(0&apos; nom_pak &apos;)&apos; INTO help.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; help.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=ENTR&apos;.
                          FREE help.
                          CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
                          PERFORM bdc_field       USING help &apos;X&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
*                        EXIT.
*                      ENDIF.
*                    ELSE.
*                      if nom_pak = Z_T351P-ZAEHL+1(1).
*                        kol_sm = sy-fdpos + 1.
*                        MOVE paket(1) TO nom_pak.
*                        MOVE paket+kol_sm TO paket.
*                        CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
*                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=WPLZ&apos;.
*                        PERFORM bdc_dynpro      USING &apos;SAPLIPM5&apos; &apos;0100&apos;.
*                        CONCATENATE &apos;PAKET_TAB-KZYK1(0&apos; nom_pak &apos;)&apos; INTO help.
*                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; help.
*                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=ENTR&apos;.
*                        FREE help.
*                        CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
*                        PERFORM bdc_field       USING help &apos;X&apos;.
*                        PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
*                        PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
*                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
*                      ENDIF.
*                    ENDIF.
*                  ENDDO.
                          PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=SVUE&apos;.
                        ENDIF.
                        IF head_stat_ghz-kod_str IS NOT INITIAL .
*              AND OPER_STAT_GHZ-NAME_PAK NE &apos;&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(02)&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOUS&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3100&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-SLWID&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
                          PERFORM bdc_field       USING &apos;PLPOD-SLWID&apos; &apos;PM00005&apos;.

*
                          PERFORM bdc_field       USING &apos;PLPOD-USR02&apos; oper_stat_ghz-num_first_oper.
                          PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                          PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.

                          PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                          IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                            PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                          ELSE.
                            PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                          ENDIF.
                          PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3100&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-USR02&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOUE&apos;.
                          PERFORM bdc_field       USING &apos;PLPOD-SLWID&apos; &apos;PM00005&apos;.
                          IF oper_stat_ghz-num_komp_op IS NOT INITIAL.
                            PERFORM bdc_field       USING &apos;PLPOD-USR02&apos; oper_stat_ghz-num_komp_op.
                          ENDIF.

                          PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                          PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.

                          PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                          IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                            PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                          ELSE.
                            PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                          ENDIF.
                          PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                        ENDIF.
                        mim_flag = 0.
                        LOOP AT mim_table.&quot;Поиск МиМ у операции
                          IF mim_table-number_oper = oper_stat_ghz-number_oper AND mim_table-number_tk = oper_stat_ghz-number_tk.
                            mim_flag = 1.&quot;Фиксирование наличия МиМ
                          ENDIF.
                        ENDLOOP.
                        IF mim_flag = 1.&quot;Если МиМ найдено
                          PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(02)&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=FHUE&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0200&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/EFIS&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-PSNFH&apos;.
                          LOOP AT mim_table.&quot;Проходим по всем МиМ
                            IF mim_table-number_oper = oper_stat_ghz-number_oper AND mim_table-number_tk = oper_stat_ghz-number_tk.
                              PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0210&apos;.
                              PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-STEUF&apos;.
                              PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=EINF&apos;.
                              PERFORM bdc_field       USING &apos;PLFHD-SFHNR&apos; mim_table-kod_mim.&quot;Код МиМ
                              PERFORM bdc_field       USING &apos;PLFHD-MGVGW&apos; mim_table-kolvo.&quot;Количество
                              PERFORM bdc_field       USING &apos;PLFHD-MGEINH&apos; &apos;М-Ч&apos;.
                              PERFORM bdc_field       USING &apos;PLFHD-STEUF&apos; &apos;1&apos;.
                            ENDIF.
                          ENDLOOP.
                          PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0210&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/EESC&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-PSNFH&apos;.
                          PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0102&apos;.
                          PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-STEUF(01)&apos;.
                          PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=SVUE&apos;.
                        ENDIF.

                        PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                        PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=MALO&apos;.
                      endif.
                    endif.
                  endif.
                ENDLOOP.
*              PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
*              PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
*
*              PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=EINF&apos;.
*              PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
*              PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
*
*              PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=END&apos;.
*              PERFORM bdc_dynpro      USING &apos;SAPLSPO1&apos; &apos;0100&apos;.
*              PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=YES&apos;.
*              PERFORM bdc_transaction USING &apos;IA01&apos;.
              ENDLOOP.
            ELSE.
*Выбор наименования единицы оборудования
              SELECT eqktx INTO name_eo FROM eqkt WHERE equnr = nomer_eo.
              ENDSELECT.
              .
              SELECT SINGLE marka FROM zpm_marka INTO zmarka WHERE marka = head_stat_ghz-marka.
*READ TABLE lt_characteristicvalues WITH KEY VALUE_CHAR = HEAD_STAT_GHZ-MARKA INTO lt_char.
              IF sy-subrc = 0.

              ELSE.
                CONCATENATE &apos;Ошибка заголовка.&apos; per_str &apos; Строка№&apos; zapis per_str&apos; Неверная марка &apos; head_stat_ghz-marka per_str&apos; Единицы оборудования:&apos; nomer_eo INTO error_table-text.
                APPEND error_table.&quot;Запись в файл ошибок
              ENDIF.

*Запись заголовка тех карты
              PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3010&apos;.
              PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RC27E-EQUNR&apos;.
              PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
              PERFORM bdc_field       USING &apos;RC27E-EQUNR&apos; nomer_eo.&quot;Номер ЕО
              PERFORM bdc_field       USING &apos;RC271-STTAG&apos; datex.&quot;Текущая дата
              PERFORM bdc_dynpro      USING &apos;SAPLCPDA&apos; &apos;3010&apos;.
              PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                    &apos;=ALCA&apos;.
              PERFORM bdc_field       USING &apos;PLKOD-PLNAL&apos; &apos;1&apos;.&quot;Константа
              PERFORM bdc_field       USING &apos;PLKOD-VERWE&apos; &apos;GNS&apos;.&quot;Константа
              PERFORM bdc_field       USING &apos;PLKOD-STATU&apos; &apos;4&apos;.&quot;Константа
              PERFORM bdc_field       USING &apos;PLKOD-STRAT&apos; head_stat_ghz-kod_str.&quot;Код стратегии ТК
              PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLKO-ZZITO_TK&apos;.
              PERFORM bdc_field       USING &apos;PLKO-ZZITO_TK&apos; head_stat_ghz-number_tk.&quot;Номер ТК
              PERFORM bdc_dynpro      USING &apos;SAPLCLFM&apos; &apos;0500&apos;.
              PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                    &apos;RMCLF-CLASS(01)&apos;.
              PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                    &apos;/00&apos;.


              PERFORM bdc_field       USING &apos;RMCLF-CLASS(01)&apos;
                    &apos;MARKA_TK&apos;.
              PERFORM bdc_dynpro      USING &apos;SAPLCTMS&apos; &apos;0109&apos;.
              PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                    &apos;RCTMS-MWERT(01)&apos;.
              PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                    &apos;=BACK&apos;.
              PERFORM bdc_field       USING &apos;RCTMS-MNAME(01)&apos;
                    &apos;MARKA_TK&apos;.
              PERFORM bdc_field       USING &apos;RCTMS-MWERT(01)&apos;
                    head_stat_ghz-marka.
              PERFORM bdc_dynpro      USING &apos;SAPLCLFM&apos; &apos;0500&apos;.
              PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                    &apos;RMCLF-CLASS(01)&apos;.
              PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                    &apos;=ENDE&apos;.
              PERFORM bdc_field       USING &apos;RMCLF-PAGPOS&apos;
                    &apos;1&apos;.
              PERFORM bdc_dynpro      USING &apos;SAPLCPDA&apos; &apos;3010&apos;.
              PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                    &apos;PLKOD-KTEXT&apos;.
              PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                    &apos;=VOUE&apos;.

              z = 0.
*perform open_group.
              LOOP AT oper_stat_ghz WHERE number_tk = head_stat_ghz-number_tk.
                FREE: zapis, ei_flag, nalichie_tk_flag, nomer_eo, trud1, trud2, trud_str, paket, nom_pak, kol_sm, naim_oper, naim_podop, mim_flag, zcode.
                zapis = sy-tabix.&quot;Номер строки файла операций


                z = z + 1.
                SELECT equnr INTO nomer_eo FROM equi WHERE zzito_tk_eo = oper_stat_ghz-eo.&quot;Поиск номера ЕО по тех коду
                ENDSELECT.
                PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
                PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=EINF&apos;.
                PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.

                PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
*            PERFORM bdc_field       USING &apos;RC27X-ENTRY_ACT&apos; &apos;1&apos;.
                PERFORM bdc_field       USING &apos;RC27X-FLG_SEL(01)&apos; &apos;X&apos;.




                PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOEL&apos;.




                PERFORM bdc_field       USING &apos;PLPOD-VORNR(01)&apos; oper_stat_ghz-number_oper.&quot;Номер операции
                PERFORM bdc_field       USING &apos;PLPOD-KTSCH(01)&apos; oper_stat_ghz-kod_vd_oper.
                PERFORM bdc_field       USING &apos;PLPOD-ARBPL(01)&apos; oper_stat_ghz-rab_mesto. &quot;Выполняющее рабочее место
                PERFORM bdc_field       USING &apos;PLPOD-LTXA1(01)&apos; oper_stat_ghz-name_oper.&quot;Наименование операции (обрезанное)
                PERFORM bdc_field       USING &apos;PLPOD-BMVRG(01)&apos; oper_stat_ghz-kol_rab.&quot;Кол-во работ
                PERFORM bdc_field       USING &apos;PLPOD-BMEIH(01)&apos; oper_stat_ghz-ei_rab.&quot;Единица измерения
                IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.&quot;Если работы на Р (сторонней орг.)
                  PERFORM bdc_field       USING &apos;PLPOD-SAKTO(01)&apos; &apos;39-0000000&apos;.&quot;Константа
                  PERFORM bdc_field       USING &apos;PLPOD-MATKL(01)&apos; &apos;TTK&apos;.&quot;Константа
                  PERFORM bdc_field       USING &apos;PLPOD-EKGRP(01)&apos; &apos;TTK&apos;.&quot;Константа
                ENDIF.



                &quot; { 10kvu 2016.10.24 Загрузка материалов (компоненты)
                &quot; Если вводится операция (НЕ подоперация) - Перейти на экран ввода Компонентов и ввести материалы в цикле.

                READ TABLE gt_materials WITH KEY  number_tk = oper_stat_ghz-number_tk number_oper = oper_stat_ghz-number_oper

                eo = oper_stat_ghz-eo INTO gs_materials.

                IF sy-subrc = 0.


*                  ASSIGN   gs_materials  TO &lt;fs_materials&gt;.

*                DATA:
*                      lv_countstr           TYPE i VALUE 0,
*                      lv_tmpstr(4)          TYPE c,
*                      lv_oldoper           LIKE oper_stat_ghz-number_oper VALUE 0,
*                      lv_intostrval         TYPE bdcdata-fval,
*                      lv_intostrnam         TYPE bdcdata-fnam.




                  PERFORM bdc_dynpro     USING &apos;SAPLCPDO&apos; &apos;3370&apos;.
                  PERFORM bdc_field      USING &apos;BDC_CURSOR&apos; &apos;PLPOD-QUALF&apos;.
                  PERFORM bdc_field      USING &apos;BDC_OKCODE&apos; &apos;=MAPM&apos;.

                  LOOP AT gt_materials into fs_materials WHERE number_tk = oper_stat_ghz-number_tk AND
                  number_oper = oper_stat_ghz-number_oper AND
                  eo = oper_stat_ghz-eo.

                    IF lv_oldoper &lt;&gt; oper_stat_ghz-number_oper.
                      lv_countstr = 1.
                    ELSE.
                      lv_countstr = lv_countstr + 1.
                    ENDIF.
                    lv_oldoper = oper_stat_ghz-number_oper.

                    lv_tmpstr = `(` &amp;&amp; lv_countstr &amp;&amp; `)`.
                    IF  lv_countstr MOD 10 = 0.

                      &quot; IF lv_oldOper &lt;&gt; DAN_OPER-N_OPER.
                      lv_countstr = 1.
                      &quot; ELSE.
                      &quot;lv_countSTR = lv_countSTR + 1.
                      &quot;ENDIF.

                      lv_tmpstr = `(` &amp;&amp; lv_countstr &amp;&amp; `)`.

                      lv_tmpstr = `(` &amp;&amp; lv_countstr &amp;&amp; `)`.
                      PERFORM bdc_dynpro      USING &apos;SAPLCMDI&apos; &apos;3500&apos;.
                      lv_intostrval = `RIHSTPX-IDNRK` &amp;&amp; lv_tmpstr.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                            lv_intostrval.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                            &apos;=P+&apos;.
                    ENDIF.
                    PERFORM bdc_dynpro      USING &apos;SAPLCMDI&apos; &apos;3500&apos;.

                    lv_intostrval = `RIHSTPX-IDNRK` &amp;&amp; lv_tmpstr.
                    PERFORM bdc_field       USING &apos;BDC_CURSOR&apos;
                          lv_intostrval.
                    PERFORM bdc_field       USING &apos;BDC_OKCODE&apos;
                          &apos;/00&apos;.
                    lv_intostrnam = `RIHSTPX-IDNRK` &amp;&amp; lv_tmpstr.
                    PERFORM bdc_field       USING lv_intostrnam
                          fs_materials-id_mat.
                    lv_intostrnam = `RIHSTPX-MENGE` &amp;&amp; lv_tmpstr.
                    IF  fs_materials-quant is INITIAL.
                      fs_materials-quant = 0.
                    ENDIF.
                    PERFORM bdc_field       USING lv_intostrnam
                          fs_materials-quant.
                    lv_intostrnam = `RIHSTPX-MEINS` &amp;&amp; lv_tmpstr.
                    PERFORM bdc_field       USING lv_intostrnam
                          fs_materials-ei.
*                    CLEAR: fs_materials.
                  ENDLOOP.

                  PERFORM bdc_dynpro        USING &apos;SAPLCMDI&apos; &apos;3500&apos;.
*              PERFORM BDC_FIELD         USING &apos;BDC_CURSOR&apos; &apos;PLPOD-LTXA1&apos;.
*              perform bdc_field       using &apos;PLPOD-LTXA1(01)&apos; OPER_STAT_GHZ-NAME_OPER.&quot;Наименование операции (обрезанное)
                  PERFORM bdc_field         USING &apos;BDC_OKCODE&apos;
                        &apos;=SVEL&apos;.

                ENDIF.
                &quot; } 10kvu 2016.10.24 Загрузка материалов (компоненты)



                PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3370&apos;.
                PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-QUALF&apos;.

                &quot;Умножение трудоемкости на 10 (ограничение в количестве знаков после запятой)
                TRANSLATE oper_stat_ghz-trudoemkost USING &apos;,.&apos;.
                trud2 = oper_stat_ghz-trudoemkost.
                trud1 = trud2.
                trud_str = trud1.
                TRANSLATE trud_str USING &apos;.,&apos;.
                PERFORM bdc_field       USING &apos;PLPOD-ARBEI&apos; trud_str.&quot;Трудоемкость
                PERFORM bdc_field       USING &apos;PLPOD-ARBEH&apos; &apos;Ч/Ч&apos;.&quot;Константа
                PERFORM bdc_field       USING &apos;PLPOD-ANZZL&apos; oper_stat_ghz-kol_ispoln.&quot;Количество исполнителей
                PERFORM bdc_field       USING &apos;PLPOD-QUALF&apos; oper_stat_ghz-specialnost.&quot;Специальность
                PERFORM bdc_field       USING &apos;PLPOD-VORNR&apos; oper_stat_ghz-number_oper.&quot;Номер операции
                PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.&quot;Наименование операции
                PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.&quot;Рабочее место
                PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.&quot;Если работы на Р (сторонней орг.)
                  PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                ELSE.
                  PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                ENDIF.
                PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOFL&apos;.

                PERFORM bdc_dynpro      USING &apos;ZPM_POLE_OPER_TK&apos; &apos;1000&apos;.
                PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
                SELECT SINGLE code FROM zpm_calc_eu INTO zcode WHERE source_justification = oper_stat_ghz-zzito_io.
                IF oper_stat_ghz-zzito_kpr = &apos;1&apos;.
                  CLEAR oper_stat_ghz-zzito_ob_kpr.
                ENDIF.
                IF oper_stat_ghz-zzito_kur = &apos;1&apos;.
                  CLEAR oper_stat_ghz-zzito_ob_kur.
                ENDIF.
                IF oper_stat_ghz-zzito_ob_kur IS NOT INITIAL.
                  READ TABLE z_dd07t WITH  KEY ddtext = oper_stat_ghz-zzito_ob_kur.
                  IF  sy-subrc = 0.
                    oper_stat_ghz-zzito_ob_kur = z_dd07t-valpos+3(1).
                  ENDIF.
                ENDIF.
                PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD_IMP_POLZ-ZZITO_OB_KPR&apos;.
                PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_IO&apos; zcode.&quot;Код обоснования
                PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_KPR&apos; oper_stat_ghz-zzito_kpr.&quot;КОЭФФИЦИЕНТ ПРОИЗВОДСТВА РАБОТ
                PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_OB_KPR&apos; oper_stat_ghz-zzito_ob_kpr.&quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА ПРОИЗВОДСТВА РАБОТ
                PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_KUR&apos; oper_stat_ghz-zzito_kur.&quot;КОЭФФИЦИЕНТ УСЛОВИЯ РАБОТ
                PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_OB_KUR&apos; oper_stat_ghz-zzito_ob_kur.&quot;ОБОСНОВАНИЕ ПРИМЕНЕНИЯ КОЭФФИЦИЕНТА УСЛОВИЙ РАБОТ
                PERFORM bdc_field       USING &apos;PLPOD_IMP_POLZ-ZZITO_KR&apos; oper_stat_ghz-zzito_kr.&quot;Квалификационный разряд
                PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=BACK&apos;.


                PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3380&apos;.
                PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOUE&apos;.
                PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                PERFORM bdc_field       USING &apos;PLPOD-BMVRG&apos; oper_stat_ghz-kol_rab.
                PERFORM bdc_field       USING &apos;PLPOD-BMEIH&apos; oper_stat_ghz-ei_rab.
                IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                  PERFORM bdc_field       USING &apos;PLPOD-SAKTO&apos; &apos;39-0000000&apos;.
                  PERFORM bdc_field       USING &apos;PLPOD-MATKL&apos; &apos;TTK&apos;.
                  PERFORM bdc_field       USING &apos;PLPOD-EKGRP&apos; &apos;TTK&apos;.
                ENDIF.
                PERFORM bdc_field       USING &apos;PLPOD-WAERS&apos; &apos;RUB&apos;.
                PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR&apos;.
                PERFORM bdc_field       USING &apos;PLPOD-VORNR&apos; oper_stat_ghz-number_oper.
                PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.
                PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                  PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                ELSE.
                  PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                ENDIF.
                PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                IF head_stat_ghz-kod_str IS NOT INITIAL AND oper_stat_ghz-znachimost_oper IS NOT INITIAL.
                  PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(02)&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=WPLT&apos;.
                  PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3600&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=IWPZ&apos;.
                  PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
                  paket = oper_stat_ghz-znachimost_oper.
* Подсчет количества пакетов
                  DO.
                    SEARCH paket FOR &apos;/&apos;.&quot;Разделение по знаку &quot;/&quot;
                    IF sy-subrc &lt;&gt; 0.&quot;Последний пакет
                      MOVE paket(1) TO nom_pak.
                      CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=WPLZ&apos;.
                      PERFORM bdc_dynpro      USING &apos;SAPLIPM5&apos; &apos;0100&apos;.
                      CONCATENATE &apos;PAKET_TAB-KZYK1(0&apos; nom_pak &apos;)&apos; INTO help.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; help.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=ENTR&apos;.
                      FREE help.
                      CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
                      PERFORM bdc_field       USING help &apos;X&apos;.
                      PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
                      EXIT.

                    ELSE.
                      kol_sm = sy-fdpos + 1.
                      MOVE paket(1) TO nom_pak.
                      MOVE paket+kol_sm TO paket.
                      CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=WPLZ&apos;.
                      PERFORM bdc_dynpro      USING &apos;SAPLIPM5&apos; &apos;0100&apos;.
                      CONCATENATE &apos;PAKET_TAB-KZYK1(0&apos; nom_pak &apos;)&apos; INTO help.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; help.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=ENTR&apos;.
                      FREE help.
                      CONCATENATE &apos;PAKETSELECT(0&apos; nom_pak &apos;)&apos; INTO help.
                      PERFORM bdc_field       USING help &apos;X&apos;.
                      PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
                    ENDIF.
                  ENDDO.
                  PERFORM bdc_dynpro      USING &apos;SAPLCIDI&apos; &apos;3000&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;RIEWP-KZYK1(01)&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=SVUE&apos;.
                ENDIF.
                IF head_stat_ghz-kod_str IS NOT INITIAL .
*              AND OPER_STAT_GHZ-NAME_PAK NE &apos;&apos;.
                  PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(02)&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOUS&apos;.
                  PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3100&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-SLWID&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/00&apos;.
                  PERFORM bdc_field       USING &apos;PLPOD-SLWID&apos; &apos;PM00005&apos;.

*              IF OPER_STAT_GHZ-TYPE_ALT_POS IS NOT INITIAL.
*                Обработка комплексных операций
*                TRANSLATE OPER_STAT_GHZ-TYPE_ALT_POS TO UPPER CASE.
*
*                IF OPER_STAT_GHZ-TYPE_ALT_POS CP &apos;ЕДИНИЧ*&apos;  AND OPER_STAT_GHZ-NUM_KOMP_OP IS NOT INITIAL.
*                  CLEAR OPER_STAT_GHZ_LINE.
*                  READ TABLE OPER_STAT_GHZ WITH KEY  NUMBER_OPER = OPER_STAT_GHZ-NUM_KOMP_OP INTO OPER_STAT_GHZ_LINE.
*
*                  IF OPER_STAT_GHZ_LINE IS  NOT INITIAL.
*                    IF OPER_STAT_GHZ_LINE-TYPE_ALT_POS CP &apos;ЕДИНИЧ*&apos;.
*
*                      CONCATENATE &apos;Ошибка операции№ &apos; OPER_STAT_GHZ-NUMBER_OPER PER_STR&apos; тех. карты№ &apos; OPER_STAT_GHZ-NUMBER_TK PER_STR&apos; Строка№&apos;
*                      ZAPIS PER_STR&apos; Тип операции указанной в поле Комплексной не соответствует&apos;
*                         INTO ERROR_TABLE-TEXT.
*                      APPEND ERROR_TABLE.&quot;Запись в файл ошибок
*                      STRATEG_FLAG = 1.&quot;Фиксирование наличия ошибки
*
*                    ELSEIF OPER_STAT_GHZ_LINE-TYPE_ALT_POS CP &apos;КОМПЛЕКС*&apos;.
*
*                   perform bdc_field       using &apos;PLPOD-USR02&apos; OPER_STAT_GHZ-NUM_KOMP_OP.
*
*                    ENDIF.
*                  ELSEIF OPER_STAT_GHZ_LINE IS INITIAL.
*                    CONCATENATE &apos;Ошибка операции№ &apos; OPER_STAT_GHZ-NUMBER_OPER PER_STR&apos; тех. карты№ &apos; OPER_STAT_GHZ-NUMBER_TK PER_STR&apos; Строка№&apos;
*                     ZAPIS PER_STR&apos; Такой комплексной операции не существует&apos;
*                        INTO ERROR_TABLE-TEXT.
*                    APPEND ERROR_TABLE.&quot;Запись в файл ошибок
*                    STRATEG_FLAG = 1.&quot;Фиксирование наличия ошибки
*
*                  ENDIF.
*                ELSEIF OPER_STAT_GHZ-TYPE_ALT_POS CP &apos;ЕДИНИЧ*&apos;  AND OPER_STAT_GHZ-NUM_KOMP_OP IS INITIAL.
*
*                  CONCATENATE &apos;Ошибка операции№ &apos; OPER_STAT_GHZ-NUMBER_OPER PER_STR&apos; тех. карты№ &apos; OPER_STAT_GHZ-NUMBER_TK PER_STR&apos; Строка№&apos;
*                  ZAPIS PER_STR&apos; Должен присутствовать № комплексной операции&apos;
*                   INTO ERROR_TABLE-TEXT.
*                  APPEND ERROR_TABLE.&quot;Запись в файл ошибок
*                  STRATEG_FLAG = 1.&quot;Фиксирование наличия ошибки
*
*                ELSEIF OPER_STAT_GHZ-TYPE_ALT_POS NE &apos;ЕДИНИЧ*&apos;  AND OPER_STAT_GHZ-NUM_KOMP_OP IS INITIAL.
*
*                  CONCATENATE &apos;Ошибка операции№ &apos; OPER_STAT_GHZ-NUMBER_OPER PER_STR&apos; тех. карты№ &apos; OPER_STAT_GHZ-NUMBER_TK PER_STR&apos; Строка№&apos;
*                  ZAPIS PER_STR&apos; Ошибочный тип альтернативной позиции&apos;
*                 INTO ERROR_TABLE-TEXT.
*                  APPEND ERROR_TABLE.&quot;Запись в файл ошибок
*                  STRATEG_FLAG = 1.&quot;Фиксирование наличия ошибки
*
*                ELSEIF OPER_STAT_GHZ-TYPE_ALT_POS NE &apos;ЕДИНИЧ*&apos;  AND OPER_STAT_GHZ-NUM_KOMP_OP IS NOT INITIAL.
*
*                  CONCATENATE &apos;Ошибка операции№ &apos; OPER_STAT_GHZ-NUMBER_OPER PER_STR&apos; тех. карты№ &apos; OPER_STAT_GHZ-NUMBER_TK PER_STR&apos; Строка№&apos;
*                  ZAPIS PER_STR&apos; Ошибочный тип альтернативной позиции&apos;
*                      INTO ERROR_TABLE-TEXT.
*                  APPEND ERROR_TABLE.&quot;Запись в файл ошибок
*                  STRATEG_FLAG = 1.&quot;Фиксирование наличия ошибки
*
*
*
*                ENDIF.
*              ENDIF.
                  PERFORM bdc_field       USING &apos;PLPOD-USR02&apos; oper_stat_ghz-num_first_oper.
                  PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                  PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.

                  PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                  IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                    PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                  ELSE.
                    PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                  ENDIF.
                  PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                  PERFORM bdc_dynpro      USING &apos;SAPLCPDO&apos; &apos;3100&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-USR02&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=VOUE&apos;.
                  PERFORM bdc_field       USING &apos;PLPOD-SLWID&apos; &apos;PM00005&apos;.
                  IF oper_stat_ghz-num_komp_op IS NOT INITIAL.
                    PERFORM bdc_field       USING &apos;PLPOD-USR02&apos; oper_stat_ghz-num_komp_op.
                  ENDIF.

                  PERFORM bdc_field       USING &apos;PLPOD-LTXA1&apos; oper_stat_ghz-name_oper.
                  PERFORM bdc_field       USING &apos;PLPOD-ARBPL&apos; oper_stat_ghz-rab_mesto.

                  PERFORM bdc_field       USING &apos;PLPOD-WERKS&apos; &apos;1400&apos;.
                  IF oper_stat_ghz-rab_mesto(1) = &apos;P&apos;.
                    PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM2&apos;.
                  ELSE.
                    PERFORM bdc_field       USING &apos;PLPOD-STEUS&apos; &apos;ZPM1&apos;.
                  ENDIF.
                  PERFORM bdc_field       USING &apos;PLPOD-AUFKT&apos; &apos;1&apos;.
                ENDIF.
                mim_flag = 0.
                LOOP AT mim_table.&quot;Поиск МиМ у операции
                  IF mim_table-number_oper = oper_stat_ghz-number_oper AND mim_table-number_tk = oper_stat_ghz-number_tk.
                    mim_flag = 1.&quot;Фиксирование наличия МиМ
                  ENDIF.
                ENDLOOP.
                IF mim_flag = 1.&quot;Если МиМ найдено
                  PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(02)&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=FHUE&apos;.
                  PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0200&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/EFIS&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-PSNFH&apos;.
                  LOOP AT mim_table.&quot;Проходим по всем МиМ
                    IF mim_table-number_oper = oper_stat_ghz-number_oper AND mim_table-number_tk = oper_stat_ghz-number_tk.
                      PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0210&apos;.
                      PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-STEUF&apos;.
                      PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=EINF&apos;.
                      PERFORM bdc_field       USING &apos;PLFHD-SFHNR&apos; mim_table-kod_mim.&quot;Код МиМ
                      PERFORM bdc_field       USING &apos;PLFHD-MGVGW&apos; mim_table-kolvo.&quot;Количество
                      PERFORM bdc_field       USING &apos;PLFHD-MGEINH&apos; &apos;М-Ч&apos;.
                      PERFORM bdc_field       USING &apos;PLFHD-STEUF&apos; &apos;1&apos;.
                    ENDIF.
                  ENDLOOP.
                  PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0210&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;/EESC&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-PSNFH&apos;.
                  PERFORM bdc_dynpro      USING &apos;SAPLCFDI&apos; &apos;0102&apos;.
                  PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLFHD-STEUF(01)&apos;.
                  PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=SVUE&apos;.
                ENDIF.
*
*          ELSE.
**            CONCATENATE &apos;Ошибка операции№ &apos; OPER_STAT_GHZ-NUMBER_OPER PER_STR&apos; тех. карты№ &apos; OPER_STAT_GHZ-NUMBER_TK PER_STR&apos; Строка№&apos; ZAPIS PER_STR&apos; Неверный код обоснования или несоответствие единицы измерения&apos; INTO ERROR_TABLE-TEXT.
**            APPEND ERROR_TABLE.&quot;Запись в таблицу ошибок
*          ENDIF.
                PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
                PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=MALO&apos;.
              ENDLOOP.
*            PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
*            PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
**        perform bdc_field       using &apos;PLPOD-LTXA1&apos; OPER_STAT_GHZ-NAME_OPER.
**        perform bdc_field       using &apos;PLPOD-ARBPL&apos; OPER_STAT_GHZ-RAB_MESTO.
*            PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=EINF&apos;.
*            PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
*            PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.
**        perform bdc_field       using &apos;PLPOD-LTXA1&apos; OPER_STAT_GHZ-NAME_OPER.
**        perform bdc_field       using &apos;PLPOD-ARBPL&apos; OPER_STAT_GHZ-RAB_MESTO.
*            PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=END&apos;.
*            PERFORM bdc_dynpro      USING &apos;SAPLSPO1&apos; &apos;0100&apos;.
*            PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=YES&apos;.
*            PERFORM bdc_transaction USING &apos;IA01&apos;.
            ENDIF.

            PERFORM bdc_dynpro      USING &apos;SAPLCPDI&apos; &apos;3400&apos;.
            PERFORM bdc_field       USING &apos;BDC_CURSOR&apos; &apos;PLPOD-VORNR(01)&apos;.

            PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=END&apos;.
            PERFORM bdc_dynpro      USING &apos;SAPLSPO1&apos; &apos;0100&apos;.
            PERFORM bdc_field       USING &apos;BDC_OKCODE&apos; &apos;=YES&apos;.
            PERFORM bdc_transaction USING &apos;IA01&apos;.
          ENDIF.
        ENDIF.
      ELSE.
        CONCATENATE &apos;Ошибка заголовка.&apos; per_str &apos; Строка№&apos; zapis per_str&apos; Осутствует единица оборудование = &apos; head_stat_ghz-eo INTO error_table-text.
        APPEND error_table.&quot;Запись в таблицу ошибок
      ENDIF.

    ENDLOOP.
    PERFORM close_group.
    PERFORM podr_text.&quot;Вызов подпрограммы загрузки подробных текстов
  ENDIF.
******************************************Загрузка операций ТК************************************************************************************
**************************************************************************************************************************************************
**************************************************************************************************************************************************
  IF r2 = &apos;X&apos;.&quot;Выбран режим работы загрузки подробных текстов
    PERFORM podr_text.&quot;Вызов подпрограммы загрузки подробных текстов
  ENDIF.
  LOOP AT error_table.&quot;Вывод ошибок на экран
    WRITE error_table-text.
  ENDLOOP.
*ВЫГРУЗКА В ФАЙЛ .TXT
  CALL FUNCTION &apos;WS_DOWNLOAD&apos;
  EXPORTING
    filename = file4 &quot;ПУТЬ ВЫГРУЖАЕМОГО ФАЙЛА
  TABLES
    data_tab = error_table &quot;ВЫГРУЖАЕМАЯ ТАБЛИЦА
*ОБРАБОТКА ОШИБОК
  EXCEPTIONS
    file_open_error = 1
    OTHERS = 2.

*&amp;---------------------------------------------------------------------*
*&amp;      Form  PODR_TEXT
*&amp;---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM podr_text.
* Заполнение подробных текстов
  DATA: text_header  LIKE thead,
        text_lines   LIKE tline OCCURS 0 WITH HEADER LINE,
        z_text_lines  LIKE tline OCCURS 0 WITH HEADER LINE,
        zz_text_lines  LIKE tline OCCURS 0 WITH HEADER LINE,
        con_txobject LIKE stxh-tdobject VALUE &apos;ROUTING&apos;,
        con_txid     LIKE stxh-tdid     VALUE &apos;PLKO&apos;,
        akobj        LIKE proj_enq-typ  VALUE &apos;E&apos;,&quot;Тип ТК (А для инструкций)
        txtsp_prps   LIKE prps-txtsp,
        lang_spp     TYPE spras VALUE &apos;R&apos;,
        uzel         LIKE plpo-sumnr,
        z TYPE char128,
   i TYPE sy-tfill,
        func.
* Заполнение подробных текстов заголовков
  LOOP AT head_stat_ghz.
    CLEAR: eapl, eqkt, plko.
    REFRESH z_text_lines.
    SELECT * FROM plko WHERE zzito_tk = head_stat_ghz-number_tk.
    IF sy-subrc = 0.
    CLEAR z_text_lines. REFRESH z_text_lines.

*      IF PLKO-TXTSP &lt;&gt; LANG_SPP.&quot;Возможна ошибка припросмотре ТК в режиме изменения (подробный текст отсутствует а в поле PLKO-TXTSP значение R))
      plko-txtsp = lang_spp.
      UPDATE plko.
      IF sy-subrc &lt;&gt; 0.
        CONCATENATE &apos;Не удалось создать ПТ к ТК &apos; head_stat_ghz-number_tk INTO error_table-text.
        APPEND error_table.
      ELSE.
        REFRESH text_lines.
        text_header-tdspras = sy-langu.
        CONCATENATE plko-mandt akobj plko-plnnr plko-plnal plko-zaehl INTO text_header-tdname.
        text_header-tdid = &apos;PLKO&apos;.
        text_header-tdobject = con_txobject.

*         TRANSLATE HEAD_STAT_GHZ-NAME_TK TO UPPER CASE.

*        Z = HEAD_STAT_GHZ-NAME_TK.
*        CALL FUNCTION &apos;ISH_N2_STRING_TO_TLINE&apos;
*          EXPORTING
*            I_STRING    = Z
*          TABLES
*            E_TLINE_TAB = TEXT_LINES.
*
*        APPEND LINES OF TEXT_LINES to Z_TEXT_LINES.
*        REFRESH TEXT_LINES.
*



        CALL FUNCTION &apos;ISH_N2_STRING_TO_TLINE&apos;
          EXPORTING
            i_string    = head_stat_ghz-opisanie_tk
          TABLES
            e_tline_tab = text_lines.

        text_lines-tdformat = &apos;* &apos;.
        MOVE head_stat_ghz-name_tk TO text_lines-tdline.    &quot; Наименование ТК (65 символов)
        INSERT text_lines INDEX 1.
        text_lines-tdline = &apos;&apos;.
        INSERT text_lines INDEX 1.
        APPEND LINES OF text_lines TO z_text_lines.
        REFRESH text_lines.
*        func = &apos;I&apos;.
        CALL FUNCTION &apos;SAVE_TEXT&apos;
          EXPORTING
            header          = text_header
            savemode_direct = &apos;X&apos;
          TABLES
*           NEWHEADER       = zthead2
            lines           = z_text_lines
          EXCEPTIONS
            id              = 1
            language        = 2
            name            = 3
            object          = 4
            OTHERS          = 5.
        IF sy-subrc &lt;&gt; 0.
          CONCATENATE &apos;Не удалось создать ПТ к ТК &apos; head_stat_ghz-number_tk INTO error_table-text.
          APPEND error_table.
        ELSE.

          CALL FUNCTION &apos;COMMIT_TEXT&apos;.

          REFRESH text_lines.
        ENDIF.

*        ENDIF.
      ENDIF.
*      ENDIF.
      uzel = 0.
*Подробные тексты операций ТК
      LOOP AT oper_stat_ghz WHERE number_tk = head_stat_ghz-number_tk.
        SELECT  * FROM plpo WHERE plnnr = plko-plnnr AND vornr = oper_stat_ghz-number_oper.
        IF sy-subrc = 0.
          SELECT SINGLE * FROM plas where plnnr = plko-plnnr and PLNKN = plpo-PLNKN.
            if plas-plnal = plko-plnal.
                      REFRESH  zz_text_lines.
          uzel = plpo-plnkn.
          plpo-txtsp = lang_spp.
          UPDATE plpo.
          IF sy-subrc &lt;&gt; 0.
            CONCATENATE &apos;Не удалось создать ПТ к ТК &apos; oper_stat_ghz-number_tk per_str &apos;Операция &apos; oper_stat_ghz-number_oper INTO error_table-text.
            APPEND error_table.
          ELSE.
            REFRESH: text_lines.
            text_header-tdspras = sy-langu.
            CONCATENATE plpo-mandt akobj plpo-plnnr plpo-plnkn plpo-zaehl INTO text_header-tdname.
            text_header-tdid = &apos;PLPO&apos;.
            text_header-tdobject = con_txobject.
            z = oper_stat_ghz-name_oper.
            CALL FUNCTION &apos;ISH_N2_STRING_TO_TLINE&apos;
              EXPORTING
                i_string    = z
              TABLES
                e_tline_tab = text_lines.

            APPEND LINES OF text_lines TO zz_text_lines.
            REFRESH text_lines.
            CALL FUNCTION &apos;ISH_N2_STRING_TO_TLINE&apos;
              EXPORTING
                i_string    = oper_stat_ghz-full_name_oper
              TABLES
                e_tline_tab = text_lines.

            text_lines-tdformat = &apos;* &apos;.
*            CONCATENATE &apos;Подробное описание:&apos;  oper_stat_ghz-number_oper INTO text_lines-tdline SEPARATED BY &apos; &apos;.
            text_lines-tdline  = &apos;Подробное описание:&apos; .
            DESCRIBE TABLE text_lines LINES sy-tfill.
            i = sy-tfill + 1.
            INSERT text_lines INDEX i.

            APPEND LINES OF text_lines TO zz_text_lines.
            REFRESH text_lines.
            CALL FUNCTION &apos;ISH_N2_STRING_TO_TLINE&apos;
              EXPORTING
                i_string    = oper_stat_ghz-opis_oper
              TABLES
                e_tline_tab = text_lines.

            APPEND LINES OF text_lines TO zz_text_lines.

            CALL FUNCTION &apos;SAVE_TEXT&apos;
              EXPORTING
                header          = text_header
                savemode_direct = &apos;X&apos;
              TABLES
                lines           = zz_text_lines
              EXCEPTIONS
                id              = 1
                language        = 2
                name            = 3
                object          = 4
                OTHERS          = 5.

            IF sy-subrc &lt;&gt; 0.
              CONCATENATE &apos;Не удалось создать ПТ к ТК &apos; oper_stat_ghz-number_tk per_str &apos;Операция &apos; oper_stat_ghz-number_oper INTO error_table-text.
            ENDIF.

*           ENDIF.
*            ENDIF.
          ENDIF.
**Подробный текст к подоперации
*          SELECT SINGLE * FROM PLPO WHERE PLNNR = PLKO-PLNNR AND SUMNR = UZEL.
*          IF SY-SUBRC = 0.
*            PLPO-TXTSP = LANG_SPP.
*            UPDATE PLPO.
*            IF SY-SUBRC &lt;&gt; 0.
*              CONCATENATE &apos;Не удалось создать ПТ к ТК &apos; OPER_STAT_GHZ-NUMBER_TK PER_STR &apos;Подоперация &apos; OPER_STAT_GHZ-NUMBER_OPER INTO ERROR_TABLE-TEXT.
*              APPEND ERROR_TABLE.
*            ELSE.
*              REFRESH TEXT_LINES.
*              TEXT_HEADER-TDSPRAS = SY-LANGU.
*              CONCATENATE PLPO-MANDT AKOBJ PLPO-PLNNR PLPO-PLNKN PLPO-ZAEHL INTO TEXT_HEADER-TDNAME.
*              TEXT_HEADER-TDID = &apos;PLPO&apos;.
*              TEXT_HEADER-TDOBJECT = CON_TXOBJECT.
*              CALL FUNCTION &apos;ISH_N2_STRING_TO_TLINE&apos;
*                EXPORTING
*                  I_STRING    = OPER_STAT_GHZ-OPIS_OPER
*                TABLES
*                  E_TLINE_TAB = TEXT_LINES.
*              TEXT_LINES-TDFORMAT = &apos;* &apos;.
*              TEXT_LINES-TDLINE = &apos;&apos;.
*              INSERT TEXT_LINES INDEX 1.
*              CALL FUNCTION &apos;SAVE_TEXT&apos;
*                EXPORTING
*                  HEADER          = TEXT_HEADER
*                  SAVEMODE_DIRECT = &apos;X&apos;
*                TABLES
*                  LINES           = TEXT_LINES
*                EXCEPTIONS
*                  ID              = 1
*                  LANGUAGE        = 2
*                  NAME            = 3
*                  OBJECT          = 4
*                  OTHERS          = 5.
*              IF SY-SUBRC &lt;&gt; 0.
*                CONCATENATE &apos;Не удалось создать ПТ к ТК &apos; OPER_STAT_GHZ-NUMBER_TK PER_STR &apos;Подоперация &apos; OPER_STAT_GHZ-NUMBER_OPER INTO ERROR_TABLE-TEXT.
*                APPEND ERROR_TABLE.
*              ENDIF.
*            ENDIF.
          ENDIF.
*Подробный текст к подоперации
        ELSE.
          CONCATENATE &apos;Не удалось создать ПТ к ТК &apos; oper_stat_ghz-number_tk per_str &apos;Операция &apos; oper_stat_ghz-number_oper INTO error_table-text.
          APPEND error_table.
        ENDIF.
        DATA stroka TYPE string.
        CONCATENATE &apos;Номер ТК:&apos; oper_stat_ghz-number_tk &apos; Номер операции:&apos; oper_stat_ghz-number_oper INTO stroka.
        MESSAGE stroka TYPE &apos;S&apos;.
        endselect.
      ENDLOOP.
    ELSE.
      CONCATENATE &apos;Не удалось создать ПТ к ТК &apos; head_stat_ghz-number_tk INTO error_table-text.
      APPEND error_table.
    ENDIF.

  ENDSELECT.

  ENDLOOP.
ENDFORM.                    &quot;PODR_TEXT</source>
 </PROG>
