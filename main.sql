-- 阿定的blog数据库模型

-- 0001建数据库dblog
create database dblog char set utf8;

-- 0002创建用户

create user appuser@'localhost' identified by 'app_PASSWORD';
create user appuser@'127.0.0.1' identified by 'app_PASSWORD';
create user appuser@'%' identified by 'app_PASSWORD';

-- 0003对用户授权

grant all on dblog.* to appuser@'localhost';
grant all on dblog.* to appuser@'127.0.0.1';
grant all on dblog.* to appuser@'%';

-- 增加业务表--

use dblog;

-- gender(用户性别基表)
create table gender(
    id tinyint primary key,
    genderstr varchar(4) default '女');

insert into gender(id,genderstr) values(1,'男'),(2,'女'),(3,'大吊萌妹');

-- user(用户表)
create table user(
    id int auto_increment primary key, -- id
    name varchar(16), -- 用户名
    passstr varchar(32), -- 密码md5值
    email varchar(64), -- 邮件地址
    signstr varchar(32), -- 个性签名
    authstr varchar(64), -- 验证地址
    gender tinyint, -- 性别标记
    registerdate datetime default now(), -- 注册日期/时间
    lastlogindate datetime default now(), -- 最近一次登录的日期/日间
    useragent varchar(32), -- 用户的的客户端类型 ie | chrome | iphone | 安卓 ... 
    longitude double, -- 经度
    latitude double , -- 纬度

    constraint uix_user__name unique index(name), -- 用户名要唯一
    constraint uix_user__email unique index(email), -- 邮件名不同用户间不能重复
    constraint frk_user__gender foreign key(gender) references gender(id) on delete cascade on update cascade -- 外键引用
);

-- mark(博客标签)
create table mark(
    id int not null auto_increment primary key, -- id
    name varchar(16) not null, -- 标签名
    user int not null, -- user表用户id 、用于表明这个标签是那个用户设立的.
    pushdate datetime default now(), -- 增加标签的时间

    constraint uix_mark__name unique index(user,name), -- 唯一约束、同一用户名下标签名不能重复
    constraint frk_mark__user foreign key(user) references user(id) on delete cascade on update cascade -- 关联到用户表
);

-- blog(博客)
create table blog(
    id int not null auto_increment primary key, -- 博客id 
    name varchar(32) not null, -- 博客名
    user int not null, -- 作者id
    pushdate datetime default now(), -- 发表时间
    accesstimes int default 0, -- 访问次数
    praisetimes int default 0, -- 点赞数  
    content text, -- blog 内容     ???数据量大的时候content 字段可能会引起性能问题 ???

    constraint frk_blog__user foreign key(user) references user(id) on delete cascade on update cascade,
    index ix_blog__user_pushdate (user,pushdate) -- mysql-5.7索引不支持desc
);

-- blog_mark_relaction_ship(博客于标签的对应关系)
create table blog_mark_relaction_ship(
    id int not null primary key, -- id
    mark int not null, -- makr id
    blog int not null, -- blog id
    user int not null, -- user id

    constraint frk_blog_mark_relaction_ship__mark foreign key(mark) references mark(id) on delete cascade on update cascade, -- 外键引用
    constraint frk_blog_mark_relaction_ship__blog foreign key(blog) references blog(id) on delete cascade on update cascade, -- 外键引用
    constraint frk_blog_mark_relaction_ship__user foreign key(user) references user(id) on delete cascade on update cascade, -- 外键引用
    index ix_blog_mark_relaction_ship__user_mark (user,mark), -- 索引
    index ix_blog_mark_relaction_ship__user_blog (user,blog)  -- 索引
);

-- commentary(评论)
create table commentary(
    id int not null auto_increment primary key,
)


drop database dblog;
create database dblog;
use dblog;
 

