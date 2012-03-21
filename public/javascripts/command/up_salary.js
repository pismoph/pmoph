//-------------------------------------
// Panel west north
//-------------------------------------
var upSalaryNorth = new Ext.Panel({
    region: "north"
    ,height: 100
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
                            ,width: 350
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
                                                    upSalaryGridStore.removeAll();
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
                                                                upSalaryGridStore.load({
                                                                    params: {
                                                                        fiscal_year: Ext.getCmp("round_fiscalyear").getValue() 
                                                                        ,round: Ext.getCmp("round").getValue()
                                                                    }
                                                                });                                                                                       
                                                            }
                                                            else if (obj.cn == 0){
                                                                str = Ext.getCmp("round_fiscalyear").getValue() + " รอบ " + Ext.getCmp("round").getRawValue();
                                                                Ext.Msg.alert('คำเตือน', 'ยังไม่มีการประมวลผลเลื่อนขั้นปี ' + str);
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
                                }]
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
// Panel  center
//-------------------------------------
var upd_up_salary = new Ext.ux.form.PisComboBox({
        valueField: 'updcode'
        ,displayField: 'updname'
        ,urlStore: pre_url + '/code/cupdate_cal_sal'
        ,fieldStore: ['updcode', 'updname']
});

var upSalaryFields = [
    {name: "posid", type: "string"}
    ,{name: "name", type: "string"}
    ,{name: "posname", type: "string"}
    ,{name: "cname", type: "string"}
    ,{name: "salary", type: "string"}
    ,{name: "j18status", type: "string"}
    ,{name: "midpoint", type: "string"}
    ,{name: "calpercent", type: "string"}
    ,{name: "score", type: "string"}
    ,{name: "evalno", type: "string"}
    ,{name: "newsalary", type: "string"}
    ,{name: "addmoney", type: "string"}
    ,{name: "note1", type: "string"}
    ,{name: "maxsalary", type: "string"}
    ,{name: "year", type: "string"}
    ,{name: "id", type: "string"}
    ,{name: "idx", type: "int"}
    ,{name: "sdcode", type: "string"}
    ,{name: "updcode", type: "string"}
];

var upSalaryCols = [
    {
        header: "#"
        ,width: 40
        ,renderer: rowNumberer.createDelegate(this)
        ,sortable: false
    }
    ,{header: "ตำแหน่งเลขที่",width: 80, sortable: false, dataIndex: 'posid'}
    ,{header: "ชื่อ-นามสกุล",width: 120, sortable: false, dataIndex: 'name'}
    ,{header: "ตำแหน่ง / ระดับ",width: 150, sortable: false, dataIndex: 'posname',renderer: function(value ,metadata ,record ,rowIndex  ,colIndex ,store ){
        return value+"<br />"+record.data.cname;   
    }}
    ,{header: "เงินเดือน",width: 80, sortable: false, dataIndex: 'salary'}
    ,{header: "รหัสการเลื่อนขั้นเงินเดือน",width: 130, sortable: false, dataIndex: 'updcode',editor: upd_up_salary,renderer: function(value ,metadata ,record ,rowIndex  ,colIndex ,store ){
        index_ = upd_up_salary.getStore().find('updcode',value)
        if (index_ != -1){
           record.data.updname = upd_up_salary.getStore().data.items[index_].data.updname;
        }
        else{
            record.data.updname = "";
        }
        return record.data.updname;
    }}
    ,{header: "ฐานในการคำนวน",width: 90, sortable: false, dataIndex: 'midpoint'}
    ,{header: "ร้อยละ",width: 80, sortable: false, dataIndex: 'calpercent',editor: {xtype: "numberfield"}}
    ,{header: "คะแนน",width: 80, sortable: false, dataIndex: 'score',editor: {xtype: "numberfield"}}
    ,{header: "ผลการประเมิน",width: 80, sortable: false, dataIndex: 'evalno',editor: {xtype: "numberfield"}}
    ,{header: "เงินเดือนที่เลื่อน",width: 90, sortable: false, dataIndex: 'newsalary'}
    ,{header: "เงินเพิ่มพิเศษ",width: 80, sortable: false, dataIndex: 'addmoney'}
    ,{header: "หมายเหตุ",width: 80, sortable: false, dataIndex: 'note1',editor: {xtype: "textfield"}}
];
var upSalaryGridStore = new Ext.data.JsonStore({
    url: pre_url + "/up_salary/read"
    ,root: "records"
    ,autoLoad: false
    ,fields: upSalaryFields
    ,idProperty: 'idx'
    ,listeners: {
        update: function( store,record ) {
            addmoney = "";
            calpercent = Number(record.data.calpercent);
            newsalary = calpercent/100;
            newsalary = newsalary * Number(record.data.midpoint);
            newsalary += Number(record.data.salary);
            newsalary = newsalary.toFixed(2)
            if (Number(newsalary) > Number(record.data.maxsalary)){
                addmoney = Number(newsalary) - Number(record.data.maxsalary);
                addmoney = addmoney.toFixed(2)
                newsalary = Number(record.data.maxsalary);
            }
            else{
                newsalary = Math.ceil(Number(newsalary)/10)*10;
            }
            record.data.addmoney = addmoney;
            record.data.newsalary = newsalary;
        }
    }
});

var upSalaryGrid = new Ext.grid.EditorGridPanel({
    region: "center"
    ,clicksToEdit: 1
    ,split: true
    ,store: upSalaryGridStore
    ,columns: upSalaryCols
    ,stripeRows: true
    ,loadMask: {msg:'Loading...'}
    ,trackMouseOver: false
    ,sm: new Ext.grid.RowSelectionModel()
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
                if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                    Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                    return false;
                }
                loadMask.show();
                Ext.Ajax.request({
                    url: "/up_salary/update"
                    ,params: {
                        data: readDataGrid(upSalaryGridStore.getModifiedRecords())
                    }
                    ,success: function(response,opts){
                        loadMask.hide();
                        obj = Ext.util.JSON.decode(response.responseText);
                        if (obj.success){
                           upSalaryGridStore.commitChanges(); 
                        }
                        else{
                            Ext.Msg.alert("คำเติอน","เกืดความผิดพลาดกรุณาลองใหม่อีกครั้ง")
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
           text: "อนุมัติคำสั่งเลื่อนเงินเดือน"
           ,iconCls: "justice"
            ,handler: function(){
                if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                    Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                    return false;
                }
                if(!form){
                    var form = new Ext.FormPanel({ 
                        labelWidth: 100
                        ,autoScroll: true
                        ,url: pre_url + "/up_salary/approve"
                        ,frame: true
                        ,monitorValid: true
                        ,defaults: {
                            anchor: "95%"
                        }
                        ,items:[
                            {
                                xtype: "textfield"
                                ,id: "cmdno"
                                ,fieldLabel: "คำสั่งเลขที่"
                                ,allowBlank: false
                            }
                            ,{
                                xtype: "datefield"
                                ,id: "forcedate"
                                ,fieldLabel: "วันที่มีผลบังคับใช้"
                                ,format: "d/m/Y"
                                ,allowBlank: false
                            }
                            ,{
                                xtype: "datefield"
                                ,id: "cmddate"
                                ,fieldLabel: "ลงวันที่"
                                ,format: "d/m/Y"
                                ,allowBlank: false
                            }
                            ,new Ext.form.ComboBox({
                                editable: false
                                ,fieldLabel: "ระดับ"
                                ,id:"level"
                                ,hiddenName:"level"
                                ,store: new Ext.data.SimpleStore({
                                    fields: ["id", "type"]
                                    ,data: [
                                        ["(51,52,53,54,31,32,33)","ทั่วไป-วิชาการ(ชำนาญการพิเศษ)"]
                                        ,["(34,35)","บริหาร"]
                                        ,["(21,22)","วิชาการ(เชี่ยวชาญ-ทรงคุณวุฒิ)"]
                                        ,["(41,42)","อำนวยการ "]
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
                           title: 'อนุมัติคำสั่งเลื่อนเงินเดือน'
                           ,width: 400
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
            }
        }
        
        ,"-",{
            text: "อนุมัติคำสั่งค่าตอบแทนพิเศษ"
            ,iconCls: "justice"
            ,handler: function(){
                if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                    Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                    return false;
                }
                if(!form){
                    var form = new Ext.FormPanel({ 
                        labelWidth: 100
                        ,autoScroll: true
                        ,url: pre_url + "/up_salary/approve_special"
                        ,frame: true
                        ,monitorValid: true
                        ,defaults: {
                            anchor: "95%"
                        }
                        ,items:[
                            {
                                xtype: "textfield"
                                ,id: "cmdno"
                                ,fieldLabel: "คำสั่งเลขที่"
                                ,allowBlank: false
                            }
                            ,{
                                xtype: "datefield"
                                ,id: "forcedate"
                                ,fieldLabel: "วันที่มีผลบังคับใช้"
                                ,format: "d/m/Y"
                                ,allowBlank: false
                            }
                            ,{
                                xtype: "datefield"
                                ,id: "cmddate"
                                ,fieldLabel: "ลงวันที่"
                                ,format: "d/m/Y"
                                ,allowBlank: false
                            }
                            ,new Ext.form.ComboBox({
                                editable: false
                                ,fieldLabel: "ระดับ"
                                ,id:"level"
                                ,hiddenName:"level"
                                ,store: new Ext.data.SimpleStore({
                                    fields: ["id", "type"]
                                    ,data: [
                                        ["(51,52,53,54,31,32,33)","ทั่วไป-วิชาการ(ชำนาญการพิเศษ)"]
                                        ,["(34,35)","บริหาร"]
                                        ,["(21,22)","วิชาการ(เชี่ยวชาญ-ทรงคุณวุฒิ)"]
                                        ,["(41,42)","อำนวยการ "]
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
                           title: 'อนุมัติคำสั่งค่าตอบแทนพิเศษ'
                           ,width: 400
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
            }
        }
        ,"-",{
            text: "รายงาน"
            ,menu: {
                items: [
                    {
                        text: "1.ประกาศร้อยละการเลื่อนเงินเดือน"
                        ,handler: function(){
                            if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                return false;
                            }
                            year = Ext.getCmp("round_fiscalyear").getValue() + Ext.getCmp("round").getValue();
                                        
                            var form = document.createElement("form");
                            form.setAttribute("method", "post");
                            form.setAttribute("action", pre_url + "/up_salary/report1?format=pdf");
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
                        text: "2. บัญชีแจ้งผลพิจารณาฯ"
                        ,menu: {
                            items: [
                                {
                                    text: "Excel"
                                    ,handler: function(){
                                        if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                            Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                            return false;
                                        }
                                        var form = document.createElement("form");
                                        form.setAttribute("method", "post");
                                        form.setAttribute("action", pre_url + "/up_salary/report2_excel?format=xls");
                                        form.setAttribute("target", "_blank");
                                        var hiddenField1 = document.createElement("input");              
                                        hiddenField1.setAttribute("name", "fiscal_year");
                                        hiddenField1.setAttribute("value", Ext.getCmp("round_fiscalyear").getValue());
                                        var hiddenField2 = document.createElement("input");              
                                        hiddenField2.setAttribute("name", "round");
                                        hiddenField2.setAttribute("value", Ext.getCmp("round").getValue());
                                        form.appendChild(hiddenField1);
                                        form.appendChild(hiddenField2);
                                        document.body.appendChild(form);
                                        form.submit();
                                        document.body.removeChild(form);
                                    }

                                }
                                ,{
                                    text: "PDF"
                                    ,handler: function(){
                                        if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                            Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                            return false;
                                        }
                                        var form = document.createElement("form");
                                        form.setAttribute("method", "post");
                                        form.setAttribute("action", pre_url + "/up_salary/report2?format=pdf");
                                        form.setAttribute("target", "_blank");
                                        var hiddenField1 = document.createElement("input");              
                                        hiddenField1.setAttribute("name", "fiscal_year");
                                        hiddenField1.setAttribute("value", Ext.getCmp("round_fiscalyear").getValue());
                                        var hiddenField2 = document.createElement("input");              
                                        hiddenField2.setAttribute("name", "round");
                                        hiddenField2.setAttribute("value", Ext.getCmp("round").getValue());
                                        form.appendChild(hiddenField1);
                                        form.appendChild(hiddenField2);
                                        document.body.appendChild(form);
                                        form.submit();
                                        document.body.removeChild(form);
                                    }

                                }
                                
                            ]
                        }
                    }
                    ,{
                        text: "3.บัญชีแจ้งผลพิจารณาฯ ชช. ขึ้นไป"
                        ,handler: function(){
                            if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                return false;
                            }
                            var form = document.createElement("form");
                            form.setAttribute("method", "post");
                            form.setAttribute("action", pre_url + "/up_salary/report3?format=pdf");
                            form.setAttribute("target", "_blank");
                            var hiddenField1 = document.createElement("input");              
                            hiddenField1.setAttribute("name", "fiscal_year");
                            hiddenField1.setAttribute("value", Ext.getCmp("round_fiscalyear").getValue());
                            var hiddenField2 = document.createElement("input");              
                            hiddenField2.setAttribute("name", "round");
                            hiddenField2.setAttribute("value", Ext.getCmp("round").getValue());
                            form.appendChild(hiddenField1);
                            form.appendChild(hiddenField2);
                            document.body.appendChild(form);
                            form.submit();
                            document.body.removeChild(form);
                        }
                        
                    }
                    ,{
                        text: "4.บัญชีแจ้งผลพิจารณาฯ ประเภทอำนวยการ"
                        ,handler: function(){
                            if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                return false;
                            }
                            var form = document.createElement("form");
                            form.setAttribute("method", "post");
                            form.setAttribute("action", pre_url + "/up_salary/report4?format=pdf");
                            form.setAttribute("target", "_blank");
                            var hiddenField1 = document.createElement("input");              
                            hiddenField1.setAttribute("name", "fiscal_year");
                            hiddenField1.setAttribute("value", Ext.getCmp("round_fiscalyear").getValue());
                            var hiddenField2 = document.createElement("input");              
                            hiddenField2.setAttribute("name", "round");
                            hiddenField2.setAttribute("value", Ext.getCmp("round").getValue());
                            form.appendChild(hiddenField1);
                            form.appendChild(hiddenField2);
                            document.body.appendChild(form);
                            form.submit();
                            document.body.removeChild(form);
                        }
                        
                    }
                    ,{
                        text: "5.บัญชีแจ้งผลพิจารณาฯผู้มาช่วยราชการ"
                        ,handler: function(){
                            if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                return false;
                            }
                            year = Ext.getCmp("round_fiscalyear").getValue() + Ext.getCmp("round").getValue();
                                        
                            var form = document.createElement("form");
                            form.setAttribute("method", "post");
                            form.setAttribute("action", pre_url + "/up_salary/report5?format=pdf");
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
                        text: "6.บัญชีเลื่อน"
                        ,handler: function(){
                            if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                return false;
                            }
                            year = Ext.getCmp("round_fiscalyear").getValue() + Ext.getCmp("round").getValue();
                            var form = document.createElement("form");
                            form.setAttribute("method", "post");
                            form.setAttribute("action", pre_url + "/up_salary/report6?format=pdf");
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
                        text: "7.บัญชีค่าตอบแทนพิเศษ"
                        ,handler: function(){
                            if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                return false;
                            }
                            year = Ext.getCmp("round_fiscalyear").getValue() + Ext.getCmp("round").getValue();
                            var form = document.createElement("form");
                            form.setAttribute("method", "post");
                            form.setAttribute("action", pre_url + "/up_salary/report7?format=pdf");
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
                        text: "8.บัญชีไม่เลื่อน"
                        ,handler: function(){
                            if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                return false;
                            }
                            year = Ext.getCmp("round_fiscalyear").getValue() + Ext.getCmp("round").getValue();
                            var form = document.createElement("form");
                            form.setAttribute("method", "post");
                            form.setAttribute("action", pre_url + "/up_salary/report8?format=pdf");
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
                        text: "9.บัญชีเลื่อนเกษียณ "
                        ,handler: function(){
                            if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                return false;
                            }
                            if (Ext.getCmp("round").getValue() == "1"){
                                Ext.Msg.alert("คำเตือน","ได้เฉพาะ รอบ 1 ตุลาคมเท่านั้น");
                                return false;
                            }
                            year = Ext.getCmp("round_fiscalyear").getValue() + Ext.getCmp("round").getValue();
                            var form = document.createElement("form");
                            form.setAttribute("method", "post");
                            form.setAttribute("action", pre_url + "/up_salary/report9?format=pdf");
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
                        text: "10.บัญชีไม่เลื่อนเกษียณ"
                        ,handler: function(){
                            if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                return false;
                            }
                            if (Ext.getCmp("round").getValue() == "1"){
                                Ext.Msg.alert("คำเตือน","ได้เฉพาะ รอบ 1 ตุลาคมเท่านั้น");
                                return false;
                            }
                            
                            year = Ext.getCmp("round_fiscalyear").getValue() + Ext.getCmp("round").getValue();
                            var form = document.createElement("form");
                            form.setAttribute("method", "post");
                            form.setAttribute("action", pre_url + "/up_salary/report10?format=pdf");
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
                        text: "11.สรุปการใช้เงิน"
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
                                                round = Ext.getCmp("round").getValue();
                                                year = Ext.getCmp("round_fiscalyear").getValue() + round;
                                                percent = Ext.getCmp("report_percent").getValue();
                                                report_type = Ext.getCmp("report_type").getValue()
                                                url = "report11_"+report_type
                                                
                                                var form = document.createElement("form");
                                                form.setAttribute("method", "post");
                                                form.setAttribute("action", pre_url + "/up_salary/"+url+"?format=pdf");
                                                form.setAttribute("target", "_blank");
                                                var hiddenField1 = document.createElement("input");              
                                                hiddenField1.setAttribute("name", "year");
                                                hiddenField1.setAttribute("value", year);
                                                
                                                var hiddenField2 = document.createElement("input");              
                                                hiddenField2.setAttribute("name", "percent");
                                                hiddenField2.setAttribute("value", percent );
                                                
                                                var hiddenField3 = document.createElement("input");              
                                                hiddenField3.setAttribute("name", "type");
                                                hiddenField3.setAttribute("value", report_type);
                                                
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
                                    title: 'สรุปการใช้เงิน'
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
                    ,{
                        text: "12.บัญชีสรุปฯ"
                        ,handler: function(){
                            if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                return false;
                            }
                            year = Ext.getCmp("round_fiscalyear").getValue() + Ext.getCmp("round").getValue();
                            var form = document.createElement("form");
                            form.setAttribute("method", "post");
                            form.setAttribute("action", pre_url + "/up_salary/report12?format=pdf");
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
                        text: "13.หนังสือแจ้งผลการเลื่อนเงินเดือน"
                        ,handler: function(){
                            if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                return false;
                            }
                            year = Ext.getCmp("round_fiscalyear").getValue() + Ext.getCmp("round").getValue();
                            PersonelTIncsalary(year);
                        }
                    }
                    ,{
                        text: "14.ส่งออกข้อมูลให้กลุ่มบุคคล"
                        ,handler: function(){
                            if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == ""){
                                Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                                return false;
                            }
                            year = Ext.getCmp("round_fiscalyear").getValue() + Ext.getCmp("round").getValue();
                            var form = document.createElement("form");
                            form.setAttribute("method", "post");
                            form.setAttribute("action", pre_url + "/up_salary/report14?format=xls");
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
        
    ]
});


function PersonelTIncsalary(y){
    PersonelTIncsalarySearch = new Ext.ux.grid.Search({
             iconCls: 'search'
             ,minChars: 3
             ,autoFocus: true
             ,position: "top"
             ,width: 200
    });
    PersonelTIncsalaryFields = [
             ,{name: "prefix", type: "string"}
             ,{name: "fname", type: "string"}
             ,{name: "lname", type: "string"}
             ,{name: "posid", type: "string"}
             ,{name: "id", type: "string"}
    ];
    PersonelTIncsalaryCols = [
         {
                  header: "#"
                  ,width: 80
                  ,renderer: rowNumberer.createDelegate(this)
                  ,sortable: false
         }
         ,{header: "เลขที่ตำแหน่ง",width: 100, sortable: false, dataIndex: 'posid'}		
         ,{header: "คำนำหน้า",width: 70, sortable: false, dataIndex: 'prefix'}
         ,{header: "ชื่อ",width: 100, sortable: false, dataIndex: 'fname'}
         ,{header: "นามสกุล",width: 100, sortable: false, dataIndex: 'lname'}
         
    ];
        
    PersonelTIncsalaryGridStore = new Ext.data.JsonStore({
            url: pre_url + "/up_salary/personel_t_incsalary"
            ,root: "records"
            ,autoLoad: false
            ,totalProperty: 'totalCount'
            ,fields: PersonelTIncsalaryFields
            ,idProperty: 'id'
    });
        
    PersonelTIncsalaryGrid = new Ext.grid.GridPanel({
            split: true
            ,store: PersonelTIncsalaryGridStore
            ,columns: PersonelTIncsalaryCols
            ,stripeRows: true
            ,loadMask: {msg:'Loading...'}
            ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
            ,plugins: [PersonelTIncsalarySearch]
            ,bbar: new Ext.PagingToolbar({
                      pageSize: 20
                      ,autoWidth: true
                      ,store: PersonelTIncsalaryGridStore
                      ,displayInfo: true
                      ,displayMsg	: 'Displaying {0} - {1} of {2}'
                      ,emptyMsg: "Not found"
            })
            ,tbar: []
    });

    PersonelTIncsalaryGrid.on('rowdblclick', function(grid, rowIndex, e ) {
        data_select = grid.getSelectionModel().getSelected().data;
        var form = document.createElement("form");
        form.setAttribute("method", "post");
        form.setAttribute("action", pre_url + "/up_salary/report13?format=pdf");
        form.setAttribute("target", "_blank");
        var hiddenField1 = document.createElement("input");              
        hiddenField1.setAttribute("name", "year");
        hiddenField1.setAttribute("value", y);        
        var hiddenField2 = document.createElement("input");              
        hiddenField2.setAttribute("name", "id");
        hiddenField2.setAttribute("value", data_select.id);
        form.appendChild(hiddenField1);
        form.appendChild(hiddenField2);
        document.body.appendChild(form);
        form.submit();
        document.body.removeChild(form);        
        win.close();
    });
    
    if(!win){
        var win = new Ext.Window({
            title: ''
            ,height: 300
            ,width: 600
            ,closable: true
            ,resizable: false
            ,plain: true
            ,border: false
            ,draggable: true 
            ,modal: true
            ,layout: "fit"
            ,items: [PersonelTIncsalaryGrid]
            ,tbar: [
                {
                    text: "ทั้งหมด"
                    ,handler: function(){
                        var form = document.createElement("form");
                        form.setAttribute("method", "post");
                        form.setAttribute("action", pre_url + "/up_salary/report13?format=pdf");
                        form.setAttribute("target", "_blank");                        
                        var hiddenField1 = document.createElement("input");              
                        hiddenField1.setAttribute("name", "year");
                        hiddenField1.setAttribute("value", y);
                        form.appendChild(hiddenField1);
                        document.body.appendChild(form);
                        form.submit();
                        document.body.removeChild(form); 
                    }
                }
            ]
        });
    }
    win.show();	
    win.center();
    PersonelTIncsalaryGridStore.baseParams = {
        year: y
    }
    PersonelTIncsalaryGridStore.load({params:{start: 0,limit: 20}});
}



//-------------------------------------
// Panel Main
//-------------------------------------
var upSalaryPanel = new Ext.Panel({
    title: "คำสั่งเลื่อนเงินเดือน"
    ,layout: "border"
    ,items: [
        upSalaryNorth
        ,upSalaryGrid  
    ]
    ,listeners: {
        afterrender: function(el){
            el.doLayout();
            upd_up_salary.getStore().load({params:{
                limit: 10
                ,start: 0
            }});
        }
    }
});