var code_tumbonRowEditor_number = 0;

var code_tumbonFields = [
	{name: "tmcode_tmp",type: 'int'}
	,{name: "tmcode",type: 'int'}
	,{name: "provcode",type: 'int'}
	,{name: "amcode",type: 'int'}
	,{name: "shortpre",type: 'string'}
	,{name: "longpre",type: 'string'}
	,{name: "tmname",type: 'string'}
	,{name: "use_status",type: 'bool'}
];	

var code_tumbonNewRecord = Ext.data.Record.create(code_tumbonFields);

var code_tumbonWriter = new Ext.data.JsonWriter({
   writeAllFields: true
   ,createRecord : function(rec) {
      data = {
	 tmcode_tmp: rec.data.tmcode_tmp
	 ,tmcode: rec.data.tmcode
	 ,provcode: rec.data.provcode
	 ,amcode: rec.data.amcode
	 ,shortpre: rec.data.shortpre
	 ,longpre: rec.data.longpre
	 ,tmname: rec.data.tmname
	 ,use_status: rec.data.use_status
      };
      return data;
   }
   ,updateRecord : function(rec) {
      data = {
	 tmcode_tmp: rec.data.tmcode_tmp
	 ,tmcode: rec.data.tmcode
	 ,provcode: rec.data.provcode
	 ,amcode: rec.data.amcode
	 ,shortpre: rec.data.shortpre
	 ,longpre: rec.data.longpre
	 ,tmname: rec.data.tmname
	 ,use_status: rec.data.use_status
      };
      return data;
   }
});

var code_tumbonRowEditor = new Ext.ux.grid.RowEditor({
	saveText: 'บันทึก'
	,cancelText: 'ยกเลิก'
	,listeners: {
		validateedit: function(rowEditor, obj,data, rowIndex ) {	
			loadMask.show();
			code_tumbonRowEditor_number  = rowIndex
		}
		,canceledit: function(rowEditor, obj,data, rowIndex ) {	
			code_tumbonRowEditor_number  = rowIndex
		}
	}
});

var code_tumboncheckColumn = new Ext.grid.CheckColumn({
	header: 'สถานะการใช้งาน'
	,dataIndex: 'use_status'
	,width: 100
	,editor: new Ext.form.Checkbox()
});

var code_tumbonCols = [
	{
		header: "#"
		,width: 50
		,renderer: rowNumberer.createDelegate(this)
		, sortable: false
	},{
		header: "รหัสตำบล"
		,width: 100
		,sortable: false
		,dataIndex: 'tmcode_tmp'
		,editor: new Ext.form.NumberField({allowBlank: false})
	},{
		header: "ชื่อย่อคำนำหน้าตำบล"
		,width: 150
		,sortable: false
		,dataIndex: 'shortpre'
		,editor: new Ext.form.TextField()
	},{
		header: "คำนำหน้าตำบล"
		,width: 100
		,sortable: false
		,dataIndex: 'longpre'
		,editor: new Ext.form.TextField()
	},{
		header: "ตำบล"
		,width: 100
		,sortable: false
		,dataIndex: 'tmname'
		,editor: new Ext.form.TextField()
	}
	,code_tumboncheckColumn
	,{header: "รหัสจ.", width: 100, sortable: false, dataIndex: "provcode",hidden: true}
	,{header: "รหัสอ.", width: 100, sortable: false, dataIndex: "amcode",hidden: true}
	,{header: "รหัสต.", width: 100, sortable: false, dataIndex: "tmcode",hidden: true}
];	

var code_tumbonSearch = new Ext.ux.grid.Search({
	iconCls: 'search'
	,minChars: 3
	,autoFocus: true
	,position: "top"
	,width: 200
});

var code_tumbonProxy = new Ext.data.HttpProxy({
   api: {
	   read: pre_url + '/ctumbon/read'
	   ,create: pre_url + '/ctumbon/create'
	   ,update: pre_url + '/ctumbon/update'
	   ,destroy: pre_url + '/ctumbon/delete'
   }
});	

var code_tumbonGridStore = new Ext.data.JsonStore({
	proxy: code_tumbonProxy
	,root: 'records'
	,autoLoad: false
	,totalProperty: 'totalCount'
	,remoteSort: true
	,fields: code_tumbonFields
	,idProperty: 'tmcode'
	,successProperty: 'success'
	,writer: code_tumbonWriter
	,autoSave: true
	,listeners: {
		write: function (store,action,result,res,rs){
			if (res.success == true)
			{
				code_tumbonGridStore.load({ params: { start: 0, limit: 20} });
			} 
			loadMask.hide();		
		}
		,exception: function(proxy, type, action, option, res, arg) {
			if (action == "create")
			{
				var obj = Ext.util.JSON.decode(res.responseText);
				if (obj.success == false)
				{
					if (obj.msg)
					{					
						Ext.Msg.alert("สถานะ",obj.msg, 
							function(btn, text){										
								if (btn == 'ok')
								{
									code_tumbonGridStore.removeAt(code_tumbonRowEditor_number);
									code_tumbonGrid.getView().refresh();
								}
							}
						);
					}
				}
			}
			if (action == "update")
			{
				if (res.success == false)
				{
					if (res.raw.msg)
					{					
						Ext.Msg.alert("สถานะ",res.raw.msg, 
							function(btn, text){										
								if (btn == 'ok')
								{
									code_tumbonGridStore.reload();
								}
							}
						);
					}
				}
			}
			loadMask.hide();
		}
	}	
});	

var code_tumbonGrid = new Ext.grid.GridPanel({
	title: "ตำบล"
	,region: 'center'
	,disabled: true
	,split: true
	,store: code_tumbonGridStore
	,columns: code_tumbonCols
	,stripeRows: true
	,loadMask: {msg:'Loading...'}
	,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
	,plugins: [code_tumbonRowEditor,code_tumbonSearch]
	,tbar: [
		{
			text: 'เพิ่ม'
			,tooltip: 'เพิ่ม'
			,iconCls: 'table-add'
			,handler: function(){
				var e = new code_tumbonNewRecord({
				    tmcode_tmp: ""
				    ,tmcode: ""
				    ,provcode: ct_source_province.getValue()
				    ,amcode: ct_source_amphur.getValue()
				    ,shortpre: ""
				    ,longpre: ""
				    ,tmname: ""
				    ,use_status: ""
				});
				code_tumbonRowEditor.stopEditing();
				code_tumbonGridStore.insert(0, e);
				code_tumbonGrid.getView().refresh();
				code_tumbonGrid.getSelectionModel().selectRow(0);
				code_tumbonRowEditor.startEditing(0);
			}
		},"-",{
			ref: '../removeBtn'
			,text: 'ลบ'
			,tooltip: 'ลบ'
			,iconCls: 'table-delete'
			,disabled: true
			,handler: function(){
				loadMask.show();
				code_tumbonRowEditor.stopEditing();
				var s = code_tumbonGrid.getSelectionModel().getSelections();
				for(var i = 0, r; r = s[i]; i++){
					code_tumbonGridStore.remove(r);
					code_tumbonGrid.getView().refresh();
				}
			}
		},"-",{
			text: "Export"
			,iconCls: "door-out"
			,menu: {
				items: [
					{
						text: "Excel"
						,iconCls: "excel"
						,handler: function() {
							var data = Ext.util.JSON.encode(code_tumbonGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/ctumbon/report?format=xls");
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
							var data = Ext.util.JSON.encode(code_tumbonGridStore.lastOptions.params);
							var form = document.createElement("form");
							form.setAttribute("method", "post");
							form.setAttribute("action", pre_url + "/ctumbon/report?format=pdf");
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
		,store: code_tumbonGridStore
		,displayInfo: true
		,displayMsg: 'Displaying {0} - {1} of {2}'
		,emptyMsg: "Not found"
	})
});


code_tumbonGrid.getSelectionModel().on('selectionchange', function(sm){
	code_tumbonGrid.removeBtn.setDisabled(sm.getCount() < 1);
});

var ct_source_province = new Ext.ux.form.PisComboBox({	
   fieldLabel: 'จังหวัด'
   ,valueField: 'provcode'
   ,displayField: 'provname'
   ,urlStore: pre_url + '/code/cprovince'
   ,fieldStore: ['provcode', 'provname']
   ,listeners:{																							
      select: function(){
	 ct_source_amphur.getStore().removeAll();
	 ct_source_amphur.getStore().baseParams = {	
		 random: Math.random()
		 ,provcode: ct_source_province.getValue()
	 };
	 ct_source_amphur.getStore().load({params:{start:0,limit:10}});	
	 ct_source_amphur.clearValue();
	 ct_source_amphur.enable();
	 delete(code_tumbonGridStore.baseParams["provcode"]);
	 delete(code_tumbonGridStore.baseParams["amcode"]);
	 if (code_tumbonGridStore.lastOptions && code_tumbonGridStore.lastOptions.params) {			    
		 delete(code_tumbonGridStore.lastOptions.params["provcode"]);
		 delete(code_tumbonGridStore.lastOptions.params["amcode"]);
	 }
	 code_tumbonGridStore.load({ params: {random: Math.random(),reset: 1} });
	 code_tumbonGrid.disable();
      }
   }
});

var ct_source_amphur = new Ext.ux.form.PisComboBox({
   fieldLabel: 'อำเภอ'
   ,disabled: true
   ,valueField: 'amcode'
   ,displayField: 'amname'
   ,urlStore: pre_url + '/code/camphur'
   ,fieldStore: ['amcode', 'amname']	 
   ,listeners:{																							
       select: function(){
	       delete(code_tumbonGridStore.baseParams["provcode"]);
	       delete(code_tumbonGridStore.baseParams["amcode"]);
	       if (code_tumbonGridStore.lastOptions && code_tumbonGridStore.lastOptions.params) {			    
		       delete(code_tumbonGridStore.lastOptions.params["provcode"]);
		       delete(code_tumbonGridStore.lastOptions.params["amcode"]);
	       }
	       code_tumbonGridStore.baseParams["provcode"] = ct_source_province.getValue()
	       code_tumbonGridStore.baseParams["amcode"] = ct_source_amphur.getValue()
	       code_tumbonGridStore.load({ params: { start: 0, limit: 20} });
	       code_tumbonGrid.enable();
       }
   }
});

var code_tumbonNorth = new Ext.Panel({
	region: "north"
	,layout: 'hbox' 
	,height: 50
	,layoutConfig: { 
		align: 'middle'
		,pack: "center"
	}
	,defaults:{
		margins:'0 20 0 0'
	}
	,items: [
		{
			xtype: "label"
			,text: "จังหวัด:"
			,margins:'0 5 0 0'
		}
		,ct_source_province
		,{
			xtype: "label"
			,text: "อำเภอ:"
			,margins:'0 5 0 0'
		}
		,ct_source_amphur
		
	]
});


var code_tumbonPanel = new Ext.Panel({
	layout: "border"
	,items: [
		code_tumbonGrid,code_tumbonNorth
	]
	,listeners: {
		beforedestroy: function(p){
			code_tumbonRowEditor.stopEditing();
		}
	}
})