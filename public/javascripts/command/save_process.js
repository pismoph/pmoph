tmp_config_blank = "<table style='font:12px tahoma,arial,helvetica,sans-serif;width:420px;' >" +
    "<tr ><td style='padding-bottom:4px' align='right' height='20px;' width='140px'>เงินเดือน:</td><td align='right' width='120px'><b>N/A</b></td>"+
    "<td width='100px' style='padding-left:20px;' align='right'>วงเงินที่ใช้เลื่อน:</td><td width='80px' align='right'><b>N/A</b></td>" +
    "</tr>" +
    "<tr ><td style='padding-bottom:4px' align='right' height='20px;'>ร้อยละ:</td><td align='right'><b>N/A</b></td>"+
    "<td style='padding-left:20px;' align='right'>เหลือ / เกิน:</td><td align='right'><b >N/A</b></td>" +
    "</tr>" +
    "<tr ><td style='padding-bottom:4px' align='right' height='20px;'>จำนวนเงินที่ใช้เลื่อนขั้น:</td><td align='right'><b>N/A</b></td></tr>" +
    "<tr ><td style='padding-bottom:4px' align='right' height='20px;'>ผู้บริหารวงเงิน:</td><td align='right'><b>N/A</b></td></tr>" +
    "<tr ><td style='padding-bottom:4px' align='right' height='20px;'>ผู้ประเมิน:</td><td align='right'><b>N/A</b></td></tr>" +
"</table>";
//-------------------------------------
// Panel west north
//-------------------------------------
var westNorthsaveProcess = new Ext.Panel({
    region: "north"
    ,height: 160
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
                                                    resetPanel();
                                                    Ext.getCmp("id_config").getStore().removeAll();
                                                    Ext.getCmp("id_config").clearValue();
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
                                                    resetPanel();
                                                    Ext.getCmp("id_config").getStore().removeAll();
                                                    Ext.getCmp("id_config").clearValue();
                                                }
                                            }
                                        })
                                    ]
                                }
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
                                        select: function(){
                                            resetPanel();
                                            //Ext.getCmp("id_config").getStore().remove();
                                        }
                                    }
                                })
                            ]
                        }
                    ]
                }
            ]
        }
    ]
    ,buttons: [
        {
            text: "ดูข้อมูล"
            ,handler: function(){
                if ( Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == "" || Ext.getCmp("id_config").getValue() == "" ){
                    Ext.Msg.alert("คำแตือน","กรุณาเลือกข้อมูลให้ครบ")
                    return false;
                }
                val = Ext.getCmp("id_config").getValue();
                store = Ext.getCmp("id_config").getStore();
                record = store.getById(val);
                setTempSummary(record.data.id,record.data.year);
                westCenterGridStore.load({
                    params: {
                        fiscal_year: Ext.getCmp("round_fiscalyear").getValue() 
                        ,round: Ext.getCmp("round").getValue()
                        ,id: Ext.getCmp("id_config").getValue()
                    }
                });
                CenterGridStore.load({
                    params: {
                        fiscal_year: Ext.getCmp("round_fiscalyear").getValue() 
                        ,round: Ext.getCmp("round").getValue()
                        ,id: Ext.getCmp("id_config").getValue()
                    }
                });
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
// Panel west center
//-------------------------------------
var smWestCenterGrid = new Ext.grid.CheckboxSelectionModel({singleSelect: false})
var summary = new Ext.ux.grid.GridSummary();
var westCenterFields = [
    {name: "dno", type: "string"}
    ,{name: "e_name", type: "string"}
    ,{name: "e_begin", type: "string"}
    ,{name: "e_end", type: "string"}
    ,{name: "up", type: "string"}
    ,{name: "idx", type: "string"}
    ,{name: "salary", type: "int"}
    ,{name: "n", type: "int"}
];

var westCenterCols = [
    smWestCenterGrid
    ,{header: "ลำดับ",width: 40, sortable: false, dataIndex: 'dno',editor: {xtype: "numberfield"}}
    ,{header: "ชื่อ",width: 70, sortable: false, dataIndex: 'e_name',editor: {xtype: "textfield"}}
    ,{header: "ตั้งแต่",width: 50, sortable: false, dataIndex: 'e_begin',editor: {xtype: "numberfield"}}
    ,{header: "ถึง",width: 50, sortable: false, dataIndex: 'e_end',editor: {xtype: "numberfield"}}
    ,{header: "เลือน<br />ร้อยละ",width: 50, sortable: false, dataIndex: 'up',editor: {xtype: "numberfield"}}
    ,{header: "จำนวน <br />คน",width: 50, sortable: false, dataIndex: 'n'}
    ,{header: "จำนวน<br />เงิน",width: 50, sortable: false, dataIndex: 'salary'}
];
var westCenterGridStore = new Ext.data.JsonStore({
    url: pre_url + "/save_process/formula"
    ,root: "records"
    ,autoLoad: false
    ,fields: westCenterFields
    ,idProperty: 'idx'
});

var westCenterGrid = new Ext.grid.EditorGridPanel({
    region: 'center'
    ,disabled: true
    ,title: "สูตรบริหารวงเงิน"
    ,clicksToEdit: 1
    ,split: true
    ,store: westCenterGridStore
    ,columns: westCenterCols
    ,stripeRows: true
    ,loadMask: {msg:'Loading...'}
    ,trackMouseOver: false
    ,sm: smWestCenterGrid
    ,plugins: [summary]
    ,listeners: {
        afterrender: function(el){
                 el.doLayout();
        }
    }
    ,tbar: [
        {
            text: "สูตร 1"
            ,handler: function(){
                if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == "" || Ext.getCmp("id_config").getValue() == ""){
                    Ext.Msg.alert("คำเติอน","กรุณาเลือกข้อมูลให้ครบ");
                    return false;
                }                       
                westCenterGridStore.load({
                    params: {
                        formula: '1'    
                    }    
                })
            }
        }
        ,"-",{
            text: "สูตร 2"
            ,handler: function(){
                if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == "" || Ext.getCmp("id_config").getValue() == ""){
                    Ext.Msg.alert("คำเติอน","กรุณาเลือกข้อมูลให้ครบ");
                    return false;
                }                 
                westCenterGridStore.load({
                    params: {
                        formula: '2'    
                    }    
                })
            }
        }
        ,"-",{
            text: "สูตร 3"
            ,handler: function(){
                if (Ext.getCmp("round_fiscalyear").getValue() == "" || Ext.getCmp("round").getValue() == "" || Ext.getCmp("id_config").getValue() == ""){
                    Ext.Msg.alert("คำเติอน","กรุณาเลือกข้อมูลให้ครบ");
                    return false;
                }                 
                westCenterGridStore.load({
                    params: {
                        formula: '3'    
                    }    
                })
            }
        }
    ]
    ,bbar: [
        {
                text: "เพิ่ม"
                ,iconCls: "table-add"
                ,handler: function(){
                        var record_tmp = Ext.data.Record.create(westCenterFields);
                        var e = new record_tmp({
                            dno: ""
                            ,e_name: ""
                            ,e_begin: ""
                            ,e_end: ""
                            ,up: ""
                            ,idx: ""
                            ,salary: ""
                            ,n: ""
                        });
                        westCenterGridStore.data.insert(westCenterGridStore.getCount(), e);
                        e.join(westCenterGridStore);
                        westCenterGrid.getView().refresh();
                }
        },"-"
        ,{
                ref: '../insertBtn'
                ,text: "แทรก"
                ,disabled: true
                ,iconCls: "table-row-insert"
                ,handler: function(){
                        var record_tmp = Ext.data.Record.create(westCenterFields);
                        var e = new record_tmp({
                            dno: ""
                            ,e_name: ""
                            ,e_begin: ""
                            ,e_end: ""
                            ,up: ""
                            ,idx: ""
                            ,salary: ""
                            ,n: ""
                        });
                        westCenterGridStore.data.insert(westCenterGridStore.indexOf(westCenterGrid.getSelectionModel().getSelected()), e);
                        e.join(westCenterGridStore);
                        westCenterGrid.getView().refresh();
                }
        },"-"
        ,{
                ref: '../removeBtn'
                ,text: "ลบ"
                ,disabled: true
                ,iconCls: "table-delete"
                ,handler: function (){
                        westCenterGridStore.remove(smWestCenterGrid.getSelections());
                }
        }        
        
        
    ]
});

westCenterGrid.getSelectionModel().on('selectionchange', function(sm){
    westCenterGrid.removeBtn.setDisabled(sm.getCount() < 1);
    westCenterGrid.insertBtn.setDisabled(sm.getCount() < 1);
});

//-------------------------------------
// Panel center north
//-------------------------------------
var centerNorthsaveProcess = new Ext.Panel({
    region: "north"
    ,disabled: true
    ,height: 200
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
              ,align: "top"
              ,padding: 5
            }
            ,defaults:{margins:'0 5 0 0'}
            ,items: [
                {
                    width: 450
                    ,items: [
                        {
                            xtype: "fieldset"
                            ,title: "วงเงินที่ใช้เลื่อนเงินเดือน"
                            ,width: 450
                            ,items: [
                                new Ext.BoxComponent({
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
                ,{
                    width: 150
                    ,layout: "form"
                    ,defaults:{style:"padding-top: 10px"}
                    ,items: [
                        {
                            xtype: "button"
                            ,text: "นำเข้าคะแนน(*.xls)"
                            ,anchor: "95%"
                            ,handler: function(){
                                if (!form){
                                    var form = new Ext.FormPanel({
                                        fileUpload: true
                                        ,frame: true
                                        ,bodyStyle: 'padding: 10px 10px 0 10px;'
                                        ,labelWidth: 80
                                        ,monitorValid: true
                                        ,defaults: {
                                            anchor: '95%'
                                            ,allowBlank: false
                                            ,msgTarget: 'side'
                                        }
                                        ,items: [
                                            {
                                                xtype: 'fileuploadfield',
                                                id: 'form-file',
                                                fieldLabel: 'ไฟล์ (*.xls)',
                                                name: 'file',
                                                buttonText: '',
                                                buttonCfg: {
                                                    iconCls: 'upload-icon'
                                                }
                                            }
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
                                                        ,url: pre_url + "/save_process/upload"
                                                        ,success:function(form, action){
                                                            obj = Ext.util.JSON.decode(action.response.responseText);
                                                            Ext.Msg.alert("สถานะ","กำหนดคอลัมน์", function(btn, text){										
                                                                    if (btn == 'ok'){
                                                                        win.close();
                                                                        mapColumn(obj.column,obj.file)
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
                                }
                                if(!win){
                                   var win = new Ext.Window({
                                           title: 'นำเข้าคะแนน'
                                           ,width: 300
                                           ,height: 150
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
                        ,{
                            xtype: "button"
                            ,text: "คำนวณเงินเลื่อนเงินเดือน"
                            ,anchor: "95%"
                            ,handler: function(){
                                if (westCenterGridStore.getCount() == 0 || CenterGridStore.getCount() == 0){
                                    Ext.Msg.alert("คำเติอน","กรุณาทำรายการให้ครบถ้วน");
                                    return false;
                                }
                                loadMask.show();
                                Ext.Ajax.request({
                                    url: pre_url + "/save_process/process_cal"
                                    ,params: {
                                        fiscal_year: Ext.getCmp("round_fiscalyear").getValue() 
                                        ,round: Ext.getCmp("round").getValue()
                                        ,id: Ext.getCmp("id_config").getValue()
                                        ,data_user: readDataGrid(CenterGridStore.data.items)
                                        ,data_config: readDataGrid(westCenterGridStore.data.items)
                                    }
                                    ,success: function(response,opts){
                                        obj = Ext.util.JSON.decode(response.responseText);
                                        loadMask.hide();
                                        if(obj.success){
                                            westCenterGridStore.reload();
                                            CenterGridStore.reload();
                                            setTempSummary(Ext.getCmp("id_config").getValue(),Ext.getCmp("round_fiscalyear").getValue()+""+Ext.getCmp("round").getValue())
                                        }
                                        else{
                                            Ext.Msg.alert("คำเตือน","เกิดความผิดพลาดกรุณาลองใหม่อีกครั้ง");
                                        }
                                    }
                                    ,failure: function(response,opts){
                                        Ext.Msg.alert("สถานะ",response.statusText);
                                        loadMask.hide();
                                    }
                                });
                            }
                        }
                        ,{
                            xtype: "button"
                            ,text: "รายงานสรุปคะแนน-วงเงิน"
                            ,anchor: "95%"
                            ,handler: function(){
                                var form = document.createElement("form");
                                form.setAttribute("method", "post");
                                form.setAttribute("action", pre_url + "/save_process/report_limit?format=pdf");
                                form.setAttribute("target", "_blank");
                                var hiddenField1 = document.createElement("input");              
                                hiddenField1.setAttribute("name", "fiscal_year");
                                hiddenField1.setAttribute("value", Ext.getCmp("round_fiscalyear").getValue());
                                var hiddenField2 = document.createElement("input");              
                                hiddenField2.setAttribute("name", "round");
                                hiddenField2.setAttribute("value", Ext.getCmp("round").getValue());
                                var hiddenField3 = document.createElement("input");              
                                hiddenField3.setAttribute("name", "id");
                                hiddenField3.setAttribute("value", Ext.getCmp("id_config").getValue());
                                form.appendChild(hiddenField1);
                                form.appendChild(hiddenField2);
                                form.appendChild(hiddenField3);
                                document.body.appendChild(form);
                                form.submit();
                                document.body.removeChild(form);                                
                            }                            
                        }
                        ,{
                            xtype: "button"
                            ,text: "รายงานผลการประเมิน(Excel)"
                            ,anchor: "95%"
                            ,handler: function(){
                                var form = document.createElement("form");
                                form.setAttribute("method", "post");
                                form.setAttribute("action", pre_url + "/save_process/report_excel?format=xls");
                                form.setAttribute("target", "_blank");
                                var hiddenField1 = document.createElement("input");              
                                hiddenField1.setAttribute("name", "fiscal_year");
                                hiddenField1.setAttribute("value", Ext.getCmp("round_fiscalyear").getValue());
                                var hiddenField2 = document.createElement("input");              
                                hiddenField2.setAttribute("name", "round");
                                hiddenField2.setAttribute("value", Ext.getCmp("round").getValue());
                                var hiddenField3 = document.createElement("input");              
                                hiddenField3.setAttribute("name", "id");
                                hiddenField3.setAttribute("value", Ext.getCmp("id_config").getValue());
                                form.appendChild(hiddenField1);
                                form.appendChild(hiddenField2);
                                form.appendChild(hiddenField3);
                                document.body.appendChild(form);
                                form.submit();
                                document.body.removeChild(form);   
                                
                            }
                        }
                        ,{
                            xtype: "button"
                            ,text: "รายงานผลการประเมิน(PDF)"
                            ,anchor: "95%"
                            ,handler: function(){
                                var form = document.createElement("form");
                                form.setAttribute("method", "post");
                                form.setAttribute("action", pre_url + "/save_process/report?format=pdf");
                                form.setAttribute("target", "_blank");
                                var hiddenField1 = document.createElement("input");              
                                hiddenField1.setAttribute("name", "fiscal_year");
                                hiddenField1.setAttribute("value", Ext.getCmp("round_fiscalyear").getValue());
                                var hiddenField2 = document.createElement("input");              
                                hiddenField2.setAttribute("name", "round");
                                hiddenField2.setAttribute("value", Ext.getCmp("round").getValue());
                                var hiddenField3 = document.createElement("input");              
                                hiddenField3.setAttribute("name", "id");
                                hiddenField3.setAttribute("value", Ext.getCmp("id_config").getValue());
                                form.appendChild(hiddenField1);
                                form.appendChild(hiddenField2);
                                form.appendChild(hiddenField3);
                                document.body.appendChild(form);
                                form.submit();
                                document.body.removeChild(form);
                            }
                        }
                        
                    ]
                }
            ]
        }
    ]
});
//-------------------------------------
// Panel  center
//-------------------------------------
var filters_menu4 = new Ext.ux.grid.GridFilters({
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
var summary_center = new Ext.ux.grid.GridSummary();
var CenterFields = [
    {name: "posid", type: "string"}
    ,{name: "name", type: "string"}
    ,{name: "salary", type: "string"}
    ,{name: "midpoint", type: "string"}
    ,{name: "score", type: "string"}
    ,{name: "newsalary", type: "string"}
    ,{name: "addmoney", type: "string"}
    ,{name: "note1", type: "string"}
    ,{name: "idx", type: "int"}
    ,{name: "maxsalary", type: "string"}
    ,{name: "id", type: "string"}
    ,{name: "updname", type: "string"}
];

var CenterCols = [
    {
        header: "#"
        ,width: 60
        ,renderer: rowNumberer.createDelegate(this)
        ,sortable: false
    }
    ,{header: "ตำแหน่งเลขที่",width: 80, sortable: false, dataIndex: 'posid'}
    ,{header: "ชื่อ-นามสกุล",width: 150, sortable: false, dataIndex: 'name'}
    ,{header: "เงินเดือน",width: 80, sortable: false, dataIndex: 'salary'}
    ,{header: "ฐานในการคำนวน",width: 90, sortable: false, dataIndex: 'midpoint'}
    ,{header: "คะแนน",width: 60, sortable: false, dataIndex: 'score',editor: {xtype: "numberfield"}}
    ,{header: "เงินเดือน<br />ที่เลื่อน",width: 80, sortable: false, dataIndex: 'newsalary'}
    ,{header: "ค่าตอบแทน<br />พิเศษ",width: 80, sortable: false, dataIndex: 'addmoney'}
    ,{header: "หมายเหตุ",width: 100, sortable: false, dataIndex: 'note1',editor: {xtype: "textfield"}}
    ,{header: "รหัสการเลื่อน<br />ขั้นเงินเดือน", width: 100, sortable: false, dataIndex: "updname"}
];
var CenterGridStore = new Ext.data.JsonStore({
    url: pre_url + "/save_process/read"
    ,root: "records"
    ,autoLoad: false
    ,fields: CenterFields
    ,idProperty: 'idx'
});

var CenterGrid = new Ext.grid.EditorGridPanel({
    disabled: true
    ,clicksToEdit: 1
    ,split: true
    ,store: CenterGridStore
    ,columns: CenterCols
    ,stripeRows: true
    ,loadMask: {msg:'Loading...'}
    ,trackMouseOver: false
    ,sm: new Ext.grid.RowSelectionModel()
    ,plugins: [summary_center,filters_menu4]
    ,listeners: {
        afterrender: function(el){
                 el.doLayout();
        }
    }
});

//-------------------------------------
// Panel Main
//-------------------------------------
var saveProcessPanel = new Ext.Panel({
    title: "บันทึกผลการประเมินการปฏิบัติงาาน"
    ,layout: "border"
    ,items: [
        {
            region: "west"
            ,frame: true
            ,width: 400
            ,layout: "border"
            ,items: [
                westNorthsaveProcess
                ,westCenterGrid
            ]
        }
        ,{
            region: "center"
            ,frame: true
            ,layout: "border"
            ,items: [
                centerNorthsaveProcess
                ,{
                    region: "center"
                    ,layout: "fit"
                    ,items: [CenterGrid]
                }
            ]
        }    
    ]
    ,listeners: {
        afterrender: function(el){
            el.doLayout();
        }
    }
});

function resetPanel(){
        tpl = new Ext.Template(tmp_config_blank);
        tpl.overwrite(Ext.get("temp_detail"), "");
        westCenterGrid.disable();
        centerNorthsaveProcess.disable();
        CenterGrid.disable();
        westCenterGridStore.removeAll();
        CenterGridStore.removeAll();
}
function mapColumn(column,file){
    data = [];
    for(i=0;i<column.length;i++){
        data.push([i,column[i]]);
    }
    
    var config_column = new Ext.form.ComboBox({
        editable: false
        ,id: "config_column"										
        ,hiddenName: 'config_column'
        ,store: new Ext.data.SimpleStore({
                     fields: ['id', 'type']
                     ,data: data 
        })
        ,valueField:'id'
        ,displayField:'type'
        ,typeAhead: true
        ,mode: 'local'
        ,triggerAction: 'all'
        ,emptyText:'Select ...'
    });
    
    var mapColumnFields = [
        {name: "static", type: "string"}
        ,{name: "config", type: "string"}
        ,{name: "col_name", type: "string"}
    ];
    
    var mapColumnCols = [
        {header: "คอลัมน์หลัก",width: 180, sortable: false, dataIndex: 'static'}
        ,{header: "คอลัมน์ Excel",width: 180, sortable: false, dataIndex: 'config',editor: config_column,renderer: function(value){
            return column[value] ;   
        }}
    ];
    var mapColumnGridStore = new Ext.data.JsonStore({
        url: pre_url + "/save_process/map_column"
        ,root: "records"
        ,autoLoad: false
        ,fields: mapColumnFields
    });
    
    var mapColumnGrid = new Ext.grid.EditorGridPanel({
        clicksToEdit: 1
        ,id: "map_column_grid"
        ,split: true
        ,store: mapColumnGridStore
        ,columns: mapColumnCols
        ,stripeRows: true
        ,loadMask: {msg:'Loading...'}
        ,trackMouseOver: false
        ,sm: new Ext.grid.RowSelectionModel()
        ,listeners: {
            afterrender: function(el){
                     el.doLayout();
            }
        }
    });    
    
    if(!win){
       var win = new Ext.Window({
            title: 'กำหนดคอลัมน์'
            ,width: 400
            ,height: 400
            ,closable: true
            ,resizable: false
            ,plain: true
            ,border: false
            ,draggable: true 
            ,modal: true
            ,layout: "fit"
            ,items: [mapColumnGrid]
            ,tbar: [
                {
                    text: "ยันยัน"
                    ,iconCls: "disk"
                    ,handler: function(){
                        check = false;
                        dataStore = Ext.getCmp("map_column_grid").getStore().data.items;
                        for(i=0;i<dataStore.length;i++){
                            if(dataStore[i].data.config === ""){
                                check = true;
                            }
                        }
                        if (check){
                            Ext.Msg.alert("คำเตือน","กรุณาเลือกข้อมูลให้ครบ");
                            return true;
                        }
                        CenterGridStore.load({
                            params: {
                                fiscal_year: Ext.getCmp("round_fiscalyear").getValue() 
                                ,round: Ext.getCmp("round").getValue()
                                ,id: Ext.getCmp("id_config").getValue()
                                ,file: file
                                ,map_column: readDataGrid(dataStore)
                            }
                        });
                        delete(CenterGridStore.baseParams["file"]);
                        delete(CenterGridStore.baseParams["map_column"]);
                        if (CenterGridStore.lastOptions && CenterGridStore.lastOptions.params) {
                            delete(CenterGridStore.lastOptions.params["map_column"]);
                            delete(CenterGridStore.lastOptions.params["file"]);
                        }
                        win.close();
                    }
                }
            ]
       });
    }
    win.show();
    win.center();
    mapColumnGridStore.load();
}

function setTempSummary(id,y){
    loadMask.show();
    Ext.Ajax.request({
        url: pre_url + "/config_personel/get_config"
        ,params: {
            id: id
            ,year: y
        }
        ,success: function(response,opts){
            obj = Ext.util.JSON.decode(response.responseText);
            loadMask.hide();
            if(obj.success){
                tpl = new Ext.Template(
                    "<table style='font:12px tahoma,arial,helvetica,sans-serif;width:420px;' >" +
                        "<tr ><td style='padding-bottom:4px' align='right' height='20px;' width='140px'>เงินเดือน:</td><td align='right' width='120px'><b>{salary}</b></td>"+
                        "<td width='100px' style='padding-left:20px;' align='right'>วงเงินที่ใช้เลื่อน:</td><td width='80px' align='right'><b>{pay}</b></td>" +
                        "</tr>" +
                        "<tr ><td style='padding-bottom:4px' align='right' height='20px;'>ร้อยละ:</td><td align='right'><b>{calpercent}</b></td>"+
                        "<td style='padding-left:20px;' align='right'>เหลือ / เกิน:</td><td align='right'><b >{diff}</b></td>" +
                        "</tr>" +
                        "<tr ><td style='padding-bottom:4px' align='right' height='20px;'>จำนวนเงินที่ใช้เลื่อนขั้น:</td><td align='right'><b>{ks24}</b></td></tr>" +
                        "<tr ><td style='padding-bottom:4px' align='right' height='20px;'>ผู้บริหารวงเงิน:</td><td align='right'><b>{admin_show}</b></td></tr>" +
                        "<tr ><td style='padding-bottom:4px' align='right' height='20px;'>ผู้ประเมิน:</td><td align='right'><b>{eval_show}</b></td></tr>" +
                    "</table>"
                );
                tpl.overwrite(Ext.get("temp_detail"), obj.data);
                westCenterGrid.enable();
                centerNorthsaveProcess.enable();
                CenterGrid.enable();
            }
        }
        ,failure: function(response,opts){
            Ext.Msg.alert("สถานะ",response.statusText);
            loadMask.hide();
        }
    });    
}