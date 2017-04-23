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
    phonenumber bigint unsigned , -- 手机号
    birthday date default '1900-01-01', -- 生日
    email varchar(64), -- 邮件地址
    signstr varchar(32), -- 个性签名
    authstr varchar(64), -- 验证地址
    gender tinyint, -- 性别标记
    forbitlogindate datetime default '1900-01-01' -- 禁止用户登录直到当前的时候超过forbitlogindate 时才可能登录
    registerdate datetime default now(), -- 注册日期/时间
    lastlogindate datetime default now(), -- 最近一次登录的日期/日间
    useragent varchar(32), -- 用户的的客户端类型 ie | chrome | iphone | 安卓 ... 
    longitude double default -1, -- 经度
    latitude double default -1, -- 纬度

    constraint uix_user__name unique index(name), -- 用户名要唯一
    constraint uix_user__email unique index(email), -- 邮件名不同用户间不能重复
    constraint frk_user__gender foreign key(gender) references gender(id) on delete no action on update cascade -- 外键引用
);

-- mark(博客标签) 
create table mark(
    id int not null auto_increment primary key, -- id
    name varchar(16) not null, -- 标签名
    user int not null, -- user表用户id 、用于表明这个标签是那个用户设立的.
    pushdate datetime default now(), -- 增加标签的时间

    constraint uix_mark__name unique index(user,name), -- 唯一约束、同一用户名下标签名不能重复
    constraint frk_mark__user foreign key(user) references user(id) on delete no action on update cascade -- 关联到用户表
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

    constraint frk_blog__user foreign key(user) references user(id) on delete no action on update cascade,
    index ix_blog__user_pushdate (user,pushdate) -- mysql-5.7索引不支持desc
);

-- blog_mark_relaction_ship(博客于标签的对应关系)
create table blog_mark_relaction_ship(
    id int not null primary key, -- id
    mark int not null, -- makr id
    blog int not null, -- blog id
    user int not null, -- user id

    constraint frk_blog_mark_relaction_ship__mark foreign key(mark) references mark(id) on delete no action on update cascade, -- 外键引用
    constraint frk_blog_mark_relaction_ship__blog foreign key(blog) references blog(id) on delete no action on update cascade, -- 外键引用
    constraint frk_blog_mark_relaction_ship__user foreign key(user) references user(id) on delete no action on update cascade, -- 外键引用
    index ix_blog_mark_relaction_ship__user_mark (user,mark), -- 索引
    index ix_blog_mark_relaction_ship__user_blog (user,blog)  -- 索引
);

-- commentary(评论) 
    -- 为了迎合对评论区的高要求、这里用闭包的方式来实现数据库后端的存储
    -- 也就是说commentary 表只存评论数据、
    -- commentary_relation_ship 表用来保存评论的树型关系
create table commentary(
    id int not null auto_increment primary key,
    blog int not null,-- blog id
    content varchar(256), -- 评论的内容
    pushdate datetime default now(), -- 评论时间
    user int not null, -- 发起这条评论的用户
    praisetimes int default 0, -- 点赞数 

    constraint frk_commentary__blog foreign key(blog) references blog(id) on delete no action on update cascade,
    constraint frk_commentary__user foreign key(user) references user(id) on delete no action on update cascade
);

-- commentary_relation_ship(评论之间的树形关系)
create table commentary_relation_ship(
    ancestor int not null, -- 祖先
    descendant int not null, -- 自己(后代)

    constraint pmk_commentary_relation_ship__ancestor__descendant primary key(ancestor,descendant),
    constraint frk_commentary_relation_ship__ancestor foreign key(ancestor) on delete no action on update cascade,
    constraint frk_commentary_relation_ship__descendant foreign key(descendant) on delete no action on update cascade
);


-- 以下是评论区的第二中设计方案 路径枚举
-- commentary(评论)
create table commentary(
    id int not null auto_increment primary key,
    blog int not null,-- blog id
    content varchar(256), -- 评论的内容
    pushdate datetime default now(), -- 评论时间
    user int not null, -- 发起这条评论的用户
    praisetimes int default 0, -- 点赞数 
    parentpath varchar(512) default null, -- 评论的树形 形态.

    constraint frk_commentary__blog foreign key(blog) references blog(id) on delete no action on update cascade,
    constraint frk_commentary__user foreign key(user) references user(id) on delete no action on update cascade
);



