#!/usr/bin/ruby

require 'pg'

conn = PGconn.connect( "dbname=pis_30 user=postgres password=1234" )
####################################
sql = "update pispersonel set totalabsent = COALESCE(totalabsent,0) + 10, vac1oct = COALESCE(totalabsent,0) + 10  "
conn.exec(sql)
######################################
sql = "update pispersonel set totalabsent = 30, vac1oct = 30  "
sql += "where id in (select id from pispersonel where pstatus = 1 and EXTRACT(year from AGE(NOW(), appointdate - INTERVAL '1 days')) >= 10 "
sql += "and totalabsent > 30 ) "
conn.exec(sql)
######################################
sql = "update pispersonel set totalabsent = 20, vac1oct = 20  "
sql += "where id in (select id from pispersonel where pstatus = 1 and EXTRACT(year from AGE(NOW(), appointdate - INTERVAL '1 days')) < 10 "
sql += "and totalabsent > 20 ) "
conn.exec(sql)

conn.close()