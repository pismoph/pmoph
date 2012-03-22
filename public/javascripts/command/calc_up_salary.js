//-------------------------------------
// Panel North
//-------------------------------------
var northCalcUpSalary = new Ext.Panel({
    region: "north"
    ,title: "คำนวณเงินสำหรับใช้ในการเลื่อนเงินเดือน"
    //,collapsible: true
    ,height: 120
    ,border: false
    ,autoScroll: true
    ,frame: true
    ,items: [
        {
            width: 660
            ,style: "padding-left:50%;margin-left:-317px"
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
                            ,width: 610
                            ,border: false
                            ,items: [
                                {
                                    layout: "column"
                                    ,items: [
                                        {
                                            width: 400
                                            ,style: "margin-right: 10px"
                                            ,layout: "form"
                                            ,items: [
                                                {
                                                    xtype: "fieldset"
                                                    ,layout: "form"
                                                    ,title: "ประมวล"
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
                                                                            GridStore.removeAll();
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
                                                                        ,data: [
                                                                            ["1","1 เมษายน"]
                                                                            ,["2","1 ตุลาคม"]
                                                                        ]
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
                                                                            GridStore.removeAll();
                                                                            loadMask.show();
                                                                            Ext.Ajax.request({
                                                                                url: pre_url + "/calc_up_salary/check_count"
                                                                                ,params: {
                                                                                    fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                                                                    ,round: Ext.getCmp("round").getValue()
                                                                                }
                                                                                ,success: function(response,opts){
                                                                                    obj = Ext.util.JSON.decode(response.responseText);
                                                                                    loadMask.hide();
                                                                                    if(obj.cn > 0){
                                                                                        GridStore.load({
                                                                                            params: {
                                                                                                fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                                                                                ,round: Ext.getCmp("round").getValue()
                                                                                            }    
                                                                                        });                                                                                        
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
                                                                ,{
                                                                    xtype: "button"
                                                                    ,text: "ประมวลผลเพื่อนบคน"
                                                                    ,handler: function(){
                                                                        if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                                                            Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                                                            return false;
                                                                        }
                                                                        GridStore.removeAll();
                                                                        loadMask.show();
                                                                        Ext.Ajax.request({
                                                                            url: pre_url + "/calc_up_salary/check_count"
                                                                            ,params: {
                                                                                fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                                                                ,round: Ext.getCmp("round").getValue()
                                                                            }
                                                                            ,success: function(response,opts){
                                                                                obj = Ext.util.JSON.decode(response.responseText);
                                                                                loadMask.hide();
                                                                                if(obj.cn == 0){
                                                                                    str = Ext.getCmp("round_fiscalyear").getValue() + " รอบ " + Ext.getCmp("round").getRawValue();
                                                                                    Ext.Msg.confirm('คำเตือน', 'ยังไม่มีการประมวลผลเลื่อนขั้นปี ' + str, function(btn, text){
                                                                                        if (btn == 'yes'){
                                                                                            loadMask.show();
                                                                                            Ext.Ajax.request({
                                                                                                url: pre_url + "/calc_up_salary/add"
                                                                                                ,params: {
                                                                                                    fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                                                                                    ,round: Ext.getCmp("round").getValue()
                                                                                                }
                                                                                                ,success: function(response,opts){
                                                                                                    obj = Ext.util.JSON.decode(response.responseText);
                                                                                                    loadMask.hide();
                                                                                                    if (obj.success){
                                                                                                        GridStore.load({
                                                                                                            params: {
                                                                                                                fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                                                                                                ,round: Ext.getCmp("round").getValue()
                                                                                                            }    
                                                                                                        });
                                                                                                    }
                                                                                                    else{
                                                                                                        Ext.Msg.alert("คำแนะนำ","เกิดความผิดพลาดกรุณลองใหม่")
                                                                                                    }
                                                                                                }
                                                                                                ,failure: function(response,opts){
                                                                                                    Ext.Msg.alert("สถานะ",response.statusText);
                                                                                                    loadMask.hide();
                                                                                                }
                                                                                            });
                                                                                        }
                                                                                        else{
                                                                                            return false;
                                                                                        }
                                                                                    });
                                                                                ///end obj.cn == 0
                                                                                }
                                                                                else {
                                                                                    str = Ext.getCmp("round_fiscalyear").getValue() + " รอบ " + Ext.getCmp("round").getRawValue();
                                                                                    Ext.Msg.confirm('คำเตือน', 'ต้องการคำนวณเงินที่ใช้สำหรับเลื่อนขั้นปี' + str +" หรือไม่", function(btn, text){
                                                                                        if (btn == 'yes'){
                                                                                            loadMask.show();
                                                                                            Ext.Ajax.request({
                                                                                                url: pre_url + "/calc_up_salary/update"
                                                                                                ,params: {
                                                                                                    fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                                                                                    ,round: Ext.getCmp("round").getValue()
                                                                                                }
                                                                                                ,success: function(response,opts){
                                                                                                    obj = Ext.util.JSON.decode(response.responseText);
                                                                                                    loadMask.hide();
                                                                                                    if (obj.success){
                                                                                                        GridStore.load({
                                                                                                            params: {
                                                                                                                fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                                                                                                ,round: Ext.getCmp("round").getValue()
                                                                                                            }    
                                                                                                        });
                                                                                                    }
                                                                                                    else{
                                                                                                        Ext.Msg.alert("คำแนะนำ","เกิดความผิดพลาดกรุณลองใหม่")
                                                                                                    }
                                                                                                }
                                                                                                ,failure: function(response,opts){
                                                                                                    Ext.Msg.alert("สถานะ",response.statusText);
                                                                                                    loadMask.hide();
                                                                                                }
                                                                                            });
                                                                                        }
                                                                                        else{
                                                                                            GridStore.load({
                                                                                                params: {
                                                                                                    fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                                                                                    ,round: Ext.getCmp("round").getValue()
                                                                                                }    
                                                                                            });
                                                                                            return false;
                                                                                        }
                                                                                    });
                                                                                ///end obj.cn > 0
                                                                                }
                                                                            }
                                                                            ,failure: function(response,opts){
                                                                                Ext.Msg.alert("สถานะ",response.statusText);
                                                                                loadMask.hide();
                                                                            }
                                                                        });                                                                        
                                                                    }
                                                                }
                                                            ]
                                                        }
                                                    ]
                                                }
                                            ]
                                        }
                                        ,{
                                            width: 190
                                            ,style: "margin-right: 10px"
                                            ,layout: "form"
                                            ,items: [
                                                {
                                                    xtype: "fieldset"
                                                    ,title: "กำหนดเงินเลื่อนเงินเดือน"
                                                    ,items: [
                                                        {
                                                            xtype: "button"
                                                            ,text: "กำหนดเงินเลื่อนเงินเดือนหน่วยงาน"
                                                            ,handler: function(){
                                                                if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                                                    Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                                                    return false;
                                                                }
                                                                salary = 0;
                                                                calpercent = 0;
                                                                ks24 = 0;
                                                                Ext.Ajax.request({
                                                                    url: pre_url + "/calc_up_salary/get_config"
                                                                    ,params: {
                                                                        fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                                                        ,round: Ext.getCmp("round").getValue()
                                                                    }
                                                                    ,success: function(response,opts){
                                                                        obj = Ext.util.JSON.decode(response.responseText);
                                                                        if (obj.success){
                                                                            salary = "";
                                                                            calpercent = "";
                                                                            ks24 = "";
                                                                            if(obj.totalCount > 0){
                                                                                salary = obj.data.salary;
                                                                                calpercent = obj.data.calpercent;
                                                                                ks24 = obj.data.ks24;                                                                               
                                                                            }
                                                                            if(!form){
                                                                               var form = new Ext.FormPanel({ 
                                                                                  labelWidth: 100
                                                                                  ,autoScroll: true
                                                                                  ,url: pre_url + "/calc_up_salary/update_t_ks24usemain"
                                                                                  ,frame: true
                                                                                  ,monitorValid: true
                                                                                  ,defaults: {
                                                                                     anchor: "95%"
                                                                                  }
                                                                                  ,items:[
                                                                                        {
                                                                                            xtype: "numberfield"
                                                                                            ,id: "config_cal[salary]"
                                                                                            ,fieldLabel: "เงินเดือน"
                                                                                            ,enableKeyEvents: true
                                                                                            ,listeners: {
                                                                                                keyup: function(el, e ){
                                                                                                    salary = Number(Ext.getCmp("config_cal[salary]").getValue());
                                                                                                    calpercent = Number(Ext.getCmp("config_cal[calpercent]").getValue());
                                                                                                    ks24 = (salary / 100) * calpercent
                                                                                                    Ext.getCmp("config_cal[ks24]").setValue(ks24);
                                                                                                }
                                                                                            }
                                                                                            ,value: salary
                                                                                        }
                                                                                        ,{
                                                                                            xtype: "numberfield"
                                                                                            ,id: "config_cal[calpercent]"
                                                                                            ,fieldLabel: "ร้อยละ"
                                                                                            ,decimalPrecision: 4
                                                                                            ,maxValue: 99.9999
                                                                                            ,enableKeyEvents: true
                                                                                            ,listeners: {
                                                                                                keyup: function(el, e ){
                                                                                                    salary = Number(Ext.getCmp("config_cal[salary]").getValue());
                                                                                                    calpercent = Number(Ext.getCmp("config_cal[calpercent]").getValue());
                                                                                                    ks24 = (salary / 100) * calpercent
                                                                                                    Ext.getCmp("config_cal[ks24]").setValue(ks24);
                                                                                                }
                                                                                            }
                                                                                            ,value: calpercent
                                                                                        }
                                                                                        ,{
                                                                                            xtype: "numberfield"
                                                                                            ,id: "config_cal[ks24]"
                                                                                            ,fieldLabel: "เงินเดือน"
                                                                                            ,readOnly: true
                                                                                            ,value: ks24
                                                                                        }
                                                                                  ]
                                                                                  ,buttons	:[
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
                                                                                                        ,success	:function(){		
                                                                                                              Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                                                                                      if (btn == 'ok'){
                                                                                                                              win.close();
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
                                                                                       title: 'กำหนดเงินเลื่อนเงินเดือนหน่วยงาน'
                                                                                       ,width: 300
                                                                                       ,height: 200
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
                                                                            loadMask.hide();
                                                                        }
                                                                        else{
                                                                            Ext.Msg.alert("คำแนะนำ","เกิดความผิดพลาดกรุณาลองใหม่");
                                                                            loadMask.hide();
                                                                            return false;
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
                                                    ]
                                                }
                                            ]
                                        }
                                    ]
                                }                                
                            ]
                        }
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
var smMenu1 = new Ext.grid.CheckboxSelectionModel({singleSelect: false})
var filters_menu1 = new Ext.ux.grid.GridFilters({
    encode: false,
    local: true,
    filters: [
        {type: 'string',dataIndex: 'posid'}
        ,{type: 'string',dataIndex: 'fname'}
        ,{type: 'string',dataIndex: 'lname'}
        ,{type: 'string',dataIndex: 'cname'}
        ,{type: 'string',dataIndex: 'salary'}
        ,{type: 'string',dataIndex: 'midpoint'}
        ,{type: 'string',dataIndex: 'j18status'}
    ]
});

var flagcalCheckColumn = new Ext.grid.CheckColumn({
	header: 'คำนวณ'
	,dataIndex: 'flagcal'
	,width: 100
	,editor: new Ext.form.Checkbox()
});
var Fields = [
    {name: "posid", type: "string"}
    ,{name: "fname", type: "string"}
    ,{name: "lname", type: "string"}
    ,{name: "cname", type: "string"}
    ,{name: "salary", type: "string"}
    ,{name: "j18status", type: "string"}
    ,{name: "note1", type: "string"}
    ,{name: "flagcal", type: "bool"}
    ,{name: "midpoint",type: "string"}
    ,{name: "year",type: "string"}
    ,{name: "id",type: "string"}
];

var Cols = [
    smMenu1
    ,{
        header: "#"
        ,width: 70
        ,renderer: rowNumberer.createDelegate(this)
        ,sortable: false
    }
    ,{header: "ตำแหน่งเลขที่",width: 100, sortable: false, dataIndex: 'posid',filter: {type: 'string'}}
    ,{header: "ชื่อ",width: 100, sortable: false, dataIndex: 'fname',filter: {type: 'string'}}
    ,{header: "นามสกุล",width: 100, sortable: false, dataIndex: 'lname',filter: {type: 'string'}}
    ,{header: "ระดับ",width: 250, sortable: false, dataIndex: 'cname',filter: {type: 'string'}}
    ,{header: "เงินเดือน",width: 100, sortable: false, dataIndex: 'salary',filter: {type: 'string'}}
    ,{header: "ฐานในการคำนวณ",width: 100, sortable: false, dataIndex: 'midpoint',filter: {type: 'string'}}
    ,flagcalCheckColumn
    ,{header: "สถานะตามจ. 18",width: 120, sortable: false, dataIndex: 'j18status',filter: {type: 'string'}}
    ,{header: "หมายเหตุ",width: 200, sortable: false, dataIndex: 'note1', editor: new Ext.form.TextField()}
    
];
var GridStore = new Ext.data.JsonStore({
    url: pre_url + "/calc_up_salary/read"
    ,root: "records"
    ,autoLoad: false
    ,fields: Fields
    ,idProperty: 'posid'
    
});

var Grid = new Ext.grid.EditorGridPanel({
    region: 'center'
    ,clicksToEdit: 1
    ,split: true
    ,store: GridStore
    ,columns: Cols
    ,stripeRows: true
    ,loadMask: {msg:'Loading...'}
    ,trackMouseOver: false
    ,sm: smMenu1
    ,plugins: [filters_menu1]
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
                    url: pre_url + "/calc_up_salary/update_table"
                    ,params: {
                        data: readDataGrid(GridStore.getModifiedRecords())
                    }
                    ,success: function(response,opts){
                        obj = Ext.util.JSON.decode(response.responseText);
                        loadMask.hide();
                        if (obj.success){
                            row_edit = GridStore.getModifiedRecords();
                            GridStore.modified = [];
                            GridStore.reload();
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
            text: "รายงาน"
            ,handler: function(){
                return false;
            }
            ,menu: {
                items:[
                    {
                        text: "รายชื่อข้าราชการ"
                        ,handler: function(){
                            return false;
                        }
                        ,menu: {
                            items: [
                                {
                                    text: "ตาม จ.18"
                                    ,handler: function(){
                                        if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                            Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                            return false;
                                        }
                                        year = Ext.getCmp("round_fiscalyear").getValue() + Ext.getCmp("round").getValue();
                                        
                                        var form = document.createElement("form");
                                        form.setAttribute("method", "post");
                                        form.setAttribute("action", pre_url + "/calc_up_salary/reportj18?format=pdf");
                                        form.setAttribute("target", "_blank");
                                        
                                        var hiddenField = document.createElement("input");              
                                        hiddenField.setAttribute("name", "year");
                                        hiddenField.setAttribute("value", year);
                                        form.appendChild(hiddenField);									
                                        document.body.appendChild(form);
                                        form.submit();
                                        document.body.removeChild(form);                                        
                                    }
                                }
                                ,{
                                    text: "ปฏิบัติงานจริง(+มาช่วยฯ-ไปช่วย)"
                                    ,handler: function(){
                                        if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                            Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                            return false;
                                        }
                                        year = Ext.getCmp("round_fiscalyear").getValue() + Ext.getCmp("round").getValue();
                                        
                                        var form = document.createElement("form");
                                        form.setAttribute("method", "post");
                                        form.setAttribute("action", pre_url + "/calc_up_salary/reportwork?format=pdf");
                                        form.setAttribute("target", "_blank");
                                        
                                        var hiddenField = document.createElement("input");              
                                        hiddenField.setAttribute("name", "year");
                                        hiddenField.setAttribute("value", year);
                                        form.appendChild(hiddenField);									
                                        document.body.appendChild(form);
                                        form.submit();
                                        document.body.removeChild(form);                                         
                                    }
                                }
                            ]
                        }
                    }
                    ,{
                        text: "คำนวณวงเงิน(ฟอร์ม2)"
                        ,handler: function(){
                            if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                return false;
                            }
                            if(!form){
                                var form = new Ext.FormPanel({ 
                                   labelWidth: 100
                                   ,autoScroll: true
                                   ,frame: true
                                   ,monitorValid: true
                                   ,defaults: {
                                      anchor: "95%"
                                   }
                                   ,items:[
                                        new Ext.form.ComboBox({
                                            editable: false
                                            ,fieldLabel: "ชนิดรายงาน"
                                            ,id:"report_type"
                                            ,width: 80
                                            ,store: new Ext.data.SimpleStore({
                                                fields: ["id", "type"]
                                                ,data: [
                                                    ["1","ตาม จ.18"]
                                                    ,["2","ปฏิบัติงานจริง(+มาช่วยฯ-ไปช่วย)"]
                                                ]
                                            })
                                            ,valueField:"id"
                                            ,displayField:"type"
                                            ,typeAhead: true
                                            ,mode: "local"
                                            ,triggerAction: "all"
                                            ,emptyText:""
                                            ,selectOnFocus:true
                                            ,allowBlank: false
                                        })
                                        ,{
                                            xtype: "numberfield"
                                            ,id: "report_percent"
                                            ,fieldLabel: "เลื่อนได้ร้อยละ"
                                            ,allowBlank: false
                                            ,value: 3
                                        }
                                        ,{
                                            xtype: "numberfield"
                                            ,id: "report_percent2"
                                            ,fieldLabel: "หน่วยงานเลื่อนได้ร้อยละ"
                                            ,allowBlank: false
                                            ,value: 2.9
                                        }
                                        ,{
                                            xtype: "numberfield"
                                            ,id: "report_percent3"
                                            ,fieldLabel: "กันไว้ร้อยละ"
                                            ,allowBlank: false
                                            ,value: 0.1
                                        }
                                   ]
                                   ,buttons	:[
                                        { 
                                            text:'ยืนยัน'
                                            ,formBind: true 
                                            ,handler:function(){ 					
                                                year = Ext.getCmp("round_fiscalyear").getValue() + Ext.getCmp("round").getValue();
                                                
                                                var form = document.createElement("form");
                                                form.setAttribute("method", "post");
                                                form.setAttribute("action", pre_url + "/calc_up_salary/reportmoney?format=pdf");
                                                form.setAttribute("target", "_blank");
                                                var hiddenField1 = document.createElement("input");              
                                                hiddenField1.setAttribute("name", "year");
                                                hiddenField1.setAttribute("value", year);
                                                
                                                var hiddenField2 = document.createElement("input");              
                                                hiddenField2.setAttribute("name", "percent");
                                                hiddenField2.setAttribute("value", Ext.getCmp("report_percent").getValue());
                                                
                                                var hiddenField3 = document.createElement("input");              
                                                hiddenField3.setAttribute("name", "type");
                                                hiddenField3.setAttribute("value", Ext.getCmp("report_type").getValue());
                                                
                                                var hiddenField4 = document.createElement("input");              
                                                hiddenField4.setAttribute("name", "percent2");
                                                hiddenField4.setAttribute("value", Ext.getCmp("report_percent2").getValue());
                                                
                                                var hiddenField5 = document.createElement("input");              
                                                hiddenField5.setAttribute("name", "percent3");
                                                hiddenField5.setAttribute("value", Ext.getCmp("report_percent3").getValue());
                                                
                                                form.appendChild(hiddenField1);
                                                form.appendChild(hiddenField2);
                                                form.appendChild(hiddenField3);
                                                form.appendChild(hiddenField4);
                                                form.appendChild(hiddenField5);
                                                
                                                document.body.appendChild(form);
                                                form.submit();
                                                document.body.removeChild(form);
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
                                    title: 'คำนวณวงเงิน(ฟอร์ม2)'
                                    ,width: 400
                                    ,height: 200
                                    ,closable: true
                                    ,resizable: false
                                    ,plain: true
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
                    ,{
                        text: "เอกสารหมายเลข 1,2"
                        ,handler: function(){
                            if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                return false;
                            }
                            if(!form){
                                var form = new Ext.FormPanel({ 
                                   labelWidth: 100
                                   ,autoScroll: true
                                   ,frame: true
                                   ,monitorValid: true
                                   ,defaults: {
                                      anchor: "95%"
                                   }
                                   ,items:[
                                        new Ext.form.ComboBox({
                                            editable: false
                                            ,fieldLabel: "ชนิดรายงาน"
                                            ,id:"report_type"
                                            ,width: 80
                                            ,store: new Ext.data.SimpleStore({
                                                fields: ["id", "type"]
                                                ,data: [
                                                    ["1","ตาม จ.18"]
                                                    ,["2","ปฏิบัติงานจริง(+มาช่วยฯ-ไปช่วย)"]
                                                ]
                                            })
                                            ,valueField:"id"
                                            ,displayField:"type"
                                            ,typeAhead: true
                                            ,mode: "local"
                                            ,triggerAction: "all"
                                            ,emptyText:""
                                            ,selectOnFocus:true
                                            ,allowBlank: false
                                        })
                                        ,{
                                            xtype: "numberfield"
                                            ,id: "report_percent"
                                            ,fieldLabel: "เลื่อนได้ร้อยละ"
                                            ,allowBlank: false
                                        }
                                   ]
                                   ,buttons	:[
                                        { 
                                            text:'ยืนยัน'
                                            ,formBind: true 
                                            ,handler:function(){ 					
                                                year = Ext.getCmp("round_fiscalyear").getValue() + Ext.getCmp("round").getValue();
                                                
                                                var form = document.createElement("form");
                                                form.setAttribute("method", "post");
                                                form.setAttribute("action", pre_url + "/calc_up_salary/reportnumber?format=pdf");
                                                form.setAttribute("target", "_blank");
                                                var hiddenField1 = document.createElement("input");              
                                                hiddenField1.setAttribute("name", "year");
                                                hiddenField1.setAttribute("value", year);
                                                
                                                var hiddenField2 = document.createElement("input");              
                                                hiddenField2.setAttribute("name", "percent");
                                                hiddenField2.setAttribute("value", Ext.getCmp("report_percent").getValue());
                                                
                                                var hiddenField3 = document.createElement("input");              
                                                hiddenField3.setAttribute("name", "type");
                                                hiddenField3.setAttribute("value", Ext.getCmp("report_type").getValue());
                                                
                                                form.appendChild(hiddenField1);
                                                form.appendChild(hiddenField2);
                                                form.appendChild(hiddenField3);
                                                
                                                document.body.appendChild(form);
                                                form.submit();
                                                document.body.removeChild(form);
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
                                    title: 'เอกสารหมายเลข 1,2'
                                    ,width: 400
                                    ,height: 150
                                    ,closable: true
                                    ,resizable: false
                                    ,plain: true
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
            }
        },"-",{
            ref: '../updateBtn'
            ,text: "แก้ไขข้อมูล"
            ,disabled: true
            ,handler: function(){
                loadMask.show();
                id = [];
                sl = smMenu1.getSelections();
                for(i=0;i<sl.length;i++){
                    id.push("'"+sl[i].data.id+"'")
                }
                Ext.Ajax.request({
                    url: pre_url + "/calc_up_salary/update_data"
                    ,params: {
                        fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                        ,round: Ext.getCmp("round").getValue()
                        ,id: "["+id.join(",")+"]"
                    }
                    ,success: function(response,opts){
                        obj = Ext.util.JSON.decode(response.responseText);
                        loadMask.hide();
                        if(obj.success){
                            GridStore.load({
                                params: {
                                    fiscal_year: Ext.getCmp("round_fiscalyear").getValue()
                                    ,round: Ext.getCmp("round").getValue()
                                }    
                            });                                                                                        
                        }
                        else{
                            Ext.Msg.alert("คำแนะนำ","เกิดความผิดพลาดกรุณาลองใหม่อีกครั้ง")
                        }
                    }
                    ,failure: function(response,opts){
                        Ext.Msg.alert("สถานะ",response.statusText);
                        loadMask.hide();
                    }
                });  

            }
        }
    ]
});

Grid.getSelectionModel().on('selectionchange', function(sm){
        
        
    Grid.updateBtn.setDisabled(sm.getCount() < 1);
});

//-------------------------------------
// Panel Main
//-------------------------------------

var panelCalcUpSalary = new Ext.Panel({
    layout: "border"
    ,items: [
        northCalcUpSalary
        ,Grid        
    ]
    ,listeners: {
        afterrender: function(el){
            el.doLayout();
        }
    }
});