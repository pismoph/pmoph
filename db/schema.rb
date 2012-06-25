# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 6) do

  create_table "cabsenttype", :id => false, :force => true do |t|
    t.integer  "abcode",                    :null => false
    t.string   "abtype",     :limit => 100
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
    t.string   "chk",        :limit => 1
    t.string   "cnt",        :limit => 1
    t.integer  "abquota"
  end

  create_table "camphur", :id => false, :force => true do |t|
    t.integer  "amcode",                   :null => false
    t.integer  "provcode",                 :null => false
    t.string   "shortpre",   :limit => 8
    t.string   "longpre",    :limit => 10
    t.string   "amname",     :limit => 50
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "carea", :id => false, :force => true do |t|
    t.integer  "acode",      :limit => 2,  :null => false
    t.string   "aname",      :limit => 20
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "ccasenote", :id => false, :force => true do |t|
    t.integer  "codecase",   :limit => 2,   :null => false
    t.string   "casename",   :limit => 200
    t.string   "detailnote", :limit => 200
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cchangename", :id => false, :force => true do |t|
    t.integer  "chgcode",    :limit => 2,   :null => false
    t.string   "chgname",    :limit => 200
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "ccmd", :id => false, :force => true do |t|
    t.integer  "cmdcode",                   :null => false
    t.string   "name",       :limit => 200
    t.string   "shortname",  :limit => 15
    t.string   "flag",       :limit => 1
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "ccountry", :id => false, :force => true do |t|
    t.integer  "cocode",                   :null => false
    t.string   "coname",     :limit => 50
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cdcdep", :id => false, :force => true do |t|
    t.integer  "depcode",    :limit => 2,  :null => false
    t.string   "depname",    :limit => 50
    t.string   "dshortname", :limit => 8
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cdecoratype", :id => false, :force => true do |t|
    t.integer  "dccode",     :limit => 2,  :null => false
    t.string   "shortname",  :limit => 6
    t.string   "dcname",     :limit => 30
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cdept", :id => false, :force => true do |t|
    t.integer  "deptcode",   :limit => 2,  :null => false
    t.string   "deptname",   :limit => 60
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cdivision", :id => false, :force => true do |t|
    t.integer  "dcode",      :limit => 2,  :null => false
    t.string   "division",   :limit => 60
    t.string   "prefix",     :limit => 15
    t.string   "flag",       :limit => 1
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cedulevel", :id => false, :force => true do |t|
    t.integer  "ecode",      :limit => 2,  :null => false
    t.string   "edulevel",   :limit => 40
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cepngroup", :id => false, :force => true do |t|
    t.integer  "gcode",                     :null => false
    t.string   "gname",      :limit => 100
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cepngsubgrp", :id => false, :force => true do |t|
    t.integer "gcode",   :null => false
    t.integer "grpcode", :null => false
  end

  create_table "cepnposwork", :id => false, :force => true do |t|
    t.decimal  "wrkcode",                   :precision => 5,  :scale => 0, :null => false
    t.integer  "gcode"
    t.integer  "grpcode"
    t.string   "wrknm",      :limit => 100
    t.integer  "levels"
    t.decimal  "minwages",                  :precision => 10, :scale => 2
    t.decimal  "maxwages",                  :precision => 10, :scale => 2
    t.string   "wrkatrb",    :limit => 100
    t.string   "note",       :limit => 100
    t.decimal  "numcode",                   :precision => 5,  :scale => 0
    t.decimal  "newmin",                    :precision => 10, :scale => 2
    t.decimal  "newmax",                    :precision => 10, :scale => 2
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cepnsubgrp", :id => false, :force => true do |t|
    t.integer  "grpcode",                   :null => false
    t.string   "grpnm",      :limit => 100
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cepnwages", :id => false, :force => true do |t|
    t.decimal "orders",               :precision => 3, :scale => 1, :null => false
    t.decimal "groups",               :precision => 8, :scale => 2, :null => false
    t.decimal "mnthly",               :precision => 8, :scale => 2
    t.decimal "daily",                :precision => 8, :scale => 2
    t.decimal "perhour",              :precision => 8, :scale => 2
    t.string  "flag",    :limit => 1
  end

  create_table "cepnwagesnew", :id => false, :force => true do |t|
    t.integer "groups",  :limit => 2,                               :null => false
    t.decimal "orders",               :precision => 3, :scale => 1, :null => false
    t.decimal "mnthly",               :precision => 8, :scale => 2
    t.decimal "mnthly2",              :precision => 8, :scale => 2
  end

  create_table "cexecutive", :id => false, :force => true do |t|
    t.decimal  "excode",                   :precision => 5, :scale => 0, :null => false
    t.string   "shortpre",   :limit => 10
    t.string   "longpre",    :limit => 30
    t.string   "exname",     :limit => 70
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cexpert", :id => false, :force => true do |t|
    t.decimal  "epcode",                   :precision => 5, :scale => 0, :null => false
    t.string   "prename",    :limit => 4
    t.string   "expert",     :limit => 80
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cfinpay", :id => false, :force => true do |t|
    t.integer  "fcode",      :limit => 2,  :null => false
    t.string   "finname",    :limit => 20
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cgrouplevel", :id => false, :force => true do |t|
    t.integer  "ccode",      :limit => 2,                                  :null => false
    t.string   "cname",      :limit => 200
    t.string   "scname",     :limit => 60
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
    t.decimal  "minsal1",                   :precision => 10, :scale => 2
    t.decimal  "maxsal1",                   :precision => 10, :scale => 2
    t.string   "gname",      :limit => 200
    t.string   "clname",     :limit => 200
    t.decimal  "baselow",                   :precision => 8,  :scale => 0
    t.decimal  "basehigh",                  :precision => 8,  :scale => 0
    t.decimal  "spmin1",                    :precision => 8,  :scale => 0
    t.decimal  "spmax1",                    :precision => 8,  :scale => 0
    t.decimal  "spbase1",                   :precision => 8,  :scale => 0
    t.decimal  "spbase2",                   :precision => 8,  :scale => 0
    t.decimal  "salmintmp",                 :precision => 8,  :scale => 0
    t.decimal  "maxsal2",                   :precision => 10, :scale => 2
    t.decimal  "minsal2",                   :precision => 10, :scale => 2
    t.decimal  "spmax2",                    :precision => 8,  :scale => 0
    t.decimal  "spmin2",                    :precision => 8,  :scale => 0
    t.decimal  "insigsal",                  :precision => 8,  :scale => 2
  end

  create_table "chmod", :id => false, :force => true do |t|
    t.integer "hmcode", :limit => 2,  :null => false
    t.string  "hmod",   :limit => 50
  end

  create_table "cinterval", :id => false, :force => true do |t|
    t.integer  "incode",     :limit => 2,  :null => false
    t.string   "inname",     :limit => 20
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cj18status", :id => false, :force => true do |t|
    t.integer  "j18code",    :limit => 2,  :null => false
    t.string   "j18status",  :limit => 30
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cjob", :id => false, :force => true do |t|
    t.integer  "jobcode",    :limit => 2,  :null => false
    t.string   "jobname",    :limit => 60
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "clocation", :id => false, :force => true do |t|
    t.integer  "lcode",      :limit => 2,  :null => false
    t.string   "location",   :limit => 30
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cmajor", :id => false, :force => true do |t|
    t.integer  "macode",     :limit => 2,  :null => false
    t.string   "major",      :limit => 50
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cmarital", :id => false, :force => true do |t|
    t.integer  "mrcode",     :limit => 2,  :null => false
    t.string   "marital",    :limit => 10
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cministry", :id => false, :force => true do |t|
    t.integer  "mcode",      :limit => 8,   :null => false
    t.string   "minname",    :limit => 100
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cmonth", :id => false, :force => true do |t|
    t.integer "mt_code", :limit => 2,  :null => false
    t.string  "mt_name", :limit => 30, :null => false
  end

  create_table "cnewsalary", :id => false, :force => true do |t|
    t.integer "c",         :limit => 2,                               :null => false
    t.decimal "salary",                 :precision => 8, :scale => 2, :null => false
    t.string  "flagbound", :limit => 1
    t.decimal "cstep",                  :precision => 3, :scale => 1, :null => false
    t.decimal "newsal",                 :precision => 8, :scale => 2
  end

  create_table "cofficecode", :id => false, :force => true do |t|
    t.integer  "officecode",               :null => false
    t.string   "officename"
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cofficeuse", :id => false, :force => true do |t|
    t.decimal "sdcode",                  :precision => 5, :scale => 0, :null => false
    t.string  "address",  :limit => 100
    t.integer "provcode", :limit => 2
    t.integer "amcode",   :limit => 2
    t.integer "tmcode",   :limit => 2
    t.decimal "zip",                     :precision => 5, :scale => 0
    t.string  "tel",      :limit => 30
    t.string  "fax",      :limit => 30
    t.string  "initid",   :limit => 13
    t.integer "vacation"
  end

  create_table "corderrps", :id => false, :force => true do |t|
    t.integer "sorder",  :limit => 2, :null => false
    t.integer "seccode", :limit => 2
    t.integer "jobcode", :limit => 2
  end

  create_table "corderrpt", :id => false, :force => true do |t|
    t.integer "sorder",  :limit => 2, :null => false
    t.integer "seccode", :limit => 2
    t.integer "jobcode", :limit => 2
  end

  create_table "corderssj", :id => false, :force => true do |t|
    t.integer "sorder",  :limit => 2, :null => false
    t.integer "seccode", :limit => 2
    t.integer "jobcode", :limit => 2
    t.integer "sdtype",  :limit => 2, :null => false
  end

  create_table "cposcase", :id => false, :force => true do |t|
    t.integer  "pcode",      :limit => 2,  :null => false
    t.string   "poscase",    :limit => 40
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cposcondition", :id => false, :force => true do |t|
    t.integer  "pcdcode",    :limit => 2,  :null => false
    t.string   "pcdname",    :limit => 40
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cposition", :id => false, :force => true do |t|
    t.decimal  "poscode",                   :precision => 5, :scale => 0, :null => false
    t.string   "shortpre",    :limit => 5
    t.string   "longpre",     :limit => 20
    t.string   "posname",     :limit => 40
    t.string   "stdcode",     :limit => 10
    t.string   "use_status",  :limit => 1
    t.string   "upd_user",    :limit => 20
    t.datetime "upd_date"
    t.string   "newshortpre", :limit => 5
    t.string   "newlongpre",  :limit => 20
    t.string   "newposname",  :limit => 60
    t.decimal  "newposcode",                :precision => 5, :scale => 0
    t.string   "kp",          :limit => 1
  end

  create_table "cposspsal", :id => false, :force => true do |t|
    t.decimal  "poscode",                  :precision => 5,  :scale => 0, :null => false
    t.integer  "c",          :limit => 2,                                 :null => false
    t.decimal  "salary",                   :precision => 10, :scale => 2
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cpostype", :id => false, :force => true do |t|
    t.integer  "ptcode",     :limit => 2,  :null => false
    t.string   "ptname",     :limit => 20
    t.string   "shortmn",    :limit => 10
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cprefix", :id => false, :force => true do |t|
    t.integer  "pcode",      :limit => 2,  :null => false
    t.string   "prefix",     :limit => 20
    t.string   "longprefix", :limit => 30
    t.integer  "prefax",     :limit => 2
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cprovince", :id => false, :force => true do |t|
    t.integer  "provcode",   :limit => 2,  :null => false
    t.string   "shortpre",   :limit => 2
    t.string   "longpre",    :limit => 7
    t.string   "provname",   :limit => 30
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cptmny", :id => false, :force => true do |t|
    t.integer  "ptcode",                                                 :null => false
    t.integer  "pt_c",                                                   :null => false
    t.decimal  "amt",                      :precision => 8, :scale => 2, :null => false
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cptsareamny", :id => false, :force => true do |t|
    t.integer  "gcode",                                                  :null => false
    t.decimal  "poscode",                  :precision => 5, :scale => 0, :null => false
    t.decimal  "salary",                   :precision => 8, :scale => 2, :null => false
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cptsmoney", :id => false, :force => true do |t|
    t.string   "gcode",      :limit => 4,                                 :null => false
    t.decimal  "poscode",                   :precision => 5, :scale => 0, :null => false
    t.string   "gname",      :limit => 100
    t.decimal  "salary",                    :precision => 8, :scale => 2, :null => false
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cptssetpos", :id => false, :force => true do |t|
    t.integer  "gcode",                                                   :null => false
    t.string   "gname",      :limit => 100
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
    t.decimal  "poscode",                   :precision => 5, :scale => 0, :null => false
  end

  create_table "cpunish", :id => false, :force => true do |t|
    t.integer  "pncode",     :limit => 2,  :null => false
    t.string   "pnname",     :limit => 20
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cqualify", :id => false, :force => true do |t|
    t.integer  "qcode",                    :null => false
    t.string   "qualify",    :limit => 80
    t.string   "shortpre",   :limit => 10
    t.string   "longpre",    :limit => 50
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
    t.integer  "ecode",      :limit => 2
  end

  create_table "crelation", :id => false, :force => true do |t|
    t.integer  "relcode",    :limit => 2,  :null => false
    t.string   "relname",    :limit => 60
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "creligion", :id => false, :force => true do |t|
    t.integer  "recode",     :limit => 2,  :null => false
    t.string   "renname",    :limit => 30
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "csalary", :id => false, :force => true do |t|
    t.integer "c",         :limit => 2,                               :null => false
    t.decimal "salary",                 :precision => 8, :scale => 2, :null => false
    t.string  "flagbound", :limit => 1
    t.decimal "cstep",                  :precision => 3, :scale => 1
    t.decimal "newsal1"
    t.decimal "newsal2"
    t.decimal "newsal3"
  end

  create_table "csalstatus", :id => false, :force => true do |t|
    t.integer  "salcode",    :limit => 2,  :null => false
    t.string   "salstatus",  :limit => 20
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "csdgroup", :id => false, :force => true do |t|
    t.integer  "sdgcode",    :limit => 2,  :null => false
    t.string   "sdgname",    :limit => 30
    t.string   "shortpre",   :limit => 10
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "csection", :id => false, :force => true do |t|
    t.integer  "seccode",    :limit => 2,  :null => false
    t.string   "shortname",  :limit => 30
    t.string   "secname",    :limit => 60
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "csex", :id => false, :force => true do |t|
    t.integer "sexcode", :limit => 2,  :null => false
    t.string  "sexname", :limit => 30, :null => false
  end

  create_table "cspcmny", :id => false, :force => true do |t|
    t.integer  "spcode",     :limit => 2,  :null => false
    t.string   "shortname",  :limit => 20
    t.string   "spcmny",     :limit => 30
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cspcode", :id => false, :force => true do |t|
    t.string  "spcode",    :limit => 4,   :null => false
    t.string  "spdesc",    :limit => 150
    t.string  "groupid",   :limit => 2
    t.string  "spcodeold", :limit => 2
    t.string  "splevel",   :limit => 1
    t.integer "poscode",                  :null => false
  end

  create_table "csubdept", :id => false, :force => true do |t|
    t.decimal  "sdcode",                     :precision => 5,  :scale => 0, :null => false
    t.string   "shortpre",    :limit => 20
    t.string   "longpre",     :limit => 30
    t.string   "subdeptname", :limit => 100
    t.integer  "sdtcode",     :limit => 2
    t.integer  "sdgcode",     :limit => 2
    t.integer  "acode",       :limit => 2
    t.integer  "trlcode",     :limit => 2
    t.integer  "provcode",    :limit => 2
    t.integer  "amcode",      :limit => 2
    t.integer  "tmcode",      :limit => 2
    t.integer  "fcode",       :limit => 2
    t.integer  "lcode",       :limit => 2
    t.string   "flagbkd",     :limit => 1
    t.string   "oldcode",     :limit => 13
    t.decimal  "oldsdcode",                  :precision => 12, :scale => 0
    t.string   "stdcode",     :limit => 10
    t.string   "use_status",  :limit => 1
    t.string   "upd_user",    :limit => 20
    t.datetime "upd_date"
  end

  add_index "csubdept", ["sdcode"], :name => "ind_sdcode", :unique => true
  add_index "csubdept", ["subdeptname"], :name => "ind_subdeptname"

  create_table "csubdepttype", :id => false, :force => true do |t|
    t.integer  "sdtcode",     :limit => 2,  :null => false
    t.string   "subdepttype", :limit => 50
    t.string   "stdcode",     :limit => 10
    t.string   "use_status",  :limit => 1
    t.string   "upd_user",    :limit => 20
    t.datetime "upd_date"
  end

  create_table "csubsdcode", :id => false, :force => true do |t|
    t.integer  "subsdcode",  :limit => 2,  :null => false
    t.string   "subsdname"
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "ctrade", :id => false, :force => true do |t|
    t.integer  "codetrade",  :limit => 2,   :null => false
    t.string   "trade",      :limit => 100
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "ctrainlevel", :id => false, :force => true do |t|
    t.integer  "trlcode",    :limit => 2,  :null => false
    t.string   "trlname",    :limit => 30
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "ctumbon", :id => false, :force => true do |t|
    t.integer  "tmcode",     :limit => 2,  :null => false
    t.integer  "amcode",     :limit => 2,  :null => false
    t.integer  "provcode",   :limit => 2,  :null => false
    t.string   "shortpre",   :limit => 2
    t.string   "longpre",    :limit => 4
    t.string   "tmname",     :limit => 30
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "cupdate", :id => false, :force => true do |t|
    t.decimal  "updcode",                  :precision => 4, :scale => 0, :null => false
    t.string   "updname",    :limit => 60
    t.integer  "updsort",    :limit => 2
    t.string   "stdcode",    :limit => 10
    t.string   "use_status", :limit => 1
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
  end

  create_table "dgdcdcr", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13,                                :null => false
    t.integer  "dccode",    :limit => 2,                                 :null => false
    t.integer  "dcyear",    :limit => 2,                                 :null => false
    t.integer  "book",      :limit => 2
    t.string   "section",   :limit => 10
    t.integer  "pageno",    :limit => 2
    t.decimal  "seq",                     :precision => 10, :scale => 0
    t.datetime "recdate"
    t.datetime "kitjadate"
    t.datetime "retdate"
    t.string   "billno",    :limit => 5
    t.string   "bookno",    :limit => 5
    t.datetime "billdate"
    t.decimal  "money",                   :precision => 6,  :scale => 0
    t.decimal  "poscode",                 :precision => 5,  :scale => 0
    t.decimal  "excode",                  :precision => 5,  :scale => 0
    t.decimal  "epcode",                  :precision => 5,  :scale => 0
    t.integer  "c",         :limit => 2
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
    t.integer  "ptcode",    :limit => 2
    t.string   "note"
  end

  create_table "dgpnabsent", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13,                               :null => false
    t.integer  "abcode",    :limit => 2,                                :null => false
    t.date     "begindate",                                             :null => false
    t.date     "enddate"
    t.decimal  "amount",                  :precision => 5, :scale => 1
    t.string   "flagcount", :limit => 1
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
  end

  add_index "dgpnabsent", ["id"], :name => "xif8dgpnabsent"

  create_table "dgpnchgname", :id => false, :force => true do |t|
    t.string "id",      :limit => 13, :null => false
    t.date   "chgdate",               :null => false
    t.string "fname",   :limit => 45
    t.string "lname",   :limit => 45
  end

  create_table "dgpneducation", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13, :null => false
    t.integer  "eorder",    :limit => 2,  :null => false
    t.integer  "macode",    :limit => 2
    t.integer  "qcode",     :limit => 2
    t.integer  "ecode",     :limit => 2
    t.integer  "cocode",    :limit => 2
    t.string   "institute"
    t.datetime "enddate"
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
    t.string   "flag",      :limit => 1
  end

  add_index "dgpneducation", ["id"], :name => "xif6dgpneducation"

  create_table "dgpnexamlev", :id => false, :force => true do |t|
    t.decimal  "poscode",                 :precision => 5, :scale => 0, :null => false
    t.integer  "c",        :limit => 2,                                 :null => false
    t.string   "id",       :limit => 13,                                :null => false
    t.date     "examdate",                                              :null => false
    t.integer  "examint",  :limit => 2
    t.string   "project",  :limit => 200
    t.string   "examno",   :limit => 10
    t.string   "upduser",  :limit => 30
    t.datetime "upddate"
  end

  add_index "dgpnexamlev", ["id"], :name => "xif9dgpnexamlev"

  create_table "dgpnhelpwork", :id => false, :force => true do |t|
    t.string   "id",          :limit => 13,                                :null => false
    t.decimal  "posid",                      :precision => 6, :scale => 0
    t.decimal  "sdcode",                     :precision => 5, :scale => 0
    t.integer  "seccode",     :limit => 2
    t.integer  "jobcode",     :limit => 2
    t.integer  "amyear",      :limit => 2
    t.integer  "ammonth",     :limit => 2
    t.date     "begindate"
    t.string   "refcmd",      :limit => 60
    t.string   "rem",         :limit => 70
    t.datetime "upddate"
    t.string   "upduser",     :limit => 30
    t.integer  "deptcode",    :limit => 2
    t.string   "prename",     :limit => 10
    t.string   "fname",       :limit => 35
    t.string   "lname",       :limit => 35
    t.integer  "olddeptcode", :limit => 2
    t.integer  "oldsdcode",   :limit => 2
    t.decimal  "poscode",                    :precision => 5, :scale => 0
    t.integer  "pcode",       :limit => 2
    t.decimal  "excode",                     :precision => 5, :scale => 0
    t.decimal  "epcode",                     :precision => 5, :scale => 0
    t.integer  "c",           :limit => 2
    t.decimal  "salary",                     :precision => 5, :scale => 0
    t.string   "fromdept",    :limit => 500
    t.string   "pid",         :limit => 13
  end

  create_table "dgpnhelpwork_absent", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13,                               :null => false
    t.integer  "abcode",    :limit => 2,                                :null => false
    t.date     "begindate",                                             :null => false
    t.date     "enddate"
    t.decimal  "amount",                  :precision => 5, :scale => 1
    t.string   "flagcount", :limit => 1
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
  end

  create_table "dgpnpersonel", :id => false, :force => true do |t|
    t.string   "id",          :limit => 13,                                :null => false
    t.integer  "pcode",       :limit => 2
    t.string   "fname",       :limit => 50
    t.string   "lname",       :limit => 50
    t.string   "sex",         :limit => 1
    t.string   "race",        :limit => 30
    t.string   "nationality", :limit => 30
    t.integer  "mrcode",      :limit => 2
    t.integer  "recode",      :limit => 2
    t.date     "birthdate"
    t.date     "appointdate"
    t.date     "deptdate"
    t.date     "cdate"
    t.date     "retiredate"
    t.integer  "dcode",       :limit => 2
    t.integer  "deptcode",    :limit => 2
    t.decimal  "sdcode",                     :precision => 5, :scale => 0
    t.integer  "seccode",     :limit => 2
    t.integer  "jobcode",     :limit => 2
    t.integer  "hmcode",      :limit => 2
    t.decimal  "poscode",                    :precision => 5, :scale => 0
    t.decimal  "excode",                     :precision => 5, :scale => 0
    t.decimal  "epcode",                     :precision => 5, :scale => 0
    t.integer  "provcode",    :limit => 2
    t.string   "address1",    :limit => 100
    t.string   "address2",    :limit => 100
    t.string   "tel",         :limit => 30
    t.decimal  "zip",                        :precision => 5, :scale => 0
    t.integer  "macode",      :limit => 2
    t.integer  "qcode",       :limit => 2
    t.integer  "ecode",       :limit => 2
    t.integer  "cocode",      :limit => 2
    t.decimal  "posid",                      :precision => 6, :scale => 0
    t.integer  "c",           :limit => 2
    t.decimal  "salary",                     :precision => 8, :scale => 2
    t.string   "oldfname",    :limit => 50
    t.string   "oldlname",    :limit => 50
    t.string   "father",      :limit => 50
    t.string   "mother",      :limit => 50
    t.string   "spouse",      :limit => 50
    t.integer  "childs",      :limit => 2
    t.decimal  "totalabsent",                :precision => 5, :scale => 1
    t.integer  "salcode",     :limit => 2
    t.integer  "j18code",     :limit => 2
    t.string   "picname",     :limit => 50
    t.string   "note"
    t.datetime "upddate"
    t.string   "upduser",     :limit => 30
    t.decimal  "oldid",                      :precision => 6, :scale => 0
    t.datetime "exitdate"
    t.integer  "spcode",      :limit => 2
    t.decimal  "spmny",                      :precision => 8, :scale => 2
    t.integer  "spexpos"
    t.integer  "codetrade",   :limit => 2
    t.date     "renamedate"
    t.date     "getindate"
    t.string   "kbk",         :limit => 1
    t.string   "pstatus",     :limit => 1
    t.integer  "ptcode",      :limit => 2
    t.decimal  "vac1oct",                    :precision => 4, :scale => 1
    t.string   "pid",         :limit => 13
  end

  add_index "dgpnpersonel", ["id"], :name => "pk_id", :unique => true

  create_table "dgpnposhis", :id => false, :force => true do |t|
    t.string   "id",         :limit => 13,                                :null => false
    t.integer  "historder",  :limit => 2,                                 :null => false
    t.date     "forcedate",                                               :null => false
    t.decimal  "poscode",                   :precision => 5, :scale => 0
    t.decimal  "excode",                    :precision => 5, :scale => 0
    t.decimal  "epcode",                    :precision => 5, :scale => 0
    t.integer  "mcode",      :limit => 2
    t.integer  "dcode",      :limit => 2
    t.integer  "deptcode",   :limit => 2
    t.decimal  "sdcode",                    :precision => 5, :scale => 0
    t.integer  "seccode",    :limit => 2
    t.integer  "jobcode",    :limit => 2
    t.integer  "hmcode",     :limit => 2
    t.decimal  "updcode",                   :precision => 4, :scale => 0
    t.decimal  "posid",                     :precision => 6, :scale => 0
    t.integer  "c",          :limit => 2
    t.decimal  "salary",                    :precision => 5, :scale => 0
    t.string   "refcmnd",    :limit => 150
    t.datetime "upddate"
    t.string   "upduser",    :limit => 30
    t.text     "note"
    t.decimal  "ptcode",                    :precision => 5, :scale => 0
    t.string   "persontype", :limit => 1
  end

  add_index "dgpnposhis", ["id"], :name => "xif7dgpnposhis"

  create_table "dgpnpunish", :id => false, :force => true do |t|
    t.string   "id",          :limit => 13, :null => false
    t.date     "forcedate",                 :null => false
    t.integer  "pncode",      :limit => 2
    t.string   "description", :limit => 60
    t.string   "cmdno",       :limit => 60
    t.datetime "upddate"
    t.string   "upduser",     :limit => 30
  end

  add_index "dgpnpunish", ["id"], :name => "xif5dgpnpunish"

  create_table "dgpntrainning", :primary_key => "tno", :force => true do |t|
    t.date     "begindate"
    t.string   "id",        :limit => 13, :null => false
    t.integer  "cocode",    :limit => 2
    t.date     "enddate"
    t.string   "cource",    :limit => 60
    t.string   "institute", :limit => 60
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
  end

  create_table "dgpoj18", :id => false, :force => true do |t|
    t.decimal  "posid",                     :precision => 6,  :scale => 0, :null => false
    t.string   "id",         :limit => 13
    t.integer  "dcode",      :limit => 2
    t.integer  "deptcode",   :limit => 2
    t.decimal  "sdcode",                    :precision => 5,  :scale => 0
    t.integer  "seccode",    :limit => 2
    t.integer  "jobcode",    :limit => 2
    t.decimal  "poscode",                   :precision => 5,  :scale => 0
    t.decimal  "excode",                    :precision => 5,  :scale => 0
    t.decimal  "epcode",                    :precision => 5,  :scale => 0
    t.integer  "lastc",      :limit => 2
    t.decimal  "lastsal",                   :precision => 5,  :scale => 0
    t.integer  "nowc",       :limit => 2
    t.decimal  "nowsal",                    :precision => 5,  :scale => 0
    t.integer  "lastcasb",   :limit => 2
    t.decimal  "lastsalasb",                :precision => 5,  :scale => 0
    t.integer  "nowcasb",    :limit => 2
    t.decimal  "nowsalasb",                 :precision => 5,  :scale => 0
    t.decimal  "decmny",                    :precision => 5,  :scale => 0
    t.decimal  "incmny",                    :precision => 5,  :scale => 0
    t.decimal  "qualmny",                   :precision => 5,  :scale => 0
    t.decimal  "posupmny",                  :precision => 5,  :scale => 0
    t.decimal  "addmny",                    :precision => 5,  :scale => 0
    t.string   "flagasb",    :limit => 1
    t.decimal  "posmny",                    :precision => 5,  :scale => 0
    t.decimal  "bkdmny",                    :precision => 5,  :scale => 0
    t.integer  "pcode",      :limit => 2
    t.integer  "incode",     :limit => 2
    t.integer  "pcdcode",    :limit => 2
    t.integer  "ptcode",     :limit => 2
    t.string   "rem",        :limit => 250
    t.datetime "upddate"
    t.string   "upduser",    :limit => 30
    t.date     "emptydate"
    t.date     "asbdate"
    t.string   "flagupdate", :limit => 1
    t.integer  "c",          :limit => 2
    t.integer  "addc",       :limit => 2
    t.decimal  "salary",                    :precision => 5,  :scale => 0
    t.integer  "rp_order"
    t.decimal  "posid2",                    :precision => 10, :scale => 0
    t.decimal  "dcode2",                    :precision => 4,  :scale => 0
    t.decimal  "sdcode2",                   :precision => 10, :scale => 0
    t.decimal  "seccode2",                  :precision => 4,  :scale => 0
    t.decimal  "jobcode2",                  :precision => 4,  :scale => 0
    t.decimal  "sortj182",                  :precision => 4,  :scale => 0
    t.decimal  "updapr",                    :precision => 5,  :scale => 0
    t.decimal  "updoct",                    :precision => 5,  :scale => 0
  end

  add_index "dgpoj18", ["id"], :name => "xif11dgpoj18"
  add_index "dgpoj18", ["posid"], :name => "pk_posid", :unique => true

  create_table "epnabsent", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13,                               :null => false
    t.integer  "abcode",    :limit => 2,                                :null => false
    t.datetime "begindate",                                             :null => false
    t.datetime "enddate"
    t.decimal  "amount",                  :precision => 5, :scale => 1
    t.string   "flagcount", :limit => 1
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
  end

  add_index "epnabsent", ["id", "abcode", "begindate"], :name => "xpkepnabsent", :unique => true
  add_index "epnabsent", ["id"], :name => "xif8epnabsent"

  create_table "epnchgname", :id => false, :force => true do |t|
    t.string   "id",      :limit => 13, :null => false
    t.datetime "chgdate",               :null => false
    t.string   "fname",   :limit => 45
    t.string   "lname",   :limit => 45
  end

  create_table "epneducation", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13, :null => false
    t.integer  "eorder",    :limit => 2,  :null => false
    t.integer  "macode",    :limit => 2
    t.integer  "qcode",     :limit => 2
    t.integer  "ecode",     :limit => 2
    t.integer  "cocode",    :limit => 2
    t.string   "institute", :limit => 60
    t.datetime "enddate"
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
    t.string   "flag",      :limit => 1
  end

  add_index "epneducation", ["id", "eorder"], :name => "xpkepneducation", :unique => true
  add_index "epneducation", ["id"], :name => "xif6epneducation"

  create_table "epnexamlev", :id => false, :force => true do |t|
    t.decimal  "poscode",                 :precision => 5, :scale => 0, :null => false
    t.integer  "c",        :limit => 2,                                 :null => false
    t.string   "id",       :limit => 13,                                :null => false
    t.datetime "examdate",                                              :null => false
    t.integer  "examint",  :limit => 2
    t.string   "project",  :limit => 200
    t.string   "examno",   :limit => 10
    t.string   "upduser",  :limit => 30
    t.datetime "upddate"
  end

  add_index "epnexamlev", ["id"], :name => "xif9epnexamlev"
  add_index "epnexamlev", ["poscode", "c", "id", "examdate"], :name => "xpkepnexamlev", :unique => true

  create_table "epnhelpwork", :id => false, :force => true do |t|
    t.string   "id",          :limit => 13,                                :null => false
    t.string   "pid",         :limit => 13
    t.decimal  "posid",                      :precision => 6, :scale => 0
    t.decimal  "sdcode",                     :precision => 5, :scale => 0
    t.integer  "seccode",     :limit => 2
    t.integer  "jobcode",     :limit => 2
    t.integer  "amyear",      :limit => 2
    t.integer  "ammonth",     :limit => 2
    t.datetime "begindate"
    t.string   "refcmd",      :limit => 60
    t.string   "rem",         :limit => 70
    t.datetime "upddate"
    t.string   "upduser",     :limit => 30
    t.integer  "deptcode",    :limit => 2
    t.string   "prename",     :limit => 10
    t.string   "fname",       :limit => 35
    t.string   "lname",       :limit => 35
    t.integer  "olddeptcode", :limit => 2
    t.integer  "oldsdcode",   :limit => 2
    t.decimal  "poscode",                    :precision => 5, :scale => 0
    t.integer  "pcode",       :limit => 2
    t.decimal  "excode",                     :precision => 5, :scale => 0
    t.decimal  "epcode",                     :precision => 5, :scale => 0
    t.integer  "c",           :limit => 2
    t.decimal  "salary",                     :precision => 5, :scale => 0
    t.string   "fromdept",    :limit => 500
  end

  create_table "epnhelpwork_absent", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13,                               :null => false
    t.integer  "abcode",    :limit => 2,                                :null => false
    t.datetime "begindate",                                             :null => false
    t.datetime "enddate"
    t.decimal  "amount",                  :precision => 5, :scale => 1
    t.string   "flagcount", :limit => 1
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
  end

  create_table "epninsig", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13,                                :null => false
    t.integer  "dccode",    :limit => 2,                                 :null => false
    t.integer  "dcyear",    :limit => 2,                                 :null => false
    t.integer  "book",      :limit => 2
    t.string   "section",   :limit => 10
    t.integer  "pageno",    :limit => 2
    t.decimal  "seq",                     :precision => 10, :scale => 0
    t.datetime "recdate"
    t.datetime "kitjadate"
    t.datetime "retdate"
    t.string   "billno",    :limit => 5
    t.string   "bookno",    :limit => 5
    t.datetime "billdate"
    t.decimal  "money",                   :precision => 6,  :scale => 0
    t.decimal  "poscode",                 :precision => 5,  :scale => 0
    t.decimal  "excode",                  :precision => 5,  :scale => 0
    t.decimal  "epcode",                  :precision => 5,  :scale => 0
    t.integer  "c",         :limit => 2
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
    t.integer  "ptcode",    :limit => 2
    t.string   "note"
  end

  add_index "epninsig", ["id", "dccode", "dcyear"], :name => "xpkepndgdcdcr", :unique => true

  create_table "epnj18", :id => false, :force => true do |t|
    t.decimal  "posid",                     :precision => 6,  :scale => 0, :null => false
    t.string   "id",         :limit => 13
    t.integer  "dcode",      :limit => 2
    t.integer  "deptcode",   :limit => 2
    t.decimal  "sdcode",                    :precision => 5,  :scale => 0
    t.integer  "seccode",    :limit => 2
    t.integer  "jobcode",    :limit => 2
    t.decimal  "poscode",                   :precision => 5,  :scale => 0
    t.decimal  "excode",                    :precision => 5,  :scale => 0
    t.decimal  "epcode",                    :precision => 5,  :scale => 0
    t.integer  "lastc",      :limit => 2
    t.decimal  "lastsal",                   :precision => 5,  :scale => 0
    t.integer  "nowc",       :limit => 2
    t.decimal  "nowsal",                    :precision => 5,  :scale => 0
    t.integer  "lastcasb",   :limit => 2
    t.decimal  "lastsalasb",                :precision => 5,  :scale => 0
    t.integer  "nowcasb",    :limit => 2
    t.decimal  "nowsalasb",                 :precision => 5,  :scale => 0
    t.decimal  "decmny",                    :precision => 5,  :scale => 0
    t.decimal  "incmny",                    :precision => 5,  :scale => 0
    t.decimal  "qualmny",                   :precision => 5,  :scale => 0
    t.decimal  "posupmny",                  :precision => 5,  :scale => 0
    t.decimal  "addmny",                    :precision => 5,  :scale => 0
    t.string   "flagasb",    :limit => 1
    t.decimal  "posmny",                    :precision => 5,  :scale => 0
    t.decimal  "bkdmny",                    :precision => 5,  :scale => 0
    t.integer  "pcode",      :limit => 2
    t.integer  "incode",     :limit => 2
    t.integer  "pcdcode",    :limit => 2
    t.integer  "ptcode",     :limit => 2
    t.string   "rem",        :limit => 250
    t.datetime "upddate"
    t.string   "upduser",    :limit => 30
    t.date     "emptydate"
    t.date     "asbdate"
    t.string   "flagupdate", :limit => 1
    t.integer  "c",          :limit => 2
    t.integer  "addc",       :limit => 2
    t.decimal  "salary",                    :precision => 5,  :scale => 0
    t.integer  "rp_order"
    t.string   "ptype",      :limit => 1
    t.decimal  "upsalary",                  :precision => 8,  :scale => 2
    t.decimal  "aprsal",                    :precision => 8,  :scale => 2
    t.decimal  "aprsalasb",                 :precision => 8,  :scale => 2
    t.decimal  "octsal",                    :precision => 8,  :scale => 2
    t.decimal  "octsalasb",                 :precision => 8,  :scale => 2
    t.decimal  "posid2",                    :precision => 10, :scale => 0
    t.decimal  "dcode2",                    :precision => 4,  :scale => 0
    t.decimal  "sdcode2",                   :precision => 10, :scale => 0
    t.decimal  "seccode2",                  :precision => 4,  :scale => 0
    t.decimal  "jobcode2",                  :precision => 4,  :scale => 0
    t.decimal  "sortj182",                  :precision => 4,  :scale => 0
  end

  add_index "epnj18", ["id"], :name => "xif11epndgpoj18"
  add_index "epnj18", ["posid"], :name => "pk_epnposid", :unique => true

  create_table "epnpersonel", :id => false, :force => true do |t|
    t.string   "id",          :limit => 13,                                :null => false
    t.integer  "pcode",       :limit => 2
    t.string   "fname",       :limit => 50
    t.string   "lname",       :limit => 50
    t.string   "sex",         :limit => 1
    t.string   "race",        :limit => 30
    t.string   "nationality", :limit => 30
    t.integer  "mrcode",      :limit => 2
    t.integer  "recode",      :limit => 2
    t.datetime "birthdate"
    t.datetime "appointdate"
    t.datetime "deptdate"
    t.datetime "cdate"
    t.datetime "retiredate"
    t.integer  "dcode",       :limit => 2
    t.integer  "deptcode",    :limit => 2
    t.decimal  "sdcode",                     :precision => 5, :scale => 0
    t.integer  "seccode",     :limit => 2
    t.integer  "jobcode",     :limit => 2
    t.integer  "hmcode",      :limit => 2
    t.decimal  "poscode",                    :precision => 5, :scale => 0
    t.decimal  "excode",                     :precision => 5, :scale => 0
    t.decimal  "epcode",                     :precision => 5, :scale => 0
    t.integer  "provcode",    :limit => 2
    t.string   "address1",    :limit => 100
    t.string   "address2",    :limit => 100
    t.string   "tel",         :limit => 30
    t.decimal  "zip",                        :precision => 5, :scale => 0
    t.integer  "macode",      :limit => 2
    t.integer  "qcode",       :limit => 2
    t.integer  "ecode",       :limit => 2
    t.integer  "cocode",      :limit => 2
    t.decimal  "posid",                      :precision => 6, :scale => 0
    t.integer  "c",           :limit => 2
    t.decimal  "salary",                     :precision => 8, :scale => 2
    t.string   "oldfname",    :limit => 50
    t.string   "oldlname",    :limit => 50
    t.string   "father",      :limit => 50
    t.string   "mother",      :limit => 50
    t.string   "spouse",      :limit => 50
    t.integer  "childs",      :limit => 2
    t.decimal  "totalabsent",                :precision => 5, :scale => 1
    t.integer  "salcode",     :limit => 2
    t.integer  "j18code",     :limit => 2
    t.string   "picname",     :limit => 50
    t.string   "note"
    t.datetime "upddate"
    t.string   "upduser",     :limit => 30
    t.decimal  "oldid",                      :precision => 6, :scale => 0
    t.datetime "exitdate"
    t.integer  "spcode",      :limit => 2
    t.decimal  "spmny",                      :precision => 8, :scale => 2
    t.integer  "spexpos"
    t.integer  "codetrade",   :limit => 2
    t.datetime "renamedate"
    t.datetime "getindate"
    t.string   "kbk",         :limit => 1
    t.string   "pstatus",     :limit => 1
    t.integer  "ptcode",      :limit => 2
    t.string   "ptype",       :limit => 1
    t.decimal  "vac1oct",                    :precision => 4, :scale => 1
    t.string   "pid",         :limit => 13
  end

  add_index "epnpersonel", ["id"], :name => "pk_epnid", :unique => true

  create_table "epnposhis", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13,                                :null => false
    t.integer  "historder", :limit => 2,                                 :null => false
    t.datetime "forcedate",                                              :null => false
    t.decimal  "poscode",                  :precision => 5, :scale => 0
    t.decimal  "excode",                   :precision => 5, :scale => 0
    t.decimal  "epcode",                   :precision => 5, :scale => 0
    t.integer  "mcode",     :limit => 2
    t.integer  "dcode",     :limit => 2
    t.integer  "deptcode",  :limit => 2
    t.decimal  "sdcode",                   :precision => 5, :scale => 0
    t.integer  "seccode",   :limit => 2
    t.integer  "jobcode",   :limit => 2
    t.integer  "hmcode",    :limit => 2
    t.decimal  "updcode",                  :precision => 4, :scale => 0
    t.decimal  "posid",                    :precision => 6, :scale => 0
    t.integer  "c",         :limit => 2
    t.decimal  "salary",                   :precision => 5, :scale => 0
    t.string   "refcmnd",   :limit => nil
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
    t.text     "note"
    t.decimal  "ptcode",                   :precision => 5, :scale => 0
  end

  add_index "epnposhis", ["id", "historder"], :name => "xpkepnposhis", :unique => true
  add_index "epnposhis", ["id"], :name => "xif7epnposhis"

  create_table "epnpunish", :id => false, :force => true do |t|
    t.string   "id",          :limit => 13, :null => false
    t.datetime "forcedate",                 :null => false
    t.integer  "pncode",      :limit => 2
    t.string   "description", :limit => 60
    t.string   "cmdno",       :limit => 60
    t.datetime "upddate"
    t.string   "upduser",     :limit => 30
  end

  add_index "epnpunish", ["id"], :name => "epndgpnpunish"

  create_table "epntrainning", :id => false, :force => true do |t|
    t.integer  "tno",                      :null => false
    t.datetime "begindate"
    t.string   "id",        :limit => 13,  :null => false
    t.integer  "cocode",    :limit => 2
    t.datetime "enddate"
    t.string   "cource",    :limit => nil
    t.string   "institute", :limit => nil
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
  end

  create_table "group_users", :force => true do |t|
    t.string   "name"
    t.string   "menu_code"
    t.string   "menu_manage_user"
    t.string   "menu_personal_info"
    t.string   "menu_report"
    t.string   "menu_command"
    t.string   "admin"
    t.string   "mcode"
    t.string   "deptcode"
    t.string   "dcode"
    t.string   "sdcode"
    t.string   "seccode"
    t.string   "jobcode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "menu_search"
    t.string   "type_group"
    t.string   "provcode"
    t.string   "menu_pisj18"
    t.string   "menu_perform_now"
    t.string   "menu_pisposhis"
    t.string   "menu_pispersonel"
    t.string   "menu_piseducation"
    t.string   "menu_pisabsent"
    t.string   "menu_pistrain"
    t.string   "menu_pisinsig"
    t.string   "menu_pispunish"
  end

  create_table "order_case", :id => false, :force => true do |t|
    t.string  "id",           :limit => 13,                                :null => false
    t.float   "serial_no",                                                 :null => false
    t.string  "bud_year",     :limit => 4,                                 :null => false
    t.string  "case1",        :limit => 1
    t.string  "case2",        :limit => 1
    t.string  "case3",        :limit => 1
    t.string  "case4",        :limit => 1
    t.string  "case5",        :limit => 1
    t.string  "kpdate",       :limit => 40
    t.string  "estdate",      :limit => 40
    t.string  "metdate",      :limit => 40
    t.decimal "kposid",                      :precision => 8, :scale => 0
    t.string  "kdate",        :limit => 40
    t.string  "kcmdno",       :limit => 40
    t.integer "casec31",      :limit => 2
    t.decimal "casesal31",                   :precision => 8, :scale => 0
    t.decimal "case31_pos1",                 :precision => 8, :scale => 0
    t.decimal "case31_pos2",                 :precision => 8, :scale => 0
    t.integer "casec32",      :limit => 2
    t.decimal "casesal32",                   :precision => 8, :scale => 2
    t.integer "casec33",      :limit => 2
    t.decimal "casesal33",                   :precision => 8, :scale => 2
    t.integer "ptcode"
    t.decimal "possal",                      :precision => 8, :scale => 2
    t.string  "posdate"
    t.text    "note"
    t.string  "case6",        :limit => 1
    t.string  "case2pos",     :limit => 100
    t.string  "case2posid",   :limit => 10
    t.string  "case2place"
    t.string  "case2start"
    t.string  "case2cmd"
    t.string  "case2cmddate", :limit => 100
    t.text    "case0"
    t.text    "case1note"
  end

  add_index "order_case", ["id", "serial_no", "bud_year"], :name => "xpkorder_case", :unique => true

  create_table "order_detailper", :id => false, :force => true do |t|
    t.string  "id",            :limit => 13,  :null => false
    t.float   "serial_no",                    :null => false
    t.string  "bud_year",      :limit => 4,   :null => false
    t.integer "pcode",         :limit => 2
    t.string  "fname",         :limit => 50
    t.string  "lname",         :limit => 50
    t.string  "flag_order",    :limit => 1
    t.text    "note1"
    t.integer "j18code",       :limit => 2
    t.integer "qcode",         :limit => 2
    t.integer "provcode",      :limit => 2
    t.integer "old_provcode",  :limit => 2
    t.date    "birthdate"
    t.string  "kp_no",         :limit => 15
    t.date    "kp_date"
    t.float   "old_budsalary"
    t.integer "kp_testno"
    t.string  "kp_test",       :limit => 100
    t.string  "certify",       :limit => 200
    t.integer "macode",        :limit => 2
    t.integer "ecode",         :limit => 2
    t.integer "cocode",        :limit => 2
    t.float   "kpposcode"
    t.integer "kplevel",       :limit => 2
    t.integer "codetrade",     :limit => 2
    t.integer "divcode",       :limit => 2
    t.integer "deptcode",      :limit => 2
    t.float   "sdcode"
    t.integer "seccode",       :limit => 2
    t.integer "jobcode",       :limit => 2
    t.string  "note"
    t.date    "workstart"
    t.date    "workend"
    t.date    "exitdate"
    t.date    "c_date"
    t.integer "new_macode",    :limit => 2
    t.integer "new_qcode",     :limit => 2
    t.integer "new_ecode",     :limit => 2
    t.string  "new_institute"
    t.string  "flag_date",     :limit => 1
    t.text    "rpt1"
    t.text    "rpt2"
    t.text    "rpt3"
    t.text    "rpt4"
    t.text    "rpt5"
    t.text    "rpt6"
    t.string  "pid",           :limit => 13
  end

  create_table "order_newpos", :id => false, :force => true do |t|
    t.string   "id",          :limit => 13,                                :null => false
    t.float    "serial_no",                                                :null => false
    t.string   "bud_year",    :limit => 4,                                 :null => false
    t.float    "posid"
    t.decimal  "epcode",                     :precision => 5, :scale => 0
    t.float    "poscode"
    t.integer  "c",           :limit => 2
    t.float    "salary"
    t.float    "excode"
    t.integer  "jobcode",     :limit => 2
    t.integer  "seccode",     :limit => 2
    t.float    "sdcode"
    t.date     "effect_date"
    t.string   "flag_order",  :limit => 1
    t.text     "note1"
    t.string   "upduser",     :limit => 30
    t.datetime "upddate"
    t.date     "out_date"
    t.date     "c_date"
    t.float    "updcode"
    t.integer  "divcode",     :limit => 2
    t.integer  "deptcode",    :limit => 2
    t.integer  "codecase",    :limit => 2
    t.integer  "casec",       :limit => 2
    t.float    "casesalary"
    t.integer  "j18code",     :limit => 2
    t.integer  "ptcode",      :limit => 2
    t.string   "flag_pok",    :limit => 1
    t.string   "out_cause",   :limit => 100
    t.date     "c_todate"
    t.string   "flagpos",     :limit => 1
    t.integer  "nowc",        :limit => 2
    t.decimal  "nowsal",                     :precision => 9, :scale => 2
    t.integer  "lastc",       :limit => 2
    t.decimal  "lastsal",                    :precision => 9, :scale => 2
    t.integer  "nowcasb",     :limit => 2
    t.decimal  "nowsalasb",                  :precision => 9, :scale => 2
    t.integer  "lastcasb",    :limit => 2
    t.decimal  "lastsalasb",                 :precision => 9, :scale => 2
  end

  create_table "order_oldpos", :id => false, :force => true do |t|
    t.string   "id",              :limit => 13,                               :null => false
    t.float    "serial_no",                                                   :null => false
    t.string   "bud_year",        :limit => 4,                                :null => false
    t.string   "flag_order",      :limit => 1
    t.text     "note1"
    t.string   "upduser",         :limit => 30
    t.datetime "upddate"
    t.float    "old_posid"
    t.float    "old_poscode"
    t.integer  "old_c",           :limit => 2
    t.float    "old_salary"
    t.float    "old_excode"
    t.integer  "old_jobcode",     :limit => 2
    t.integer  "old_seccode",     :limit => 2
    t.float    "old_sdcode"
    t.date     "out_date"
    t.date     "oldjob_date"
    t.date     "c_date"
    t.float    "old_budsalary"
    t.integer  "old_divcode",     :limit => 2
    t.integer  "old_deptcode",    :limit => 2
    t.integer  "old_provcode",    :limit => 2
    t.date     "old_effect_date"
    t.float    "old_epcode"
    t.integer  "old_ptcode",      :limit => 2
    t.integer  "old_mcode",       :limit => 2
    t.integer  "nowc",            :limit => 2
    t.decimal  "nowsal",                        :precision => 9, :scale => 2
    t.integer  "lastc",           :limit => 2
    t.decimal  "lastsal",                       :precision => 9, :scale => 2
    t.integer  "nowcasb",         :limit => 2
    t.decimal  "nowsalasb",                     :precision => 9, :scale => 2
    t.integer  "lastcasb",        :limit => 2
    t.decimal  "lastsalasb",                    :precision => 9, :scale => 2
  end

  create_table "order_position", :id => false, :force => true do |t|
    t.decimal  "posid",                       :precision => 6,  :scale => 0, :null => false
    t.decimal  "serial_no",                   :precision => 6,  :scale => 0, :null => false
    t.string   "bud_year",     :limit => 4,                                  :null => false
    t.decimal  "poscode",                     :precision => 5,  :scale => 0
    t.integer  "c",            :limit => 2
    t.decimal  "salary",                      :precision => 8,  :scale => 2
    t.decimal  "excode",                      :precision => 5,  :scale => 0
    t.integer  "jobcode",      :limit => 2
    t.integer  "seccode",      :limit => 2
    t.decimal  "sdcode",                      :precision => 5,  :scale => 0
    t.date     "effect_date"
    t.string   "flag_order",   :limit => 1
    t.text     "note1"
    t.string   "upduser",      :limit => 30
    t.datetime "upddate"
    t.decimal  "old_posid",                   :precision => 6,  :scale => 0
    t.decimal  "old_poscode",                 :precision => 5,  :scale => 0
    t.integer  "old_c",        :limit => 2
    t.decimal  "old_salary",                  :precision => 8,  :scale => 2
    t.decimal  "old_excode",                  :precision => 5,  :scale => 0
    t.integer  "old_job",      :limit => 2
    t.integer  "old_seccode",  :limit => 2
    t.decimal  "old_sdcode",                  :precision => 5,  :scale => 0
    t.decimal  "updcode",                     :precision => 4,  :scale => 0
    t.decimal  "epcode",                      :precision => 5,  :scale => 0
    t.decimal  "old_epcode",                  :precision => 5,  :scale => 0
    t.integer  "ptcode",       :limit => 2
    t.integer  "old_ptcode",   :limit => 2
    t.integer  "divcode",      :limit => 2
    t.integer  "old_divcode",  :limit => 2
    t.integer  "deptcode",     :limit => 2
    t.integer  "old_deptcode", :limit => 2
    t.string   "flag_date",    :limit => 1
    t.decimal  "posmny",                      :precision => 12, :scale => 2
    t.string   "posmny_date",  :limit => 100
    t.string   "flag_posmny",  :limit => 1
  end

  create_table "order_template", :id => false, :force => true do |t|
    t.integer "cmdcode", :null => false
    t.text    "doc"
    t.text    "note"
  end

  create_table "orderj18", :id => false, :force => true do |t|
    t.integer "sorder",  :limit => 2, :null => false
    t.integer "seccode", :limit => 2
    t.integer "jobcode", :limit => 2
  end

  create_table "orders", :id => false, :force => true do |t|
    t.decimal  "serial_no",                    :precision => 6, :scale => 0, :null => false
    t.string   "bud_year",       :limit => 4,                                :null => false
    t.integer  "order_type"
    t.date     "construct_date"
    t.string   "order_no"
    t.date     "order_date"
    t.string   "flag_upd",       :limit => 1
    t.string   "upduser",        :limit => 30
    t.datetime "upddate"
    t.text     "doc"
    t.text     "note"
  end

  create_table "pbcatcol", :id => false, :force => true do |t|
    t.string  "pbc_tnam", :limit => 129, :null => false
    t.integer "pbc_tid"
    t.string  "pbc_ownr", :limit => 129, :null => false
    t.string  "pbc_cnam", :limit => 129, :null => false
    t.integer "pbc_cid",  :limit => 2
    t.string  "pbc_labl", :limit => 254
    t.integer "pbc_lpos", :limit => 2
    t.string  "pbc_hdr",  :limit => 254
    t.integer "pbc_hpos", :limit => 2
    t.integer "pbc_jtfy", :limit => 2
    t.string  "pbc_mask", :limit => 31
    t.integer "pbc_case", :limit => 2
    t.integer "pbc_hght", :limit => 2
    t.integer "pbc_wdth", :limit => 2
    t.string  "pbc_ptrn", :limit => 31
    t.string  "pbc_bmap", :limit => 1
    t.string  "pbc_init", :limit => 254
    t.string  "pbc_cmnt", :limit => 254
    t.string  "pbc_edit", :limit => 31
    t.string  "pbc_tag",  :limit => 254
  end

  add_index "pbcatcol", ["pbc_tnam", "pbc_ownr", "pbc_cnam"], :name => "pbcatc_x", :unique => true

  create_table "pbcatedt", :id => false, :force => true do |t|
    t.string  "pbe_name", :limit => 30,  :null => false
    t.string  "pbe_edit", :limit => 254
    t.integer "pbe_type", :limit => 2
    t.integer "pbe_cntr"
    t.integer "pbe_seqn", :limit => 2,   :null => false
    t.integer "pbe_flag"
    t.string  "pbe_work", :limit => 32
  end

  add_index "pbcatedt", ["pbe_name", "pbe_seqn"], :name => "pbcate_x", :unique => true

  create_table "pbcatfmt", :id => false, :force => true do |t|
    t.string  "pbf_name", :limit => 30,  :null => false
    t.string  "pbf_frmt", :limit => 254
    t.integer "pbf_type", :limit => 2
    t.integer "pbf_cntr"
  end

  add_index "pbcatfmt", ["pbf_name"], :name => "pbcatf_x", :unique => true

  create_table "pbcattbl", :id => false, :force => true do |t|
    t.string  "pbt_tnam", :limit => 129, :null => false
    t.integer "pbt_tid"
    t.string  "pbt_ownr", :limit => 129, :null => false
    t.integer "pbd_fhgt", :limit => 2
    t.integer "pbd_fwgt", :limit => 2
    t.string  "pbd_fitl", :limit => 1
    t.string  "pbd_funl", :limit => 1
    t.integer "pbd_fchr", :limit => 2
    t.integer "pbd_fptc", :limit => 2
    t.string  "pbd_ffce", :limit => 18
    t.integer "pbh_fhgt", :limit => 2
    t.integer "pbh_fwgt", :limit => 2
    t.string  "pbh_fitl", :limit => 1
    t.string  "pbh_funl", :limit => 1
    t.integer "pbh_fchr", :limit => 2
    t.integer "pbh_fptc", :limit => 2
    t.string  "pbh_ffce", :limit => 18
    t.integer "pbl_fhgt", :limit => 2
    t.integer "pbl_fwgt", :limit => 2
    t.string  "pbl_fitl", :limit => 1
    t.string  "pbl_funl", :limit => 1
    t.integer "pbl_fchr", :limit => 2
    t.integer "pbl_fptc", :limit => 2
    t.string  "pbl_ffce", :limit => 18
    t.string  "pbt_cmnt", :limit => 254
  end

  add_index "pbcattbl", ["pbt_tnam", "pbt_ownr"], :name => "pbcatt_x", :unique => true

  create_table "pbcatvld", :id => false, :force => true do |t|
    t.string  "pbv_name", :limit => 30,  :null => false
    t.string  "pbv_vald", :limit => 254
    t.integer "pbv_type", :limit => 2
    t.integer "pbv_cntr"
    t.string  "pbv_msg",  :limit => 254
  end

  add_index "pbcatvld", ["pbv_name"], :name => "pbcatv_x", :unique => true

  create_table "pisabsent", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13,                               :null => false
    t.integer  "abcode",    :limit => 2,                                :null => false
    t.datetime "begindate",                                             :null => false
    t.datetime "enddate"
    t.decimal  "amount",                  :precision => 5, :scale => 1
    t.string   "flagcount", :limit => 1
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
  end

  create_table "pischgname", :id => false, :force => true do |t|
    t.string  "id",      :limit => 13, :null => false
    t.integer "chgno",                 :null => false
    t.date    "chgdate"
    t.integer "pcode",   :limit => 2
    t.string  "fname",   :limit => 45
    t.string  "lname",   :limit => 45
    t.string  "ref"
    t.integer "chgcode", :limit => 2
  end

  create_table "piseducation", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13,                  :null => false
    t.integer  "eorder",                                   :null => false
    t.integer  "macode",    :limit => 2
    t.integer  "qcode"
    t.integer  "ecode",     :limit => 2
    t.integer  "cocode",    :limit => 2
    t.string   "institute"
    t.date     "enddate"
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
    t.string   "flag",      :limit => 1
    t.string   "spcode",    :limit => 4
    t.string   "maxed",     :limit => 1
    t.string   "status",    :limit => 1,  :default => "1"
    t.string   "note"
    t.string   "regisno"
    t.date     "edstart"
    t.date     "edend"
    t.string   "refno"
  end

  create_table "pisfamily", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13, :null => false
    t.string   "cid",       :limit => 13, :null => false
    t.integer  "pcode",     :limit => 2
    t.string   "fname",     :limit => 50
    t.string   "lname",     :limit => 50
    t.string   "sex",       :limit => 1
    t.date     "birthdate"
    t.integer  "relcode",   :limit => 2
    t.string   "status",    :limit => 1
    t.string   "note"
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
  end

  create_table "pisinsig", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13,                                :null => false
    t.integer  "dccode",    :limit => 2,                                 :null => false
    t.integer  "dcyear",    :limit => 2,                                 :null => false
    t.integer  "book",      :limit => 2
    t.string   "section",   :limit => 10
    t.integer  "pageno"
    t.decimal  "seq",                     :precision => 10, :scale => 0
    t.datetime "recdate"
    t.datetime "kitjadate"
    t.datetime "retdate"
    t.string   "billno",    :limit => 5
    t.string   "bookno",    :limit => 5
    t.datetime "billdate"
    t.decimal  "money",                   :precision => 6,  :scale => 0
    t.decimal  "poscode",                 :precision => 5,  :scale => 0
    t.decimal  "excode",                  :precision => 5,  :scale => 0
    t.decimal  "epcode",                  :precision => 5,  :scale => 0
    t.integer  "c",         :limit => 2
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
    t.integer  "ptcode",    :limit => 2
    t.string   "note"
  end

  create_table "pisj18", :id => false, :force => true do |t|
    t.decimal  "posid",                     :precision => 6,  :scale => 0, :null => false
    t.string   "id",         :limit => 13
    t.integer  "dcode",      :limit => 2
    t.integer  "deptcode",   :limit => 2
    t.decimal  "sdcode",                    :precision => 5,  :scale => 0
    t.integer  "seccode",    :limit => 2
    t.integer  "jobcode",    :limit => 2
    t.decimal  "poscode",                   :precision => 5,  :scale => 0
    t.decimal  "excode",                    :precision => 5,  :scale => 0
    t.decimal  "epcode",                    :precision => 5,  :scale => 0
    t.integer  "lastc",      :limit => 2
    t.decimal  "lastsal",                   :precision => 5,  :scale => 0
    t.integer  "nowc",       :limit => 2
    t.decimal  "nowsal",                    :precision => 5,  :scale => 0
    t.integer  "lastcasb",   :limit => 2
    t.decimal  "lastsalasb",                :precision => 5,  :scale => 0
    t.integer  "nowcasb",    :limit => 2
    t.decimal  "nowsalasb",                 :precision => 5,  :scale => 0
    t.decimal  "decmny",                    :precision => 5,  :scale => 0
    t.decimal  "incmny",                    :precision => 5,  :scale => 0
    t.decimal  "qualmny",                   :precision => 5,  :scale => 0
    t.decimal  "posupmny",                  :precision => 5,  :scale => 0
    t.decimal  "addmny",                    :precision => 5,  :scale => 0
    t.string   "flagasb",    :limit => 1
    t.decimal  "posmny",                    :precision => 5,  :scale => 0
    t.decimal  "bkdmny",                    :precision => 5,  :scale => 0
    t.integer  "pcode",      :limit => 2
    t.integer  "incode",     :limit => 2
    t.integer  "pcdcode",    :limit => 2
    t.integer  "ptcode",     :limit => 2
    t.string   "rem",        :limit => 250
    t.datetime "upddate"
    t.string   "upduser",    :limit => 30
    t.date     "emptydate"
    t.date     "asbdate"
    t.string   "flagupdate", :limit => 1
    t.integer  "c",          :limit => 2
    t.integer  "addc",       :limit => 2
    t.decimal  "salary",                    :precision => 5,  :scale => 0
    t.integer  "rp_order"
    t.decimal  "posid2",                    :precision => 10, :scale => 0
    t.decimal  "dcode2",                    :precision => 4,  :scale => 0
    t.decimal  "sdcode2",                   :precision => 10, :scale => 0
    t.decimal  "seccode2",                  :precision => 4,  :scale => 0
    t.decimal  "jobcode2",                  :precision => 4,  :scale => 0
    t.decimal  "sortj182",                  :precision => 4,  :scale => 0
    t.decimal  "updapr",                    :precision => 5,  :scale => 0
    t.decimal  "updoct",                    :precision => 5,  :scale => 0
    t.integer  "mincode",    :limit => 2
    t.integer  "subdcode",   :limit => 2
    t.decimal  "octsalary",                 :precision => 5,  :scale => 0
    t.integer  "octc",       :limit => 2
    t.decimal  "aprsalary",                 :precision => 5,  :scale => 0
    t.integer  "aprc",       :limit => 2
    t.string   "rem2",       :limit => 250
  end

  create_table "pispersonel", :id => false, :force => true do |t|
    t.string   "id",          :limit => 13,                                :null => false
    t.integer  "pcode",       :limit => 2
    t.string   "fname",       :limit => 50
    t.string   "lname",       :limit => 50
    t.string   "sex",         :limit => 1
    t.string   "race",        :limit => 30
    t.string   "nationality", :limit => 30
    t.integer  "mrcode",      :limit => 2
    t.integer  "recode",      :limit => 2
    t.date     "birthdate"
    t.date     "appointdate"
    t.date     "deptdate"
    t.date     "cdate"
    t.date     "retiredate"
    t.integer  "dcode",       :limit => 2
    t.integer  "deptcode",    :limit => 2
    t.decimal  "sdcode",                     :precision => 5, :scale => 0
    t.integer  "seccode",     :limit => 2
    t.integer  "jobcode",     :limit => 2
    t.integer  "hmcode",      :limit => 2
    t.decimal  "poscode",                    :precision => 5, :scale => 0
    t.decimal  "excode",                     :precision => 5, :scale => 0
    t.decimal  "epcode",                     :precision => 5, :scale => 0
    t.integer  "provcode",    :limit => 2
    t.string   "address1",    :limit => 100
    t.string   "address2",    :limit => 100
    t.string   "tel",         :limit => 30
    t.decimal  "zip",                        :precision => 5, :scale => 0
    t.integer  "macode",      :limit => 2
    t.integer  "qcode",       :limit => 2
    t.integer  "ecode",       :limit => 2
    t.integer  "cocode",      :limit => 2
    t.decimal  "posid",                      :precision => 6, :scale => 0
    t.integer  "c",           :limit => 2
    t.decimal  "salary",                     :precision => 8, :scale => 2
    t.string   "oldfname",    :limit => 50
    t.string   "oldlname",    :limit => 50
    t.string   "father",      :limit => 50
    t.string   "mother",      :limit => 50
    t.string   "spouse",      :limit => 50
    t.integer  "childs",      :limit => 2
    t.decimal  "totalabsent",                :precision => 5, :scale => 1
    t.integer  "salcode",     :limit => 2
    t.integer  "j18code",     :limit => 2
    t.string   "picname",     :limit => 50
    t.string   "note"
    t.datetime "upddate"
    t.string   "upduser",     :limit => 30
    t.decimal  "oldid",                      :precision => 6, :scale => 0
    t.date     "exitdate"
    t.integer  "spcode",      :limit => 2
    t.decimal  "spmny",                      :precision => 8, :scale => 2
    t.integer  "spexpos"
    t.integer  "codetrade",   :limit => 2
    t.date     "renamedate"
    t.date     "getindate"
    t.string   "kbk",         :limit => 1
    t.string   "pstatus",     :limit => 1
    t.integer  "ptcode",      :limit => 2
    t.decimal  "vac1oct",                    :precision => 4, :scale => 1
    t.string   "pid",         :limit => 13
    t.integer  "mincode",     :limit => 2
    t.integer  "officecode",  :limit => 2
    t.date     "attenddate"
    t.date     "reentrydate"
    t.date     "quitdate"
    t.string   "note2"
    t.string   "specialty"
    t.integer  "subdcode",    :limit => 2
    t.string   "bloodgroup",  :limit => 2
    t.decimal  "spmny1",                     :precision => 8, :scale => 2
    t.decimal  "spmny2",                     :precision => 8, :scale => 2
    t.decimal  "spmny3",                     :precision => 8, :scale => 2
  end

  create_table "pispicturehis", :id => false, :force => true do |t|
    t.string "id",       :limit => 13, :null => false
    t.date   "picdate",                :null => false
    t.string "filename"
    t.string "note"
  end

  create_table "pisposhis", :id => false, :force => true do |t|
    t.string   "id",         :limit => 13,                                :null => false
    t.integer  "historder",  :limit => 2,                                 :null => false
    t.date     "forcedate",                                               :null => false
    t.decimal  "poscode",                   :precision => 5, :scale => 0
    t.decimal  "excode",                    :precision => 5, :scale => 0
    t.decimal  "epcode",                    :precision => 5, :scale => 0
    t.integer  "mcode",      :limit => 2
    t.integer  "dcode",      :limit => 2
    t.integer  "deptcode",   :limit => 2
    t.decimal  "sdcode",                    :precision => 5, :scale => 0
    t.integer  "seccode",    :limit => 2
    t.integer  "jobcode",    :limit => 2
    t.integer  "hmcode",     :limit => 2
    t.decimal  "updcode",                   :precision => 4, :scale => 0
    t.decimal  "posid",                     :precision => 6, :scale => 0
    t.integer  "c",          :limit => 2
    t.decimal  "salary",                    :precision => 5, :scale => 0
    t.string   "refcmnd",    :limit => nil
    t.datetime "upddate"
    t.string   "upduser",    :limit => 30
    t.text     "note"
    t.decimal  "ptcode",                    :precision => 5, :scale => 0
    t.string   "persontype", :limit => 1
    t.integer  "subdcode",   :limit => 2
    t.integer  "officecode", :limit => 2
    t.integer  "histno",     :limit => 2
    t.decimal  "posmny",                    :precision => 7, :scale => 2
    t.decimal  "spmny",                     :precision => 7, :scale => 2
    t.decimal  "uppercent",                 :precision => 7, :scale => 5
    t.decimal  "upsalary",                  :precision => 7, :scale => 2
    t.string   "score"
  end

  add_index "pisposhis", ["forcedate"], :name => "idx_pisposhis3"
  add_index "pisposhis", ["historder"], :name => "idx_pisposhis2"
  add_index "pisposhis", ["id"], :name => "idx_pisposhis1"

  create_table "pispts", :id => false, :force => true do |t|
    t.string   "id",          :limit => 13,                               :null => false
    t.string   "spcode",      :limit => 4
    t.integer  "qcode"
    t.string   "gcode",       :limit => 4
    t.decimal  "ptsmny",                    :precision => 8, :scale => 2
    t.decimal  "areamny",                   :precision => 8, :scale => 2
    t.decimal  "hospmny",                   :precision => 8, :scale => 2
    t.decimal  "appointcode",               :precision => 8, :scale => 0
    t.date     "appointdate"
    t.datetime "upddate"
    t.string   "upduser",     :limit => 30
    t.string   "spno",        :limit => 10
  end

  create_table "pispunish", :id => false, :force => true do |t|
    t.string   "id",          :limit => 13, :null => false
    t.date     "forcedate",                 :null => false
    t.integer  "pncode",      :limit => 2
    t.string   "description", :limit => 60
    t.string   "cmdno",       :limit => 60
    t.datetime "upddate"
    t.string   "upduser",     :limit => 30
  end

  create_table "pistrainning", :id => false, :force => true do |t|
    t.integer  "tno",                     :null => false
    t.date     "begindate"
    t.string   "id",        :limit => 13, :null => false
    t.integer  "cocode",    :limit => 2
    t.date     "enddate"
    t.string   "cource"
    t.string   "institute"
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
  end

  create_table "t1", :force => true do |t|
    t.string "a", :limit => 1
    t.string "b", :limit => 1
  end

  create_table "t2", :force => true do |t|
    t.string "a", :limit => 1
    t.string "c", :limit => 1
  end

  create_table "t_dgdcdcr", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13,                                :null => false
    t.integer  "dccode",    :limit => 2,                                 :null => false
    t.integer  "dcyear",    :limit => 2,                                 :null => false
    t.integer  "book",      :limit => 2
    t.string   "section",   :limit => 10
    t.integer  "pageno",    :limit => 2
    t.integer  "seq",       :limit => 2
    t.date     "recdate"
    t.date     "kitjadate"
    t.date     "retdate"
    t.string   "billno",    :limit => 5
    t.string   "bookno",    :limit => 5
    t.date     "billdate"
    t.decimal  "money",                   :precision => 6,  :scale => 0
    t.decimal  "poscode",                 :precision => 5,  :scale => 0
    t.decimal  "excode",                  :precision => 5,  :scale => 0
    t.decimal  "epcode",                  :precision => 5,  :scale => 0
    t.integer  "c",         :limit => 2
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
    t.date     "entrydate"
    t.date     "leveldate"
    t.string   "note1",     :limit => 50
    t.string   "note2",     :limit => 50
    t.decimal  "salary",                  :precision => 12, :scale => 2
    t.integer  "ptcode",    :limit => 2
  end

  add_index "t_dgdcdcr", ["dccode", "id", "dcyear"], :name => "xpkt_dgdcdcr", :unique => true

  create_table "t_epnincsalary", :id => false, :force => true do |t|
    t.integer "year",      :limit => 2,                                 :null => false
    t.string  "id",        :limit => 13,                                :null => false
    t.decimal "posid",                    :precision => 6, :scale => 0
    t.decimal "poscode",                  :precision => 5, :scale => 0
    t.integer "level",     :limit => 2
    t.decimal "salary",                   :precision => 8, :scale => 2
    t.decimal "updcode",                  :precision => 4, :scale => 0
    t.string  "note1",     :limit => 200
    t.decimal "newsalary",                :precision => 8, :scale => 2
    t.decimal "sdcode",                   :precision => 5, :scale => 0
    t.integer "seccode",   :limit => 2
    t.integer "jobcode",   :limit => 2
    t.decimal "excode",                   :precision => 5, :scale => 0
    t.string  "fname",     :limit => 50
    t.string  "lname",     :limit => 50
    t.integer "pcode",     :limit => 2
    t.integer "rp_order",  :limit => 2
    t.decimal "epcode",                   :precision => 5, :scale => 0
    t.integer "ptcode",    :limit => 2
    t.string  "flag_inc",  :limit => 1
    t.decimal "upsalary",                 :precision => 8, :scale => 2
    t.string  "cmdno",     :limit => 30
    t.date    "cmddate"
  end

  create_table "t_epnincsalary2", :id => false, :force => true do |t|
    t.integer "year",      :limit => 2,                                 :null => false
    t.string  "id",        :limit => 13,                                :null => false
    t.decimal "posid",                    :precision => 6, :scale => 0
    t.decimal "poscode",                  :precision => 5, :scale => 0
    t.integer "level",     :limit => 2
    t.decimal "salary",                   :precision => 8, :scale => 2
    t.decimal "updcode",                  :precision => 4, :scale => 0
    t.string  "note1",     :limit => 200
    t.decimal "newsalary",                :precision => 8, :scale => 2
    t.decimal "sdcode",                   :precision => 5, :scale => 0
    t.integer "seccode",   :limit => 2
    t.integer "jobcode",   :limit => 2
    t.decimal "excode",                   :precision => 5, :scale => 0
    t.string  "fname",     :limit => 50
    t.string  "lname",     :limit => 50
    t.integer "pcode",     :limit => 2
    t.integer "rp_order",  :limit => 2
    t.decimal "epcode",                   :precision => 5, :scale => 0
    t.integer "ptcode",    :limit => 2
    t.string  "flag_inc",  :limit => 1
  end

  create_table "t_epninsig", :id => false, :force => true do |t|
    t.string   "id",        :limit => 13,                                :null => false
    t.integer  "dccode",    :limit => 2,                                 :null => false
    t.integer  "dcyear",    :limit => 2,                                 :null => false
    t.integer  "book",      :limit => 2
    t.string   "section",   :limit => 10
    t.integer  "pageno",    :limit => 2
    t.integer  "seq",       :limit => 2
    t.datetime "recdate"
    t.datetime "kitjadate"
    t.datetime "retdate"
    t.string   "billno",    :limit => 5
    t.string   "bookno",    :limit => 5
    t.datetime "billdate"
    t.decimal  "money",                   :precision => 6,  :scale => 0
    t.decimal  "poscode",                 :precision => 5,  :scale => 0
    t.decimal  "excode",                  :precision => 5,  :scale => 0
    t.decimal  "epcode",                  :precision => 5,  :scale => 0
    t.integer  "c",         :limit => 2
    t.datetime "upddate"
    t.string   "upduser",   :limit => 30
    t.date     "entrydate"
    t.date     "leveldate"
    t.string   "note1",     :limit => 50
    t.string   "note2",     :limit => 50
    t.decimal  "salary",                  :precision => 12, :scale => 2
    t.integer  "ptcode",    :limit => 2
  end

  add_index "t_epninsig", ["dccode", "id", "dcyear"], :name => "xpkt_epndgdcdcr", :unique => true
  add_index "t_epninsig", ["dccode", "id", "dcyear"], :name => "xpkt_epninsig", :unique => true

  create_table "t_epnmovein", :id => false, :force => true do |t|
    t.integer  "tno",                                                      :null => false
    t.string   "cmdno",       :limit => 80,                                :null => false
    t.decimal  "oldposid",                   :precision => 6, :scale => 0
    t.string   "id",          :limit => 13,                                :null => false
    t.integer  "pcode",       :limit => 2
    t.string   "fname",       :limit => 50
    t.string   "lname",       :limit => 50
    t.integer  "oldjobcode",  :limit => 2
    t.integer  "oldseccode",  :limit => 2
    t.decimal  "oldposcode",                 :precision => 5, :scale => 0
    t.decimal  "oldsdcode",                  :precision => 5, :scale => 0
    t.decimal  "oldepcode",                  :precision => 5, :scale => 0
    t.decimal  "oldexcode",                  :precision => 5, :scale => 0
    t.integer  "olddcode",    :limit => 2
    t.integer  "olddeptcode", :limit => 2
    t.integer  "oldc",        :limit => 2
    t.decimal  "oldsalary",                  :precision => 8, :scale => 2
    t.decimal  "poscode",                    :precision => 5, :scale => 0
    t.decimal  "excode",                     :precision => 5, :scale => 0
    t.integer  "jobcode",     :limit => 2
    t.integer  "c",           :limit => 2
    t.integer  "ptcode",      :limit => 2
    t.integer  "glevel",      :limit => 2
    t.integer  "seccode",     :limit => 2
    t.decimal  "sdcode",                     :precision => 5, :scale => 0
    t.decimal  "epcode",                     :precision => 5, :scale => 0
    t.integer  "deptcode",    :limit => 2
    t.integer  "dcode",       :limit => 2
    t.decimal  "posid",                      :precision => 6, :scale => 0
    t.decimal  "salary",                     :precision => 8, :scale => 2
    t.datetime "startdate"
    t.string   "note",        :limit => 100
    t.integer  "codecase",    :limit => 2
    t.decimal  "casesalary",                 :precision => 8, :scale => 2
    t.integer  "j18code",     :limit => 2
    t.integer  "casec",       :limit => 2
    t.string   "cspeed",      :limit => 1
    t.string   "posname",     :limit => 70
    t.integer  "updcode",     :limit => 2
    t.string   "flag_update", :limit => 1
    t.string   "posid_oldid", :limit => 13
    t.integer  "oldptcode",   :limit => 2
    t.integer  "nowc",        :limit => 2
    t.decimal  "nowsal",                     :precision => 8, :scale => 2
    t.integer  "lastc",       :limit => 2
    t.decimal  "lastsal",                    :precision => 8, :scale => 2
    t.integer  "nowcasb",     :limit => 2
    t.decimal  "nowsalasb",                  :precision => 8, :scale => 2
    t.integer  "lastcasb",    :limit => 2
    t.decimal  "lastsalasb",                 :precision => 8, :scale => 2
    t.integer  "nowc2",       :limit => 2
    t.decimal  "nowsal2",                    :precision => 8, :scale => 2
    t.integer  "lastc2",      :limit => 2
    t.decimal  "lastsal2",                   :precision => 8, :scale => 2
    t.integer  "nowcasb2",    :limit => 2
    t.decimal  "nowsalasb2",                 :precision => 8, :scale => 2
    t.integer  "lastcasb2",   :limit => 2
    t.decimal  "lastsalasb2",                :precision => 8, :scale => 2
  end

  create_table "t_incsalary", :id => false, :force => true do |t|
    t.integer "year",       :limit => 2,                                 :null => false
    t.string  "id",         :limit => 13,                                :null => false
    t.decimal "posid",                     :precision => 6, :scale => 0
    t.decimal "poscode",                   :precision => 5, :scale => 0
    t.integer "level",      :limit => 2
    t.decimal "salary",                    :precision => 8, :scale => 2
    t.decimal "updcode",                   :precision => 4, :scale => 0
    t.string  "note1",      :limit => 200
    t.decimal "newsalary",                 :precision => 8, :scale => 2
    t.decimal "sdcode",                    :precision => 5, :scale => 0
    t.integer "seccode",    :limit => 2
    t.integer "jobcode",    :limit => 2
    t.decimal "excode",                    :precision => 5, :scale => 0
    t.string  "fname",      :limit => 50
    t.string  "lname",      :limit => 50
    t.integer "pcode",      :limit => 2
    t.integer "rp_order",   :limit => 2
    t.decimal "epcode",                    :precision => 5, :scale => 0
    t.integer "ptcode",     :limit => 2
    t.string  "flag_inc",   :limit => 1
    t.string  "cmdno",      :limit => 30
    t.date    "cmddate"
    t.integer "subdcode",   :limit => 2
    t.decimal "dcode",                     :precision => 5, :scale => 0
    t.decimal "subddcode",                 :precision => 5, :scale => 0
    t.decimal "wdcode",                    :precision => 5, :scale => 0
    t.decimal "wsdcode",                   :precision => 5, :scale => 0
    t.decimal "wseccode",                  :precision => 5, :scale => 0
    t.decimal "wjobcode",                  :precision => 5, :scale => 0
    t.integer "wsubdcode",  :limit => 2
    t.integer "j18code",    :limit => 2
    t.string  "flagcal",    :limit => 1
    t.decimal "calpercent",                :precision => 6, :scale => 4
    t.decimal "score",                     :precision => 7, :scale => 4
    t.decimal "addmoney",                  :precision => 8, :scale => 2
    t.decimal "evalno",                    :precision => 4, :scale => 0
    t.decimal "midpoint",                  :precision => 8, :scale => 2
    t.integer "evalid1"
    t.string  "flageval1",  :limit => 1
    t.decimal "maxsalary",                 :precision => 8, :scale => 2
    t.date    "cmddate2"
    t.string  "cmdno2",     :limit => 30
    t.integer "rp_orderw",  :limit => 2
  end

  add_index "t_incsalary", ["id"], :name => "idx_incsalary1"
  add_index "t_incsalary", ["posid"], :name => "idx_incsalary2"
  add_index "t_incsalary", ["year"], :name => "idx_incsalary3"

  create_table "t_incsalary2", :id => false, :force => true do |t|
    t.integer "year",      :limit => 2,                                 :null => false
    t.string  "id",        :limit => 13,                                :null => false
    t.decimal "posid",                    :precision => 6, :scale => 0
    t.decimal "poscode",                  :precision => 5, :scale => 0
    t.integer "level",     :limit => 2
    t.decimal "salary",                   :precision => 8, :scale => 2
    t.decimal "updcode",                  :precision => 4, :scale => 0
    t.string  "note1",     :limit => 200
    t.decimal "newsalary",                :precision => 8, :scale => 2
    t.decimal "sdcode",                   :precision => 5, :scale => 0
    t.integer "seccode",   :limit => 2
    t.integer "jobcode",   :limit => 2
    t.decimal "excode",                   :precision => 5, :scale => 0
    t.string  "fname",     :limit => 50
    t.string  "lname",     :limit => 50
    t.integer "pcode",     :limit => 2
    t.integer "rp_order",  :limit => 2
    t.decimal "epcode",                   :precision => 5, :scale => 0
    t.integer "ptcode",    :limit => 2
    t.string  "flag_inc",  :limit => 1
    t.string  "cmdno",     :limit => 30
    t.date    "cmddate"
  end

  create_table "t_ks24usemain", :id => false, :force => true do |t|
    t.integer  "year",       :limit => 2,                                  :null => false
    t.decimal  "sdcode",                    :precision => 5,  :scale => 0, :null => false
    t.decimal  "calpercent",                :precision => 6,  :scale => 4
    t.decimal  "salary",                    :precision => 16, :scale => 2
    t.decimal  "ks24",                      :precision => 16, :scale => 2
    t.decimal  "pay",                       :precision => 16, :scale => 2
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
    t.string   "e1_name",    :limit => 180
    t.decimal  "e1_begin",                  :precision => 6,  :scale => 4
    t.decimal  "e1_end",                    :precision => 6,  :scale => 4
    t.string   "e2_name",    :limit => 180
    t.decimal  "e2_begin",                  :precision => 6,  :scale => 4
    t.decimal  "e2_end",                    :precision => 6,  :scale => 4
    t.string   "e3_name",    :limit => 180
    t.decimal  "e3_begin",                  :precision => 6,  :scale => 4
    t.decimal  "e3_end",                    :precision => 6,  :scale => 4
    t.string   "e4_name",    :limit => 180
    t.decimal  "e4_begin",                  :precision => 6,  :scale => 4
    t.decimal  "e4_end",                    :precision => 6,  :scale => 4
    t.string   "e5_name",    :limit => 180
    t.decimal  "e5_begin",                  :precision => 6,  :scale => 4
    t.decimal  "e5_end",                    :precision => 6,  :scale => 4
    t.string   "u1_name",    :limit => 180
    t.decimal  "u1_begin",                  :precision => 6,  :scale => 4
    t.decimal  "u1_end",                    :precision => 6,  :scale => 4
    t.string   "u2_name",    :limit => 180
    t.decimal  "u2_begin",                  :precision => 6,  :scale => 4
    t.decimal  "u2_end",                    :precision => 6,  :scale => 4
    t.string   "u3_name",    :limit => 180
    t.decimal  "u3_begin",                  :precision => 6,  :scale => 4
    t.decimal  "u3_end",                    :precision => 6,  :scale => 4
    t.string   "u4_name",    :limit => 180
    t.decimal  "u4_begin",                  :precision => 6,  :scale => 4
    t.decimal  "u4_end",                    :precision => 6,  :scale => 4
    t.string   "u5_name",    :limit => 180
    t.decimal  "u5_begin",                  :precision => 6,  :scale => 4
    t.decimal  "u5_end",                    :precision => 6,  :scale => 4
  end

  create_table "t_ks24usesub", :id => false, :force => true do |t|
    t.integer  "year",       :limit => 2,                                  :null => false
    t.integer  "id",                                                       :null => false
    t.string   "usename",    :limit => 200
    t.decimal  "officecode",                :precision => 5,  :scale => 0
    t.decimal  "sdcode",                    :precision => 5,  :scale => 0
    t.decimal  "subdcode",                  :precision => 5,  :scale => 0
    t.integer  "seccode",    :limit => 2
    t.integer  "jobcode",    :limit => 2
    t.decimal  "calpercent",                :precision => 6,  :scale => 4
    t.decimal  "salary",                    :precision => 16, :scale => 2
    t.decimal  "ks24",                      :precision => 16, :scale => 2
    t.decimal  "pay",                       :precision => 16, :scale => 2
    t.string   "admin_id",   :limit => 13
    t.string   "upd_user",   :limit => 20
    t.datetime "upd_date"
    t.integer  "etype",      :limit => 2
    t.string   "eval_id",    :limit => 13
  end

  create_table "t_ks24usesubdetail", :id => false, :force => true do |t|
    t.integer  "year",     :limit => 2,                                 :null => false
    t.integer  "id",                                                    :null => false
    t.integer  "dno",                                                   :null => false
    t.string   "upd_user", :limit => 20
    t.datetime "upd_date"
    t.string   "e_name",   :limit => 180
    t.decimal  "e_begin",                 :precision => 7, :scale => 4
    t.decimal  "e_end",                   :precision => 7, :scale => 4
    t.decimal  "up",                      :precision => 6, :scale => 4
  end

  create_table "t_movein", :primary_key => "tno", :force => true do |t|
    t.string  "cmdno",       :limit => 80,                                :null => false
    t.decimal "oldposid",                   :precision => 6, :scale => 0
    t.string  "id",          :limit => 13,                                :null => false
    t.integer "pcode",       :limit => 2
    t.string  "fname",       :limit => 50
    t.string  "lname",       :limit => 50
    t.integer "oldjobcode",  :limit => 2
    t.integer "oldseccode",  :limit => 2
    t.decimal "oldposcode",                 :precision => 5, :scale => 0
    t.decimal "oldsdcode",                  :precision => 5, :scale => 0
    t.decimal "oldepcode",                  :precision => 5, :scale => 0
    t.decimal "oldexcode",                  :precision => 5, :scale => 0
    t.integer "olddcode",    :limit => 2
    t.integer "olddeptcode", :limit => 2
    t.integer "oldc",        :limit => 2
    t.decimal "oldsalary",                  :precision => 8, :scale => 2
    t.decimal "poscode",                    :precision => 5, :scale => 0
    t.decimal "excode",                     :precision => 5, :scale => 0
    t.integer "jobcode",     :limit => 2
    t.integer "c",           :limit => 2
    t.integer "ptcode",      :limit => 2
    t.integer "glevel",      :limit => 2
    t.integer "seccode",     :limit => 2
    t.decimal "sdcode",                     :precision => 5, :scale => 0
    t.decimal "epcode",                     :precision => 5, :scale => 0
    t.integer "deptcode",    :limit => 2
    t.integer "dcode",       :limit => 2
    t.decimal "posid",                      :precision => 6, :scale => 0
    t.decimal "salary",                     :precision => 8, :scale => 2
    t.date    "startdate"
    t.string  "note",        :limit => 100
    t.integer "codecase",    :limit => 2
    t.decimal "casesalary",                 :precision => 8, :scale => 2
    t.integer "j18code",     :limit => 2
    t.integer "casec",       :limit => 2
    t.string  "cspeed",      :limit => 1
    t.string  "posname",     :limit => 70
    t.integer "updcode",     :limit => 2
    t.string  "flag_update", :limit => 1
    t.string  "posid_oldid", :limit => 13
    t.integer "oldptcode",   :limit => 2
    t.integer "nowc",        :limit => 2
    t.decimal "nowsal",                     :precision => 8, :scale => 2
    t.integer "lastc",       :limit => 2
    t.decimal "lastsal",                    :precision => 8, :scale => 2
    t.integer "nowcasb",     :limit => 2
    t.decimal "nowsalasb",                  :precision => 8, :scale => 2
    t.integer "lastcasb",    :limit => 2
    t.decimal "lastsalasb",                 :precision => 8, :scale => 2
    t.integer "nowc2",       :limit => 2
    t.decimal "nowsal2",                    :precision => 8, :scale => 2
    t.integer "lastc2",      :limit => 2
    t.decimal "lastsal2",                   :precision => 8, :scale => 2
    t.integer "nowcasb2",    :limit => 2
    t.decimal "nowsalasb2",                 :precision => 8, :scale => 2
    t.integer "lastcasb2",   :limit => 2
    t.decimal "lastsalasb2",                :precision => 8, :scale => 2
    t.decimal "wdeptcode",                  :precision => 5, :scale => 0
    t.decimal "wdcode",                     :precision => 5, :scale => 0
    t.decimal "wsdcode",                    :precision => 5, :scale => 0
    t.decimal "wseccode",                   :precision => 5, :scale => 0
    t.decimal "wjobcode",                   :precision => 5, :scale => 0
    t.decimal "wofficecode",                :precision => 5, :scale => 0
    t.decimal "wsubdcode",                  :precision => 5, :scale => 0
    t.decimal "oldsubdcode",                :precision => 5, :scale => 0
    t.decimal "subdcode",                   :precision => 5, :scale => 0
    t.decimal "upsalary",                   :precision => 8, :scale => 2
    t.decimal "uppercent",                  :precision => 8, :scale => 5
    t.decimal "spmny",                      :precision => 8, :scale => 2
  end

  create_table "t_pispts", :id => false, :force => true do |t|
    t.string   "dyear",       :limit => 6,                                :null => false
    t.string   "id",          :limit => 13,                               :null => false
    t.string   "cid",         :limit => 13
    t.integer  "pcode"
    t.string   "fname",       :limit => 50
    t.string   "lname",       :limit => 50
    t.decimal  "poscode",                   :precision => 5, :scale => 0
    t.string   "qcode",       :limit => 4
    t.decimal  "sdcode",                    :precision => 5, :scale => 0
    t.date     "officedate"
    t.string   "spcode",      :limit => 4
    t.integer  "ptsqcode"
    t.string   "gcode",       :limit => 4
    t.decimal  "ptsmny",                    :precision => 8, :scale => 2
    t.decimal  "areamny",                   :precision => 8, :scale => 2
    t.decimal  "hospmny",                   :precision => 8, :scale => 2
    t.decimal  "appointcode",               :precision => 8, :scale => 0
    t.date     "appointdate"
    t.datetime "upddate"
    t.string   "upduser",     :limit => 30
    t.string   "spno",        :limit => 10
  end

  create_table "t_setnewpos", :id => false, :force => true do |t|
    t.decimal "posid",                         :precision => 6, :scale => 0, :null => false
    t.string  "id",             :limit => 13
    t.integer "pcode",          :limit => 2
    t.string  "fname",          :limit => 50
    t.string  "lname",          :limit => 50
    t.string  "cid",            :limit => 13
    t.integer "deptcode",       :limit => 2
    t.integer "dcode",          :limit => 2
    t.decimal "sdcode",                        :precision => 5, :scale => 0
    t.integer "subdcode",       :limit => 2
    t.integer "seccode",        :limit => 2
    t.integer "jobcode",        :limit => 2
    t.decimal "posidnew",                      :precision => 6, :scale => 0
    t.decimal "salary",                        :precision => 8, :scale => 2
    t.decimal "posold_poscode",                :precision => 5, :scale => 0
    t.decimal "posold_excode",                 :precision => 5, :scale => 0
    t.decimal "posold_epcode",                 :precision => 5, :scale => 0
    t.decimal "posold_ptcode",                 :precision => 5, :scale => 0
    t.integer "posold_c",       :limit => 2
    t.decimal "posnew_poscode",                :precision => 5, :scale => 0
    t.decimal "posnew_excode",                 :precision => 5, :scale => 0
    t.decimal "posnew_epcode",                 :precision => 5, :scale => 0
    t.decimal "posnew_ptcode",                 :precision => 5, :scale => 0
    t.integer "posnew_c",       :limit => 2
    t.decimal "perold_poscode",                :precision => 5, :scale => 0
    t.decimal "perold_excode",                 :precision => 5, :scale => 0
    t.decimal "perold_epcode",                 :precision => 5, :scale => 0
    t.decimal "perold_ptcode",                 :precision => 5, :scale => 0
    t.integer "perold_c",       :limit => 2
    t.decimal "pernew_poscode",                :precision => 5, :scale => 0
    t.decimal "pernew_excode",                 :precision => 5, :scale => 0
    t.decimal "pernew_epcode",                 :precision => 5, :scale => 0
    t.decimal "pernew_ptcode",                 :precision => 5, :scale => 0
    t.integer "pernew_c",       :limit => 2
    t.decimal "updcode",                       :precision => 4, :scale => 0
    t.string  "cmdno",          :limit => 30
    t.date    "cmddate"
    t.string  "note1",          :limit => 200
    t.string  "flag",           :limit => 1
    t.integer "perold_incode",  :limit => 2
    t.integer "pernew_incode",  :limit => 2
    t.integer "posold_incode",  :limit => 2
    t.integer "posnew_incode",  :limit => 2
    t.string  "note2",          :limit => 200
    t.string  "note3",          :limit => 200
    t.integer "rporder",        :limit => 2
    t.string  "kp",             :limit => 1
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.string   "fname"
    t.string   "lname"
    t.string   "group_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vacation", :id => false, :force => true do |t|
    t.string   "id",         :limit => 13,                               :null => false
    t.string   "year",       :limit => 2,                                :null => false
    t.decimal  "old_vac",                  :precision => 5, :scale => 1
    t.string   "audit_user", :limit => 35
    t.datetime "audit_date"
    t.decimal  "new_vac",                  :precision => 5, :scale => 1
  end

end
