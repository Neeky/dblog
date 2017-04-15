-- 阿定的blog数据库模型

-- 0001建数据库dblog
create database dblog char set utf8;

-- 0002创建用户

create user appuser@'localhost' identified by 'app_PASSWORD';
create user appuser@'127.0.0.1' identified by 'app_PASSWORD';
create user appuser@'%' identified by 'app_PASSWORD';

-- 0003授权

grant all on dblog.* to appuser@'localhost';
grant all on dblog.* to appuser@'127.0.0.1';
grant all on dblog.* to appuser@'%';

-- 0004
