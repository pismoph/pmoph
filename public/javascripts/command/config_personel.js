tmp_config_blank = "<table style='font:12px tahoma,arial,helvetica,sans-serif;width:325px;'>" +                                         
    "<tr ><td style='padding-bottom:4px' align='right' height='24px;' width='110px'>หมายเลขกลุ่มประเมิน:</td><td align='right'><b>N/A</b></td></tr>" +
    "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>เงินเดือน:</td><td align='right'><b>N/A</b></td></tr>" +
    "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>ร้อยละ:</td><td align='right'><b>N/A</b></td></tr>" +
    "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>เงินที่ใช้เลื่อน:</td><td align='right'><b>N/A</b></td></tr>" +
    "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>ผู้บริหารวงเงิน:</td><td align='right'><b>N/A</b></td></tr>" +
    "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>ผู้ประเมิน:</td><td align='right'><b>N/A</b></td></tr>" +
    "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>กลุ่มการประเมิน:</td><td align='right'><b>N/A</b></td></tr>" +
    "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>หน่วยงาน:</td><td align='right'><b>N/A</b></td></tr>" +
"</table>";
//-------------------------------------
// Panel west
//-------------------------------------
var westConfigPersonel = new Ext.Panel({
    region: "west"
    ,width: 380
    ,border: false
    ,autoScroll: true
    ,frame: true
    ,buttonAlign: "center"
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
                            ,width: 330
                            ,layout: "form"
                            ,labelWidth: 70
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
                                                    clearConfigPersonel();
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
                                                    clearConfigPersonel();
                                                }
                                            }
                                        })
                                    ]
                                }
                                ,{
                                    xtype: "displayfield"
                                    ,value: "<span style='margin-left:-75px;'>หน่วยงานที่ปฏิบัติ:</span>"
                                }
                                ,{
                                    xtype: "checkbox"
                                    ,boxLabel: "ทั้งหมดงาน"
                                    ,id: "all_subdept"
                                }
                                ,{
                                         xtype: "compositefield"
                                         ,fieldLabel: "หน่วยงาน"
                                         ,anchor: "100%"
                                         ,items: [
                                                  {
                                                           xtype: "numberfield"
                                                           ,id: "sdcode"
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
                                                                                               Ext.getCmp("sdcode").setValue("");
                                                                                               Ext.getCmp("subdept_show").setValue("");
                                                                                            }
                                                                                            else{
                                                                                               Ext.getCmp("sdcode").setValue(obj.records[0].sdcode);
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
                                                                                      Ext.getCmp("sdcode").setValue("");
                                                                                      Ext.getCmp("subdept_show").setValue("");    
                                                                             }
                                                                    }
                                                                    
                                                           }
                                                  }
                                                  ,{
                                                           xtype: "textarea"
                                                           ,id: "subdept_show"
                                                           ,readOnly: true
                                                           ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
							   ,height: 50
							   ,width: 155
                                                  }
                                                  ,{
                                                           xtype: "button"
                                                           ,id: "sdcode_button"
                                                           ,text: "..."
                                                           ,handler: function(){
                                                                    searchSubdept(Ext.getCmp("sdcode"),Ext.getCmp("subdept_show"));
                                                           }
                                                  }
                                         ]
                                }
                                ,new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
                                    fieldLabel: "ฝ่าย/กลุ่มงาน"
                                    ,hiddenName: 'seccode'
                                    ,id: 'seccode'
                                    ,valueField: 'seccode'
                                    ,displayField: 'secname'
                                    ,urlStore: pre_url + '/code/csection'
                                    ,fieldStore: ['seccode', 'secname']
                                    ,anchor: "95%"
                                })
                                ,new Ext.ux.form.PisComboBox({//งาน
                                    fieldLabel: "งาน"
                                    ,hiddenName: 'jobcode'
                                    ,id: 'jobcode'
                                    ,valueField: 'jobcode'
                                    ,displayField: 'jobname'
                                    ,urlStore: pre_url + '/code/cjob'
                                    ,fieldStore: ['jobcode', 'jobname']
                                   ,anchor: "95%"
                                })                                
                                ,{
                                    xtype: "displayfield"
                                    ,value: "<span style='margin-left:-75px;'>หมายเลขกลุ่มประเมิน:</span>"
                                }
                                ,new Ext.ux.form.PisComboBox({//หมายเลขกลุ่มประเมิน
                                    hiddenName: 'id_config'
                                    ,id: 'id_config'
                                    ,valueField: 'id'
                                    ,displayField: 'usename'
                                    ,urlStore: pre_url + '/code/t_ks24usesub'
                                    ,fieldStore: ['id', 'usename','year']
                                    ,anchor: "95%"
                                    ,listeners: {
                                        select: function( combo, record, index ){
                                            loadMask.show();
                                            Ext.Ajax.request({
                                                url: pre_url + "/config_personel/get_config"
                                                ,params: {
                                                    id: record.data.id
                                                    ,year: record.data.year
                                                }
                                                ,success: function(response,opts){
                                                    obj = Ext.util.JSON.decode(response.responseText);
                                                    loadMask.hide();
                                                    if(obj.success){
                                                        tpl = new Ext.Template(
                                                            "<table style='font:12px tahoma,arial,helvetica,sans-serif;width:325px;'>" +                                         
                                                                "<tr ><td style='padding-bottom:4px' align='right' height='24px;' width='110px'>หมายเลขกลุ่มประเมิน:</td><td align='right'><b>{usename}</b></td></tr>" +
                                                                "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>เงินเดือน:</td><td align='right'><b>{salary}</b></td></tr>" +
                                                                "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>ร้อยละ:</td><td align='right'><b>{calpercent}</b></td></tr>" +
                                                                "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>เงินที่ใช้เลื่อน:</td><td align='right'><b>{ks24}</b></td></tr>" +
                                                                "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>ผู้บริหารวงเงิน:</td><td align='right'><b>{admin_show}</b></td></tr>" +
                                                                "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>ผู้ประเมิน:</td><td align='right'><b>{eval_show}</b></td></tr>" +
                                                                "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>กลุ่มการประเมิน:</td><td align='right'><b>{etype}</b></td></tr>" +
                                                                "<tr ><td style='padding-bottom:4px' align='right' height='24px;'>หน่วยงาน:</td><td align='right'><b>{sdcode_show}</b></td></tr>" +
                                                            "</table>"
                                                        );
                                                        tpl.overwrite(Ext.get("temp_detail"), obj.data);
                                                    }
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
    ,buttons: [
        {
            text: "ดูข้อมูล"
            ,handler: function(){
                if ((!Ext.getCmp("all_subdept").getValue() && Ext.getCmp("sdcode").getValue() == "") || (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == "") || Ext.getCmp("id_config").getValue() == "" ){
                    Ext.Msg.alert("คำแตือน","กรุณาเลือกข้อมูลให้ครบ")
                    return false;
                }
                GridStore.load({
                    params: {
                        fiscal_year: Ext.getCmp("round_fiscalyear").getValue() 
                        ,round: Ext.getCmp("round").getValue()
                        ,all_subdept: Ext.getCmp("all_subdept").getValue()
                        ,sdcode: Ext.getCmp("sdcode").getValue()
                        ,seccode: Ext.getCmp("seccode").getValue()
                        ,jobcode: Ext.getCmp("jobcode").getValue() 
                    }    
                });
                Grid.enable();
            }
        }
    ]
    ,listeners: {
        afterrender: function(el){
            Ext.getCmp("round_fiscalyear").setValue(fiscalYear(new Date()) + 543 );
        }
    }
});

Ext.getCmp("id_config").getStore().on('beforeload', function(store, option ) {
        if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
            return false;
        }
        option.params.fiscal_year = Ext.getCmp("round_fiscalyear").getValue();
        option.params.round = Ext.getCmp("round").getValue();
});
//-------------------------------------
// Panel Center
//-------------------------------------
var filters_menu3 = new Ext.ux.grid.GridFilters({
    encode: false,
    local: true,
    filters: [
        {type: 'string',dataIndex: 'posid'}
        ,{type: 'string',dataIndex: 'name'}
        ,{type: 'string',dataIndex: 'cname'}
        ,{type: 'string',dataIndex: 'salary'}
        ,{type: 'string',dataIndex: 'midpoint'}
        ,{type: 'string',dataIndex: 'j18status'}
    ]
});
var flageval1CheckColumn = new Ext.grid.CheckColumn({
	header: 'กำหนดประเมิน'
	,dataIndex: 'flageval1'
	,width: 80
	,editor: new Ext.form.Checkbox()
});

/*var upd_config_personel = new Ext.ux.form.PisComboBox({
        valueField: 'updcode'
        ,displayField: 'updname'
        ,urlStore: pre_url + '/code/cupdate_cal_sal'
        ,fieldStore: ['updcode', 'updname']
});*/


var Fields = [
    {name: "posid", type: "string"}
    ,{name: "name", type: "string"}
    ,{name: "j18status", type: "string"}
    ,{name: "salary", type: "string"}
    ,{name: "midpoint", type: "string"}
    ,{name: "flageval1", type: "bool"}
    ,{name: "evalid1", type: "string"}
    /*,{name: "updcode", type: "string"}*/
    ,{name: "updname", type: "string"}
    ,{name: "id", type: "string"}
    ,{name: "idx", type: "string"}
    ,{name: "year", type: "string"}
];

var Cols = [
    {
        header: "#"
        ,width: 50
        ,renderer: rowNumberer.createDelegate(this)
        ,sortable: false
    }
    ,{header: "ตำแหน่งเลขที่",width: 80, sortable: false, dataIndex: 'posid'}
    ,{header: "ชื่อ-นามสกุล",width: 150, sortable: false, dataIndex: 'name'}
    ,{header: "สถานะตาม จ.18",width: 100, sortable: false, dataIndex: 'j18status'}
    ,{header: "เงินเดือน",width: 80, sortable: false, dataIndex: 'salary'}
    ,{header: "ฐานในการคำนวณ",width: 100, sortable: false, dataIndex: 'midpoint'}
    ,flageval1CheckColumn
    ,{header: "หมายเลขกลุ่ม",width: 80, sortable: false, dataIndex: 'evalid1'}
    /*,{header: "รหัสการเลื่อนขั้นเงินเดือน",width: 150, sortable: false, dataIndex: 'updcode',editor: upd_config_personel,renderer: function(value ,metadata ,record ,rowIndex  ,colIndex ,store ){
        index_ = upd_config_personel.getStore().find('updcode',value)
        if (index_ != -1){
           record.data.updname = upd_config_personel.getStore().data.items[index_].data.updname;
        }
        else{
            record.data.updname = "";
        }
        return record.data.updname;
    }}
    */
];
var GridStore = new Ext.data.JsonStore({
    url: pre_url + "/config_personel/read"
    ,root: "records"
    ,autoLoad: false
    ,fields: Fields
    ,idProperty: 'idx'
    ,listeners: {
        update: function( store,record ) {
            if (record.data.flageval1){
                record.set("evalid1", Ext.getCmp("id_config").getValue())
            }
            else{
                record.set("evalid1", "")
            }
        }
    }
});

var Grid = new Ext.grid.EditorGridPanel({
    region: 'center'
    ,disabled: true
    ,clicksToEdit: 1
    ,split: true
    ,store: GridStore
    ,columns: Cols
    ,stripeRows: true
    ,loadMask: {msg:'Loading...'}
    ,trackMouseOver: false
    ,sm: new Ext.grid.RowSelectionModel()
    ,plugins: [filters_menu3]
    ,listeners: {
        afterrender: function(el){
                 el.doLayout();
        }
    }
    ,tbar: [
        {
            text: "บันทึก"
            ,iconCls: "disk"
            ,handler: function(){
                if (GridStore.getModifiedRecords().length == 0){
                    Ext.Msg.alert("คำเตือน","กรุณาทำรายการก่อน");
                    return false;
                }
                loadMask.show();
                Ext.Ajax.request({
                    url: pre_url + "/config_personel/update"
		    ,timeout: 1200000
                    ,params: {
                        data: readDataGrid(GridStore.getModifiedRecords())
                    }
                    ,success: function(response,opts){
                        obj = Ext.util.JSON.decode(response.responseText);
                        loadMask.hide();
                        if (obj.success){
                            GridStore.commitChanges();
			    Ext.Msg.alert("","บันทึกเสร็จเรียบร้อย");
                        }
                        else{
                            Ext.Msg.alert("คำแนะนำ","เกิดข้อผิดพลาดกรุณาลองใหม่");
                            return false;
                        }                        
                    }
                    ,failure: function(response,opts){
                        Ext.Msg.alert("สถานะ",response.statusText);
                        loadMask.hide();
                    }
                });                
            }
        }
        ,"-",{
           text: "ประเมินทั้งหมด"
           ,handler: function(){
                store_items = GridStore.data.items;
                for (i=0;i<store_items.length;i++){
                    store_items[i].set("flageval1", true)
                    //store_items[i].set("evalid1", Ext.getCmp("id_config").getValue())
                    
                }
           }
        }
        ,"-",{
            text: "ไม่ประเมินทั้งหมด"
           ,handler: function(){
                store_items = GridStore.data.items;
                for (i=0;i<store_items.length;i++){
                    store_items[i].set("flageval1", false)
                    //store_items[i].set("evalid1", "")
                }
           }            
        }
    ]/*
    ,viewConfig: {
        forceFit:true
        ,enableRowBody:true
        ,showPreview:true
        ,getRowClass: function(record, rowIndex, p, store){
                p.body = '<p>'+"wrwerewrewrewrwrwerwerwerew"+'</p>';
                return 'x-grid3-row-expanded';
            
        }
    }
     */
});

//-------------------------------------
// Panel Main
//-------------------------------------
var panelConfigPersonel = new Ext.Panel({
    title: "กำหนดบุคคล-การบริหารวงเงิน"
    ,layout: "border"
    ,items: [
        westConfigPersonel
        ,Grid    
    ]
    ,listeners: {
        afterrender: function(el){
            el.doLayout();
            /*upd_config_personel.getStore().load({params:{
                limit: 10
                ,start: 0
            }});*/
        }
    }
});


function clearConfigPersonel(){
    Ext.getCmp("all_subdept").setValue(false);
    Ext.getCmp("sdcode").setValue("");
    Ext.getCmp("subdept_show").setValue("");
    Ext.getCmp("seccode").getStore().removeAll();
    Ext.getCmp("seccode").clearValue();
    Ext.getCmp("jobcode").getStore().removeAll();
    Ext.getCmp("jobcode").clearValue();
    Ext.getCmp("id_config").getStore().removeAll();
    Ext.getCmp("id_config").clearValue();
    tpl = new Ext.Template(tmp_config_blank);
    tpl.overwrite(Ext.get("temp_detail"), "");
    GridStore.removeAll();
    Grid.disable();
}