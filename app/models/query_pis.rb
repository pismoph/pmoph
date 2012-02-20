# coding: utf-8
class QueryPis < ActiveRecord::Base
  def self.update_by_sql(sql)
    begin
      connection.update(sql)
      return true
    rescue
      return false
    end
  end
  
  def self.insert_by_arg(arg,table_name)
    val = []
    col = []
    str = ""
    arg.keys.each do |k|
      tmp = (arg[k] == "")? "null":"'#{arg[k]}'"
      col.push("\"#{k.to_s}\"")
      val.push("#{tmp}")
    end
    str = "insert into #{table_name}(#{col.join(",")}) values(#{val.join(",")})"
    begin
      connection.insert(str)
      return true
    rescue
      return false
    end
  end
  
  def self.update_by_arg(arg,table_name,where)
    val = []
    str = ""
    arg.keys.each do |k|
      tmp = (arg[k] == "")? "null":"'#{arg[k].to_s.strip}'"
      val.push("\"#{k.to_s}\" = #{tmp} ")
    end
    str = "update #{table_name} set #{val.join(",")} where #{where}"
    begin
      connection.update(str)
      return true
    rescue
      return false
    end
  end
  
  def self.insert_mass(tb,col,val)
    sql = "insert into #{tb}(#{col}) values#{val.join(",")}"
    connection.insert(sql)
  end
end
