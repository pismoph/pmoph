--จำนวนตำแหน่งทั้งหมด
select count(*) from pisj18 where flagupdate = '1';
--จำนวนที่ตำรงตำแหน่ง
select 
	count(*) 
from 
	pisj18
	,pispersonel 
where 
	pisj18.posid = pispersonel.posid and
	pisj18.id = pispersonel.id ;
        
--จำนวนตำแหน่งที่ว่าง
select 
	posid,id
from 
	pisj18
	 
where 
	flagupdate = '1' and (length(trim(id))  = 0 or id is null)

--ตำแแหน่งคู่กับคน
select 
	*
from 
	pispersonel
	,pisj18
where
	pispersonel.posid = pisj18.posid and 
	pispersonel.id = pisj18.id and	
	pisj18.flagupdate = '1' and pispersonel.pstatus = '1'
