-- A view for postfix to find the correct mailboxes
drop view if exists postfix_mailbox cascade;
create view postfix_mailbox as
  select
    concat(mailman_mailbox.account, '@', mailman_domain.name) as address,
    concat(mailman_mailbox.account, '/') as maildir
  from mailman_mailbox
  join mailman_domain on (mailman_mailbox.domain_id = mailman_domain.id)
  where mailman_mailbox.enabled = true and mailman_domain.enabled = true;

-- A view for postfix to find a virtual domain
drop view if exists postfix_domain;
create view postfix_domain as
  select
    name
  from mailman_domain
  where enabled = true;

-- A view for postfix to resolve aliases
drop view if exists postfix_alias;
create view postfix_alias as
  select
    concat(mailman_alias.account, '@', mailman_domain.name) as alias,
    string_agg(mailman_target.address, ', ') as destination
  from mailman_alias
  join mailman_aliases_targets on (mailman_alias.id = mailman_aliases_targets.alias_id)
  join mailman_target on (mailman_target.id = mailman_aliases_targets.target_id)
  join mailman_domain on (mailman_domain.id = mailman_alias.domain_id)
  where mailman_alias.enabled = true and mailman_domain.enabled = true
  group by alias, account;

-- A view for dovecot to find the correct mailboxes
drop view if exists dovecot_user;
create view dovecot_user as
  select
    address as user,
    maildir
  from postfix_mailbox;

-- A view for dovecot to authenticate users
drop view if exists dovecot_password;
create view dovecot_password as
  select
    concat(mailman_mailbox.account, '@', mailman_domain.name) as user,
    mailman_mailbox.password
  from mailman_mailbox
  join mailman_domain on (mailman_mailbox.domain_id = mailman_domain.id)
  where mailman_mailbox.enabled = true and mailman_domain.enabled = true;

-- A view for dovecot to iterate its users
drop view if exists dovecot_iterate;
create view dovecot_iterate as
  select
    concat(mailman_mailbox.account, '@', mailman_domain.name) as user
  from mailman_mailbox
  join mailman_domain on (mailman_mailbox.domain_id = mailman_domain.id)
  where mailman_mailbox.enabled = true and mailman_domain.enabled = true;

