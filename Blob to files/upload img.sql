rem PL/SQL Developer Test Script

set feedback off
set autoprint off

rem Execute PL/SQL Block
declare
  v_blob   BLOB;
  v_length INTEGER;

  v_index     INTEGER := 1;
  v_bytecount INTEGER;
  v_tempraw   RAW(32767);
  v_file      UTL_FILE.file_type;
  v_filename  varchar2(255);
  v_mimetype  varchar2(255);

  v_ex int;

BEGIN
  /*****************************************
   1. Create Direcdory IMG in db shema 
   2. Create Temporary table or table 
      load_img
             FILE_BLOB (blob)
             file_name (varchar2)
             mime_type (varchar2)
  ******************************************/

  -----------------------------  
  SELECT FILE_BLOB, DBMS_LOB.getlength(FILE_BLOB), file_name, mime_type
    INTO v_blob, v_length, v_filename, v_mimetype
    FROM load_img
   where rownum = 1;
  ------------------------------   
  v_file := UTL_FILE.fopen('CDN', v_filename, 'wb', 32767);
  WHILE v_index <= v_length LOOP
    v_bytecount := 32767;
    DBMS_LOB.read(v_blob, v_bytecount, v_index, v_tempraw);
    UTL_FILE.put_raw(v_file, v_tempraw);
    UTL_FILE.fflush(v_file);
    v_index := v_index + v_bytecount;
  END LOOP;
  UTL_FILE.fclose(v_file);

  -- save file name to your gds table --
  select count(*) into v_ex from CDN_FILES where file_name = v_filename;
  if v_ex = 0 then
    insert into CDN_FILES
      (file_name, MIME_TYPE)
    values
      (v_filename, v_mimetype);
  end if;

  delete FROM load_img;
END;
/
