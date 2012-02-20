var action_griddetail = new Ext.ux.grid.RowActions({
	 header:'จัดการ'
	,keepSelection: true
	,widthSlope: 40
	,actions:[
		{iconCls: 'table-edit', tooltip: 'แก้ไข'}
		,{iconCls: 'table-delete', tooltip: 'ลบ'}
	]		
});

action_griddetail.on({
	action:function(grid, record, action, row, col) {
		if (action == "table-edit"){
		     code_subdepDataEdit(record.data.sdcode);
		}
		else if (action == "table-delete"){
		     code_subdepDataDelete(record.data.sdcode);
		}
	}
});

var code_subdeptFields = [
	{name: "sdcode_tmp", type: "int"}
	,{name: "sdcode", type: "int"}
	,{name: "shortpre", type: "string"}
	,{name: "longpre", type: "string"}
	,{name: "subdeptname", type: "string"}
	,{name: "use_status", type: "string"}
	,{name: "sdgcode", type: "string"}
	,{name: "sdgname", type: "string"}	
	,{name: "acode", type: "string"}
	,{name: "aname", type: "string"}
	,{name: "trlcode", type: "string"}
	,{name: "trlname", type: "string"}
	,{name: "provcode", type: "string"}
	,{name: "provname", type: "string"}
	,{name: "amcode", type: "string"}
	,{name: "amname", type: "string"}
	,{name: "tmcode", type: "string"}
	,{name: "tmname", type: "string"}
	,{name: "fcode", type: "string"}
	,{name: "finname", type: "string"}
	,{name: "lcode", type: "string"}
	,{name: "location", type: "string"}
];
var code_subdeptCols = [
	 {header: "รหัสหน่วยงาน", width: 80, sortable: false, dataIndex: "sdcode"}
	 ,{header: "ชื่อย่อคำนำหน้า", width: 80, sortable: false, dataIndex: "shortpre"}
	 ,{header: "คำนำหน้า", width: 150, sortable: false, dataIndex: "longpre"}
	 ,{header: "หน่วยงาน", width: 280, sortable: false, dataIndex: "subdeptname"}	 
	 ,{header: "ประเภทหน่วยงาน", width: 120, sortable: false, dataIndex: "sdgname"}	 
	 ,{header: "Training", width: 150, sortable: false, dataIndex: "trlname"}
	 ,{header: "ส่วน", width: 100, sortable: false, dataIndex: "location"}
	 ,{header: "เขต", width: 100, sortable: false, dataIndex: "aname"}	 
	 ,{header: "จังหวัด", width: 80, sortable: false, dataIndex: "provname"}
	 ,{header: "อำเภอ", width: 80, sortable: false, dataIndex: "amname"}
	 ,{header: "ตำบล", width: 80, sortable: false, dataIndex: "tmname"}
	 ,{header: "คลังเบิกจ่าย", width: 80, sortable: false, dataIndex: "finname"}
	 ,{header: "สถานะการใช้งาน", width: 100, sortable: false, dataIndex: "use_status"}
	 ,action_griddetail
];

var code_subdeptSearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});

var code_subdeptGridStore = new Ext.data.JsonStore({
	url: pre_url+'/csubdept/read'
	,root: 'records'
	,autoLoad: false
	,totalProperty: 'totalCount'
	,remoteSort: true
	,fields: code_subdeptFields
	,idProperty: 'sdcode'
	,successProperty: 'success'
});	

var code_subdeptGrid = new Ext.grid.GridPanel({
	title: "หน่วยงาน"
	,store: code_subdeptGridStore
	,columns: code_subdeptCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_subdeptSearch,action_griddetail]
	,tbar: [
		{
			text: 'เพิ่ม'
			,tooltip: 'เพิ่ม'
			,iconCls: 'table-add'
			,handler: function(){
			   code_subdeptForm(pre_url+'/csubdept/create')
			}
		},"-",{
			text: "Export"
			,iconCls: "table-go"
			,menu: {
				items: [
					{
						text: "Excel"
						,iconCls: "excel"
						,handler: function() {
							var data = Ext.util.JSON.encode(code_subdeptGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/csubdept/report?format=xls");
							form.setAttribute("target", "_blank");
							var hiddenField = document.createElement("input");              
							hiddenField.setAttribute("name", "data");
							hiddenField.setAttribute("value", data);
							form.appendChild(hiddenField);									
							document.body.appendChild(form);
							form.submit();
							document.body.removeChild(form);
						}
					},{
						text: "PDF"
						,iconCls: "pdf"
						,handler: function() {
							var data = Ext.util.JSON.encode(code_subdeptGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/csubdept/report?format=pdf");
							form.setAttribute("target", "_blank");
							var hiddenField = document.createElement("input");              
							hiddenField.setAttribute("name", "data");
							hiddenField.setAttribute("value", data);
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
	,bbar: new Ext.PagingToolbar({
		pageSize: 20
		,autoWidth: true
		,store: code_subdeptGridStore
		,displayInfo: true
		,displayMsg: 'Displaying {0} - {1} of {2}'
		,emptyMsg: "Not found"
	})
});



function code_subdeptForm(url,rec){
   if(!form){
      var form = new Ext.FormPanel({ 
	 labelWidth: 100
	 ,autoScroll: true
	 ,url: url
	 ,frame: true
	 ,monitorValid: true
	 ,defaults: {
	    anchor: "95%"
	 }
	 ,items:[
	    {
	       xtype: "hidden"
	       ,id: "sdcode"
	    }
	    ,{
	       xtype: "numberfield"
	       ,id: "sdcode_tmp"
	       ,fieldLabel: "รหัสหน่วยงาน"
	       ,allowBlank: false
	    }
	    ,{
	       xtype: "textfield"
	       ,id:"shortpre"
	       ,fieldLabel: "ชื่อย่อคำนำหน้า"
	    }
	    ,{
	       xtype: "textfield"
	       ,id:"longpre"
	       ,fieldLabel: "คำนำหน้า"
	    }
	    ,{
	       xtype: "textfield"
	       ,id:"subdeptname"
	       ,fieldLabel: "หน่วยงาน"
	    }
	    ,new Ext.ux.form.PisComboBox({
	       fieldLabel: 'ประเภทหน่วยงาน'
	       ,hiddenName: 'sdgcode'
	       ,id: 'sdgcode'
	       ,valueField: 'sdgcode'
	       ,displayField: 'sdgname'
	       ,urlStore: pre_url + '/code/csdgroup'
	       ,fieldStore: ['sdgcode', 'sdgname']
	    })
	    ,new Ext.ux.form.PisComboBox({
	       fieldLabel: 'Training'
	       ,hiddenName: 'trlcode'
	       ,id: 'trlcode'
	       ,valueField: 'trlcode'
	       ,displayField: 'trlname'	       
	       ,urlStore: pre_url + '/code/ctrainlevel'
	       ,fieldStore: ['trlcode', 'trlname']
	    })
	    ,new Ext.ux.form.PisComboBox({
	       fieldLabel: 'ส่วน'
	       ,hiddenName: 'lcode'
	       ,id: 'lcode'
	       ,valueField: 'lcode'
	       ,displayField: 'location'
	       ,urlStore: pre_url + '/code/clocation'
	       ,fieldStore: ['lcode', 'location']
	    })
	    ,new Ext.ux.form.PisComboBox({
	       fieldLabel: 'เขต'
	       ,hiddenName: 'acode'
	       ,id: 'acode'
	       ,valueField: 'acode'
	       ,displayField: 'aname'
	       ,urlStore: pre_url + '/code/carea'
	       ,fieldStore: ['acode', 'aname']
	    })
	    ,new Ext.ux.form.PisComboBox({
	       fieldLabel: 'จังหวัด'
	       ,hiddenName: 'provcode'
	       ,id: 'provcode'
	       ,valueField: 'provcode'
	       ,displayField: 'provname'
	       ,urlStore: pre_url + '/code/cprovince'
	       ,fieldStore: ['provcode', 'provname']
	       ,listeners: {
			select: function(){
				 ct_genres_amphur = Ext.getCmp("amcode").store;
				 ct_genres_tumbon = Ext.getCmp("tmcode").store;
				 ct_source_province = Ext.getCmp("provcode");
				 ct_source_amphur = Ext.getCmp("amcode");
				 ct_source_tumbon = Ext.getCmp("tmcode");
				 ct_genres_amphur.removeAll();
				 ct_genres_tumbon.removeAll();
				 ct_genres_amphur.baseParams = {	
					 random: Math.random()
					 ,provcode: ct_source_province.getValue()
				 };
				 ct_source_amphur.clearValue();
				 ct_source_tumbon.clearValue();
				 ct_genres_amphur.load({params:{start:0,limit:10}});
				 ct_source_amphur.enable();
				 ct_source_tumbon.disable();
			}		  
			,blur: function(el){
				 if (el.getValue() == el.getRawValue()){
				      el.clearValue();
				 }
				 if(el.getValue() == ""){
				    Ext.getCmp("amcode").store.removeAll();
				    Ext.getCmp("amcode").clearValue();
				    Ext.getCmp("tmcode").store.removeAll();
				    Ext.getCmp("tmcode").clearValue();
				    Ext.getCmp("amcode").disable();
				    Ext.getCmp("tmcode").disable();
				 }
			}
	       }
	    })
	    ,new Ext.ux.form.PisComboBox({
	       fieldLabel: 'อำเภอ'
	       ,disabled: true
	       ,hiddenName: 'amcode'
	       ,id: 'amcode'
	       ,valueField: 'amcode'
	       ,displayField: 'amname'
	       ,urlStore: pre_url + '/code/camphur'
	       ,fieldStore: ['amcode', 'amname']
	       ,listeners: {
			select: function(){
				    
				    ct_genres_tumbon = Ext.getCmp("tmcode").store;				    
				    ct_source_province = Ext.getCmp("provcode");
				    ct_source_amphur = Ext.getCmp("amcode");
				    ct_source_tumbon = Ext.getCmp("tmcode");				    
				    ct_genres_tumbon.removeAll();
				    ct_genres_tumbon.baseParams = {	
					    random: Math.random()
					    ,provcode: ct_source_province.getValue()
					    ,amcode: ct_source_amphur.getValue()
				    };	
				    ct_source_tumbon.clearValue();
				    ct_genres_tumbon.load({params:{start:0,limit:10}});
				    ct_source_tumbon.enable();
			}		  
			,blur: function(el){
				 if (el.getValue() == el.getRawValue()){
				      el.clearValue();
				 }
				 if(el.getValue() == ""){
				    Ext.getCmp("tmcode").store.removeAll();
				    Ext.getCmp("tmcode").clearValue();
				    Ext.getCmp("tmcode").disable();
				 }				 
			}
	       }
	    })
	    ,new Ext.ux.form.PisComboBox({
	       fieldLabel: 'ตำบล'
	       ,disabled: true
	       ,hiddenName: 'tmcode'
	       ,id: 'tmcode'
	       ,valueField: 'tmcode'
	       ,displayField: 'tmname'
	       ,urlStore: pre_url + '/code/ctumbon'
	       ,fieldStore: ['tmcode', 'tmname']
	    })
	    ,new Ext.ux.form.PisComboBox({
	       fieldLabel: 'คลังเบิกจ่าย'
	       ,hiddenName: 'fcode'
	       ,id: 'fcode'
	       ,valueField: 'fcode'
	       ,displayField: 'finname'
	       ,urlStore: pre_url + '/code/cfinpay'
	       ,fieldStore: ['fcode', 'finname']
	    })
	    ,{
	       xtype: "xcheckbox"
	       ,id: "use_status"
	       ,fieldLabel: "สถานะการใช้งาน"
	       ,submitOffValue:'0'
	       ,submitOnValue:'1'
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
					 ,success	:function(){		
						 Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
								 if (btn == 'ok'){
									 win.close();
									 code_subdeptGridStore.reload();
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
							 Ext.Msg.alert('สถานะ', 'Authentication server is unreachable : ' + action.response.responseText); 
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
	      title: 'เพิ่มหน่วยงาน'
	      ,width: 400
	      ,height: 500
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
   
   if (rec != undefined){
      Ext.getCmp("sdcode").setValue(rec.sdcode);
      Ext.getCmp("sdcode_tmp").setValue(rec.sdcode_tmp);
      Ext.getCmp("shortpre").setValue(rec.shortpre);
      Ext.getCmp("longpre").setValue(rec.longpre);
      Ext.getCmp("subdeptname").setValue(rec.subdeptname);
      Ext.getCmp("use_status").setValue(rec.use_status);      
      Ext.getCmp("sdgcode").getStore().load({
	 params: {
	    sdgcode: rec.sdgcode
	    ,start: 0
	    ,limit: 10
	 }
	 ,callback :function(){
	    Ext.getCmp("sdgcode").setValue(rec.sdgcode);
	 }
      });      
      Ext.getCmp("acode").getStore().load({
	 params: {
	    acode: rec.acode
	    ,start: 0
	    ,limit: 10
	 }
	 ,callback :function(){
	    Ext.getCmp("acode").setValue(rec.acode);
	 }
      });      
      Ext.getCmp("trlcode").getStore().load({
	 params: {
	    trlcode: rec.trlcode
	    ,start: 0
	    ,limit: 10
	 }
	 ,callback :function(){
	    Ext.getCmp("trlcode").setValue(rec.trlcode);
	 }
      });      
      Ext.getCmp("fcode").getStore().load({
	 params: {
	    fcode: rec.fcode
	    ,start: 0
	    ,limit: 10
	 }
	 ,callback :function(){
	    Ext.getCmp("fcode").setValue(rec.fcode);
	 }
      });      
      Ext.getCmp("lcode").getStore().load({
	 params: {
	    lcode: rec.lcode
	    ,start: 0
	    ,limit: 10
	 }
	 ,callback :function(){
	    Ext.getCmp("lcode").setValue(rec.lcode);
	 }
      });      
      Ext.getCmp("provcode").getStore().load({
	 params: {
	    provcode: rec.provcode
	    ,start: 0
	    ,limit: 10
	 }
	 ,callback :function(){
	    Ext.getCmp("provcode").setValue(rec.provcode);
	 }
      });
      if (rec.amcode != "" && rec.amcode != null){
	 Ext.getCmp("amcode").enable();
	 Ext.getCmp("amcode").getStore().load({
	    params: {
	       provcode: rec.provcode
	       ,amcode: rec.amcode
	       ,start: 0
	       ,limit: 10
	    }
	    ,callback :function(){
	       Ext.getCmp("amcode").setValue(rec.amcode);
	    }
	 });
	 Ext.getCmp("amcode").store.baseParams= {
	    provcode: rec.provcode
	 };
      }
      if (rec.tmcode != "" && rec.tmcode != null){	 
	 Ext.getCmp("tmcode").enable();
	 Ext.getCmp("tmcode").getStore().load({
	    params: {
	       provcode: rec.provcode
	       ,amcode: rec.amcode
	       ,tmcode: rec.tmcode
	       ,start: 0
	       ,limit: 10
	    }
	    ,callback :function(){
	       Ext.getCmp("tmcode").setValue(rec.tmcode);
	    }
	 });
	 Ext.getCmp("tmcode").store.baseParams= {
	    provcode: rec.provcode
	    ,amcode: rec.amcode
	 };	 
      }
      win.show();
      win.center(); 
      loadMask.hide();
   }
   else{
      win.show();
      win.center(); 
   }
  
}

function code_subdepDataEdit(sdcode){
   loadMask.show();
   Ext.Ajax.request({
      url: pre_url+'/csubdept/search_edit'
      ,params: {
	 sdcode: sdcode
      }
      ,success: function(response,opts){
	 obj = Ext.util.JSON.decode(response.responseText);	 
	 code_subdeptForm(pre_url+'/csubdept/update',obj.records[0])
      }
      ,failure: function(response,opts){
	 Ext.Msg.alert("สถานะ",response.statusText);
	 loadMask.hide();
      }
   });    
}

function code_subdepDataDelete(sdcode){
   loadMask.show();
   Ext.Ajax.request({
      url: pre_url+'/csubdept/delete'
      ,params: {
	 sdcode: sdcode
      }
      ,success: function(response,opts){
	 obj = Ext.util.JSON.decode(response.responseText);	 
	 if (obj.success == true){
	    code_subdeptGridStore.reload();
	 }
	 else if (obj.success == false){
	    Ext.Msg.alert('สถานะ', obj.msg);
	 }
	 
	 loadMask.hide();
      }
      ,failure: function(response,opts){
	 Ext.Msg.alert("สถานะ",response.statusText);
	 loadMask.hide();
      }
   });    
}
