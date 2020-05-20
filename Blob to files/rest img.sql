rem PL/SQL Developer Test Script

set feedback off
set autoprint off

rem Declare variables
variable status varchar2(2000)
variable id number

rem Set variables
begin
  :status := '200';
  :id := 1;
end;
/

rem Execute PL/SQL Block
-- Created on 5/20/2020 by AVHRS 
declare
  -- Local variables here

  l_bfile BFILE;
  l_blob  BLOB;

  r_       CDN_FILES%rowtype;
  dir_name varchar2(199) := 'CDN';
begin
  select * into r_ from CDN_FILES where id = :id;

  l_bfile := BFILENAME(dir_name, r_.file_name);
  IF (dbms_lob.fileexists(l_bfile) = 1) THEN
  
    INSERT INTO LOAD_IMG
      (FILE_BLOB)
    VALUES
      (empty_blob()) RETURN FILE_BLOB INTO l_blob;
  
    L_BFILE := bfilename(dir_name, r_.file_name);
    dbms_lob.fileopen(l_bfile, dbms_lob.FILE_READONLY);
    dbms_lob.loadfromfile(l_blob, l_bfile, dbms_lob.getlength(l_bfile));
    dbms_lob.fileclose(l_bfile);
  
    owa_util.mime_header(r_.mime_type, false);
    htp.p('Content-Length: ' || dbms_lob.getlength(l_blob));
    owa_util.http_header_close;
    wpg_docload.download_file(l_blob);
    :status := 200;
  ELSE
    :status := 404;
  END IF;

  delete FROM load_img;
exception
  when others then
    :status := 500;
end;
/

rem Print variables
print status
print id
