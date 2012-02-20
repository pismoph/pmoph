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
                loadMask.show();
                Ext.Ajax.request({
                    url: "/config_personel/get_config"
                    ,params: {
                        id: record.data.id
                        ,year: record.data.year
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
var summary = new Ext.ux.grid.GridSummary();
var westCenterFields = [
    {name: "dno", type: "string"}
    ,{name: "e_name", type: "string"}
    ,{name: "e_begin", type: "string"}
    ,{name: "e_end", type: "string"}
    ,{name: "up", type: "string"}
    ,{name: "idx", type: "string"}
];

var westCenterCols = [
    {header: "ลำดับ",width: 50, sortable: false, dataIndex: 'dno'}
    ,{header: "ชื่อ",width: 120, sortable: false, dataIndex: 'e_name'}
    ,{header: "ตั้งแต่",width: 60, sortable: false, dataIndex: 'e_begin'}
    ,{header: "ถึง",width: 60, sortable: false, dataIndex: 'e_end'}
    ,{header: "เลือน<br />ร้อยละ",width: 60, sortable: false, dataIndex: 'up'}
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
    ,sm: new Ext.grid.RowSelectionModel()
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
                
                
                Col = new Ext.grid.ColumnModel([
                    {header: "ลำดับ",width: 50, sortable: false, dataIndex: 'dno',editor: {xtype: "numberfield"}}
                    ,{header: "ชื่อ",width: 120, sortable: false, dataIndex: 'e_name',editor: {xtype: "textfield"}}
                    ,{header: "ตั้งแต่",width: 60, sortable: false, dataIndex: 'e_begin',editor: {xtype: "numberfield"}}
                    ,{header: "ถึง",width: 60, sortable: false, dataIndex: 'e_end',editor: {xtype: "numberfield"}}
                    ,{header: "เลือน<br />ร้อยละ",width: 60, sortable: false, dataIndex: 'up',editor: {xtype: "numberfield"}}
                ]);								
                                                                                                                                                                                
                westCenterGrid.reconfigure(westCenterGridStore, Col);
                                        
                                        
                                        
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
});



//-------------------------------------
// Panel center north
//-------------------------------------
var centerNorthsaveProcess = new Ext.Panel({
    region: "north"
    ,disabled: true
    ,height: 180
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
                            ,text: "นำเข้าคะแนน(*.txt)"
                            ,anchor: "95%"
                        }
                        ,{
                            xtype: "button"
                            ,text: "คำนวณเงินเลื่อนเงินเดือน"
                            ,anchor: "95%"
                        }
                        ,{
                            xtype: "button"
                            ,text: "รายงานสรุปคะแนน-วงเงิน"
                            ,anchor: "95%"
                        }
                        ,{
                            xtype: "button"
                            ,text: "รายงานผลการประเมิน(Excel)"
                            ,anchor: "95%"
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
var summary_center = new Ext.ux.grid.GridSummary();
var CenterFields = [
    {name: "dno", type: "string"}
    ,{name: "e_name", type: "string"}
    ,{name: "e_begin", type: "string"}
    ,{name: "e_end", type: "string"}
    ,{name: "up", type: "string"}
    ,{name: "idx", type: "string"}
];

var CenterCols = [
    {
        header: "#"
        ,width: 60
        ,renderer: rowNumberer.createDelegate(this)
        ,sortable: false
    }
    ,{header: "ตำแหน่งเลขที่",width: 120, sortable: false, dataIndex: 'posid'}
    ,{header: "ชื่อ-นามสกุล",width: 120, sortable: false, dataIndex: 'name'}
    ,{header: "เงินเดือน",width: 120, sortable: false, dataIndex: 'salary'}
    ,{header: "ฐานในการคำนวน",width: 120, sortable: false, dataIndex: 'midpoint'}
    ,{header: "คะแนน",width: 120, sortable: false, dataIndex: 'score'}
    ,{header: "เงินเดือนที่เลื่อน",width: 120, sortable: false, dataIndex: 'newsalary'}
    ,{header: "เงินเพิ่มพิเศษ",width: 120, sortable: false, dataIndex: 'addmoney'}
    ,{header: "หมายเหตุ",width: 120, sortable: false, dataIndex: 'note1'}
];
var CenterGridStore = new Ext.data.JsonStore({
    url: pre_url + "/save_process/formula"
    ,root: "records"
    ,autoLoad: false
    ,fields: CenterFields
    ,idProperty: 'idx'
});

var CenterGrid = new Ext.grid.EditorGridPanel({
    disabled: true
    ,title: "สูตรบริหารวงเงิน"
    ,clicksToEdit: 1
    ,split: true
    ,store: CenterGridStore
    ,columns: CenterCols
    ,stripeRows: true
    ,loadMask: {msg:'Loading...'}
    ,trackMouseOver: false
    ,sm: new Ext.grid.RowSelectionModel()
    ,plugins: [summary_center]
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