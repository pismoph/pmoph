/********************************************************************/
/*Grid*/
/******************************************************************/
var data_personalSearch = new Ext.ux.grid.Search({
        iconCls: 'search'
        ,minChars: 3
        ,autoFocus: true
        ,position: "top"
        ,width: 200
});
var data_personalFields = [
         ,{name: "id", type: "string"}
         ,{name: "sex", type: "string"}
         ,{name: "prefix", type: "string"}
         ,{name: "fname", type: "string"}
         ,{name: "lname", type: "string"}
         ,{name: "pid", type: "string"}
         ,{name: "birthdate", type: "string"}
         ,{name: "tel", type: "string"}
         ,{name: "name", type: "string"}
];    
var data_personalCols = [
     {
              header: "#"
              ,width: 80
              ,renderer: rowNumberer.createDelegate(this)
              ,sortable: false
     }		
     ,{header: "คำนำหน้า",width: 70, sortable: false, dataIndex: 'prefix'}
     ,{header: "ชื่อ",width: 100, sortable: false, dataIndex: 'fname'}
     ,{header: "นามสกุล",width: 100, sortable: false, dataIndex: 'lname'}
     ,{header: "เลขบัตรประชาชน",width: 100, sortable: false, dataIndex: 'pid'}
     ,{header: "วันเกิด",width: 100, sortable: false, dataIndex: 'birthdate'}
     ,{header: "เพศ",width: 100, sortable: false, dataIndex: 'sex'}
     ,{header: "เบอร์โทรศัพท์",width: 100, sortable: false, dataIndex: 'tel'}
];    
var data_personalGridStore = new Ext.data.JsonStore({
        url: pre_url + "/info_personal/read"
        ,root: "records"
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,fields: data_personalFields
        ,idProperty: 'id'
});
var data_personalGrid = new Ext.grid.GridPanel({
        region: 'center'
        ,split: true
        ,store: data_personalGridStore
        ,columns: data_personalCols
        ,stripeRows: true
        ,loadMask: {msg:'Loading...'}
        ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
        ,plugins: [data_personalSearch]
        ,bbar: new Ext.PagingToolbar({
                        pageSize: 20
                        ,autoWidth: true
                        ,store: data_personalGridStore
                        ,displayInfo: true
                        ,displayMsg	: 'Displaying {0} - {1} of {2}'
                        ,emptyMsg: "Not found"
        })
        ,tbar: []
});
data_personalGrid.on('rowdblclick', function(grid, rowIndex, e ) {
        data_select = grid.getSelectionModel().getSelected().data;
        data_personel_id = data_select.id;
        searchEditPersonel(data_select);
});   
function searchEditPersonel(data_select){
        loadMask.show();
        Ext.Ajax.request({
                 url: pre_url + "/info_personal/search_edit"
                 ,params: {
                          id: data_select.id
                 }
                 ,success: function(response,opts){
                          obj = Ext.util.JSON.decode(response.responseText);
                          data = obj.data.pispersonel
                          if (obj.success){
                                        tab_personel.getActiveTab().setTitle("ข้อมูลส่วนตัว ( " +data_select.name+ " )")
                                        panelPersonalnow.getLayout().setActiveItem(data_personal_panel);
                                        data_personal_form.getForm().reset();
                                        data_personal_north.enable();
                                        data_personal_change_nameGrid.removeAll();
                                        Ext.getCmp("id").setValue(data.id);
                                        Ext.getCmp("pispersonel[pid]").setValue(data.pid);
                                        Ext.getCmp("pispersonel[fname]").setValue(data.fname);
                                        Ext.getCmp("pispersonel[lname]").setValue(data.lname);
                                        Ext.getCmp("pispersonel[address1]").setValue(data.address1);
                                        Ext.getCmp("pispersonel[address2]").setValue(data.address2);
                                        Ext.getCmp("pispersonel[zip]").setValue(data.zip);
                                        Ext.getCmp("pispersonel[tel]").setValue(data.tel);
                                        Ext.getCmp("pispersonel[sex]").setValue(data.sex);
                                        Ext.getCmp("pispersonel[nationality]").setValue(data.nationality);
                                        Ext.getCmp("pispersonel[bloodgroup]").setValue(data.bloodgroup);
                                        Ext.getCmp("pispersonel[race]").setValue(data.race);
                                        Ext.getCmp("pispersonel[birthdate]").setValue(to_date_app(data.birthdate));                                
                                        Ext.getCmp("pispersonel[pcode]").getStore().load({
                                                 params: {
                                                          pcode: data.pcode
                                                          ,start: 0
                                                          ,limit: 10
                                                 }
                                                 ,callback :function(){
                                                          Ext.getCmp("pispersonel[pcode]").setValue(data.pcode);                                                     
                                                 }
                                        });                                        
                                        Ext.getCmp("pispersonel[mrcode]").getStore().load({
                                                 params: {
                                                          mrcode: data.mrcode
                                                          ,start: 0
                                                          ,limit: 10
                                                 }
                                                 ,callback :function(){
                                                          Ext.getCmp("pispersonel[mrcode]").setValue(data.mrcode);                                                     
                                                 }
                                        });                                        
                                        Ext.getCmp("pispersonel[recode]").getStore().load({
                                                 params: {
                                                        recode: data.recode
                                                        ,start: 0
                                                        ,limit: 10
                                                 }
                                                 ,callback :function(){
                                                          Ext.getCmp("pispersonel[recode]").setValue(data.recode);                                                     
                                                 }
                                        });                                        
                                        Ext.getCmp("pispersonel[provcode]").getStore().load({
                                                 params: {
                                                          provcode: data.provcode
                                                          ,start: 0
                                                          ,limit: 10
                                                 }
                                                 ,callback :function(){
                                                        Ext.getCmp("pispersonel[provcode]").setValue(data.provcode);
                                                        if (obj.data["pispersonel[birthdate]"] != ""){
                                                                SetAgeDataPerson();
                                                        }
                                                        loadMask.hide();
                                                 }
                                        });
                                        if (data.picname == "" || data.picname == null){
                                                var tpl = new Ext.Template("");
                                                tpl.overwrite(Ext.get("div_image"), "");      
                                        }
                                        else{
                                                data.picname = pre_url + "/images/personel/"+data.picname
                                                var tpl = new Ext.Template("<img src='{src}' width='100%' height='100%'>");
                                                tpl.overwrite(Ext.get("div_image"), {src: data.picname});     
                                        }

                                        
                                        data_personal_change_nameGridStore.baseParams = {
                                                 id: data_select.id
                                        }
                                        data_personal_change_nameGridStore.load();
                                   
                          }
                          else{
                                   Ext.Msg.alert("สถานะ","กรุณาลองใหม่อีกครั้ง");
                                   loadMask.hide();
                          }        
                 }
                 ,failure: function(response,opts){
                          Ext.Msg.alert("สถานะ",response.statusText);
                          loadMask.hide();
                 }
        });        
}

function searchPersonelById(personel_id){
         loadMask.show();
         Ext.Ajax.request({
                  url: pre_url + "/info_personal/search_id"
                  ,params: {
                           id: personel_id
                  }
                  ,success: function(response,opts){
                           obj = Ext.util.JSON.decode(response.responseText);
                            searchEditPersonel(obj.data[0]);
                            loadMask.hide();
                  }
                  ,failure: function(response,opts){
                           Ext.Msg.alert("สถานะ",response.statusText);
                           loadMask.hide();
                  }
         });
}
/********************************************************************/
/*Panel  Image*/
/******************************************************************/
var data_personal_image = new Ext.Panel({
         region: "west"
         ,title: "แสดงภาพข้าราชการ"
         ,width: 200
         ,items: [
                  new Ext.BoxComponent({
                           autoEl: {
                                    tag: "div"
                                    ,id: "div_image"
                                    ,html: "<img src='#' width='100%' height='100%'>"
                           }
                  })
         ]
});
 /********************************************************************/
/*Grid Change name*/
/******************************************************************/
var data_personal_change_nameFields = [
         {name: "chgno", type: "int"}
         ,{name: "id", type: "string"}
         ,{name: "chgdate", type: "string"}
         ,{name: "prefix", type: "string"}
         ,{name: "fname", type: "string"}
         ,{name: "lname", type: "string"}
         ,{name: "ref", type: "string"}
         ,{name: "chgname", type: "string"}
];

var data_personal_change_nameCols = [
        {
                header: "#"
                ,width: 30
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "วันที่", width: 100, sortable: false, dataIndex: "chgdate"}
        ,{header: "คำนำหน้า", width: 100, sortable: false, dataIndex: "prefix"}
        ,{header: "ชื่อ", width: 100, sortable: false, dataIndex: "fname"}
        ,{header: "นามสกุล", width: 100, sortable: false, dataIndex: "lname"}
        ,{header: "สถานะการเปลี่ยน", width: 100, sortable: false, dataIndex: "chgname"}
        ,{header: "เอกสารอ้างอิง", width: 100, sortable: false, dataIndex: "ref"}
];

var data_personal_change_nameGridStore = new Ext.data.JsonStore({
        url: pre_url + "/info_pis_change_name/read"
        ,root: 'records'
        ,autoLoad: false
        ,fields: data_personal_change_nameFields
        ,idProperty: 'chgno'
});

var data_personal_change_nameGrid = new Ext.grid.GridPanel({
        region: "center"
        ,title: "ประวัติการเปลี่ยนชื่อ - นามสกุล"
        ,store: data_personal_change_nameGridStore
        ,columns: data_personal_change_nameCols
        ,stripeRows: true
        ,loadMask: {msg:'Loading...'}
        ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})  
        ,plugins: []
        ,tbar: [
                {
                        text: "เพิ่ม"
                        ,handler: function (){
                                if(!form){
                                        var form = new Ext.FormPanel({ 
                                                autoScroll: true
                                                ,url: pre_url + '/info_pis_change_name/add'
                                                ,frame: true
                                                ,monitorValid: true
                                                ,labelAlign: "right"
                                                ,labelWidth: 120
                                                ,items:[
                                                        {
                                                               xtype: "hidden"
                                                               ,id: "pischgname[id]"
                                                               ,value: data_personel_id
                                                        }
                                                        ,{
                                                                xtype: "datefield"
                                                                ,fieldLabel: "วันที่"
                                                                ,id: "pischgname[chgdate]"
                                                                ,format: "d/m/Y"
                                                                ,width: 165
                                                        }
                                                        ,new Ext.ux.form.PisComboBox({//คำนำหน้า
                                                                fieldLabel: 'คำนำหน้า'
                                                                ,hiddenName: 'pischgname[pcode]'
                                                                ,id: 'pischgname[pcode]'
                                                                ,valueField: 'pcode'
                                                                ,displayField: 'longprefix'
                                                                ,urlStore: pre_url + '/code/cprefix'
                                                                ,fieldStore: ['pcode', 'longprefix']
                                                                
                                                        })	
                                                        ,{
                                                                xtype: "textfield"
                                                                ,id: "pischgname[fname]"
                                                                ,fieldLabel: "ชื่อ"
                                                                ,width: 165
                                                        }
                                                        ,{
                                                                xtype: "textfield"
                                                                ,id: "pischgname[lname]"
                                                                ,fieldLabel: "นามสกุล"
                                                                ,width: 165
                                                        }
                                                        ,new Ext.ux.form.PisComboBox({//สถานะการเปลี่ยน
                                                                fieldLabel: 'สถานะการเปลี่ยน'
                                                                ,hiddenName: 'pischgname[chgcode]'
                                                                ,id: 'pischgname[chgcode]'
                                                                ,valueField: 'chgcode'
                                                                ,displayField: 'chgname'
                                                                ,urlStore: pre_url + '/code/cchangename'
                                                                ,fieldStore: ['chgcode', 'chgname']
                                                                
                                                        })
                                                        ,{
                                                                xtype: "textfield"
                                                                ,id: "pischgname[ref]"
                                                                ,fieldLabel: "เอกสารอ้างอิง"
                                                                ,anchor: '95%'
                                                        }
                                                ]
                                                ,buttons:[
                                                        { 
                                                                text:'บันทึก'
                                                                ,formBind: true 
                                                                ,handler:function(){
                                                                        loadMask.show();
                                                                        form.getForm().submit(
                                                                        { 
                                                                                method:'POST'
                                                                                ,waitTitle:'Saving Data'
                                                                                ,waitMsg:'Sending data...'
                                                                                ,success:function(){
                                                                                        loadMask.hide();
                                                                                        Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                                                                        if (btn == 'ok')
                                                                                                        {
                                                                                                                win.close();
                                                                                                                data_personal_change_nameGridStore.load();
                                                                                                        }	
                                                                                                }
                                                                                        );                                                                         
                                                                                }
                                                                                ,failure:function(form, action){
                                                                                        loadMask.hide();
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
                                                title: 'เพิ่มรายการเปลี่ยนชื่อ'
                                                ,width: 500
                                                ,height: 300
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
                ,'-',{
                        ref: '../removeBtn'
                        ,text: 'ลบ'
                        ,tooltip: 'ลบ'
                        ,iconCls: 'table-delete'
                        ,disabled: true
                        ,handler: function(){
                                Ext.Msg.confirm('สถานะ', 'ต้องการลบใช่หรือไม่', function(btn, text){			
                                        if (btn == 'yes')
                                        {				
                                                loadMask.show();
                                                Ext.Ajax.request({
                                                        url: pre_url + '/info_pis_change_name/delete' , 
                                                        params: { 
                                                                id: data_personal_change_nameGrid.getSelectionModel().getSelections()[0].data.id
                                                                ,chgno: data_personal_change_nameGrid.getSelectionModel().getSelections()[0].data.chgno
                                                                ,random: Math.random()
                                                        },	
                                                        failure: function ( result, request) { 
                                                                loadMask.hide();
                                                                Ext.MessageBox.alert('สถานะ', "Error: "+result.responseText); 
                                                        },
                                                        success: function ( result, request ) { 
                                                                loadMask.hide();
                                                                var obj = Ext.util.JSON.decode(result.responseText); 
                                                                if (obj.success == false)
                                                                {
                                                                        Ext.MessageBox.alert('สถานะ', 'ไม่สามารถลบได้ <br> Error: ' + obj.msg); 
                                                                }
                                                                else if (obj.success == true)
                                                                {
                                                                        Ext.MessageBox.alert('สถานะ', 'ลบเสร็จเรียบร้อย',function(btn, text){
                                                                                        if (btn == 'ok'){
                                                                                                data_personal_change_nameGridStore.load();
                                                                                        }
                                                                                }
                                                                        ); 
                                                                }
                                                        }
                                                });	
                                        }//end if (btn == 'yes')
                                        else
                                        {
                                                return false;
                                        }
                                });	
                        }
                }
        ]
});

data_personal_change_nameGrid.getSelectionModel().on('selectionchange', function(sm){
        data_personal_change_nameGrid.removeBtn.setDisabled(sm.getCount() < 1);  
});
data_personal_change_nameGrid.on('rowdblclick', function(grid, rowIndex, e ) {
         
         loadMask.show();
         Ext.Ajax.request({
                  url: pre_url + "/info_pis_change_name/search_edit"
                  ,params: {
                           id: grid.getSelectionModel().getSelected().data.id
                           ,chgno: grid.getSelectionModel().getSelected().data.chgno
                  }
                  ,success: function(response,opts){
                           obj = Ext.util.JSON.decode(response.responseText);
                           if (obj.success){
                                if(!form){
                                        var form = new Ext.FormPanel({ 
                                                autoScroll: true
                                                ,url: pre_url + '/info_pis_change_name/edit'
                                                ,frame: true
                                                ,monitorValid: true
                                                ,labelAlign: "right"
                                                ,labelWidth: 120
                                                ,items:[
                                                        {
                                                               xtype: "hidden"
                                                               ,id: "pischgname[id]"
                                                               ,value: obj.data.pischgname.id[0]
                                                        }
                                                        ,{
                                                               xtype: "hidden"
                                                               ,id: "pischgname[chgno]"
                                                               ,value: obj.data.pischgname.chgno
                                                        }
                                                        ,{
                                                                xtype: "datefield"
                                                                ,fieldLabel: "วันที่"
                                                                ,id: "pischgname[chgdate]"
                                                                ,format: "d/m/Y"
                                                                ,width: 165
                                                                ,value: to_date_app(obj.data.pischgname.chgdate)
                                                        }
                                                        ,new Ext.ux.form.PisComboBox({//คำนำหน้า
                                                                fieldLabel: 'คำนำหน้า'
                                                                ,hiddenName: 'pischgname[pcode]'
                                                                ,id: 'pischgname[pcode]'
                                                                ,valueField: 'pcode'
                                                                ,displayField: 'longprefix'
                                                                ,urlStore: pre_url + '/code/cprefix'
                                                                ,fieldStore: ['pcode', 'longprefix']
                                                                
                                                        })	
                                                        ,{
                                                                xtype: "textfield"
                                                                ,id: "pischgname[fname]"
                                                                ,fieldLabel: "ชื่อ"
                                                                ,width: 165
                                                                ,value: obj.data.pischgname.fname
                                                        }
                                                        ,{
                                                                xtype: "textfield"
                                                                ,id: "pischgname[lname]"
                                                                ,fieldLabel: "นามสกุล"
                                                                ,width: 165
                                                                ,value: obj.data.pischgname.lname
                                                        }
                                                        ,new Ext.ux.form.PisComboBox({//สถานะการเปลี่ยน
                                                                fieldLabel: 'สถานะการเปลี่ยน'
                                                                ,hiddenName: 'pischgname[chgcode]'
                                                                ,id: 'pischgname[chgcode]'
                                                                ,valueField: 'chgcode'
                                                                ,displayField: 'chgname'
                                                                ,urlStore: pre_url + '/code/cchangename'
                                                                ,fieldStore: ['chgcode', 'chgname']
                                                                
                                                        })
                                                        ,{
                                                                xtype: "textfield"
                                                                ,id: "pischgname[ref]"
                                                                ,fieldLabel: "เอกสารอ้างอิง"
                                                                ,anchor: '95%'
                                                                ,value: obj.data.pischgname.ref
                                                        }
                                                ]
                                                ,buttons:[
                                                        { 
                                                                text:'บันทึก'
                                                                ,formBind: true 
                                                                ,handler:function(){
                                                                        loadMask.show();
                                                                        form.getForm().submit(
                                                                        { 
                                                                                method:'POST'
                                                                                ,waitTitle:'Saving Data'
                                                                                ,waitMsg:'Sending data...'
                                                                                ,success:function(){
                                                                                        loadMask.hide();
                                                                                        Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                                                                        if (btn == 'ok')
                                                                                                        {
                                                                                                                win.close();
                                                                                                                data_personal_change_nameGridStore.load();
                                                                                                        }	
                                                                                                }
                                                                                        );                                                                         
                                                                                }
                                                                                ,failure:function(form, action){
                                                                                        loadMask.hide();
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
                                                title: 'เพิ่มรายการเปลี่ยนชื่อ'
                                                ,width: 500
                                                ,height: 300
                                                ,resizable: false
                                                ,plain: true
                                                ,border: false
                                                ,draggable: true 
                                                ,modal: true
                                                ,layout: "fit"
                                                ,items: [form]
                                        });
                                }
                                Ext.getCmp("pischgname[chgcode]").getStore().load({
                                         params: {
                                                chgcode: obj.data.pischgname.chgcode
                                                ,start: 0
                                                ,limit: 10
                                         }
                                         ,callback :function(){
                                                  Ext.getCmp("pischgname[chgcode]").setValue(obj.data.pischgname.chgcode);                                                     
                                         }
                                });
                                Ext.getCmp("pischgname[pcode]").getStore().load({
                                         params: {
                                                pcode: obj.data.pischgname.pcode
                                                ,start: 0
                                                ,limit: 10
                                         }
                                         ,callback :function(){
                                                  Ext.getCmp("pischgname[pcode]").setValue(obj.data.pischgname.pcode);
                                                  loadMask.hide();
                                         }
                                });
                                win.show();
                                win.center();
                           }else{
                                    Ext.Msg.alert("สถานะ","กรุณาลองใหม่อีกครั้ง");
                                    loadMask.hide();
                           }
                  }
                  ,failure: function(response,opts){
                           Ext.Msg.alert("สถานะ",response.statusText);
                           loadMask.hide();
                  }
         });
});  
/********************************************************************/
/*Panel North*/
/******************************************************************/    
var data_personal_north = new Ext.Panel({
    region: "north"
    ,height: 200
    ,layout: "border"
            ,disabled: true
    ,items: [
        data_personal_image
        ,data_personal_change_nameGrid
    ]
});
/********************************************************************/
/*Form*/
/******************************************************************/    
var data_personal_form = new Ext.form.FormPanel({
              region: "center"
            ,autoScroll: true
            ,bodyStyle: "padding:5px"
            ,labelAlign: "right"	
            ,frame: true
            ,monitorValid: true
            ,fileUpload: true
            ,defaults: {
                    msgTarget: "side"
            }
            ,items: [
                    {
                            xtype: "hidden"
                            ,id: "id"
                    }
                    ,{
                           xtype: "fieldset"
                           ,bodyStyle: "padding:10px"
                           ,labelWidth: 150
                           ,width: 1000
                           ,layout: "form"
                           ,defaults: {
                                   msgTarget: "side"
                           }
                           ,items: [
                                   {
                                           xtype: "textfield"
                                           ,fieldLabel: "เลขประจำตัวประชาชน"
                                           ,id: "pispersonel[pid]"
                                           ,width: 150						
                                   }
                                   ,{
                                           layout: "column"
                                           ,items: [
                                                   {
                                                           width: 300
                                                           ,labelWidth: 80
                                                           ,layout: "form"
                                                           ,defaults: {
                                                                   msgTarget: "side"
                                                           }
                                                           ,items: [
                                                                new Ext.ux.form.PisComboBox({//คำนำหน้า
                                                                        fieldLabel: 'คำนำหน้า'
                                                                        ,hiddenName: 'pispersonel[pcode]'
                                                                        ,id: 'pispersonel[pcode]'
                                                                        ,valueField: 'pcode'
                                                                        ,displayField: 'longprefix'
                                                                        ,urlStore: pre_url + '/code/cprefix'
                                                                        ,fieldStore: ['pcode', 'longprefix']
                                                                        
                                                               })
                                                           ]
                                                   },{
                                                           width: 190
                                                           ,labelWidth: 20
                                                           ,layout: "form"
                                                           ,defaults: {
                                                                   msgTarget: "side"
                                                           }
                                                           ,items: [
                                                                   {
                                                                           xtype: "textfield"
                                                                           ,anchor: "95%"
                                                                           ,id: "pispersonel[fname]"
                                                                           ,fieldLabel: "ชื่อ"
                                                                   }	
                                                           ]
                                                   },{
                                                           width: 230
                                                           ,labelWidth: 60
                                                           ,layout: "form"
                                                           ,defaults: {
                                                                   msgTarget: "side"
                                                           }
                                                           ,items: [
                                                                   {
                                                                           xtype: "textfield"
                                                                           ,anchor: "95%"
                                                                           ,id: "pispersonel[lname]"
                                                                           ,fieldLabel: "นามสกุล"
                                                                   }	
                                                           ]
                                                   }
                                           ]
                                   }
                                   ,{
                                           layout: "column"
                                           ,items: [
                                                   {
                                                           width: 300
                                                           ,layout: "form"
                                                           ,labelWidth: 80
                                                           ,defaults: {
                                                                   anchor: "95%"
                                                                   ,msgTarget: "side"
                                                           }
                                                           ,items: [	
                                                                        {
                                                                                xtype: "datefield"
                                                                                ,fieldLabel: "วันเกิด"
                                                                                ,id: "pispersonel[birthdate]"
                                                                                ,format: "d/m/Y"
                                                                                ,listeners: {
                                                                                                select: function(el,date ){
                                                                                                                SetAgeDataPerson();
                                                                                                } 
                                                                                }
                                                                        }
                                                                        ,new Ext.ux.form.PisComboBox({//สถานะภาพ
                                                                                fieldLabel: 'สถานะภาพ'
                                                                                ,hiddenName: 'pispersonel[mrcode]'
                                                                                ,id: 'pispersonel[mrcode]'
                                                                                ,valueField: 'mrcode'
                                                                                ,displayField: 'marital'
                                                                                ,urlStore: pre_url + '/code/cmarital'
                                                                                ,fieldStore: ['mrcode', 'marital']                                                                                
                                                                        })
                                                                        ,new Ext.ux.form.PisComboBox({//ศาสนา
                                                                                fieldLabel: 'ศาสนา'
                                                                                ,hiddenName: 'pispersonel[recode]'
                                                                                ,id: 'pispersonel[recode]'
                                                                                ,valueField: 'recode'
                                                                                ,displayField: 'renname'
                                                                                ,urlStore: pre_url + '/code/creligion'
                                                                                ,fieldStore: ['recode', 'renname']
                                                                                ,anchor: "95%"       
                                                                        })
                                                               ]
                                                   },{
                                                           width: 300
                                                           ,layout: "form"
                                                           ,labelWidth: 80
                                                           ,defaults: {
                                                                   anchor: "95%"
                                                                   ,msgTarget: "side"
                                                           }
                                                           ,items: [
                                                                   new Ext.BoxComponent({
                                                                           id: "age_data_person"
                                                                           ,autoEl: {
                                                                                tag: "div"
                                                                                ,html: "<table style='font:12px tahoma,arial,helvetica,sans-serif'>" +
                                                                                        "<tr ><td style='width:78px' align='right' height='24px'>อายุ:</td><td style='padding-left:5px'></td></tr>" + 
                                                                                "</table>"
                                                                           }
                                                                   })
                                                                   ,{
                                                                           xtype: "textfield"
                                                                           ,id: "pispersonel[race]"
                                                                           ,fieldLabel: "เชื้อชาติ"
                                                                   }
                                                                   ,new Ext.ux.form.PisComboBox({//ภูมิลำเนา
                                                                        fieldLabel: 'ภูมิลำเนา'
                                                                        ,hiddenName: 'pispersonel[provcode]'
                                                                        ,id: 'pispersonel[provcode]'
                                                                        ,valueField: 'provcode'
                                                                        ,displayField: 'provname'
                                                                        ,urlStore: pre_url + '/code/cprovince'
                                                                        ,fieldStore: ['provcode', 'provname']
                                                                        ,anchor: "95%"                                                                       
                                                                   })
                                                           ]
                                                   },{
                                                           width: 300
                                                           ,layout: "form"
                                                           ,labelWidth: 80
                                                           ,defaults: {
                                                                   anchor: "95%"
                                                                   ,msgTarget: "side"
                                                           }
                                                           ,items: [
                                                                   new Ext.form.ComboBox({//เพศ
                                                                           fieldLabel: "เพศ"
                                                                           ,editable: true
                                                                           ,id: "pispersonel[sex]"										
                                                                           ,hiddenName: 'pispersonel[sex]'
                                                                           ,width: 100
                                                                           ,store: new Ext.data.SimpleStore({
                                                                                        fields: ['id', 'type']
                                                                                        ,data: [
                                                                                                ["1", "ชาย"]
                                                                                                ,["2", "หญิง"]                                                                           
                                                                                        ] 
                                                                           })
                                                                           ,valueField	:'id'
                                                                           ,displayField:'type'
                                                                           ,typeAhead	: true
                                                                           ,mode: 'local'
                                                                           ,triggerAction: 'all'
                                                                           ,emptyText	:'Select ...'
                                                                   })
                                                                   ,{
                                                                           xtype: "textfield"
                                                                           ,id: "pispersonel[nationality]"
                                                                           ,fieldLabel: "สัญชาติ"
                                                                   }
                                                                   ,new Ext.form.ComboBox({//กรุ๊ปเลือด
                                                                           fieldLabel: "กรุ๊ปเลือด"
                                                                           ,editable: true
                                                                           ,id: "pispersonel[bloodgroup]"										
                                                                           ,hiddenName: 'pispersonel[bloodgroup]'
                                                                           ,width: 100
                                                                           ,store: new Ext.data.SimpleStore({
                                                                                        fields: ['id', 'type']
                                                                                        ,data: [
                                                                                                ["A", "A"]
                                                                                                ,["B", "B"]
                                                                                                ,["AB", "AB"]
                                                                                                ,["O", "O"]
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
                                                           
                                                   }
                                           ]
                                   }
                           ]
                           ,listeners: {
                                    afterrender: function(el){
                                             el.doLayout();
                                    }
                           } 
                    },{
                           xtype: "fieldset"
                           ,bodyStyle: "padding:10px"
                           ,labelWidth: 150
                           ,width: 1000
                           ,layout: "form"
                           ,defaults: {
                                   msgTarget: "side"
                           }
                           ,items: [
                                   {
                                           xtype: "textfield"
                                           ,id: "pispersonel[address1]"
                                           ,fieldLabel: "บ้านเลขที่ ซอย ถนน"
                                           ,anchor: "95%"
                                   }
                                   ,{
                                           xtype: "textfield"
                                           ,id: "pispersonel[address2]"
                                           ,fieldLabel: "ตำบล อำเภอ จังหวัด"
                                           ,anchor: "95%"
                                   }
                                   ,{
                                           xtype: "numberfield"
                                           ,id: "pispersonel[zip]"
                                           ,fieldLabel: "รหัสไปรษณีย์"
                                   }
                                   ,{
                                           xtype: "textfield"
                                           ,id: "pispersonel[tel]"
                                           ,fieldLabel: "โทรศัพท์"
                                   }
                                   ,{
                                           xtype: "fileuploadfield"
                                           ,id: 'picname'
                                           ,name: 'picname'										
                                           ,fieldLabel: "รูปภาพข้าราชการ"
                                           ,anchor: "50%"
                                   }
                           ]
                           ,listeners: {
                                    afterrender: function(el){
                                             el.doLayout();
                                    }
                           } 
                    },
                                    

            ]
            ,buttons:[
                    { 
                            text:'บันทึก'
                            ,formBind: true 
                            ,handler:function(){ 					
                                    data_personal_form.getForm().submit(
                                    { 
                                            method:'POST'
                                            ,url: pre_url + "/info_personal/update"
                                            ,waitTitle:'Saving Data'
                                            ,waitMsg:'Sending data...'
                                            ,success:function(){		
                                                    Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                                                                    if (btn == 'ok'){
                                                                            panelPersonalnow.getLayout().setActiveItem(panelPersonalFirst);
                                                                            data_personalGridStore.reload();
                                                                    }	
                                                            }
                                                    );                         
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
                                data_personel_id = "";
                                panelPersonalnow.getLayout().setActiveItem(panelPersonalFirst);
                                data_personalGridStore.load({ params: { start: 0, limit: 20} });
                            }
                    }
            ]
}); 
var data_personal_panel = new Ext.Panel({
        layout: "border"
             ,title: "&nbsp;"
        ,items: [
            data_personal_north
            ,data_personal_form
        ]
        ,listeners: {
                 deactivate : function( p ){
                          tab_personel.getActiveTab().setTitle("ข้อมูลส่วนตัว")
                 } 
        }
});

/***********************************************************************/
//panel 
/************************************************************************/
var panelPersonalFirst = new Ext.Panel({
         layout: "border"
         ,items: [
                  data_personalGrid
         ]
});
var panelPersonalnow = new Ext.Panel({
         layout: "card"
         ,activeItem: 0
         ,items: [
                  panelPersonalFirst
                  ,data_personal_panel
         ]
});
/********************************************************************/
/*Function*/
/*****************************************************************/
function SetAgeDataPerson(){
                data = {
                        age: ''
                };	
                tmp_date = Ext.getCmp("pispersonel[birthdate]").getRawValue();
                tmp_date = tmp_date.replace(tmp_date.split("/")[2],(Number(tmp_date.split("/")[2]) - 543));
                tmp_date = calage(tmp_date);
                data.age = tmp_date[0]+" ปี  " + tmp_date[1] + " เดือน  " + tmp_date[2] + " วัน" ;
                var tpl = new Ext.Template(
                                                                                 "<table style='font:12px tahoma,arial,helvetica,sans-serif'>" ,
                                                                                        "<tr ><td style='width:78px' align='right' height='24px'>อายุ:</td><td style='padding-left:5px'>{age}</td></tr>" ,
                                                                                "</table>"
                );
                tpl.overwrite(Ext.get("age_data_person"), data);
}