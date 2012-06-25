tmp_config_blank = "<table style='font:12px tahoma,arial,helvetica,sans-serif;width:300px;'>" +
    "<caption><center><b>วงเงินที่ใช้เลื่อนเงินเดือนของทั้งหน่วยงาน</b></center></caption>"+                                          
    "<tr ><td style='padding-bottom:4px' align='right' height='24px;' width='150px'>เงินเดือน:</td><td align='right'><b>N/A</b></td></tr>" +
    "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>ร้อยละ:</td><td align='right'><b>N/A</b></td></tr>" +
    "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>จำนวนเงินที่ใช้เลื่อนทั้งหมด:</td><td align='right'><b>N/A</b></td></tr>" +
"</table>";
ks24_page = 0;
//-------------------------------------
// Panel North
//-------------------------------------
var northConfigGroupSalary = new Ext.Panel({
    region: "north"
    ,height: 200
    ,border: false
    ,autoScroll: true
    ,frame: true
    ,items: [
        {
            layout: "hbox"
            ,border: false
            ,layoutConfig: {
              pack: "center"
              ,align: "middle"
              ,padding: 5
            }
            ,items: [
                {
                    layout: "form"
                    ,items: [
                        {
                            xtype: "fieldset"
                            ,width: 300
                            ,layout: "form"
                            ,labelWidth: 50
                            ,labelAlign: "right"
                            ,items: [
                                {
                                    xtype: "compositefield"
                                    ,fieldLabel: "ปี พ.ศ"
                                    ,items: [
                                        {
                                            xtype: "numberfield"
                                            ,id: "round_fiscalyear"
                                            ,width: 80
                                            ,enableKeyEvents: true
                                            ,listeners: {
                                                keyup: function(el, e ){
                                                    resetConfigGroup();
                                                }
                                            }
                                        }
                                        ,{
                                            xtype: "displayfield"
                                            ,style: "padding: 4px"
                                            ,value: "รอบ:"
                                        }
                                        ,new Ext.form.ComboBox({
                                            editable: false
                                            ,id:"round"
                                            ,width: 80
                                            ,store: new Ext.data.SimpleStore({
                                                fields: ["id", "type"]
                                                ,data: [["1","1 เมษายน"],["2","1 ตุลาคม"]]
                                            })
                                            ,valueField:"id"
                                            ,displayField:"type"
                                            ,typeAhead: true
                                            ,mode: "local"
                                            ,triggerAction: "all"
                                            ,emptyText:""
                                            ,selectOnFocus:true
                                            ,listeners: {
                                                select: function(){
                                                    if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                                        return false;
                                                    }
                                                    loadMask.show();
                                                    GridStore.removeAll();
                                                    var tpl = new Ext.Template(tmp_config_blank);
                                                    tpl.overwrite(Ext.get("temp_detail"), "");
                                                    Ext.Ajax.request({
                                                        url: pre_url + "/config_group_sal/get_config"
                                                        ,params: {
                                                            fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                                            ,round: Ext.getCmp("round").getValue()
                                                        }
                                                        ,success: function(response,opts){
                                                            obj = Ext.util.JSON.decode(response.responseText);
                                                            loadMask.hide();
                                                            if (obj.success){
                                                                tpl = new Ext.Template(
                                                                    "<table style='font:12px tahoma,arial,helvetica,sans-serif;width:300px;'>" +
                                                                        "<caption><center><b>วงเงินที่ใช้เลื่อนเงินเดือนของทั้งหน่วยงาน</b></center></caption>"+                                          
                                                                        "<tr ><td style='padding-bottom:4px' align='right' height='24px;' width='150px'>เงินเดือน:</td><td align='right'><b>{salary}</b></td></tr>" +
                                                                        "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>ร้อยละ:</td><td align='right'><b>{calpercent}</b></td></tr>" +
                                                                        "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>จำนวนเงินที่ใช้เลื่อนทั้งหมด:</td><td align='right'><b>{ks24}</b></td></tr>" +
                                                                    "</table>"
                                                                );
                                                                tpl.overwrite(Ext.get("temp_detail"), obj.data);
                                                                ks24_page = Number(obj.data.ks24);
                                                            }
                                                            else{
                                                               ks24_page = 0;
                                                            }
                                                            GridStore.load({
                                                                params: {
                                                                    fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                                                    ,round: Ext.getCmp("round").getValue()
                                                                    }    
                                                            });                                                            
                                                        }
                                                        ,failure: function(response,opts){
                                                            Ext.Msg.alert("สถานะ",response.statusText);
                                                            loadMask.hide();
                                                        }
                                                    }); 
                                                }
                                            }
                                        })
                                    ]
                                }
                            ]
                        }
                        ,new Ext.BoxComponent({
                            autoEl: {
                                tag: "div"
                                ,id: "temp_detail"
                                ,html: tmp_config_blank
                            }
                        })
                    ]
                }
            ]
        }
    ]
    ,listeners: {
        afterrender: function(el){
            Ext.getCmp("round_fiscalyear").setValue(fiscalYear(new Date()) + 543 );
        }
    }
});

//-------------------------------------
// Panel Center
//-------------------------------------
function nameSum(v, params, data) {
    return "รวมทั้งหมด<br />เทียบกับวงเงินทั้งหน่วยงาน";
}

function SubdeptDiff(v, params, data) {
    return (v)+"<br />"+(ks24_page - v);
}
var summary = new Ext.ux.grid.GridSummary();
var Fields = [
    {name: "usename", type: "string"}
    ,{name: "sdcode", type: "string"}
    ,{name: "etype", type: "string"}
    ,{name: "salary", type: "string"}
    ,{name: "calpercent", type: "string"}
    ,{name: "ks24", type: "string"}
    ,{name: "pay", type: "string"}
    ,{name: "diff", type: "string"}
    ,{name: "admin_id",type: "string"}
    ,{name: "eval_id",type: "string"}
    ,{name: "year",type: "string"}
    ,{name: "id",type: "string"}
];

var Cols = [
    {
        header: "#"
        ,width: 70
        ,renderer: rowNumberer.createDelegate(this)
        ,sortable: false
    }
    ,{header: "ชื่อกลุ่ม",width: 100, sortable: false, dataIndex: 'usename'}
    ,{header: "หน่วยงาน",width: 320, sortable: false, dataIndex: 'sdcode'}
    ,{header: "กลุ่มการประเมิน",width: 150, sortable: false, dataIndex: 'etype', summaryType: 'sum', summaryRenderer: nameSum}
    ,{header: "เงินเดือน",width: 100, sortable: false, dataIndex: 'salary', summaryType: 'sum'}
    ,{header: "ร้อยละ",width: 100, sortable: false, dataIndex: 'calpercent'}
    ,{header: "วงเงินที่ใช้ได้",width: 100, sortable: false, dataIndex: 'ks24', summaryType: 'sum', summaryRenderer: SubdeptDiff}
    ,{header: "เงินที่ใช้เลื่อน",width: 100, sortable: false, dataIndex: 'pay', summaryType: 'sum', summaryRenderer: SubdeptDiff}
    ,{header: "เหลือเกิน",width: 100, sortable: false, dataIndex: 'diff', summaryType: 'sum'}
    ,{header: "ผู้บริหารวงเงิน",width: 150, sortable: false, dataIndex: 'admin_id'}
    ,{header: "ผู้ประเมิน",width: 150, sortable: false, dataIndex: 'eval_id'}
];
var GridStore = new Ext.data.JsonStore({
    url: pre_url + "/config_group_sal/read"
    ,root: "records"
    ,autoLoad: false
    ,fields: Fields
    ,idProperty: 'id'
});

var Grid = new Ext.grid.GridPanel({
    region: 'center'
    ,clicksToEdit: 1
    ,split: true
    ,store: GridStore
    ,columns: Cols
    ,stripeRows: true
    ,loadMask: {msg:'Loading...'}
    ,trackMouseOver: false
    ,sm: new Ext.grid.RowSelectionModel()
    ,plugins: [summary]
    ,listeners: {
        afterrender: function(el){
                 el.doLayout();
        }
    }
    ,tbar: [
        {
            text: "เพิ่ม"
            ,iconCls: "table-add"
            ,handler: function(){
                if(!form){
                    if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                        Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                        return false;
                    }
                    var form = new Ext.FormPanel({ 
                        labelWidth: 100
                        ,autoScroll: true
                        ,url: pre_url + "/config_group_sal/create"
                        ,frame: true
                        ,monitorValid: true
                        ,items: [
                            {
                                xtype: "textfield"
                                ,fieldLabel: "ชื่อกลุ่มประเมิน"
                                ,id: "field[usename]"
                                ,anchor: "95%"
                            }
                            ,{
                                xtype: "numericfield"
                                ,fieldLabel: "เงินเดือน"
                                ,id: "field[salary]"
                                ,enableKeyEvents: true
                                ,listeners: {
                                    keyup: function(el, e ){
                                        salary = Number(Ext.getCmp("field[salary]").getValue());
                                        calpercent = Number(Ext.getCmp("field[calpercent]").getValue());
                                        ks24 = (salary / 100) * calpercent
                                        Ext.getCmp("field[ks24]").setValue(ks24);
                                    }
                                }
                            }
                            ,{
                                xtype: "numberfield"
                                ,fieldLabel: "ร้อยละ"
                                ,id: "field[calpercent]"
                                ,enableKeyEvents: true
                                ,decimalPrecision: 4
                                ,maxValue: 99.9999
                                ,listeners: {
                                    keyup: function(el, e ){
                                        salary = Number(Ext.getCmp("field[salary]").getValue());
                                        calpercent = Number(Ext.getCmp("field[calpercent]").getValue());
                                        ks24 = (salary / 100) * calpercent
                                        Ext.getCmp("field[ks24]").setValue(ks24);
                                    }
                                }
                            }
                            ,{
                                xtype: "numericfield"
                                ,fieldLabel: "จำนวนเงินที่ใช้ได้"
                                ,id: "field[ks24]"
                                //,readOnly: true
                                ,enableKeyEvents: true
                                ,listeners: {
                                    keyup: function(el, e ){
                                        ks24 = Number(Ext.getCmp("field[ks24]").getValue())
                                        calpercent = Number(Ext.getCmp("field[calpercent]").getValue());
                                        salary = (ks24*100)/calpercent
                                        Ext.getCmp("field[salary]").setValue(salary);
                                    }
                                }
                            }
                            ,{
                                     xtype: "compositefield"
                                     ,fieldLabel: "หน่วยงาน"
                                     ,anchor: "100%"
                                     ,items: [
                                              {
                                                       xtype: "numberfield"
                                                       ,id: "field[sdcode]"
                                                       ,width: 50
                                                       ,enableKeyEvents: true
                                                       ,listeners: {
                                                                specialkey : function( el,e ){
                                                                         Ext.getCmp("subdept_show").setValue("");
                                                                         if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
                                                                                  loadMask.show();
                                                                                  Ext.Ajax.request({
                                                                                     url: pre_url + '/code/csubdept_search'
                                                                                     ,params: {
                                                                                        sdcode: el.getValue()
                                                                                     }
                                                                                     ,success: function(response,opts){
                                                                                        obj = Ext.util.JSON.decode(response.responseText);
                                                                                        if (obj.totalcount == 0){
                                                                                           Ext.Msg.alert("สถานะ", "ไม่พบข้อมูล");
                                                                                           Ext.getCmp("field[sdcode]").setValue("");
                                                                                           Ext.getCmp("subdept_show").setValue("");
                                                                                        }
                                                                                        else{
                                                                                           Ext.getCmp("field[sdcode]").setValue(obj.records[0].sdcode);
                                                                                           Ext.getCmp("subdept_show").setValue(obj.records[0].subdeptname);
                                                                                        }
                                                                                        
                                                                                        loadMask.hide();
                                                                                     }
                                                                                     ,failure: function(response,opts){
                                                                                        Ext.Msg.alert("สถานะ",response.statusText);
                                                                                        loadMask.hide();
                                                                                     }
                                                                                  });                                                                                           
                                                                         }        
                                                                }
                                                                ,blur: function(el){
                                                                         if (Ext.getCmp("subdept_show").getValue() == ""){
                                                                                  Ext.getCmp("field[sdcode]").setValue("");
                                                                                  Ext.getCmp("subdept_show").setValue("");    
                                                                         }
                                                                }
                                                                
                                                       }
                                              }
                                              ,{
                                                       xtype: "textfield"
                                                       ,id: "subdept_show"
                                                       ,readOnly: true
                                                       ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:75%;"
                                              }
                                              ,{
                                                       xtype: "button"
                                                       ,id: "sdcode_button"
                                                       ,text: "..."
                                                       ,handler: function(){
                                                                searchSubdept(Ext.getCmp("field[sdcode]"),Ext.getCmp("subdept_show"));
                                                       }
                                              }
                                     ]
                            }
                            ,new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
                                fieldLabel: "ฝ่าย/กลุ่มงาน"
                                ,hiddenName: 'field[seccode]'
                                ,id: 'field[seccode]'
                                ,valueField: 'seccode'
                                ,displayField: 'secname'
                                ,urlStore: pre_url + '/code/csection'
                                ,fieldStore: ['seccode', 'secname']
                                ,anchor: "95%"
                                   
                            })
                            ,new Ext.ux.form.PisComboBox({//งาน
                                fieldLabel: "งาน"
                                ,hiddenName: 'field[jobcode]'
                                ,id: 'field[jobcode]'
                                ,valueField: 'jobcode'
                                ,displayField: 'jobname'
                                ,urlStore: pre_url + '/code/cjob'
                                ,fieldStore: ['jobcode', 'jobname']
                               ,anchor: "95%"
                            })
                            
                            
                            ,{
                                     xtype: "compositefield"
                                     ,fieldLabel: "ผู้บริหารวงเงิน"
                                     ,anchor: "100%"
                                     ,items: [
                                              {
                                                       xtype: "numberfield"
                                                       ,id: "admin_posid"
                                                       ,width: 50
                                                       ,enableKeyEvents: true
                                                       ,listeners: {
                                                                specialkey : function( el,e ){
                                                                         Ext.getCmp("admin_show").setValue("");
                                                                         if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
                                                                            loadMask.show();
                                                                            Ext.Ajax.request({
                                                                               url: pre_url + '/info_personal/search_posid'
                                                                               ,params: {
                                                                                  posid: el.getValue()
                                                                               }
                                                                               ,success: function(response,opts){
                                                                                  obj = Ext.util.JSON.decode(response.responseText);
                                                                                  if (obj.success){
                                                                                      Ext.getCmp("field[admin_id]").setValue(obj.data[0].id);
                                                                                      Ext.getCmp("admin_show").setValue(obj.data[0].name);
                                                                                      Ext.getCmp("admin_posid").setValue(obj.data[0].posid);
                                                                                  }
                                                                                  else{
                                                                                      Ext.getCmp("field[admin_id]").setValue("");
                                                                                      Ext.getCmp("admin_show").setValue("");
                                                                                      Ext.getCmp("admin_posid").setValue("");
                                                                                      Ext.Msg.alert("สถานะ", "ไม่พบข้อมูล");
                                                                                  }
                                                                                  loadMask.hide();
                                                                               }
                                                                               ,failure: function(response,opts){
                                                                                  Ext.Msg.alert("สถานะ",response.statusText);
                                                                                  loadMask.hide();
                                                                               }
                                                                            });                                                                                           
                                                                         }        
                                                                }
                                                                ,blur: function(el){
                                                                    if (Ext.getCmp("admin_show").getValue() == ""){
                                                                       Ext.getCmp("field[admin_id]").setValue("");
                                                                       Ext.getCmp("admin_show").setValue("");
                                                                       Ext.getCmp("admin_posid").setValue("");
                                                                    }
                                                                }
                                                                
                                                       }
                                              }
                                              ,{
                                                       xtype: "textfield"
                                                       ,id: "admin_show"
                                                       ,readOnly: true
                                                       ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:40%;"
                                              }
                                              ,{
                                                       xtype: "button"
                                                       ,id: "admin_button"
                                                       ,text: "..."
                                                       ,handler: function(){
                                                                personelNow(Ext.getCmp("admin_posid")
                                                                            ,Ext.getCmp("admin_show")
                                                                            ,Ext.getCmp("field[admin_id]"));
                                                       }
                                              },{
                                                xtype: "hidden"
                                                ,id:  "field[admin_id]"
                                              }
                                     ]
                            }
                            ,{
                                     xtype: "compositefield"
                                     ,fieldLabel: "ผู้ประเมิน"
                                     ,anchor: "100%"
                                     ,items: [
                                              {
                                                       xtype: "numberfield"
                                                       ,id: "eval_posid"
                                                       ,width: 50
                                                       ,enableKeyEvents: true
                                                       ,listeners: {
                                                                specialkey : function( el,e ){
                                                                         Ext.getCmp("eval_show").setValue("");
                                                                         if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
                                                                            loadMask.show();
                                                                            Ext.Ajax.request({
                                                                               url: pre_url + '/info_personal/search_posid'
                                                                               ,params: {
                                                                                  posid: el.getValue()
                                                                               }
                                                                               ,success: function(response,opts){
                                                                                  obj = Ext.util.JSON.decode(response.responseText);
                                                                                  if (obj.success){
                                                                                      Ext.getCmp("field[eval_id]").setValue(obj.data[0].id);
                                                                                      Ext.getCmp("eval_show").setValue(obj.data[0].name);
                                                                                      Ext.getCmp("eval_posid").setValue(obj.data[0].posid);
                                                                                  }
                                                                                  else{
                                                                                      Ext.getCmp("field[eval_id]").setValue("");
                                                                                      Ext.getCmp("eval_show").setValue("");
                                                                                      Ext.getCmp("eval_posid").setValue("");
                                                                                      Ext.Msg.alert("สถานะ", "ไม่พบข้อมูล");
                                                                                  }
                                                                                  loadMask.hide();
                                                                               }
                                                                               ,failure: function(response,opts){
                                                                                  Ext.Msg.alert("สถานะ",response.statusText);
                                                                                  loadMask.hide();
                                                                               }
                                                                            });                                                                                           
                                                                         }        
                                                                }
                                                                ,blur: function(el){
                                                                    if (Ext.getCmp("eval_show").getValue() == ""){
                                                                       Ext.getCmp("field[eval_id]").setValue("");
                                                                       Ext.getCmp("eval_show").setValue("");
                                                                       Ext.getCmp("eval_posid").setValue("");
                                                                    }
                                                                }
                                                                
                                                       }
                                              }
                                              ,{
                                                       xtype: "textfield"
                                                       ,id: "eval_show"
                                                       ,readOnly: true
                                                       ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:40%;"
                                              }
                                              ,{
                                                       xtype: "button"
                                                       ,id: "eval_button"
                                                       ,text: "..."
                                                       ,handler: function(){
                                                                personelNow(Ext.getCmp("eval_posid")
                                                                            ,Ext.getCmp("eval_show")
                                                                            ,Ext.getCmp("field[eval_id]"));
                                                       }
                                              },{
                                                xtype: "hidden"
                                                ,id:  "field[eval_id]"
                                              }
                                     ]
                            }
                            ,new Ext.form.ComboBox({//กลุ่มการประเมิน
                                    fieldLabel: "กลุ่มการประเมิน"
                                    ,editable: true
                                    ,id: "field[etype]"										
                                    ,hiddenName: 'field[etype]'
                                    ,width: 200
                                    ,store: new Ext.data.SimpleStore({
                                                 fields: ['id', 'type']
                                                 ,data: [
                                                         ["1", "ผู้ปฏิบัติงาน"]
                                                         ,["2", "หัวหน้างาน"]
                                                         ,["3", "หัวหน้าฝ่าย กลุ่ม กลุ่มงาน"]
                                                         ,["4", "หัวหน้าหน่วยงาน"]
                                                 ] 
                                    })
                                    ,valueField	:'id'
                                    ,displayField:'type'
                                    ,typeAhead	: true
                                    ,mode: 'local'
                                    ,triggerAction: 'all'
                                    ,emptyText	:'Select ...'
                            })
                        ]
                        ,buttons:[
                            { 
                                text:'บันทึก'
                                ,formBind: true 
                                ,handler:function(){ 					
                                    form.getForm().submit(
                                    { 
                                        method:'POST'
                                        ,waitTitle:'Saving Data'
                                        ,waitMsg:'Sending data...'
                                        ,params: {
                                            fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                            ,round: Ext.getCmp("round").getValue()
                                        }
                                        ,success:function(){		
                                              Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                      if (btn == 'ok'){
                                                              win.close();
                                                      }	
                                              });
                                                GridStore.load({
                                                    params: {
                                                        fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                                        ,round: Ext.getCmp("round").getValue()
                                                        }    
                                                });
                                        }
                                        ,failure:function(form, action){ 
                                                if(action.failureType == 'server'){ 
                                                        obj = Ext.util.JSON.decode(action.response.responseText); 
                                                        Ext.Msg.alert('สถานะ', obj.msg); 
                                                }
                                                else{	 
                                                        Ext.Msg.alert('สถานะ', 'Authentication server is unreachable : ' + action.response.responseText); 
                                                } 
                                        } 
                                    }); 
                                } 
                            },{
                                    text: "ยกเลิก"
                                    ,handler: function(){
                                            win.close();
                                    }
                            }
                        ] 
                    });
                }//end if form
                if(!win){
                   var win = new Ext.Window({
                           title: 'กำหนดกลุ่มบริหารวงเงินให้หน่วยงาน'
                           ,width: 500
                           ,height: 370
                           ,closable: true
                           ,resizable: false
                           ,plain	: true
                           ,border: false
                           ,draggable: true 
                           ,modal: true
                           ,layout: "fit"
                           ,items: [form]
                   });
                }
                win.show();
                win.center();                                
            }
        }
    ]
});

Grid.on('rowdblclick', function(grid, rowIndex, e ) {
    data_select = grid.getSelectionModel().getSelected().data;
    loadMask.show();
    Ext.Ajax.request({
        url: pre_url + "/config_group_sal/search_edit"
        ,params: {
            id: data_select.id
            ,year: data_select.year
        }
        ,success: function(response,opts){
            obj = Ext.util.JSON.decode(response.responseText);
            if (obj.success){
                if(!form){
                    var form = new Ext.FormPanel({ 
                        labelWidth: 100
                        ,autoScroll: true
                        ,url: pre_url + "/config_group_sal/update"
                        ,frame: true
                        ,monitorValid: true
                        ,items: [
                            {xtype: "hidden",id:"year",value: data_select.year}
                            ,{xtype: "hidden",id:"id",value: data_select.id}
                            ,{
                                xtype: "textfield"
                                ,fieldLabel: "ชื่อกลุ่มประเมิน"
                                ,id: "field[usename]"
                                ,anchor: "95%"
                                ,value: obj.data.usename
                            }
                            ,{
                                xtype: "numericfield"
                                ,fieldLabel: "เงินเดือน"
                                ,id: "field[salary]"
                                ,enableKeyEvents: true
                                ,listeners: {
                                    keyup: function(el, e ){
                                        salary = Number(Ext.getCmp("field[salary]").getValue());
                                        calpercent = Number(Ext.getCmp("field[calpercent]").getValue());
                                        ks24 = (salary / 100) * calpercent
                                        Ext.getCmp("field[ks24]").setValue(ks24);
                                    }
                                }
                                ,value: obj.data.salary
                            }
                            ,{
                                xtype: "numberfield"
                                ,fieldLabel: "ร้อยละ"
                                ,id: "field[calpercent]"
                                ,enableKeyEvents: true
                                ,decimalPrecision: 4
                                ,maxValue: 99.9999
                                ,listeners: {
                                    keyup: function(el, e ){
                                        salary = Number(Ext.getCmp("field[salary]").getValue());
                                        calpercent = Number(Ext.getCmp("field[calpercent]").getValue());
                                        ks24 = (salary / 100) * calpercent
                                        Ext.getCmp("field[ks24]").setValue(ks24);
                                    }
                                }
                                ,value: obj.data.calpercent
                            }
                            ,{
                                xtype: "numericfield"
                                ,fieldLabel: "จำนวนเงินที่ใช้ได้"
                                ,id: "field[ks24]"
                                //,readOnly: true
                                ,value: obj.data.ks24
                                ,enableKeyEvents: true
                                ,listeners: {
                                    keyup: function(el, e ){
                                        ks24 = Number(Ext.getCmp("field[ks24]").getValue())
                                        calpercent = Number(Ext.getCmp("field[calpercent]").getValue());
                                        salary = (ks24*100)/calpercent
                                        Ext.getCmp("field[salary]").setValue(salary);
                                    }
                                }
                            }
                            ,{
                                     xtype: "compositefield"
                                     ,fieldLabel: "หน่วยงาน"
                                     ,anchor: "100%"
                                     ,items: [
                                              {
                                                       xtype: "numberfield"
                                                       ,id: "field[sdcode]"
                                                       ,width: 50
                                                       ,enableKeyEvents: true
                                                       ,listeners: {
                                                                specialkey : function( el,e ){
                                                                         Ext.getCmp("subdept_show").setValue("");
                                                                         if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
                                                                                  loadMask.show();
                                                                                  Ext.Ajax.request({
                                                                                     url: pre_url + '/code/csubdept_search'
                                                                                     ,params: {
                                                                                        sdcode: el.getValue()
                                                                                     }
                                                                                     ,success: function(response,opts){
                                                                                        obj = Ext.util.JSON.decode(response.responseText);
                                                                                        if (obj.totalcount == 0){
                                                                                           Ext.Msg.alert("สถานะ", "ไม่พบข้อมูล");
                                                                                           Ext.getCmp("field[sdcode]").setValue("");
                                                                                           Ext.getCmp("subdept_show").setValue("");
                                                                                        }
                                                                                        else{
                                                                                           Ext.getCmp("field[sdcode]").setValue(obj.records[0].sdcode);
                                                                                           Ext.getCmp("subdept_show").setValue(obj.records[0].subdeptname);
                                                                                        }
                                                                                        
                                                                                        loadMask.hide();
                                                                                     }
                                                                                     ,failure: function(response,opts){
                                                                                        Ext.Msg.alert("สถานะ",response.statusText);
                                                                                        loadMask.hide();
                                                                                     }
                                                                                  });                                                                                           
                                                                         }        
                                                                }
                                                                ,blur: function(el){
                                                                         if (Ext.getCmp("subdept_show").getValue() == ""){
                                                                                  Ext.getCmp("field[sdcode]").setValue("");
                                                                                  Ext.getCmp("subdept_show").setValue("");    
                                                                         }
                                                                }
                                                                
                                                       }
                                                       ,value: obj.data.sdcode
                                              }
                                              ,{
                                                       xtype: "textfield"
                                                       ,id: "subdept_show"
                                                       ,readOnly: true
                                                       ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:75%;"
                                                       ,value: obj.data.sdcode_show
                                              }
                                              ,{
                                                       xtype: "button"
                                                       ,id: "sdcode_button"
                                                       ,text: "..."
                                                       ,handler: function(){
                                                                searchSubdept(Ext.getCmp("field[sdcode]"),Ext.getCmp("subdept_show"));
                                                       }
                                              }
                                     ]
                            }
                            ,new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
                                fieldLabel: "ฝ่าย/กลุ่มงาน"
                                ,hiddenName: 'field[seccode]'
                                ,id: 'field[seccode]'
                                ,valueField: 'seccode'
                                ,displayField: 'secname'
                                ,urlStore: pre_url + '/code/csection'
                                ,fieldStore: ['seccode', 'secname']
                                ,anchor: "95%"
                                   
                            })
                            ,new Ext.ux.form.PisComboBox({//งาน
                                fieldLabel: "งาน"
                                ,hiddenName: 'field[jobcode]'
                                ,id: 'field[jobcode]'
                                ,valueField: 'jobcode'
                                ,displayField: 'jobname'
                                ,urlStore: pre_url + '/code/cjob'
                                ,fieldStore: ['jobcode', 'jobname']
                                ,anchor: "95%"
                            })
                            
                            
                            ,{
                                     xtype: "compositefield"
                                     ,fieldLabel: "ผู้บริหารวงเงิน"
                                     ,anchor: "100%"
                                     ,items: [
                                              {
                                                       xtype: "numberfield"
                                                       ,id: "admin_posid"
                                                       ,width: 50
                                                       ,enableKeyEvents: true
                                                       ,listeners: {
                                                                specialkey : function( el,e ){
                                                                         Ext.getCmp("admin_show").setValue("");
                                                                         if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
                                                                            loadMask.show();
                                                                            Ext.Ajax.request({
                                                                               url: pre_url + '/info_personal/search_posid'
                                                                               ,params: {
                                                                                  posid: el.getValue()
                                                                               }
                                                                               ,success: function(response,opts){
                                                                                  obj = Ext.util.JSON.decode(response.responseText);
                                                                                  if (obj.success){
                                                                                      Ext.getCmp("field[admin_id]").setValue(obj.data[0].id);
                                                                                      Ext.getCmp("admin_show").setValue(obj.data[0].name);
                                                                                      Ext.getCmp("admin_posid").setValue(obj.data[0].posid);
                                                                                  }
                                                                                  else{
                                                                                      Ext.getCmp("field[admin_id]").setValue("");
                                                                                      Ext.getCmp("admin_show").setValue("");
                                                                                      Ext.getCmp("admin_posid").setValue("");
                                                                                      Ext.Msg.alert("สถานะ", "ไม่พบข้อมูล");
                                                                                  }
                                                                                  loadMask.hide();
                                                                               }
                                                                               ,failure: function(response,opts){
                                                                                  Ext.Msg.alert("สถานะ",response.statusText);
                                                                                  loadMask.hide();
                                                                               }
                                                                            });                                                                                           
                                                                         }        
                                                                }
                                                                ,blur: function(el){
                                                                    if (Ext.getCmp("admin_show").getValue() == ""){
                                                                       Ext.getCmp("field[admin_id]").setValue("");
                                                                       Ext.getCmp("admin_show").setValue("");
                                                                       Ext.getCmp("admin_posid").setValue("");
                                                                    }
                                                                }
                                                                
                                                       }
                                                       ,value: obj.data.admin_posid
                                              }
                                              ,{
                                                       xtype: "textfield"
                                                       ,id: "admin_show"
                                                       ,readOnly: true
                                                       ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:40%;"
                                                       ,value: obj.data.admin_show
                                              }
                                              ,{
                                                       xtype: "button"
                                                       ,id: "admin_button"
                                                       ,text: "..."
                                                       ,handler: function(){
                                                                personelNow(Ext.getCmp("admin_posid")
                                                                            ,Ext.getCmp("admin_show")
                                                                            ,Ext.getCmp("field[admin_id]"));
                                                       }
                                              },{
                                                xtype: "hidden"
                                                ,id:  "field[admin_id]"
                                                ,value: obj.data.admin_id
                                              }
                                     ]
                            }
                            ,{
                                     xtype: "compositefield"
                                     ,fieldLabel: "ผู้ประเมิน"
                                     ,anchor: "100%"
                                     ,items: [
                                              {
                                                       xtype: "numberfield"
                                                       ,id: "eval_posid"
                                                       ,width: 50
                                                       ,enableKeyEvents: true
                                                       ,listeners: {
                                                                specialkey : function( el,e ){
                                                                         Ext.getCmp("eval_show").setValue("");
                                                                         if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
                                                                            loadMask.show();
                                                                            Ext.Ajax.request({
                                                                               url: pre_url + '/info_personal/search_posid'
                                                                               ,params: {
                                                                                  posid: el.getValue()
                                                                               }
                                                                               ,success: function(response,opts){
                                                                                  obj = Ext.util.JSON.decode(response.responseText);
                                                                                  if (obj.success){
                                                                                      Ext.getCmp("field[eval_id]").setValue(obj.data[0].id);
                                                                                      Ext.getCmp("eval_show").setValue(obj.data[0].name);
                                                                                      Ext.getCmp("eval_posid").setValue(obj.data[0].posid);
                                                                                  }
                                                                                  else{
                                                                                      Ext.getCmp("field[eval_id]").setValue("");
                                                                                      Ext.getCmp("eval_show").setValue("");
                                                                                      Ext.getCmp("eval_posid").setValue("");
                                                                                      Ext.Msg.alert("สถานะ", "ไม่พบข้อมูล");
                                                                                  }
                                                                                  loadMask.hide();
                                                                               }
                                                                               ,failure: function(response,opts){
                                                                                  Ext.Msg.alert("สถานะ",response.statusText);
                                                                                  loadMask.hide();
                                                                               }
                                                                            });                                                                                           
                                                                         }        
                                                                }
                                                                ,blur: function(el){
                                                                    if (Ext.getCmp("eval_show").getValue() == ""){
                                                                       Ext.getCmp("field[eval_id]").setValue("");
                                                                       Ext.getCmp("eval_show").setValue("");
                                                                       Ext.getCmp("eval_posid").setValue("");
                                                                    }
                                                                }
                                                                
                                                       }
                                                       ,value: obj.data.eval_posid
                                              }
                                              ,{
                                                       xtype: "textfield"
                                                       ,id: "eval_show"
                                                       ,readOnly: true
                                                       ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:40%;"
                                                       ,value: obj.data.eval_show
                                              }
                                              ,{
                                                       xtype: "button"
                                                       ,id: "eval_button"
                                                       ,text: "..."
                                                       ,handler: function(){
                                                                personelNow(Ext.getCmp("eval_posid")
                                                                            ,Ext.getCmp("eval_show")
                                                                            ,Ext.getCmp("field[eval_id]"));
                                                       }
                                              },{
                                                xtype: "hidden"
                                                ,id:  "field[eval_id]"
                                                ,value: obj.data.eval_id
                                              }
                                     ]
                            }
                            ,new Ext.form.ComboBox({//กลุ่มการประเมิน
                                    fieldLabel: "กลุ่มการประเมิน"
                                    ,editable: true
                                    ,id: "field[etype]"										
                                    ,hiddenName: 'field[etype]'
                                    ,width: 200
                                    ,store: new Ext.data.SimpleStore({
                                                 fields: ['id', 'type']
                                                 ,data: [
                                                         ["1", "ผู้ปฏิบัติงาน"]
                                                         ,["2", "หัวหน้างาน"]
                                                         ,["3", "หัวหน้าฝ่าย กลุ่ม กลุ่มงาน"]
                                                         ,["4", "หัวหน้าหน่วยงาน"]
                                                 ] 
                                    })
                                    ,valueField	:'id'
                                    ,displayField:'type'
                                    ,typeAhead	: true
                                    ,mode: 'local'
                                    ,triggerAction: 'all'
                                    ,emptyText	:'Select ...'
                                    ,value: obj.data.etype
                            })
                        ]
                        ,buttons:[
                            { 
                                text:'บันทึก'
                                ,formBind: true 
                                ,handler:function(){
                                    //debugger;
                                    form.getForm().submit(
                                    { 
                                        method:'POST'
                                        ,waitTitle:'Saving Data'
                                        ,waitMsg:'Sending data...'
                                        ,success:function(){		
                                              Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                      if (btn == 'ok'){
                                                              win.close();
                                                      }	
                                              });
                                                GridStore.load({
                                                    params: {
                                                        fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                                        ,round: Ext.getCmp("round").getValue()
                                                        }    
                                                });
                                        }
                                        ,failure:function(form, action){ 
                                                if(action.failureType == 'server'){ 
                                                        obj = Ext.util.JSON.decode(action.response.responseText); 
                                                        Ext.Msg.alert('สถานะ', obj.msg); 
                                                }
                                                else{	 
                                                        Ext.Msg.alert('สถานะ', 'Authentication server is unreachable : ' + action.response.responseText); 
                                                } 
                                        } 
                                    }); 
                                } 
                            },{
                                    text: "ยกเลิก"
                                    ,handler: function(){
                                            win.close();
                                    }
                            }
                        ] 
                    });
                }//end if form
                if(!win){
                   var win = new Ext.Window({
                           title: 'กำหนดกลุ่มบริหารวงเงินให้หน่วยงาน'
                           ,width: 500
                           ,height: 370
                           ,closable: true
                           ,resizable: false
                           ,plain	: true
                           ,border: false
                           ,draggable: true 
                           ,modal: true
                           ,layout: "fit"
                           ,items: [form]
                   });
                }
                Ext.getCmp("field[seccode]").getStore().load({
                        params: {
                                seccode: obj.data.seccode
                                ,start: 0
                                ,limit: 10
                        }
                        ,callback :function(){
                                Ext.getCmp("field[seccode]").setValue(obj.data.seccode);
                        }
                });
                Ext.getCmp("field[jobcode]").getStore().load({
                        params: {
                                jobcode: obj.data.jobcode
                                ,start: 0
                                ,limit: 10
                        }
                        ,callback :function(){
                                Ext.getCmp("field[jobcode]").setValue(obj.data.jobcode);
                                win.show();
                                win.center();
                                loadMask.hide();
                        }
                });
            }
            else{
                Ext.Msg.alert("คำเตือน","เกิดความผิดพลาดกรุณาลองใหม่อีกครั้ง"); 
                loadMask.hide();
            }
        }
        ,failure: function(response,opts){
            Ext.Msg.alert("สถานะ",response.statusText);
            loadMask.hide();
        }
    }); 
});


//-------------------------------------
// Panel Main
//-------------------------------------
var panelConfigGroupSalary = new Ext.Panel({
    title: "กำหนดกลุ่มบริหารวงเงินให้หน่วยงาน"
    ,layout: "border"
    ,items: [
        northConfigGroupSalary
        ,Grid     
    ]
    ,listeners: {
        afterrender: function(el){
            el.doLayout();
        }
    }
});

function resetConfigGroup(){
    tpl = new Ext.Template(tmp_config_blank);
    tpl.overwrite(Ext.get("temp_detail"), "");
    GridStore.removeAll();
}