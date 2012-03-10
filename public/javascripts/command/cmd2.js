var pre_url = "";

//---------------------------------------------------------------------------

var txtCommandNumber = new Ext.form.TextField({
	id: 'txtCommandNumber',
	fieldLabel: 'เลขที่คำสั่ง',
	width: 400
});

var dateForce = new Ext.form.DateField({
	fieldLabel: 'วันที่คำสั่งมีผลบังคับ',
	format: 'd/m/Y'
});

var cmbCodeUpdate = new Ext.form.ComboBox({
	hiddenName: 'cmbCodeUpdate',
	editable: true,
	fieldLabel: 'การเคลื่อนไหว',
	mode: 'local',
	width: 685,
	triggerAction: 'all',
	valueField: 'updcode',
	displayField: 'updname',
	store: new Ext.data.Store({
		url: '/code/cupdate',
		autoLoad: true,
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['updcode', 'updname']
		}),
		listeners: {
			load : function( Store, records, options ) {
				
			}
		}
	})
});

var txtRemark = new Ext.form.TextField({
	fieldLabel: 'หมายเหตุ',
	width: 685
});

var radio1 = new Ext.form.RadioGroup({
	fieldLabel: '',
	columns: 5,
	width: 650,
	items: [{
		name: 'radio1',
		inputValue: '1',
		boxLabel: 'สับตรง'
	},{
		name: 'radio1',
		inputValue: '2',
		boxLabel: 'สับเปลี่ยนเงิน'
	},{
		name: 'radio1',
		inputValue: '3',
		boxLabel: 'ขาดอัตรามาเบิก'
	},{
		name: 'radio1',
		inputValue: '4',
		boxLabel: 'อาศัยเบิก'
	},{
		name: 'radio1',
		inputValue: '5',
		boxLabel: 'ไม่มี',
		checked: true
	}]
});

var txtPosition = new Ext.form.NumberField({
	fieldLabel: 'เลขที่ตำแหน่ง',
	width: 120,
	enableKeyEvents: true,
	listeners: {
		keypress: function( me, e ){
			if(e.keyCode == e.ENTER){
				Ext.Ajax.request({
					method: 'post',
					url: 'cmd2_get_olddata.php',
					params: {posid: me.getValue()},
					success: function(result, request ) {
						var x = me.getValue();
						var dat = Ext.util.JSON.decode(result.responseText).Records[0];
						if(Ext.util.JSON.decode(result.responseText).Records.length > 0){
							txtPosition.setValue(x);
							text8.setValue(dat.fname+" "+dat.lname);
							cmbPosition.setValue(dat.poscode);
							cmbGrouplevel.setValue(dat.ccode);
							txtSalary.setValue(dat.salary);
						} else {
							Ext.Msg.alert("Error","ไม่พบข้อมูลตำแหน่ง");
						}
					}
				});	
			}
		}
	}
});

var txtPositionOld = new Ext.form.NumberField({
	fieldLabel: 'เลขที่ตำแหน่ง',
	width: 120,
	enableKeyEvents: true,
	listeners: {
		keypress: function( me, e ){
			if(e.keyCode == e.ENTER){
				Ext.Ajax.request({
					method: 'post',
					url: 'cmd2_get_olddata.php',
					params: {posid: me.getValue()},
					success: function(result, request ) {
						var x = me.getValue();
						frmAddEdit.getForm().reset();
						var dat = Ext.util.JSON.decode(result.responseText).Records[0];
						if(Ext.util.JSON.decode(result.responseText).Records.length > 0){
							txtPositionOld.setValue(x);
							text21.setValue(dat.fname+" "+dat.lname);
							text22.setValue(dat.longpre+" "+dat.posname);
							text23.setValue(dat.cname);
							text24.setValue(dat.salary);
							
							txtPosition.setValue(txtPositionOld.getValue());
							text8.setValue(dat.fname+" "+dat.lname);
							cmbPosition.setValue(dat.poscode);
							cmbGrouplevel.setValue(dat.ccode);
							txtSalary.setValue(dat.salary);
						} else {
							Ext.Msg.alert("Error","ไม่พบข้อมูลตำแหน่ง");
						}
					}
				});	
			}
		}
	}
});

var text4 = new Ext.form.NumberField({
	id: 'text4',
	fieldLabel: 'ชื่อหน่วยงาน',
	width: 100
});

var txtSalary = new Ext.form.NumberField({
	id: 'txtSalary',
	fieldLabel: 'เงินเดือน',
	width: 120
});



var text7 = new Ext.form.TextField({
	id: 'text7',
	fieldLabel: '',
	width: 250,
	readOnly: true,
	hideLabel: true,
	style: {
		background: '#CCCCCC'
	}
});

var text8 = new Ext.form.TextField({
	id: 'text8',
	fieldLabel: 'ชื่อผู้ครองตำแหน่งเดิม',
	width: 350,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text21 = new Ext.form.TextField({
	id: 'text21',
	fieldLabel: 'ชื่อผู้ครองตำแหน่ง',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text22 = new Ext.form.TextField({
	id: 'text22',
	fieldLabel: 'ตำแหน่งสายงาน',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text23 = new Ext.form.TextField({
	id: 'text23',
	fieldLabel: 'ระดับ',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text24 = new Ext.form.TextField({
	id: 'text24',
	fieldLabel: 'เงินเดือน',
	width: 120,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text25 = new Ext.form.TextField({
	id: 'text25',
	fieldLabel: 'ตำแหน่งบริหาร',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text26 = new Ext.form.TextField({
	id: 'text26',
	fieldLabel: 'ความเชี่ยวชาญ',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text27 = new Ext.form.TextField({
	id: 'text27',
	fieldLabel: 'ว. / วช. / ชช.',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text28 = new Ext.form.TextField({
	id: 'text28',
	fieldLabel: 'กอง',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text29 = new Ext.form.TextField({
	id: 'text29',
	fieldLabel: 'ชื่อหน่วยงาน',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text30 = new Ext.form.TextField({
	id: 'text30',
	fieldLabel: 'กลุ่ม',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text31 = new Ext.form.TextField({
	id: 'text31',
	fieldLabel: 'ฝ่าย / กลุ่มงาน',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text32 = new Ext.form.TextField({
	id: 'text32',
	fieldLabel: 'งาน',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text40 = new Ext.form.TextField({
	id: 'text40',
	fieldLabel: 'อาศัยเบิกอันดับ',
	width: 80
});

var text41 = new Ext.form.TextField({
	id: 'text41',
	fieldLabel: 'ขั้น',
	width: 150
});

var text42 = new Ext.form.TextField({
	id: 'text42',
	fieldLabel: 'กรม',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text43 = new Ext.form.TextField({
	id: 'text43',
	fieldLabel: 'กอง',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text44 = new Ext.form.TextField({
	id: 'text44',
	fieldLabel: 'ชื่อหน่วยงาน',
	width: 750,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text45 = new Ext.form.TextField({
	id: 'text45',
	fieldLabel: 'กลุ่ม',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text46 = new Ext.form.TextField({
	id: 'text46',
	fieldLabel: 'ฝ่าย / กลุ่มงาน',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text47 = new Ext.form.TextField({
	id: 'text47',
	fieldLabel: 'งาน',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text48 = new Ext.form.TextField({
	id: 'text48',
	fieldLabel: 'โครงสร้างภายใน',
	width: 300,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});


var button1 = new Ext.Button({
	id: 'button1',
	iconCls: 'zoom',
	text: ''
});

var button2 = new Ext.Button({
	id: 'button2',
	iconCls: 'zoom',
	text: ''
});



var cmbPosition = new Ext.form.ComboBox({
	hiddenName: 'cmbPosition',
	editable: true,
	fieldLabel: 'ตำแหน่งสายงาน',
	mode: 'local',
	width: 350,
	triggerAction: 'all',
	valueField: 'poscode',
	displayField: 'posname',
	store: new Ext.data.Store({
		url: '/code/cposition',
		autoLoad: true,
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['poscode', 'posname']
		}),
		listeners: {
			load : function( Store, records, options ) {
				
			}
		}
	})
});

var cmbExecutive = new Ext.form.ComboBox({
	hiddenName: 'cmbExecutive',
	editable: true,
	fieldLabel: 'ตำแหน่งบริหาร',
	mode: 'local',
	width: 350,
	triggerAction: 'all',
	valueField: 'excode',
	displayField: 'exname',
	store: new Ext.data.Store({
		url: '/code/cexecutive',
		autoLoad: true,
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['excode', 'exname']
		}),
		listeners: {
			load : function( Store, records, options ) {
				
			}
		}
	})
});

var cmbExpert = new Ext.form.ComboBox({
	hiddenName: 'cmbExpert',
	editable: true,
	fieldLabel: 'ความเชี่ยวชาญ',
	mode: 'local',
	width: 350,
	triggerAction: 'all',
	valueField: 'epcode',
	displayField: 'expert',
	store: new Ext.data.Store({
		url: '/code/cexpert',
		autoLoad: true,
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['epcode', 'expert']
		}),
		listeners: {
			load : function( Store, records, options ) {
				
			}
		}
	})
});

var cmbPostype = new Ext.form.ComboBox({
	hiddenName: 'cmbPostype',
	editable: true,
	fieldLabel: 'ว. / วช. /ชช.',
	mode: 'local',
	width: 350,
	triggerAction: 'all',
	valueField: 'ptcode',
	displayField: 'ptname',
	store: new Ext.data.Store({
		url: '/code/cpostype',
		autoLoad: true,
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['ptcode', 'ptname']
		}),
		listeners: {
			load : function( Store, records, options ) {
				
			}
		}
	})
});

var cmbJob = new Ext.form.ComboBox({
	hiddenName: 'cmbJob',
	editable: true,
	fieldLabel: 'งาน',
	mode: 'local',
	width: 350,
	triggerAction: 'all',
	valueField: 'jobcode',
	displayField: 'jobname',
	store: new Ext.data.Store({
		url: '/code/cjob',
		autoLoad: true,
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['jobcode', 'jobname']
		}),
		listeners: {
			load : function( Store, records, options ) {
				//combo28.setValue(combo28.getValue());
			}
		}
	})
});

var cmbJ18status = new Ext.form.ComboBox({
	hiddenName: 'cmbJ18status',
	editable: true,
	fieldLabel: 'ปฏิบัติงานจริง',
	mode: 'local',
	width: 220,
	triggerAction: 'all',
	valueField: 'j18code',
	displayField: 'j18status',
	store: new Ext.data.Store({
		url: '/code/cj18status',
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

var cmbDiv = new Ext.form.ComboBox({
	hiddenName: 'cmbDiv',
	editable: true,
	fieldLabel: 'กอง',
	mode: 'local',
	width: 350,
	triggerAction: 'all',
	valueField: 'dcode',
	displayField: 'division',
	store: new Ext.data.Store({
		url: '/code/cdivision',
		autoLoad: true,
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['dcode', 'division']
		}),
		listeners: {
			load : function( Store, records, options ) {
				//combo10.setValue(combo10.getValue());
			}
		}
	})
});

var cmbSectionG = new Ext.form.ComboBox({
	hiddenName: 'cmbSectionG',
	editable: true,
	fieldLabel: 'กลุ่มภารกิจ',
	mode: 'local',
	width: 350,
	triggerAction: 'all',
	valueField: 'subsdcode',
	displayField: 'subsdname',
	store: new Ext.data.Store({
		url: '/code/csubsdcode',
		autoLoad: true,
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['subsdcode', 'subsdname']
		}),
		listeners: {
			load : function( Store, records, options ) {
				
			}
		}
	})
});

var cmbGrouplevel = new Ext.form.ComboBox({
	hiddenName: 'cmbGrouplevel',
	editable: true,
	fieldLabel: 'ระดับ',
	mode: 'local',
	width: 350,
	triggerAction: 'all',
	valueField: 'ccode',
	displayField: 'cname',
	store: new Ext.data.Store({
		url: '/code/cgrouplevel',
		autoLoad: true,
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['ccode', 'cname']
		}),
		listeners: {
			load : function( Store, records, options ) {
				
			}
		}
	})
});

var cmbSection = new Ext.form.ComboBox({
	hiddenName: 'cmbSection',
	editable: true,
	fieldLabel: 'ฝ่าย / กลุ่มงาน',
	mode: 'local',
	width: 350,
	triggerAction: 'all',
	valueField: 'seccode',
	displayField: 'secname',
	store: new Ext.data.Store({
		url: '/code/csection',
		autoLoad: true,
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['seccode', 'secname']
		}),
		listeners: {
			load : function( Store, records, options ) {
				//combo11.setValue(combo11.getValue());
			}
		}
	})
});

var fieldset1 = new Ext.form.FieldSet({
	title: 'ตำแหน่งที่แต่งตั้ง',
	width: 530,
	items : [
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [txtPosition]
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
					items: [cmbPosition]
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [cmbGrouplevel]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [txtSalary]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [cmbExecutive]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [cmbExpert]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [cmbPostype]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [cmbDiv]
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
					items: [cmbSectionG]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [cmbSection]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [cmbJob]
				}
			]
		}
	]
});

var fieldset2 = new Ext.form.FieldSet({
	title: 'ตำแหน่งเดิม',
	width: 400,
	items : [
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [txtPositionOld]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text21]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text22]
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text23]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text24]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text25]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text26]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text27]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text28]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text29]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text30]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text31]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text32]
				}
			]
		}
	]
});

var fieldset3 = new Ext.form.FieldSet({
	title: '',
	width: 940,
	labelWidth: 95,
	items : [
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [cmbJ18status]
				},{
					layout: 'form',
					items: [text40],
					style: 'padding-left:50px'
				},{
					layout: 'form',
					items: [text41],
					style: 'padding-left:50px'
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text42]
				},{
					layout: 'form',
					items: [text43],
					style: 'padding-left:50px'
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text44]
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text45]
				},{
					layout: 'form',
					items: [text46],
					style: 'padding-left:50px'
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text47]
				},{
					layout: 'form',
					items: [text48],
					style: 'padding-left:50px'
				}
			]
		}
	]
});

var frmAddEdit = new Ext.form.FormPanel({
	title: 'บันทึกคำสั่งย้าย / เลื่อนภายในหน่วยงาน',
	labelAlign: 'left',
	labelWidth: 130,
	frame: true,
	region: 'center',
	autoScroll: true,
	items: [
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [txtCommandNumber]
				},{
					layout: 'form',
					style: 'padding-left: 20px',
					items: [dateForce]
				}
			]
		},
		cmbCodeUpdate,
		txtRemark,
		radio1,
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [fieldset2]
				},{
					layout: 'form',
					style: 'padding-left: 10px',
					items: [fieldset1]
				}
			]
		},
		fieldset3
	],
	buttons: [
		{
			text: 'บันทึก',
			iconCls: 'disk',
			formBind: true,
			listeners: {
				click: function(){
					
				}
			}
		},
		{
			text: 'ยกเลิก',
			iconCls: 'arrow-undo',
			listeners: {
				click: function(){
					
				}
			}
		}
	]
});

var viewport = new Ext.Viewport({
	layout: 'border',
	renderTo: Ext.getBody(),
	//autoScroll: true,
	items: [
		frmAddEdit
	]
});
