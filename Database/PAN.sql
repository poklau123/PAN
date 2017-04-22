/*==============================================================*/
/* DBMS name:      Microsoft SQL Server 2005                    */
/* Created on:     2017/4/22 16:54:10                           */
/*==============================================================*/


if exists (select 1
          from sysobjects
          where id = object_id('"CLR Trigger_files"')
          and type = 'TR')
   drop trigger "CLR Trigger_files"
go

if exists (select 1
          from sysobjects
          where id = object_id('td_files')
          and type = 'TR')
   drop trigger td_files
go

if exists (select 1
          from sysobjects
          where id = object_id('"CLR Trigger_filetypes"')
          and type = 'TR')
   drop trigger "CLR Trigger_filetypes"
go

if exists (select 1
          from sysobjects
          where id = object_id('td_filetypes')
          and type = 'TR')
   drop trigger td_filetypes
go

if exists (select 1
          from sysobjects
          where id = object_id('tu_filetypes')
          and type = 'TR')
   drop trigger tu_filetypes
go

if exists (select 1
          from sysobjects
          where id = object_id('"CLR Trigger_folders"')
          and type = 'TR')
   drop trigger "CLR Trigger_folders"
go

if exists (select 1
          from sysobjects
          where id = object_id('td_folders')
          and type = 'TR')
   drop trigger td_folders
go

if exists (select 1
          from sysobjects
          where id = object_id('ti_folders')
          and type = 'TR')
   drop trigger ti_folders
go

if exists (select 1
          from sysobjects
          where id = object_id('tu_folders')
          and type = 'TR')
   drop trigger tu_folders
go

if exists (select 1
          from sysobjects
          where id = object_id('"CLR Trigger_record"')
          and type = 'TR')
   drop trigger "CLR Trigger_record"
go

if exists (select 1
          from sysobjects
          where id = object_id('ti_record')
          and type = 'TR')
   drop trigger ti_record
go

if exists (select 1
          from sysobjects
          where id = object_id('tu_record')
          and type = 'TR')
   drop trigger tu_record
go

if exists (select 1
          from sysobjects
          where id = object_id('"CLR Trigger_users"')
          and type = 'TR')
   drop trigger "CLR Trigger_users"
go

if exists (select 1
          from sysobjects
          where id = object_id('td_users')
          and type = 'TR')
   drop trigger td_users
go

if exists (select 1
          from sysobjects
          where id = object_id('tu_users')
          and type = 'TR')
   drop trigger tu_users
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('files')
            and   name  = 'filesuser_FK'
            and   indid > 0
            and   indid < 255)
   drop index files.filesuser_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('files')
            and   name  = 'files_filetypes_relationship_FK'
            and   indid > 0
            and   indid < 255)
   drop index files.files_filetypes_relationship_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('files')
            and   name  = 'folders_files_relationship_FK'
            and   indid > 0
            and   indid < 255)
   drop index files.folders_files_relationship_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('files')
            and   type = 'U')
   drop table files
go

if exists (select 1
            from  sysobjects
           where  id = object_id('filetypes')
            and   type = 'U')
   drop table filetypes
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('folders')
            and   name  = 'parent_folder_relationship_FK'
            and   indid > 0
            and   indid < 255)
   drop index folders.parent_folder_relationship_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('folders')
            and   name  = 'users_folders_relationship_FK'
            and   indid > 0
            and   indid < 255)
   drop index folders.users_folders_relationship_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('folders')
            and   type = 'U')
   drop table folders
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('record')
            and   name  = 'files_download_record_FK'
            and   indid > 0
            and   indid < 255)
   drop index record.files_download_record_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('record')
            and   type = 'U')
   drop table record
go

if exists (select 1
            from  sysobjects
           where  id = object_id('users')
            and   type = 'U')
   drop table users
go

/*==============================================================*/
/* Table: files                                                 */
/*==============================================================*/
create table files (
   id                   numeric              identity,
   fol_id               numeric              null,
   use_id               numeric              null,
   fil_id               numeric              null,
   name                 varchar(256)         not null,
   size                 numeric              not null,
   guid                 varchar(1024)        not null,
   softdelete           bit                  not null default 0,
   created_at           datetime             not null,
   updated_at           datetime             not null,
   constraint PK_FILES primary key nonclustered (id)
)
go

/*==============================================================*/
/* Index: folders_files_relationship_FK                         */
/*==============================================================*/
create index folders_files_relationship_FK on files (
fol_id ASC
)
go

/*==============================================================*/
/* Index: files_filetypes_relationship_FK                       */
/*==============================================================*/
create index files_filetypes_relationship_FK on files (
fil_id ASC
)
go

/*==============================================================*/
/* Index: filesuser_FK                                          */
/*==============================================================*/
create index filesuser_FK on files (
use_id ASC
)
go

/*==============================================================*/
/* Table: filetypes                                             */
/*==============================================================*/
create table filetypes (
   id                   numeric              identity,
   name                 varchar(256)         not null,
   constraint PK_FILETYPES primary key nonclustered (id)
)
go

/*==============================================================*/
/* Table: folders                                               */
/*==============================================================*/
create table folders (
   id                   numeric              identity,
   fol_id               numeric              null,
   use_id               numeric              null,
   name                 varchar(60)          not null,
   created_at           datetime             not null,
   updated_at           datetime             not null,
   constraint PK_FOLDERS primary key nonclustered (id)
)
go

/*==============================================================*/
/* Index: users_folders_relationship_FK                         */
/*==============================================================*/
create index users_folders_relationship_FK on folders (
use_id ASC
)
go

/*==============================================================*/
/* Index: parent_folder_relationship_FK                         */
/*==============================================================*/
create index parent_folder_relationship_FK on folders (
fol_id ASC
)
go

/*==============================================================*/
/* Table: record                                                */
/*==============================================================*/
create table record (
   id                   numeric              identity,
   fil_id               numeric              null,
   time                 datetime             not null,
   constraint PK_RECORD primary key nonclustered (id)
)
go

/*==============================================================*/
/* Index: files_download_record_FK                              */
/*==============================================================*/
create index files_download_record_FK on record (
fil_id ASC
)
go

/*==============================================================*/
/* Table: users                                                 */
/*==============================================================*/
create table users (
   id                   numeric              identity,
   name                 varchar(60)          not null,
   password             varchar(100)         not null,
   savedsize            numeric              not null default 0,
   constraint PK_USERS primary key nonclustered (id)
)
go


create trigger "CLR Trigger_files" on files  insert as
external name %Assembly.GeneratedName%.
go


create trigger td_files on files for delete as
begin
    declare
       @numrows  int,
       @errno    int,
       @errmsg   varchar(255)

    select  @numrows = @@rowcount
    if @numrows = 0
       return

    /*  Delete all children in "record"  */
    delete record
    from   record t2, deleted t1
    where  t2.fil_id = t1.id


    return

/*  Errors handling  */
error:
    raiserror @errno @errmsg
    rollback  transaction
end
go


create trigger "CLR Trigger_filetypes" on filetypes  insert as
external name %Assembly.GeneratedName%.
go


create trigger td_filetypes on filetypes for delete as
begin
    declare
       @numrows  int,
       @errno    int,
       @errmsg   varchar(255)

    select  @numrows = @@rowcount
    if @numrows = 0
       return

    /*  Set parent code of "filetypes" to NULL in child "files"  */
    update files
     set   fil_id = NULL
    from   files t2, deleted t1
    where  t2.fil_id = t1.id


    return

/*  Errors handling  */
error:
    raiserror @errno @errmsg
    rollback  transaction
end
go


create trigger tu_filetypes on filetypes for update as
begin
   declare
      @numrows  int,
      @numnull  int,
      @errno    int,
      @errmsg   varchar(255)

      select  @numrows = @@rowcount
      if @numrows = 0
         return

      /*  Cannot modify parent code in "filetypes" if children still exist in "files"  */
      if update(id)
      begin
         if exists (select 1
                    from   files t2, inserted i1, deleted d1
                    where  t2.fil_id = d1.id
                     and  (i1.id != d1.id))
            begin
               select @errno  = 50005,
                      @errmsg = 'Children still exist in "files". Cannot modify parent code in "filetypes".'
               goto error
            end
      end


      return

/*  Errors handling  */
error:
    raiserror @errno @errmsg
    rollback  transaction
end
go


create trigger "CLR Trigger_folders" on folders  insert as
external name %Assembly.GeneratedName%.
go


create trigger td_folders on folders for delete as
begin
    declare
       @numrows  int,
       @errno    int,
       @errmsg   varchar(255)

    select  @numrows = @@rowcount
    if @numrows = 0
       return

    /*  Delete all children in "folders"  */
    delete folders
    from   folders t2, deleted t1
    where  t2.fol_id = t1.id

    /*  Delete all children in "files"  */
    delete files
    from   files t2, deleted t1
    where  t2.fol_id = t1.id


    return

/*  Errors handling  */
error:
    raiserror @errno @errmsg
    rollback  transaction
end
go


create trigger ti_folders on folders for insert as
begin
    declare
       @numrows  int,
       @numnull  int,
       @errno    int,
       @errmsg   varchar(255)

    select  @numrows = @@rowcount
    if @numrows = 0
       return

    /*  Parent "users" must exist when inserting a child in "folders"  */
    if update(use_id)
    begin
       select @numnull = (select count(*)
                          from   inserted
                          where  use_id is null)
       if @numnull != @numrows
          if (select count(*)
              from   users t1, inserted t2
              where  t1.id = t2.use_id) != @numrows - @numnull
          begin
             select @errno  = 50002,
                    @errmsg = 'Parent does not exist in "users". Cannot create child in "folders".'
             goto error
          end
    end
    /*  Parent "folders" must exist when inserting a child in "folders"  */
    if update(fol_id)
    begin
       select @numnull = (select count(*)
                          from   inserted
                          where  fol_id is null)
       if @numnull != @numrows
          if (select count(*)
              from   folders t1, inserted t2
              where  t1.id = t2.fol_id) != @numrows - @numnull
          begin
             select @errno  = 50002,
                    @errmsg = 'Parent does not exist in "folders". Cannot create child in "folders".'
             goto error
          end
    end

    return

/*  Errors handling  */
error:
    raiserror @errno @errmsg
    rollback  transaction
end
go


create trigger tu_folders on folders for update as
begin
   declare
      @numrows  int,
      @numnull  int,
      @errno    int,
      @errmsg   varchar(255)

      select  @numrows = @@rowcount
      if @numrows = 0
         return

      /*  Parent "users" must exist when updating a child in "folders"  */
      if update(use_id)
      begin
         select @numnull = (select count(*)
                            from   inserted
                            where  use_id is null)
         if @numnull != @numrows
            if (select count(*)
                from   users t1, inserted t2
                where  t1.id = t2.use_id) != @numrows - @numnull
            begin
               select @errno  = 50003,
                      @errmsg = 'users" does not exist. Cannot modify child in "folders".'
               goto error
            end
      end
      /*  Parent "folders" must exist when updating a child in "folders"  */
      if update(fol_id)
      begin
         select @numnull = (select count(*)
                            from   inserted
                            where  fol_id is null)
         if @numnull != @numrows
            if (select count(*)
                from   folders t1, inserted t2
                where  t1.id = t2.fol_id) != @numrows - @numnull
            begin
               select @errno  = 50003,
                      @errmsg = 'folders" does not exist. Cannot modify child in "folders".'
               goto error
            end
      end
      /*  Cannot modify parent code in "folders" if children still exist in "folders"  */
      if update(id)
      begin
         if exists (select 1
                    from   folders t2, inserted i1, deleted d1
                    where  t2.fol_id = d1.id
                     and  (i1.id != d1.id))
            begin
               select @errno  = 50005,
                      @errmsg = 'Children still exist in "folders". Cannot modify parent code in "folders".'
               goto error
            end
      end

      /*  Cannot modify parent code in "folders" if children still exist in "files"  */
      if update(id)
      begin
         if exists (select 1
                    from   files t2, inserted i1, deleted d1
                    where  t2.fol_id = d1.id
                     and  (i1.id != d1.id))
            begin
               select @errno  = 50005,
                      @errmsg = 'Children still exist in "files". Cannot modify parent code in "folders".'
               goto error
            end
      end


      return

/*  Errors handling  */
error:
    raiserror @errno @errmsg
    rollback  transaction
end
go


create trigger "CLR Trigger_record" on record  insert as
external name %Assembly.GeneratedName%.
go


create trigger ti_record on record for insert as
begin
    declare
       @numrows  int,
       @numnull  int,
       @errno    int,
       @errmsg   varchar(255)

    select  @numrows = @@rowcount
    if @numrows = 0
       return

    /*  Parent "files" must exist when inserting a child in "record"  */
    if update(fil_id)
    begin
       select @numnull = (select count(*)
                          from   inserted
                          where  fil_id is null)
       if @numnull != @numrows
          if (select count(*)
              from   files t1, inserted t2
              where  t1.id = t2.fil_id) != @numrows - @numnull
          begin
             select @errno  = 50002,
                    @errmsg = 'Parent does not exist in "files". Cannot create child in "record".'
             goto error
          end
    end

    return

/*  Errors handling  */
error:
    raiserror @errno @errmsg
    rollback  transaction
end
go


create trigger tu_record on record for update as
begin
   declare
      @numrows  int,
      @numnull  int,
      @errno    int,
      @errmsg   varchar(255)

      select  @numrows = @@rowcount
      if @numrows = 0
         return

      /*  Parent "files" must exist when updating a child in "record"  */
      if update(fil_id)
      begin
         select @numnull = (select count(*)
                            from   inserted
                            where  fil_id is null)
         if @numnull != @numrows
            if (select count(*)
                from   files t1, inserted t2
                where  t1.id = t2.fil_id) != @numrows - @numnull
            begin
               select @errno  = 50003,
                      @errmsg = 'files" does not exist. Cannot modify child in "record".'
               goto error
            end
      end

      return

/*  Errors handling  */
error:
    raiserror @errno @errmsg
    rollback  transaction
end
go


create trigger "CLR Trigger_users" on users  insert as
external name %Assembly.GeneratedName%.
go


create trigger td_users on users for delete as
begin
    declare
       @numrows  int,
       @errno    int,
       @errmsg   varchar(255)

    select  @numrows = @@rowcount
    if @numrows = 0
       return

    /*  Delete all children in "folders"  */
    delete folders
    from   folders t2, deleted t1
    where  t2.use_id = t1.id

    /*  Delete all children in "files"  */
    delete files
    from   files t2, deleted t1
    where  t2.use_id = t1.id


    return

/*  Errors handling  */
error:
    raiserror @errno @errmsg
    rollback  transaction
end
go


create trigger tu_users on users for update as
begin
   declare
      @numrows  int,
      @numnull  int,
      @errno    int,
      @errmsg   varchar(255)

      select  @numrows = @@rowcount
      if @numrows = 0
         return

      /*  Cannot modify parent code in "users" if children still exist in "folders"  */
      if update(id)
      begin
         if exists (select 1
                    from   folders t2, inserted i1, deleted d1
                    where  t2.use_id = d1.id
                     and  (i1.id != d1.id))
            begin
               select @errno  = 50005,
                      @errmsg = 'Children still exist in "folders". Cannot modify parent code in "users".'
               goto error
            end
      end

      /*  Cannot modify parent code in "users" if children still exist in "files"  */
      if update(id)
      begin
         if exists (select 1
                    from   files t2, inserted i1, deleted d1
                    where  t2.use_id = d1.id
                     and  (i1.id != d1.id))
            begin
               select @errno  = 50005,
                      @errmsg = 'Children still exist in "files". Cannot modify parent code in "users".'
               goto error
            end
      end


      return

/*  Errors handling  */
error:
    raiserror @errno @errmsg
    rollback  transaction
end
go

