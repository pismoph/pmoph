var pre_url = ""; 

//---------------------------------------------------------------------------

var text1 = new Ext.form.TextField({
	id: 'text1',
	fieldLabel: 'คำสั่ง',
	width: 595,
	allowBlank: false
});

var text2 = new Ext.form.TextField({
	id: 'text2',
	fieldLabel: 'เลขที่ตำแหน่ง',
	width: 120,
	allowBlank: false,
	enableKeyEvents: true,
	listeners: {
		keypress: function( me, e ){
			if(e.keyCode == e.ENTER){
				text2_get_position(me);
			}
		},
		change: function( me, newValue, oldValue ){
			if(me.getValue() != ""){
				text2_get_position(me);
			}
		}
	}
});

var text4 = new Ext.form.NumberField({
	id: 'text4',
	fieldLabel: 'หน่วยงาน',
	width: 100,
	allowBlank: false,
	enableKeyEvents: true,
	listeners: {
		keypress: function( me, e ){
			if(e.keyCode == e.ENTER){
				if(me.getValue() != ""){
					Ext.Ajax.request({
						method: 'post',
						url: pre_url+'/cmd3/get_place',
						params: {id: me.getValue()},
						success: function(result, request ) {
							var dat = Ext.util.JSON.decode(result.responseText).Records;
							if(dat.length == 0){
								text7.setValue('');
								Ext.Msg.show({
									title:'ไม่พบข้อมูล',
									msg: 'ไม่พบข้อมูลหน่วยงานที่ค้นหา',
									buttons: Ext.Msg.OK,
									fn: function(){},
									animEl: 'text4',
									icon: Ext.MessageBox.ERROR
								});
							} else {
								text7.setValue(dat[0].fullsubdeptname);
							}
						}
					});
				}
			}
		}
	}
});

var text5 = new Ext.form.NumberField({
	id: 'text5',
	fieldLabel: 'เงินเดือน (บาท)',
	width: 220
});

var text6 = new Ext.form.TextField({
	id: 'text6',
	fieldLabel: 'หมายเหตุ',
	width: 615
});

var text7 = new Ext.form.TextField({
	id: 'text7',
	fieldLabel: '',
	width: 493,
	readOnly: true,
	hideLabel: true,
	style: {
		background: '#CCCCCC'
	},
	value: ''
});

var text8 = new Ext.form.TextField({
	id: 'text8',
	fieldLabel: 'ชื่อ - สกุล',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	},
	value: ''
});

var date1 = new Ext.form.DateField({
	id: 'date1',
	fieldLabel: 'วันที่มีผลบังคับใช้',
	format: 'd/m/Y',
	width: 100,
	allowBlank: false
});

var button1 = new Ext.Button({
	id: 'button1',
	iconCls: 'zoom',
	text: '',
	tooltip: 'ค้นหาตำแหน่งข้าราชการที่ครอง',
	listeners: {
		click: function(){
			winSearchPosition.setPosition(button1.getPosition());
			winSearchPosition.show();
			cmbSearchPosition.setValue(1); //เมื่อเปิดหน้าต่างครั้งแรกให้ แสดงรายชื่อตำแหน่งชื่อคนมาทั้งหมด
			funcSearchPosition();
		}
	}
});

var button2 = new Ext.Button({
	id: 'button2',
	iconCls: 'zoom',
	text: ''
});

var combo1 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'การเคลื่อนไหว'
	,hiddenName: 'combo1'
	,allowBlank: false
	,width: 320
	,valueField: 'updcode'
	,displayField: 'updname'
	,urlStore: pre_url + '/code/cupdate'
	,fieldStore: ['updcode', 'updname']
});

var combo2 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'ตำแหน่งสายงาน'
	,hiddenName: 'combo2'
	,width: 220
	,valueField: 'poscode'
	,displayField: 'posname'
	,urlStore: pre_url + '/code/cposition'
	,fieldStore: ['poscode', 'posname']
});

var combo3 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'ตำแหน่งบริหาร'
	,hiddenName: 'combo3'
	,width: 220
	,valueField: 'excode'
	,displayField: 'exname'
	,urlStore: pre_url + '/code/cexecutive'
	,fieldStore: ['excode', 'exname']
});

var combo4 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'กระทรวง'
	,hiddenName: 'combo4'
	,width: 220
	,valueField: 'mcode'
	,displayField: 'minname'
	,urlStore: pre_url + '/code/cministry'
	,fieldStore: ['mcode', 'minname']
});

var combo5 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'กรม'
	,hiddenName: 'combo5'
	,width: 220
	,valueField: 'deptcode'
	,displayField: 'deptname'
	,urlStore: pre_url + '/code/cdept'
	,fieldStore: ['deptcode', 'deptname']
});

var combo6 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'กลุ่มภารกิจ'
	,hiddenName: 'combo6'
	,width: 220
	,valueField: 'subsdcode'
	,displayField: 'subsdname'
	,urlStore: pre_url + '/code/csubsdcode'
	,fieldStore: ['subsdcode', 'subsdname']
});

var combo7 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'งาน'
	,hiddenName: 'combo7'
	,width: 220
	,valueField: 'jobcode'
	,displayField: 'jobname'
	,urlStore: pre_url + '/code/cjob'
	,fieldStore: ['jobcode', 'jobname']
});

var combo8 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'ระดับ'
	,hiddenName: 'combo8'
	,width: 220
	,valueField: 'ccode'
	,displayField: 'cname'
	,urlStore: pre_url + '/code/cgrouplevel'
	,fieldStore: ['ccode', 'cname']
});

var combo9 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'ความเชี่ยวชาญ'
	,hiddenName: 'combo9'
	,width: 220
	,valueField: 'epcode'
	,displayField: 'expert'
	,urlStore: pre_url + '/code/cexpert'
	,fieldStore: ['epcode', 'expert']
});

var combo10 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'กอง'
	,hiddenName: 'combo10'
	,width: 220
	,valueField: 'dcode'
	,displayField: 'division'
	,urlStore: pre_url + '/code/cdivision'
	,fieldStore: ['dcode', 'division']
});

var combo11 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'ฝ่าย / กลุ่มงาน'
	,hiddenName: 'combo11'
	,width: 220
	,valueField: 'seccode'
	,displayField: 'secname'
	,urlStore: pre_url + '/code/csection'
	,fieldStore: ['seccode', 'secname']
});

var combo12 = new Ext.form.ComboBox({
	hiddenName: 'combo12',
	editable: true,
	fieldLabel: 'โครงสร้างภายใน',
	mode: 'local',
	width: 220,
	triggerAction: 'all',
	valueField: 'off_id',
	displayField: 'off_name',
	store: new Ext.data.Store({
		url: 'person_pcucode.php',
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['off_id', 'off_name']
		}),
		listeners: {
			load : function( Store, records, options ) {
				
			}
		}
	})
});

var combo13 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'ว. / วช. /ชช.'
	,hiddenName: 'combo13'
	,width: 220
	,valueField: 'ptcode'
	,displayField: 'ptname'
	,urlStore: pre_url + '/code/cpostype'
	,fieldStore: ['ptcode', 'ptname']
});

var combo14 = new Ext.form.ComboBox({
	hiddenName: 'combo14',
	editable: true,
	fieldLabel: 'ปฏิบัติงานตรง จ.18',
	mode: 'local',
	width: 220,
	triggerAction: 'all',
	valueField: 'j18code',
	displayField: 'j18status',
	store: new Ext.data.Store({
		url: pre_url+'/code/cj18status',
		autoLoad: true,
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['j18code', 'j18status']
		}),
		listeners: {
			load : function( Store, records, options ) {
				
			}
		}
	})
});

var fieldset1 = new Ext.form.FieldSet({
	title: '',
	autoWidth: true,
	autoHeight: true,
	items : [
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text2]
				},
				{
					layout: 'form',
					items: [button1]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text8]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo14]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo2]
				},
				{
					layout: 'form',
					items: [combo8],
					style: 'padding-left:50px'
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text5]
				},
				{
					layout: 'form',
					items: [combo13],
					style: 'padding-left:50px'
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo3]
				},
				{
					layout: 'form',
					items: [combo9],
					style: 'padding-left:50px'
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo4]
				},
				{
					layout: 'form',
					items: [combo5],
					style: 'padding-left:50px'
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo10]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text4]
				},
				{
					layout: 'form',
					items: [text7]
				},
				{
					layout: 'form',
					items: [button2]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo6]
				},
				{
					layout: 'form',
					items: [combo11],
					style: 'padding-left:50px'
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo7]
				},
				{
					layout: 'form',
					items: [combo12],
					style: 'padding-left:50px'
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text6]
				}
			]
		}
	]
});

var frmAddEdit = new Ext.form.FormPanel({
	id: 'frmAddEdit',
	title: 'บันทึกคำสั่งปฏิบัติราชการ',
	labelAlign: 'left',
	labelWidth: 120,
	autoScroll: true,
	frame: true,
	monitorValid: true,
	region: 'center',
	items: [
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo1]
				},
				{
					layout: 'form',
					items: [date1],
					style: 'padding-left:50px'
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text1]
				}
			]
		},
		fieldset1
	],
	buttons: [
		{
			text: 'บันทึก',
			iconCls: 'disk',
			formBind: true,
			listeners: {
				click: function(){
					save_data();
				}
			}
		},
		{
			text: 'ยกเลิก',
			iconCls: 'arrow-undo',
			listeners: {
				click: function(){
					reset_form();
				}
			}
		}
	]
});

/*var viewport = new Ext.Viewport({
	layout: 'border',
	renderTo: Ext.getBody(),
	//autoScroll: true,
	items: [
		frmAddEdit
	]
});*/

function text2_get_position(me){
	Ext.Ajax.request({
		method: 'post',
		url: pre_url+'/cmd3/get_position',
		params: {posid: me.getValue()},
		success: function(result, request ) {
			var x = me.getValue();
			var dat = Ext.util.JSON.decode(result.responseText).Records[0];
			if(Ext.util.JSON.decode(result.responseText).Records.length > 0){
				text2.setValue(x);
				text8.setValue(dat.fullname);
				//text6.setValue(dat.note);
				combo14.setValue(dat.j18code);
				
				//combo2.setValue(dat.poscode);
				combo2.getStore().load({
					params: {
						poscode: dat.poscode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo2.setValue(dat.poscode);
					}
				});
				
				//combo8.setValue(dat.ccode);
				combo8.getStore().load({
					params: {
						ccode: dat.ccode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo8.setValue(dat.ccode);
					}
				});
				
				//เงินเดือน
				text5.setValue(dat.salary);
				
				//combo3.setValue(dat.excode);
				combo3.getStore().load({
					params: {
						excode: dat.excode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo3.setValue(dat.excode);
					}
				});
				
				//combo9.setValue(dat.epcode);
				combo9.getStore().load({
					params: {
						epcode: dat.epcode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo9.setValue(dat.epcode);
					}
				});
				
				//combo13.setValue(dat.ptcode);
				combo13.getStore().load({
					params: {
						ptcode: dat.ptcode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo13.setValue(dat.ptcode);
					}
				});
				
				//combo4.setValue(dat.mincode);
				combo4.getStore().load({
					params: {
						mcode: dat.mincode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo4.setValue(dat.mincode);
					}
				});
				
				//combo5.setValue(dat.deptcode);
				combo5.getStore().load({
					params: {
						deptcode: dat.deptcode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo5.setValue(dat.deptcode);
					}
				});
				
				//combo10.setValue(dat.dcode);
				combo10.getStore().load({
					params: {
						dcode: dat.dcode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo10.setValue(dat.dcode);
					}
				});
				
				text4.setValue(dat.sdcode);
				text7.setValue(dat.fullsubdeptname);
				
				//combo11.setValue(dat.seccode);
				combo11.getStore().load({
					params: {
						seccode: dat.seccode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo11.setValue(dat.seccode);
					}
				});
				
				//combo7.setValue(dat.jobcode);
				combo7.getStore().load({
					params: {
						jobcode: dat.jobcode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo7.setValue(dat.jobcode);
					}
				});
				
				combo6.setValue("");
				combo12.setValue("");
			} else {
				Ext.Msg.show({
					title:'ไม่พบข้อมูล',
					msg: 'เลขที่ตำแหน่งนี้จะต้องเป็นตำแหน่งที่มีคนครองอยู่เท่านั้น',
					buttons: Ext.Msg.OK,
					fn: function(){},
					icon: Ext.MessageBox.ERROR
				});
				//ก่อนจะรีเซตฟอร์ม ต้องสำรองข้อมูลใน การเคลื่อนไหว, คำสั่ง และ วันที่มีผลบังคับใช้ เอาไว้ก่อน
				a = combo1.getValue();
				b = text1.getValue();
				c = date1.getValue();
				frmAddEdit.getForm().reset();
				combo1.setValue(a);
				text1.setValue(b);
				if(c != ""){
					c = c.format("d")+"/"+c.format("m")+"/"+ (Number(c.format("Y"))+543).toString();
					date1.setValue(c);
				}
			}
		}
	});
}

function funcSearchPosition(){
	GridStorePosition.baseParams = {
		condition_id: cmbSearchPosition.getValue(),
		query: txtSearchPosition.getValue()
	};
	GridStorePosition.load({
		params:{
			start: 0,
			limit: 100
		}
	});
}

var GridStorePosition = new Ext.data.JsonStore({
	url: pre_url+'/cmd3/list_position',
	root: 'Records',
	totalProperty: 'totalCount',
	idProperty: 'posid',
	fields: [
		"posid",
		"posname",
		"fullname"
	]
});

var GridPosition = new Ext.grid.GridPanel({
	id: 'GridPosition',
	title: '',
	frame: false,
	stripeRows: true,
	store: GridStorePosition,
	viewConfig: {forceFit: true},
	loadMask: {
		msg: 'Please wait...'
	},
	columns: [
		new Ext.grid.RowNumberer(),
		{header: "เลขที่ตำแหน่ง",dataIndex: 'posid', width: 4, sortable: true},
		{header: "ตำแหน่ง",dataIndex: 'posname', width: 10, sortable: true},
		{header: "ชื่อ - นามสกุล",dataIndex: 'fullname', width: 10, sortable: true}
	],
	listeners: {
		rowdblclick: function( me, rowIndex, e ){
			text2.setValue(me.selModel.selections.items[0].data.posid);
			winSearchPosition.hide();
			text2_get_position(text2);
		}
	},
	tbar: [
		'ค้นหาโดย : ',
		cmbSearchPosition = new Ext.form.ComboBox({
			hiddenName: 'cmbSearchPosition',
			mode: 'local',
			width: 200,
			triggerAction: 'all',
			valueField: 'condition_id',
			displayField: 'condition_text',
			store: new Ext.data.ArrayStore({
				fields: ['condition_id', 'condition_text'],
				data: [['1', 'ชื่อ-นามสกุลผู้ครองตำแหน่ง'], ['2', 'ตำแหน่งสายงาน']]
			}),
			listeners: {
				select : function( me, record, index ) {
					funcSearchPosition();
				}
			}
		}),
		'คำค้นหา : ',
		txtSearchPosition = new Ext.form.TextField({
			id: 'txtSearchPosition',
			width: 200,
			enableKeyEvents: true,
			listeners: {
				keypress: function( me, e ){
					if(e.keyCode == e.ENTER){
						funcSearchPosition();
					}
				}
			}
		}),
		btnSearchPosition = new Ext.Button({
			id: 'btnSearchPosition',
			iconCls: 'zoom',
			text: '',
			listeners: {
				click: function(){
					funcSearchPosition();
				}
			}
		})
	],
	bbar: new Ext.PagingToolbar({
		store: GridStorePosition,
		pageSize: 100,
		displayInfo: true,
		displayMsg: 'รายการที่ {0} - {1} จากทั้งหมด {2}',
		emptyMsg: "ไม่มีข้อมูล"
	})
});

var winSearchPosition = new Ext.Window({
	title: 'ค้นหาข้าราชการ',
	iconCls: 'book-open',
	applyTo: 'div_window_searchposition',
	layout: 'fit',
	width: 600,
	height: 420,
	autoScroll: true,
	closeAction: 'hide',
	modal: true,
	items: [
		GridPosition
	],
	buttons: [
		{
			text: 'ตกลง',
			iconCls: 'accept',
			formBind: true,
			listeners: {
				click: function(){
					if( GridPosition.selModel.selections.items.length != 0 ){
						text2.setValue(GridPosition.selModel.selections.items[0].data.posid);
						winSearchPosition.hide();
						text2_get_position(text2);
					} else {
						Ext.Msg.alert("Error", "กรุณาคลิกเลือกเลขที่ตำแหน่งที่ต้องการ");
					}
				}
			}
		},
		{
			text: 'ยกเลิก',
			iconCls: 'arrow-undo',
			listeners: {
				click: function(){
					winSearchPosition.hide();
				}
			}
		}
	]
});

function save_data(){
	Ext.Ajax.request({
		method: 'post',
		url: pre_url+'/cmd3/save',
		params: {
			updcode: combo1.getValue(), //การเคลื่อนไหว
			refcmnd: text1.getValue(), //คำสั่ง
			forcedate: date1.getValue(), //วันที่มีผลบังคับใช้

			posid: text2.getValue(), //เลขที่ตำแหน่ง
			
			j18code: combo14.getValue(), //ปฏิบัติงานตรง จ.18
			poscode: combo2.getValue(), //ตำแหน่งสายงาน
			c: combo8.getValue(), //ระดับ
			salary: text5.getValue(), //เงินเดือน
			excode: combo3.getValue(), //ตำแหน่งบริหาร
			epcode: combo9.getValue(), //ความเชี่ยวชาญ
			ptcode: combo13.getValue(), //ว./วช./ชช.
			mincode: combo4.getValue(), //กระทรวง
			deptcode: combo5.getValue(), //กรม
			dcode: combo10.getValue(), //กอง
			sdcode: text4.getValue(), //รหัสหน่วยงาน
			seccode: combo11.getValue(), //ฝ่าย /กลุ่มงาน
			jobcode: combo7.getValue(), //งาน

			note: 'ไปปฏิบัติราชการ '+text7.getValue()+' '+text6.getValue(), //หมายเหตุ
			
			upddate: '', //วันที่บันทึก เดี๋ยวให้ทาง postgres บันทึกเวลาเอง
			upduser: 'admin' //user ที่บันทึก
		},
		success: function(result, request ) {
			obj = Ext.util.JSON.decode(result.responseText);
			//debugger;
			if( obj.success == true){
				Ext.Msg.show({
					title:'Complete',
					msg: 'บันทึกข้อมูลเสร็จแล้ว',
					buttons: Ext.Msg.OK,
					fn: function(){
						//ก่อนจะรีเซตฟอร์ม ต้องสำรองข้อมูลใน การเคลื่อนไหว, คำสั่ง และ วันที่มีผลบังคับใช้ เอาไว้ก่อน
						a = combo1.getValue();
						b = text1.getValue();
						c = date1.getValue();
						frmAddEdit.getForm().reset();
						//การเคลื่อนไหว
						combo1.getStore().load({
							params: {
								updcode: a
								,start: 0
								,limit: 10
							},
							callback :function(){
								combo1.setValue(a);
							}
						});
						text1.setValue(b);
						if(c != ""){
							c = c.format("d")+"/"+c.format("m")+"/"+ (Number(c.format("Y"))+543).toString();
							date1.setValue(c);
						}
					},
					animEl: 'text1',
					icon: Ext.MessageBox.INFO
				});
			} else {
				Ext.Msg.show({
					title:'Error',
					msg: 'เกิดข้อผิดพลาดในการบันทึก',
					buttons: Ext.Msg.OK,
					fn: function(){},
					animEl: 'text1',
					icon: Ext.MessageBox.ERROR
				});
			}
		}
	});
}

function reset_form(){
	frmAddEdit.getForm.reset();
}





