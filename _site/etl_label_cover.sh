#! /bin/bash
#参数1:cycle
#参数3:日期
#参数4:配置文件
#cycle默认值为0，表示全部

if [ $# -ge 1 ]; then
   n_date=`date -d "$1" +"%Y%m%d"`
      if [ $? -ne 0 ]; then
           echo ":Incorrect date format!!!"
           exit 1
      fi
       else
   n_date=`date -d " -1 days" +"%Y%m%d"`
fi
   v_date=`date -d "${n_date}" +"%Y-%m-%d"`

cycle=0

curr_path=$(cd `dirname $0`;pwd)
cd ${curr_path}

configfile=${curr_path}/../../config/config.properties

if [ $# -eq 4 ]; then
  configfile=$4
fi



source ${configfile}



if [ ! -e ./data  ]; then
    echo "数据目录不存在!!!"
    exit 0
fi
rm -f ./data/*

hadoop dfs -get ${hdfs_data}/l_date=${v_date}/* data/


tmp_file=data/data_tmp.txt

filename=data/data.txt

cat data/part*|grep -v -E 'gds_cat' >${tmp_file}

awk -F'#' '{if($1<0){print $0}}' ${tmp_file}>data/error.log

awk -F'#' '{if($1>=0){print $0}}' ${tmp_file} > ${filename}

sed  's/#/\t/g' ${filename} > data/tmp.txt
awk -F'\t' '{if($1==4){a[$2","$4];}}END{for(i in a) print i }' data/tmp.txt|sed "s/,/\t/g" >data/tmp5.txt


#sort -u data/tmp4.txt>data/tmp4_s.txt
#加载四级标签覆盖数#之前造的label_info 表里的四级id,目前不需要再次造在初始化的时候需要
#awk -F'\t' 'BEGIN{b=0;}{if(a!=$2){b=1;a=$2}else{b=b+1} printf  "%s\t%s%05s\t%s\n",$2,$2,b,$4}' data/tmp4_s.txt>data/tmp5.txt


#处理 label_info 中的四级标签信息
mysql -h ${mysql_ip} -P ${mysql_port} -u${mysql_user} -p${mysql_pwd} ${db_name}  --default-character-set=utf8 <<!

select '-------0';
create table if not exists label_forth_info
(
label_id_third varchar(50),
label_value varchar(255)
);

truncate table label_forth_info;
load data local infile './data/tmp5.txt'
into table label_forth_info;
commit;


create table if not exists label_cover_forth
(
type varchar(10),
label_id varchar(50),
channel varchar(50),
label_value varchar(100),
cover_num bigint
);


/*将数据导入中间表处理*/
truncate table label_cover_forth;
load data local infile './data/tmp.txt'
into table label_cover_forth;
commit;
!

mysql -h ${mysql_ip} -P ${mysql_port} -u${mysql_user} -p${mysql_pwd} ${db_name}  --default-character-set=utf8 <<!
/*label_info表中四级标签的配置信息*/

create table if not exists label_info_mid
(
value   varchar(100),
label_name  varchar(100) ,
uri   varchar(200)
);

truncate table label_info_mid;
insert into  label_info_mid(value,label_name,uri)
select 
a.label_value,
coalesce(c.web_data,a.label_value) as label_name,
CONCAT(b.uri,b.id,'/') as uri 
 from 
label_forth_info a
inner join label_info b on a.label_id_third = b.label_id  and b.availably=1
left join label_mapping c on c.third_level_id=a.label_id_third and a.label_value = c.mapping_data
;

update label_info set availably=0 where label_level=4 ;
update label_info a , label_info_mid b set a.availably = 1 where  a.uri=b.uri and a.label_name = b.label_name ;
UPDATE label_info a , label_info b SET a.create_uid = b.create_uid, a.update_uid = b.update_uid WHERE  a.parent_id=b.id AND a.label_level = 4;
select '------009';

create table if not exists label_info_tmp2
(
uri varchar(100),
label_name varchar(100),
value  varchar(100),
third_id  varchar(100),
parent_id  varchar(100),
path  varchar(100),
rule varchar(100),
forth_id varchar(100),
rank int
);

truncate table label_info_tmp2;

insert into label_info_tmp2
select uri,
       label_name,
       value,
       substr(forth_id,1,LENGTH(forth_id)-5) as third_id,
       parent_id,
       path,
       rule,
       concat(substr(forth_id,1,LENGTH(forth_id)-5),substr(CAST(substr(forth_id, length(forth_id)-4) AS UNSIGNED)+rank+100000,2)) forth_id ,
       rank 
from (
     select 
         e.uri,
         e.label_name,
         e.value,
         e.path,
         e.forth_id,
         e.parent_id,
         e.rule,
         if(@pdept=e.uri and @pdept is not null,@rank:=@rank+1,@rank:=1) as rank,
         @pdept:=e.uri 
		from (
		select 
			d.uri,
			d.label_name,
                        d.value,
                        c.path,
			c.label_id forth_id,
			c.parent_id,
			c.rule
		from (
			select 
			b.uri,
			b.label_name ,
                        b.value
			from label_info_mid b  
			left join label_info a on a.uri=b.uri and a.label_name = b.label_name
			where a.uri is null and a.label_name is null
			order by b.label_name  
		) d  inner join 
		(
select 
			concat(m.uri,m.id,'/') as uri,
			concat(m.path,m.label_name,'/') as path,
                        max(COALESCE(n.label_id,concat(m.label_id,'00000'))) label_id,
			m.id as parent_id,
			m.label_name as rule
		from (select * from label_info 	where label_level=4 ) n
		right join (select * from label_info where  label_level=3 and availably=1) m on n.parent_id = m.id
		group by concat(m.uri,m.id)) c on d.uri = c.uri  order by c.uri
		) e,
		(select @pdept := null ,@rank:=0) s
) result;

select '-----------------0002';



/*label_info表中四级标签的配置信息*/

insert into  label_info(label_id,label_name,parent_id,uri,label_level,path,label_rule,status,create_time,update_time,type,method_content)
select 
a.forth_id,
coalesce(c.web_data,a.label_name),
a.parent_id,
a.uri ,
4 as level,
a.path,
a.rule,
3 as status,
now() as create_time,
now() as update_time,
2 as type,
a.value
 from 
label_info_tmp2 a
left join label_mapping c on a.third_id=c.third_level_id and a.value = c.mapping_data;

select '------2';
!


rm -rf ./data/cover.txt

mysql -h ${mysql_ip} -P ${mysql_port} -u${mysql_user} -p${mysql_pwd}  --default-character-set=utf8  -s -e "
 
use  ${db_name};
SELECT
b.id,a.cover_num,a.channel,if(TRIM(a.label_value)='','',a.label_value) as category_id,1,0
from
label_cover_forth a
inner join label_info b on a.label_id =  b.label_id
where a.type in ('2','3')
union all
select b.id,a.cover_num,a.channel,'' as category_id,1,0
from
(select id,SUBSTR(label_id,1,LENGTH(label_id)-5) as label_id_t,coalesce(method_content,label_name) as method_content
from label_info where (label_level=4 or label_level = 3) and type <> 3 and (label_content is null or label_content = '')
) b
inner join label_cover_forth a on a.label_id = label_id_t and a.label_value=b.method_content
where a.type='4'
union all
select b.id,a.cover_num,a.channel,'' as category_id,1,0
from
(select id,SUBSTR(label_id,1,LENGTH(label_id)-5) as label_id_t,label_name
from label_info where (label_level=4 or label_level = 3) and type = 3 and label_content is not null and label_content <> ''
) b
inner join label_cover_forth a on a.label_id = label_id_t and a.label_value=b.label_name
where a.type='4'
">./data/cover.txt

sort -k 1 -k 2 ./data/cover.txt > ./data/cover_data.txt



java -jar OutCodis-jar-with-dependencies.jar ${curr_path}/../../config/mr_config.properties  ./data/cover_data.txt ${n_date}



mysql -h ${mysql_ip} -P ${mysql_port} -u${mysql_user} -p${mysql_pwd} ${db_name}  --default-character-set=utf8 <<!
/*处理1级标签的覆盖数*/
update label_customer_cover set last_flag = 0;
select '------44';
delete from label_customer_cover where create_date = date(now());
select '------5';
insert into label_customer_cover(label_id,cover_num,create_date,last_flag,channel)
SELECT
b.id,a.cover_num,date(now()),1,a.channel
from label_cover_forth a
inner join label_info b on a.label_id=b.label_id
where a.type='1';

select '------6';
!


mysql -h ${mysql_ip} -P ${mysql_port} -u${mysql_user} -p${mysql_pwd} ${db_name}  --default-character-set=utf8 <<!

/*修改home_page中的总数*/
delete from home_page where create_date = '${v_date}';
set @effective_label_num:=(select count(*) from label_info where status=3 and availably=1 and label_level=3);
set @old_customer_num_t:=(select max(cover_customer_num) from home_page where create_date=ADDDATE('${v_date}',INTERVAL -1 day));
set @old_customer_num:=COALESCE(@old_customer_num_t,0);
set @total:=(select max(cover_num) from label_cover_forth where type ='0');

insert into home_page(cover_customer_num,new_customer_num,effective_label_num,create_date)
select @total as cover_customer_num,
CASE
WHEN @total>@old_customer_num THEN
        @total-@old_customer_num
else 0
end as new_customer_num,
@effective_label_num,
date('${v_date}')
from dual;


select '-------7';
insert into customer_label_avg_num(channel,label_num,total,create_date)
select a.channel,ceil(sum_n/cover_num),cover_num,'${v_date}' as create_date from (
select
channel,
sum(cover_num) as sum_n
from label_cover_forth
where type = 2 or type = 3 group by channel
) a inner join  (
select channel,cover_num from label_cover_forth where type=0
) b on a.channel = b.channel;

update label_task a,label_cover b  set update_users = b.cover_num where a.lid=b.label_id;

update home_page set effective_label_num = (select max(label_num) from customer_label_avg_num where create_date = '${v_date}') where create_date ='${v_date}';

!
