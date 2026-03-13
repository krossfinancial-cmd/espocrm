begin;

do $$
declare
    obj record;
begin
    for obj in
        select format('drop view if exists %I.%I cascade;', schemaname, viewname) as ddl
        from pg_views
        where schemaname = 'public'
    loop
        execute obj.ddl;
    end loop;

    for obj in
        select format('drop table if exists %I.%I cascade;', schemaname, tablename) as ddl
        from pg_tables
        where schemaname = 'public'
    loop
        execute obj.ddl;
    end loop;

    for obj in
        select format('drop sequence if exists %I.%I cascade;', sequence_schema, sequence_name) as ddl
        from information_schema.sequences
        where sequence_schema = 'public'
    loop
        execute obj.ddl;
    end loop;

    for obj in
        select format(
            'drop function if exists %I.%I(%s) cascade;',
            n.nspname,
            p.proname,
            pg_get_function_identity_arguments(p.oid)
        ) as ddl
        from pg_proc p
        join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public'
    loop
        execute obj.ddl;
    end loop;
end $$;

commit;
