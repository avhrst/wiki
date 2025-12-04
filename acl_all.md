## ACL for usrer list

```
set define off

-- Run as SYS or a user with XDB/ACL admin privileges
declare
  procedure grant_http_all(p_principal in varchar2) is
  begin
    dbms_network_acl_admin.append_host_ace (
      host       => '*',       -- all hosts
      lower_port => null,      -- all ports
      upper_port => null,      -- all ports
      ace        => xs$ace_type(
                     privilege_list => xs$name_list('http'),
                     principal_name => p_principal,
                     principal_type => xs_acl.ptype_db
                   )
    );
  exception
    when dup_val_on_index then
      null; -- ACE already exists, ignore
  end;
begin
  -- put all your app principals here
  for r in (
    select username
    from   dba_users
    where  username in (
             'APEX_240200',
             'SOFA_QA',
             'SOFA_DEV'
           )
  ) loop
    grant_http_all(r.username);
  end loop;
end;
/
```