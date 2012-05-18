//-------------------------------------
// Panel west north
//-------------------------------------
var processInsigNorth = new Ext.Panel({
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
                            ,width: 600
                            ,layout: "form"
                            ,labelWidth: 360
                            ,labelAlign: "right"
                            ,items: [
                                {
                                    xtype: "compositefield"
                                    ,fieldLabel: "ผู้มีคุณสมบัติครบที่จะได้รับเครื่องราชอิสริยาภรณ์ ในวันที่ 5 ธันวาคม พ.ศ. "
                                    ,items: [
                                        {
                                            xtype: "numberfield"
                                            ,id: "round_year"
                                            ,width: 80
                                            ,enableKeyEvents: true
                                            ,listeners: {
                                                keyup: function(el, e ){
                                                    processInsigGridStore.removeAll();
                                                    processInsig.disable();
                                                }
                                            }
                                        },{
                                            xtype: "button"
                                            ,text: "ดูข้อมูล"
                                            ,width: 80
                                            ,handler: function(){
                                                year = Ext.getCmp("round_year").getValue().toString();
                                                if(year.trim == "" || Number(year) < 543 ){
                                                    Ext.Msg.alert("คำเตือน","กรุณทำรายการให้ครบและถูกต้อง");
                                                    return false;
                                                }
                                                processInsigGridStore.baseParams = {
                                                    year: year
                                                };
                                                processInsigGridStore.load();
                                                processInsigGrid.enable();
                                            }
                                        }
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
            Ext.getCmp("round_year").setValue(fiscalYear(new Date()) + 543 );
        }
    }
});

//-------------------------------------
// Panel  center
//-------------------------------------
var smProcessInsig = new Ext.grid.CheckboxSelectionModel({singleSelect: false})
var processInsigFields = [
    {name: "posid", type: "string"}
    ,{name: "prefix", type: "string"}
    ,{name: "fname", type: "string"}
    ,{name: "lname", type: "string"}
    ,{name: "sex", type: "string"}
    ,{name: "id", type: "string"}
];
var processInsigCols = [
    smProcessInsig
    ,{
        header: "#"
        ,width: 60
        ,renderer: rowNumberer.createDelegate(this)
        ,sortable: false
    }
    ,{header: "ตำแหน่งเลขที่",width: 80, sortable: false, dataIndex: 'posid'}
    ,{header: "คำนำหน้า",width: 80, sortable: false, dataIndex: 'prefix'}
    ,{header: "ชื่อ",width: 120, sortable: false, dataIndex: 'fname'}
    ,{header: "นามสกุล",width: 120, sortable: false, dataIndex: 'lname'}
    ,{header: "เพศ",width: 80, sortable: false, dataIndex: 'sex'}
];
var processInsigGridStore = new Ext.data.JsonStore({
    url: pre_url + "/process_insig/read"
    ,root: "records"
    ,autoLoad: false
    ,fields: processInsigFields
    ,idProperty: 'id'
});
var processInsigGrid = new Ext.grid.EditorGridPanel({
    region: "center"
    ,clicksToEdit: 1
    ,split: true
    ,store: processInsigGridStore
    ,columns: processInsigCols
    ,stripeRows: true
    ,disabled: true
    ,loadMask: {msg:'Loading...'}
    ,trackMouseOver: false
    ,sm: smProcessInsig
    ,listeners: {
        afterrender: function(el){
                 el.doLayout();
        }
    }
    ,tbar: [
        {
            text: "ประมวลผล"
            ,iconCls: "award_star_add"
            ,handler: function(){
                loadMask.show();
                Ext.Ajax.request({
                    url: pre_url + "/process_insig/check_count"
                    ,params: {
                        year: Ext.getCmp("round_year").getValue()
                    }
                    ,success: function(response,opts){
                        loadMask.hide();
                        obj = Ext.util.JSON.decode(response.responseText);
                        if (obj.success){
                            if (obj.count > 0){
                                Ext.Msg.confirm('สถานะ', 'มีการประมวลผลแล้วต้องการทำรายการต่อหรือไม่', function(btn, text){			
				    if (btn == 'yes'){
                                        ProcessInsig(Ext.getCmp("round_year").getValue());  
                                    }
                                });
                            }
                            else{
                                ProcessInsig(Ext.getCmp("round_year").getValue());
                            }
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
            text: "เพิ่มข้อมูล"
            ,iconCls: "table-add"
            ,handler: function(){
                ProcessInsigPersonelNow();
            }
        }
        ,"-",{
            ref: '../removeBtn'
            ,text: "ลบข้อมูล"
            ,iconCls: "table-delete"
            ,disabled: true
            ,handler: function(){
                loadMask.show();
                data = processInsigGrid.getSelectionModel().getSelections();
                id = [];
                for(i=0;i<data.length;i++){
                    id.push(data[i].id)
                }
                Ext.Ajax.request({
                    url: pre_url + "/process_insig/delete"
                    ,params: {
                        id: "'"+id.join("','")+"'"
                        ,year: Ext.getCmp("round_year").getValue()
                    }
                    ,success: function(response,opts){
                        loadMask.hide();
                        obj = Ext.util.JSON.decode(response.responseText);
                        if (obj.success){
                            processInsigGridStore.reload();
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
            text: "พิมพ์บัญชี"
            ,menu: {
                items: [
                    {
                        text: "คุณสมบัติชั้นต่ำกว่าสายสะพาย"
                        ,handler: function(){
                            var form = document.createElement("form");
                            form.setAttribute("method", "post");
                            form.setAttribute("action", pre_url + "/process_insig/report_down?format=pdf");
                            form.setAttribute("target", "_blank");
                            var hiddenField1 = document.createElement("input");              
                            hiddenField1.setAttribute("name", "year");
                            hiddenField1.setAttribute("value", Ext.getCmp("round_year").getValue());
                            form.appendChild(hiddenField1);
                            document.body.appendChild(form);
                            form.submit();
                            document.body.removeChild(form);
                        }
                    }
                    ,{    
                        text: "คุณสมบัติชั้นสายสะพาย"
                        ,handler: function(){
                            var form = document.createElement("form");
                            form.setAttribute("method", "post");
                            form.setAttribute("action", pre_url + "/process_insig/report_up?format=pdf");
                            form.setAttribute("target", "_blank");
                            var hiddenField1 = document.createElement("input");              
                            hiddenField1.setAttribute("name", "year");
                            hiddenField1.setAttribute("value", Ext.getCmp("round_year").getValue());
                            form.appendChild(hiddenField1);
                            document.body.appendChild(form);
                            form.submit();
                            document.body.removeChild(form);
                        }
                        
                    }
                ]
            }
        }
        ,"-",{
            text: "ลงราชกิจานุเบกษา"
            ,handler: function(){
                if(!form){
                    var form = new Ext.FormPanel({ 
                        labelWidth: 100
                        ,autoScroll: true
                        ,url: pre_url + '/process_insig/approved'
                        ,frame: true
                        ,monitorValid: true
                        ,bodyStyle: "padding:10px"
                        ,items: [
                            {
                                xtype: "fieldset"
                                ,layout: "form"
                                ,title: "ลงราชกิจานุเบกษา"
                                ,labelWidth: 135
                                ,labelAlign: "right"
                                ,items: [
                                    {
                                        xtype: "textfield"
                                        ,fieldLabel: "ในวันที่ 5 ธันวาควม พ.ศ."
                                        ,id: "t_dgdcdcr[dcyear]"
                                        ,value: Ext.getCmp("round_year").getValue()
                                        ,allowBlank: false
                                    }
                                    ,{
                                        xtype: "textfield"
                                        ,fieldLabel: "เล่มที่"
                                        ,id: "t_dgdcdcr[book]"
                                        ,allowBlank: false
                                    }
                                    ,{
                                        xtype: "textfield"
                                        ,fieldLabel: "ตอนที่"
                                        ,id: "t_dgdcdcr[section]"
                                        ,allowBlank: false
                                    }
                                    ,{
                                        xtype: "datefield"
                                        ,fieldLabel: "วันที่ลงราชกิจานุเบกษา"
                                        ,format: "d/m/Y"
                                        ,id: "t_dgdcdcr[kitjadate]"
                                        ,allowBlank: false
                                    }
                                ]
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
                                        ,success:function(){		
                                            Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                if (btn == 'ok')
                                                {
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
                                                        Ext.Msg.alert('สถานะ', 'Authentication server is unreachable: ' + action.response.responseText); 
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
                        title: 'ลงราชกิจานุเบกษา'
                        ,width: 400
                        ,height: 250
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
});
processInsigGrid.getSelectionModel().on('selectionchange', function(sm){
    processInsigGrid.removeBtn.setDisabled(smProcessInsig.getCount() < 1);
});
processInsigGrid.on('rowdblclick', function(grid, rowIndex, e ) {
    data_select = grid.getSelectionModel().getSelected().data;
    GetEditProcessInsig(data_select.id)
});
function ProcessInsig(year){
    year = Ext.getCmp("round_year").getValue().toString();
    if(year.trim == "" || Number(year) < 543 ){
        Ext.Msg.alert("คำเตือน","กรุณทำรายการให้ครบและถูกต้อง");
        return false;
    }
    loadMask.show();
    Ext.Ajax.request({
        url: pre_url + "/process_insig/process_insig"
        ,params: {
            year: year
        }
        ,success: function(response,opts){
            loadMask.hide();
            obj = Ext.util.JSON.decode(response.responseText);
            if (obj.success){
                processInsigGridStore.baseParams = {
                    year: Ext.getCmp("round_year").getValue()
                }
                processInsigGridStore.load();
                
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
function ProcessInsigPersonelNow(){
    personelNowSearch = new Ext.ux.grid.Search({
             iconCls: 'search'
             ,minChars: 3
             ,autoFocus: true
             ,position: "top"
             ,width: 200
    });
    personelNowFields = [
             ,{name: "prefix", type: "string"}
             ,{name: "fname", type: "string"}
             ,{name: "lname", type: "string"}
             ,{name: "posid", type: "string"}
             ,{name: "id", type: "string"}
    ];
    personelNowCols = [
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
    personelNowGridStore = new Ext.data.JsonStore({
            url: pre_url + "/info_personal/read"
            ,root: "records"
            ,autoLoad: false
            ,totalProperty: 'totalCount'
            ,fields: personelNowFields
            ,idProperty: 'id'
    });
    personelNowGrid = new Ext.grid.GridPanel({
            split: true
            ,store: personelNowGridStore
            ,columns: personelNowCols
            ,stripeRows: true
            ,loadMask: {msg:'Loading...'}
            ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
            ,plugins: [personelNowSearch]
            ,bbar: new Ext.PagingToolbar({
                      pageSize: 20
                      ,autoWidth: true
                      ,store: personelNowGridStore
                      ,displayInfo: true
                      ,displayMsg	: 'Displaying {0} - {1} of {2}'
                      ,emptyMsg: "Not found"
            })
            ,tbar: []
    });
    personelNowGrid.on('rowdblclick', function(grid, rowIndex, e ) {
        data_select = grid.getSelectionModel().getSelected().data;
        GetProcessInsig(data_select.id)
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
            ,items: [personelNowGrid]
            });
    }
    win.show();	
    win.center();
    personelNowGridStore.load({params:{start: 0,limit: 20}});
}
function GetProcessInsig(id){
    loadMask.show();
    Ext.Ajax.request({
        url: pre_url + "/process_insig/get_process_insig"
        ,params: {
            id: id
        }
        ,success: function(response,opts){
            loadMask.hide();
            obj = Ext.util.JSON.decode(response.responseText);
            if (obj.success){
                AddProcessInsig(obj.records[0]);
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
function AddProcessInsig(data){
    loadMask.show();
    if(!form){
        var form = new Ext.FormPanel({ 
            labelWidth: 100
            ,autoScroll: true
            ,url: pre_url + '/process_insig/create'
            ,frame: true
            ,monitorValid: true
            ,bodyStyle: "padding:10px"
            ,items:[
                    {
                            xtype: "hidden"
                            ,id: "t_dgdcdcr[id]"
                            ,value: data.id
                    }
                    ,{
                            xtype: "hidden"
                            ,id: "t_dgdcdcr[dcyear]"
                            ,value: Ext.getCmp("round_year").getValue()
                    }
                    ,{
                        xtype: "textfield"
                        ,id: "posid"
                        ,value: data.posid
                        ,fieldLabel: "เลขที่ตำแหน่ง"
                        ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
                        ,readOnly: true
                        ,width: 150
                    }
                    ,{
                            xtype: "textfield"
                            ,value: data.name
                            ,fieldLabel: "ชื่อ-นามสกุล"
                            ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
                            ,readOnly: true
                            ,width: 150
                    }
                    ,new Ext.ux.form.PisComboBox({//ชั้นเครื่องราชย์
                            fieldLabel: 'ชั้นเครื่องราชย์'
                            ,hiddenName: 't_dgdcdcr[dccode]'
                            ,id: 't_dgdcdcr[dccode]'
                            ,valueField: 'dccode'
                            ,displayField: 'dcname'
                            ,urlStore: pre_url + '/code/cdecoratype'
                            ,fieldStore: ['dccode', 'dcname']
                            ,anchor: "90%"
                            ,allowBlank: false
                    })
                    ,new Ext.ux.form.PisComboBox({//ตำแหน่งสายงาน
                             fieldLabel: "ตำแหน่งสายงาน"
                             ,hiddenName: 't_dgdcdcr[poscode]'
                             ,id: 't_dgdcdcr[poscode]'
                             ,valueField: 'poscode'
                             ,displayField: 'posname'
                             ,urlStore: pre_url + '/code/cposition'
                             ,fieldStore: ['poscode', 'posname']
                             ,anchor: "90%"
                    })
                    ,new Ext.ux.form.PisComboBox({//ระดับ
                             fieldLabel: "ระดับ"
                             ,hiddenName: 't_dgdcdcr[c]'
                             ,id: 't_dgdcdcr[c]'
                             ,valueField: 'ccode'
                             ,displayField: 'cname'
                             ,urlStore: pre_url + '/code/cgrouplevel'
                             ,fieldStore: ['ccode', 'cname']
                             ,anchor: "90%"
                    })
                    ,new Ext.ux.form.PisComboBox({//ตำแหน่งบริหาร
                            fieldLabel: "ตำแหน่งบริหาร"
                            ,hiddenName: 't_dgdcdcr[excode]'
                            ,id: 't_dgdcdcr[excode]'
                            ,valueField: 'excode'
                            ,displayField: 'exname'
                            ,urlStore: pre_url + '/code/cexecutive'
                            ,fieldStore: ['excode', 'exname']
                            ,anchor: "90%"
                    })
                    ,new Ext.ux.form.PisComboBox({//ว./ว.ช/ชช.
                            fieldLabel: "ว./ว.ช/ชช."
                            ,hiddenName: 't_dgdcdcr[ptcode]'
                            ,id: 't_dgdcdcr[ptcode]'
                            ,valueField: 'ptcode'
                            ,displayField: 'ptname'
                            ,urlStore: pre_url + '/code/cpostype'
                            ,fieldStore: ['ptcode', 'ptname']
                            ,anchor: "90%"
                    })
                    ,new Ext.ux.form.PisComboBox({//ความเชี่ยวชาญ
                            fieldLabel: "ความเชี่ยวชาญ"
                            ,hiddenName: 't_dgdcdcr[epcode]'
                            ,id: 't_dgdcdcr[epcode]'
                            ,valueField: 'epcode'
                            ,displayField: 'expert'
                            ,urlStore: pre_url + '/code/cexpert'
                            ,fieldStore: ['epcode', 'expert']
                            ,anchor: "90%"
                    })
                    ,{
                        xtype: "numberfield"
                        ,id: "t_dgdcdcr[salary]"
                        ,fieldLabel: "เงินเดือน"
                        ,width: 150
                        ,value: data.salary
                    }
                    ,{
                        layout: "column"
                        ,items: [
                            {
                                layout: "form"
                                ,items: [
                                    {
                                        xtype: "datefield"
                                        ,id: "t_dgdcdcr[entrydate]"
                                        ,fieldLabel: "วันที่บรรจุ"
                                        ,format: "d/m/Y"
                                        ,value: to_date_app(data.entrydate)
                                        ,enableKeyEvents: true
                                        ,listeners: {
                                            select: function(field,el ){
                                                SetAgeProcessInsig(field,Ext.getCmp("entrytime"));										
                                            }
                                            ,specialkey: function(field, el){
                                                if (el.getKey() == Ext.EventObject.ENTER || el.getKey() == Ext.EventObject.TAB){
                                                    SetAgeProcessInsig(field,Ext.getCmp("entrytime"));
                                                }
                                            }
                                        }
                                    }
                                    ,{
                                        xtype: "datefield"
                                        ,id: "t_dgdcdcr[leveldate]"
                                        ,fieldLabel: "วันที่เข้าสู่ระดับ"
                                        ,format: "d/m/Y"
                                        ,value: to_date_app(data.leveldate)
                                        ,enableKeyEvents: true
                                        ,listeners: {
                                            select: function(field,el ){
                                                SetAgeProcessInsig(field,Ext.getCmp("leveltime"));										
                                            }
                                            ,specialkey: function(field, el){
                                                if (el.getKey() == Ext.EventObject.ENTER || el.getKey() == Ext.EventObject.TAB){
                                                    SetAgeProcessInsig(field,Ext.getCmp("leveltime"));
                                                }
                                            }
                                        }
                                    }
                                ]
                            }
                            ,{
                                layout: "form"
                                ,style: "padding-left:10px"
                                ,labelWidth: 60
                                ,items: [
                                    {
                                        xtype: "textfield"
                                        ,id: "entrytime"
                                        ,readOnly: true
                                        ,fieldLabel: "ระยะเวลา"
                                        ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
                                    }
                                    ,{
                                        xtype: "textfield"
                                        ,id: "leveltime"
                                        ,readOnly: true
                                        ,fieldLabel: "ระยะเวลา"
                                        ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
                                    }
                                ]
                            }
                        ]
                    }
                    ,{
                        xtype: "textfield"
                        ,id: "t_dgdcdcr[note1]"
                        ,fieldLabel: "หมายเหตุ1"
                        ,anchor: "90%"
                    }
                    ,{
                        xtype: "textfield"
                        ,id: "t_dgdcdcr[note2]"
                        ,fieldLabel: "หมายเหตุ2"
                        ,anchor: "90%"
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
                            ,success:function(){		
                                Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                    if (btn == 'ok')
                                    {
                                        processInsigGridStore.reload();
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
                                            Ext.Msg.alert('สถานะ', 'Authentication server is unreachable: ' + action.response.responseText); 
                                    } 
                            } 
                        }); 
                    } 
                },{
                    text: "ยกเลิก"
                    ,handler: function	(){
                        win.close();
                    }
                }
            ] 
        });
    }//end if form
    if(!win){
        var win = new Ext.Window({
            title: 'เพิ่ม/แก้ไข ประวัติเครื่องราชย์'
            ,width: 600
            ,height: 500
            ,closable: true
            ,resizable: false
            ,plain: true
            ,border: false
            ,draggable: true 
            ,modal: true
            ,layout: "fit"
            ,maximizable: true
            ,items: [form]
        });
    }
    SetAgeProcessInsig(Ext.getCmp("t_dgdcdcr[entrydate]"),Ext.getCmp("entrytime"));
    SetAgeProcessInsig(Ext.getCmp("t_dgdcdcr[leveldate]"),Ext.getCmp("leveltime"));
    Ext.getCmp("t_dgdcdcr[epcode]").getStore().load({
        params: {
            epcode: data.epcode
            ,start: 0
            ,limit: 10
        }
        ,callback :function(){
            Ext.getCmp("t_dgdcdcr[epcode]").setValue(data.epcode);
        }
    });
    Ext.getCmp("t_dgdcdcr[ptcode]").getStore().load({
        params: {
            ptcode: data.ptcode
            ,start: 0
            ,limit: 10
        }
        ,callback :function(){
            Ext.getCmp("t_dgdcdcr[ptcode]").setValue(data.ptcode);
        }
    });
    Ext.getCmp("t_dgdcdcr[excode]").getStore().load({
        params: {
            excode: data.excode
            ,start: 0
            ,limit: 10
        }
        ,callback :function(){
            Ext.getCmp("t_dgdcdcr[excode]").setValue(data.excode);
        }
    });
    Ext.getCmp("t_dgdcdcr[c]").getStore().load({
        params: {
            ccode: data.c
            ,start: 0
            ,limit: 10
        }
        ,callback :function(){
            Ext.getCmp("t_dgdcdcr[c]").setValue(data.c);
        }
    });
    Ext.getCmp("t_dgdcdcr[poscode]").getStore().load({
        params: {
            poscode: data.poscode
            ,start: 0
            ,limit: 10
        }
        ,callback :function(){
            Ext.getCmp("t_dgdcdcr[poscode]").setValue(data.poscode);
            win.show();
            win.center();
            loadMask.hide();
        }
    });
    /*Ext.getCmp("t_dgdcdcr[dccode]").getStore().load({
        params: {
            dccode: data.dccode
            ,start: 0
            ,limit: 10
        }
        ,callback :function(){
            Ext.getCmp("t_dgdcdcr[dccode]").setValue(data.dccode);
            win.show();
            win.center();
            loadMask.hide();
        }
    });*/    
}
function SetAgeProcessInsig(source,destination){
    if (source.getRawValue().trim() == "" || !source.validate()){
        destination.setValue("");
        return false;
    }
    year = Number(Ext.getCmp("round_year").getValue())-543;
    date_max = new Date(year,9,5);
    date_min = source.getValue();
    age = dateDiff(date_max, date_min);
    year = (age[0] == 0)? "" : age[0]+" ปี";
    month = (age[1] == 0)? "" : age[1]+" เดือน";
    day = (age[2] == 0)? "" : age[2]+" วัน";
    age = year+" "+month+" "+day;
    age = age.trim();
    destination.setValue(age);
}
function GetEditProcessInsig(id){
    loadMask.show();
    Ext.Ajax.request({
        url: pre_url + "/process_insig/get_edit_process_insig"
        ,params: {
            id: id
            ,year: Ext.getCmp("round_year").getValue()
        }
        ,success: function(response,opts){
            loadMask.hide();
            obj = Ext.util.JSON.decode(response.responseText);
            if (obj.success){
                EditProcessInsig(obj.records[0]);
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
function EditProcessInsig(data){
    loadMask.show();
    if(!form){
        var form = new Ext.FormPanel({ 
            labelWidth: 100
            ,autoScroll: true
            ,url: pre_url + '/process_insig/update'
            ,frame: true
            ,monitorValid: true
            ,bodyStyle: "padding:10px"
            ,items:[
                    {
                            xtype: "hidden"
                            ,id: "t_dgdcdcr[id]"
                            ,value: data.id
                    }
                    ,{
                            xtype: "hidden"
                            ,id: "t_dgdcdcr[dcyear]"
                            ,value: Ext.getCmp("round_year").getValue()
                    }
                    ,{
                        xtype: "textfield"
                        ,id: "posid"
                        ,value: data.posid
                        ,fieldLabel: "เลขที่ตำแหน่ง"
                        ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
                        ,readOnly: true
                        ,width: 150
                    }
                    ,{
                            xtype: "textfield"
                            ,value: data.name
                            ,fieldLabel: "ชื่อ-นามสกุล"
                            ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
                            ,readOnly: true
                            ,width: 150
                    }
                    ,new Ext.ux.form.PisComboBox({//ชั้นเครื่องราชย์
                            fieldLabel: 'ชั้นเครื่องราชย์'
                            ,hiddenName: 't_dgdcdcr[dccode]'
                            ,id: 't_dgdcdcr[dccode]'
                            ,valueField: 'dccode'
                            ,displayField: 'dcname'
                            ,urlStore: pre_url + '/code/cdecoratype'
                            ,fieldStore: ['dccode', 'dcname']
                            ,anchor: "90%"
                            ,allowBlank: false
                    })
                    ,new Ext.ux.form.PisComboBox({//ตำแหน่งสายงาน
                             fieldLabel: "ตำแหน่งสายงาน"
                             ,hiddenName: 't_dgdcdcr[poscode]'
                             ,id: 't_dgdcdcr[poscode]'
                             ,valueField: 'poscode'
                             ,displayField: 'posname'
                             ,urlStore: pre_url + '/code/cposition'
                             ,fieldStore: ['poscode', 'posname']
                             ,anchor: "90%"
                    })
                    ,new Ext.ux.form.PisComboBox({//ระดับ
                             fieldLabel: "ระดับ"
                             ,hiddenName: 't_dgdcdcr[c]'
                             ,id: 't_dgdcdcr[c]'
                             ,valueField: 'ccode'
                             ,displayField: 'cname'
                             ,urlStore: pre_url + '/code/cgrouplevel'
                             ,fieldStore: ['ccode', 'cname']
                             ,anchor: "90%"
                    })
                    ,new Ext.ux.form.PisComboBox({//ตำแหน่งบริหาร
                            fieldLabel: "ตำแหน่งบริหาร"
                            ,hiddenName: 't_dgdcdcr[excode]'
                            ,id: 't_dgdcdcr[excode]'
                            ,valueField: 'excode'
                            ,displayField: 'exname'
                            ,urlStore: pre_url + '/code/cexecutive'
                            ,fieldStore: ['excode', 'exname']
                            ,anchor: "90%"
                    })
                    ,new Ext.ux.form.PisComboBox({//ว./ว.ช/ชช.
                            fieldLabel: "ว./ว.ช/ชช."
                            ,hiddenName: 't_dgdcdcr[ptcode]'
                            ,id: 't_dgdcdcr[ptcode]'
                            ,valueField: 'ptcode'
                            ,displayField: 'ptname'
                            ,urlStore: pre_url + '/code/cpostype'
                            ,fieldStore: ['ptcode', 'ptname']
                            ,anchor: "90%"
                    })
                    ,new Ext.ux.form.PisComboBox({//ความเชี่ยวชาญ
                            fieldLabel: "ความเชี่ยวชาญ"
                            ,hiddenName: 't_dgdcdcr[epcode]'
                            ,id: 't_dgdcdcr[epcode]'
                            ,valueField: 'epcode'
                            ,displayField: 'expert'
                            ,urlStore: pre_url + '/code/cexpert'
                            ,fieldStore: ['epcode', 'expert']
                            ,anchor: "90%"
                    })
                    ,{
                        xtype: "numberfield"
                        ,id: "t_dgdcdcr[salary]"
                        ,fieldLabel: "เงินเดือน"
                        ,width: 150
                        ,value: data.salary
                    }
                    ,{
                        layout: "column"
                        ,items: [
                            {
                                layout: "form"
                                ,items: [
                                    {
                                        xtype: "datefield"
                                        ,id: "t_dgdcdcr[entrydate]"
                                        ,fieldLabel: "วันที่บรรจุ"
                                        ,format: "d/m/Y"
                                        ,value: to_date_app(data.entrydate)
                                        ,enableKeyEvents: true
                                        ,listeners: {
                                            select: function(field,el ){
                                                SetAgeProcessInsig(field,Ext.getCmp("entrytime"));										
                                            }
                                            ,specialkey: function(field, el){
                                                if (el.getKey() == Ext.EventObject.ENTER || el.getKey() == Ext.EventObject.TAB){
                                                    SetAgeProcessInsig(field,Ext.getCmp("entrytime"));
                                                }
                                            }
                                        }
                                    }
                                    ,{
                                        xtype: "datefield"
                                        ,id: "t_dgdcdcr[leveldate]"
                                        ,fieldLabel: "วันที่เข้าสู่ระดับ"
                                        ,format: "d/m/Y"
                                        ,value: to_date_app(data.leveldate)
                                        ,enableKeyEvents: true
                                        ,listeners: {
                                            select: function(field,el ){
                                                SetAgeProcessInsig(field,Ext.getCmp("leveltime"));										
                                            }
                                            ,specialkey: function(field, el){
                                                if (el.getKey() == Ext.EventObject.ENTER || el.getKey() == Ext.EventObject.TAB){
                                                    SetAgeProcessInsig(field,Ext.getCmp("leveltime"));
                                                }
                                            }
                                        }
                                    }
                                ]
                            }
                            ,{
                                layout: "form"
                                ,style: "padding-left:10px"
                                ,labelWidth: 60
                                ,items: [
                                    {
                                        xtype: "textfield"
                                        ,id: "entrytime"
                                        ,readOnly: true
                                        ,fieldLabel: "ระยะเวลา"
                                        ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
                                    }
                                    ,{
                                        xtype: "textfield"
                                        ,id: "leveltime"
                                        ,readOnly: true
                                        ,fieldLabel: "ระยะเวลา"
                                        ,style: "color: #ffffff;background-color:#888888;background-image:url('#');"
                                    }
                                ]
                            }
                        ]
                    }
                    ,{
                        xtype: "textfield"
                        ,id: "t_dgdcdcr[note1]"
                        ,fieldLabel: "หมายเหตุ1"
                        ,anchor: "90%"
                        ,value: data.note1
                    }
                    ,{
                        xtype: "textfield"
                        ,id: "t_dgdcdcr[note2]"
                        ,fieldLabel: "หมายเหตุ2"
                        ,anchor: "90%"
                        ,value: data.note2
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
                            ,success:function(){		
                                Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                    if (btn == 'ok')
                                    {
                                        processInsigGridStore.reload();
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
                                            Ext.Msg.alert('สถานะ', 'Authentication server is unreachable: ' + action.response.responseText); 
                                    } 
                            } 
                        }); 
                    } 
                },{
                    text: "ยกเลิก"
                    ,handler: function	(){
                        win.close();
                    }
                }
            ] 
        });
    }//end if form
    if(!win){
        var win = new Ext.Window({
            title: 'เพิ่ม/แก้ไข ประวัติเครื่องราชย์'
            ,width: 600
            ,height: 500
            ,closable: true
            ,resizable: false
            ,plain: true
            ,border: false
            ,draggable: true 
            ,modal: true
            ,layout: "fit"
            ,maximizable: true
            ,items: [form]
        });
    }
    SetAgeProcessInsig(Ext.getCmp("t_dgdcdcr[entrydate]"),Ext.getCmp("entrytime"));
    SetAgeProcessInsig(Ext.getCmp("t_dgdcdcr[leveldate]"),Ext.getCmp("leveltime"));
    Ext.getCmp("t_dgdcdcr[epcode]").getStore().load({
        params: {
            epcode: data.epcode
            ,start: 0
            ,limit: 10
        }
        ,callback :function(){
            Ext.getCmp("t_dgdcdcr[epcode]").setValue(data.epcode);
        }
    });
    Ext.getCmp("t_dgdcdcr[ptcode]").getStore().load({
        params: {
            ptcode: data.ptcode
            ,start: 0
            ,limit: 10
        }
        ,callback :function(){
            Ext.getCmp("t_dgdcdcr[ptcode]").setValue(data.ptcode);
        }
    });
    Ext.getCmp("t_dgdcdcr[excode]").getStore().load({
        params: {
            excode: data.excode
            ,start: 0
            ,limit: 10
        }
        ,callback :function(){
            Ext.getCmp("t_dgdcdcr[excode]").setValue(data.excode);
        }
    });
    Ext.getCmp("t_dgdcdcr[c]").getStore().load({
        params: {
            ccode: data.c
            ,start: 0
            ,limit: 10
        }
        ,callback :function(){
            Ext.getCmp("t_dgdcdcr[c]").setValue(data.c);
        }
    });
    Ext.getCmp("t_dgdcdcr[poscode]").getStore().load({
        params: {
            poscode: data.poscode
            ,start: 0
            ,limit: 10
        }
        ,callback :function(){
            Ext.getCmp("t_dgdcdcr[poscode]").setValue(data.poscode);
        }
    });
    Ext.getCmp("t_dgdcdcr[dccode]").getStore().load({
        params: {
            dccode: data.dccode
            ,start: 0
            ,limit: 10
        }
        ,callback :function(){
            Ext.getCmp("t_dgdcdcr[dccode]").setValue(data.dccode);
            win.show();
            win.center();
            loadMask.hide();
        }
    });   
}

//-------------------------------------
// Panel Main
//-------------------------------------

var processInsigPanel = new Ext.Panel({
    layout: "border"
    ,items: [
        processInsigNorth
        ,processInsigGrid     
    ]
    ,listeners: {
        afterrender: function(el){
            el.doLayout();
        }
    }
});