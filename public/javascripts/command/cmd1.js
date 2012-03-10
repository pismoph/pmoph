var pre_url = ""; 

function date1_auto_fill(){
	var upd = Number(combo1.getValue());
	if(upd >= 1 && upd <= 115){ //บรรจุใหม่
		date3.setValue(date_sql2thai(date1.getValue().format('Y-m-d')));
		date5.setValue(date_sql2thai(date1.getValue().format('Y-m-d')));
		date8.setValue(date_sql2thai(date1.getValue().format('Y-m-d')));
	} else if(upd >= 121 && upd <= 126){ //บรรจุกลับ
		date5.setValue(date_sql2thai(date1.getValue().format('Y-m-d')));
		date6.setValue(date_sql2thai(date1.getValue().format('Y-m-d')));		
	} else if(upd >= 201 && upd <= 300){ //ย้ายไป
		date5.setValue(date_sql2thai(date1.getValue().format('Y-m-d')));
	} else if(upd >= 400 && upd <= 431){ //รับโอน
		date4.setValue(date_sql2thai(date1.getValue().format('Y-m-d')));
		date5.setValue(date_sql2thai(date1.getValue().format('Y-m-d')));
	}
}

var btnTest = new Ext.Button({
	id: 'btnTest',
	iconCls: 'zoom',
	text: 'Test',
	listeners: {
		click: function(){
			/*Ext.Ajax.request({
				url: pre_url + "/position_blank/rc_insert_update"
				,params: {
					posid: '888',
					dat: 'hello'
				}
				,success: function(response,opts){
					obj = Ext.util.JSON.decode(response.responseText);
					if(obj.success == true){
						Ext.Msg.alert("Complete", "Action is OK");
					} else {
						Ext.Msg.alert("Error", obj.msg);
					}
				}
			});*/
			Ext.Msg.alert("data", "data="+hidOld.getValue());
		}
	}
});

var text1 = new Ext.form.TextField({
	id: 'text1',
	fieldLabel: 'คำสั่ง',
	width: 320,
	allowBlank: false
});

function text2_get_position(me){
	Ext.Ajax.request({
		method: 'post',
		url: pre_url+'/cmd1/get_position_blank',
		params: {posid: me.getValue()},
		success: function(result, request ) {
			var x = me.getValue();
			var dat = Ext.util.JSON.decode(result.responseText).Records[0];
			if(Ext.util.JSON.decode(result.responseText).Records.length > 0){
				text2.setValue(x);
				
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
					msg: 'เลขที่ตำแหน่งนี้จะต้องเป็นตำแหน่งที่ว่างเท่านั้น',
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

var text2 = new Ext.form.NumberField({
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

var button1 = new Ext.Button({
	id: 'button1',
	iconCls: 'zoom',
	text: '',
	tooltip: 'ค้นหาตำแหน่งว่าง',
	listeners: {
		click: function(){
			winPositionBlank.setPosition(button1.getPosition());
			winPositionBlank.show();
			cmbSearchPosition.setValue(3); //เมื่อเปิดหน้าต่างครั้งแรกให้ แสดงตำแหน่งว่างมารอไว้ก่อน
			funcSearchPosition();
		}
	}
});

function text4_selected(){
	/*combo6.setValue('');
	combo11.setValue('');
	combo7.setValue('');
	combo12.setValue('');
	combo11.store.load({
		params:{
			parent_id: text4.getValue()
		}
	});*/
}

var text4 = new Ext.form.NumberField({
	id: 'text4',
	fieldLabel: 'หน่วยงาน',
	width: 100,
	enableKeyEvents: true,
	listeners: {
		keypress: function( me, e ){
			if(e.keyCode == e.ENTER){
				if(me.getValue() != ""){
					Ext.Ajax.request({
						method: 'post',
						url: pre_url+'/cmd1/get_place',
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
								text4_selected();
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
	width: 100,
	allowBlank: false
});

var text6 = new Ext.form.TextField({
	id: 'text6',
	fieldLabel: 'หมายเหตุ',
	width: 600
});

var text7 = new Ext.form.TextField({
	id: 'text7',
	fieldLabel: '',
	width: 403,
	readOnly: true,
	hideLabel: true,
	style: {
		background: '#CCCCCC'
	},
	value: ''
});

function text20_check_valid(me){
	//ตรวจสอบความถูกต้องของเลข 13 หลัก
	if(me.isValid() == false){
		Ext.Msg.alert("Error", "เลขประจำตัวประชาชนไม่ถูกต้อง");
		return;
	}
	
	//ตรวจสอบการมีอยู่แล้วของเลขบัตรประชาชน แล้วแค่เตือนเท่านั้น
	Ext.Ajax.request({
		url: pre_url + "/cmd1/pid_check_duplicate"
		,params: {
			"pid": me.getValue()
		}
		,success: function(response,opts){
			obj = Ext.util.JSON.decode(response.responseText);
			//debugger;
			if(obj.Records.length != 0){
				Ext.Msg.alert("เตือน", "เลขประจำตัวประชาชนนี้ ซ้ำกับในฐานข้อมูล");
			} else {
				//แต่ถ้าเป็น ID จากอดีตข้าราชการ ก็ให้ดึงข้อมูลเก่าขึ้นมารอไว้เลย
				//หลังจากตรวจสอบแล้ว ก็ให้เอาข้อมูล หน่วยงานปฏิบัติงานจริงมารอไว้เลย
				combo21.setValue(1);
				
				//combo23.setValue(combo4.getValue());
				combo23.getStore().load({
					params: {
						mcode: combo4.getValue()
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo23.setValue(combo4.getValue());
					}
				});
			
				//combo24.setValue(combo5.getValue());
				combo24.getStore().load({
					params: {
						deptcode: combo5.getValue()
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo24.setValue(combo5.getValue());
					}
				});
			
				//combo25.setValue(combo10.getValue());
				combo25.getStore().load({
					params: {
						dcode: combo10.getValue()
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo25.setValue(combo10.getValue());
					}
				});
			
				combo26.getStore().load({
					params: {
						subsdcode: combo6.getValue()
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo26.setValue(combo6.getValue());
					}
				});
				
				text23.setValue(text4.getValue());
				text24.setValue(text7.getValue());
				
				//combo27.setValue(combo11.getValue());
				combo27.getStore().load({
					params: {
						seccode: combo11.getValue()
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo27.setValue(combo11.getValue());
					}
				});
			
				//combo28.setValue(combo7.getValue());
				combo28.getStore().load({
					params: {
						jobcode: combo7.getValue()
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo28.setValue(combo7.getValue());
					}
				});
			
				combo29.setValue('');
				
				date1_auto_fill();
			}
		}
	});
	
}

function isNationalID(id) {
	if(id.length != 13) return false;
	for(i=0, sum=0; i < 12; i++){
		sum += parseFloat(id.charAt(i))*(13-i);
	}
	if((11-sum%11)%10!=parseFloat(id.charAt(12))) return false;
	return true;
}

var text20 = new Ext.form.NumberField({
	id: 'text20',
	fieldLabel: 'เลขประจำตัวประชาชน',
	width: 160,
	allowBlank: false,
	minLength: 13,
	maxLength: 13,
	enableKeyEvents: true,
	listeners: {
		keypress: function( me, e ){
			if(e.keyCode == e.ENTER){
				hidOld.setValue(""); //ระบุว่าเป็นการป้อนเลข13หลักเข้าไปใหม่
				text20_check_valid(me);
			}
		},
		change: function( me, newValue, oldValue ){
			if(me.getValue() != ""){
				hidOld.setValue(""); //ระบุว่าเป็นการป้อนเลข13หลักเข้าไปใหม่
				text20_check_valid(me);
			}
		}
	},
	validator: function(value){
		return isNationalID(value);
	}
});

var hidOld = new Ext.form.Hidden({
	id: 'hidOld' //ถ้าไม่ใช่ค่าว่างเปล่า แสดงว่าเป็นการดึงข้อมูลอดีตข้าราชการมา
});

var text21 = new Ext.form.TextField({
	id: 'text21',
	fieldLabel: 'ชื่อ',
	width: 150,
	allowBlank: false
});

var text22 = new Ext.form.TextField({
	id: 'text22',
	fieldLabel: 'นามสกุล',
	width: 150,
	allowBlank: false
});

function text23_selected(){
	/*combo26.setValue('');
	combo27.setValue('');
	combo28.setValue('');
	combo29.setValue('');
	combo27.store.load({
		params:{
			parent_id: text23.getValue()
		}
	});*/
}

var text23 = new Ext.form.NumberField({
	id: 'text23',
	fieldLabel: 'หน่วยงาน',
	width: 100,
	enableKeyEvents: true,
	listeners: {
		keypress: function( me, e ){
			if(e.keyCode == e.ENTER){
				if(me.getValue() != ""){
					Ext.Ajax.request({
						method: 'post',
						url: pre_url+'/cmd1/get_place',
						params: {id: me.getValue()},
						success: function(result, request ) {
							var dat = Ext.util.JSON.decode(result.responseText).Records;
							if(dat.length == 0){
								text24.setValue('');
								Ext.Msg.show({
									title:'ไม่พบข้อมูล',
									msg: 'ไม่พบข้อมูลหน่วยงานที่ค้นหา',
									buttons: Ext.Msg.OK,
									fn: function(){},
									animEl: 'text23',
									icon: Ext.MessageBox.ERROR
								});
							} else {
								text24.setValue(dat[0].fullsubdeptname);
								text23_selected();
							}
						}
					});
				}
			}
		}
	}
});

var text24 = new Ext.form.TextField({
	id: 'text24',
	fieldLabel: '',
	width: 403,
	readOnly: true,
	hideLabel: true,
	style: {
		background: '#CCCCCC'
	}
});

var text25 = new Ext.form.TextField({
	id: 'text25',
	fieldLabel: 'อายุ',
	width: 120,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text26 = new Ext.form.TextField({
	id: 'text26',
	fieldLabel: 'วันครบเกษียณ',
	width: 120,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text27 = new Ext.form.TextField({
	id: 'text27',
	fieldLabel: 'อายุราชการ',
	width: 120,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text28 = new Ext.form.TextField({
	id: 'text28',
	fieldLabel: 'ระยะเวลาครบเกษียณ',
	width: 120,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text29 = new Ext.form.TextField({
	id: 'text29',
	fieldLabel: 'ระยะเวลา',
	width: 120,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text30 = new Ext.form.TextField({
	id: 'text30',
	fieldLabel: 'ระยะเวลา',
	width: 120,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text31 = new Ext.form.TextField({
	id: 'text31',
	fieldLabel: 'ระยะเวลา',
	width: 120,
	readOnly: true,
	style: {
		background: '#CCCCCC'
	}
});

var text32 = new Ext.form.TextField({
	id: 'text32',
	fieldLabel: 'ความสามารถพิเศษ',
	width: 320
});

var text33 = new Ext.form.TextField({
	id: 'text33',
	fieldLabel: 'หมายเหตุ 1',
	width: 640
});

var text34 = new Ext.form.TextField({
	id: 'text34',
	fieldLabel: 'หมายเหตุ 2',
	width: 640
});

var date1 = new Ext.form.DateField({
	id: 'date1',
	fieldLabel: 'วันที่มีผลบังคับใช้',
	format: 'd/m/Y',
	width: 100,
	allowBlank: false,
	enableKeyEvents: true,
	listeners: {
		keypress: function( me, e ){
			if(e.keyCode == e.ENTER){
				
			}
		},
		change: function( me, newValue, oldValue ){
			if(me.getValue() != ""){
				
			}
		}
	}
});

function date2_calculate(me){
	if(me.getValue() != ""){
		Ext.Ajax.request({
			method: 'post',
			url: pre_url+'/cmd1/age_calculate',
			params: {bDate: me.getValue()},
			success: function(result, request ) {
				var dat = Ext.util.JSON.decode(result.responseText).Records;
				text25.setValue(dat.age_text);
				text26.setValue(dat.retire_date);
				text28.setValue(dat.retire_text);
			}
		});	
	} else {
		text25.setValue('');
		text26.setValue('');
		text28.setValue('');
	}
}

var date2 = new Ext.form.DateField({
	id: 'date2',
	fieldLabel: 'วันเกิด',
	format: 'd/m/Y',
	width: 100,
	allowBlank: false,
	enableKeyEvents: true,
	listeners: {
		change: function( me, newValue, oldValue ){
			date2_calculate(me);
		},
		keypress: function( me, e ){
			if(e.keyCode == e.ENTER){
				date2_calculate(me);
			}
		}
	}
});

function date_x_calculate(me, resultObject){
	if(me.getValue() != ""){
		Ext.Ajax.request({
			method: 'post',
			url: pre_url+'/cmd1/date_calculate',
			params: {dataDate: me.getValue()},
			success: function(result, request ) {
				var dat = Ext.util.JSON.decode(result.responseText).Records;
				resultObject.setValue(dat.age_text);
			}
		});	
	} else {
		resultObject.setValue('');
	}
}

var date3 = new Ext.form.DateField({
	id: 'date3',
	fieldLabel: 'วันบรรจุเข้ารับราชการ',
	format: 'd/m/Y',
	width: 100,
	enableKeyEvents: true,
	listeners: {
		change: function( me, newValue, oldValue ){
			date_x_calculate(me, text27);
		},
		keypress: function( me, e ){
			if(e.keyCode == e.ENTER){
				date_x_calculate(me, text27);
			}
		}
	}
});

var date4 = new Ext.form.DateField({
	id: 'date4',
	fieldLabel: 'วันที่รับโอน',
	format: 'd/m/Y',
	width: 100
});

var date5 = new Ext.form.DateField({
	id: 'date5',
	fieldLabel: 'วันเข้าสู่หน่วยงานปัจจุบัน',
	format: 'd/m/Y',
	width: 100,
	enableKeyEvents: true,
	listeners: {
		change: function( me, newValue, oldValue ){
			date_x_calculate(me, text29);
		},
		keypress: function( me, e ){
			if(e.keyCode == e.ENTER){
				date_x_calculate(me, text29);
			}
		}
	}
});

var date6 = new Ext.form.DateField({
	id: 'date6',
	fieldLabel: 'วันที่บรรจุกลับ',
	format: 'd/m/Y',
	width: 100
});

var date7 = new Ext.form.DateField({
	id: 'date7',
	fieldLabel: 'วันที่ออกจากราชการ',
	format: 'd/m/Y',
	width: 100
});

var date8 = new Ext.form.DateField({
	id: 'date8',
	fieldLabel: 'วันเข้าสู่ระดับปัจจุบัน',
	format: 'd/m/Y',
	width: 100,
	enableKeyEvents: true,
	listeners: {
		change: function( me, newValue, oldValue ){
			date_x_calculate(me, text30);
		},
		keypress: function( me, e ){
			if(e.keyCode == e.ENTER){
				date_x_calculate(me, text30);
			}
		}
	}
});

var date9 = new Ext.form.DateField({
	id: 'date9',
	fieldLabel: 'วันที่มาช่วยราชการ',
	format: 'd/m/Y',
	width: 100,
	enableKeyEvents: true,
	listeners: {
		change: function( me, newValue, oldValue ){
			date_x_calculate(me, text31);
		},
		keypress: function( me, e ){
			if(e.keyCode == e.ENTER){
				date_x_calculate(me, text31);
			}
		}
	}
});

var button2 = new Ext.Button({
	id: 'button2',
	iconCls: 'zoom',
	text: '',
	tooltip: 'ค้นหาหน่วยงาน',
	listeners: {
		click: function(){
			winPlaceTarget.setValue("text4|text7"); //กำหนดเป้าหมายแสดงผลการค้นหา
			winPlace.setAnimateTarget(this.getEl());
			winPlace.setPosition(this.getPosition());
			winPlace.show();
		}
	}
});

var button3 = new Ext.Button({
	id: 'button3',
	iconCls: 'zoom',
	text: '',
	tooltip: 'ค้นหาอดีตข้าราชการ',
	listeners: {
		click: function(){
			winOldPerson.setPosition(button3.getPosition());
			winOldPerson.show();
			cmbSearchOldPerson.setValue(3); //เมื่อเปิดหน้าต่างครั้งแรกให้ แสดงรายชื่อขึ้นมารอไว้ก่อน
			funcSearchOldPerson();
		}
	}
});

var button4 = new Ext.Button({
	id: 'button4',
	iconCls: 'zoom',
	text: '',
	tooltip: 'ค้นหาหน่วยงาน',
	listeners: {
		click: function(){
			winPlaceTarget.setValue("text23|text24"); //กำหนดเป้าหมายแสดงผลการค้นหา
			winPlace.setAnimateTarget(this.getEl());
			winPlace.setPosition(this.getPosition());
			winPlace.show();
		}
	}
});

var combo1 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'การเคลื่อนไหว'
	,hiddenName: 'combo1'
	,width: 320
	,valueField: 'updcode'
	,displayField: 'updname'
	,urlStore: pre_url + '/code/cupdate'
	,fieldStore: ['updcode', 'updname']
});

var combo2 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'ตำแหน่งสายงาน'
	,hiddenName: 'combo2'
	,width: 200
	,valueField: 'poscode'
	,displayField: 'posname'
	,urlStore: pre_url + '/code/cposition'
	,fieldStore: ['poscode', 'posname']
});

var combo3 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'ตำแหน่งบริหาร'
	,hiddenName: 'combo3'
	,width: 200
	,valueField: 'excode'
	,displayField: 'exname'
	,urlStore: pre_url + '/code/cexecutive'
	,fieldStore: ['excode', 'exname']
});

var combo4 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'กระทรวง'
	,hiddenName: 'combo4'
	,width: 200
	,valueField: 'mcode'
	,displayField: 'minname'
	,urlStore: pre_url + '/code/cministry'
	,fieldStore: ['mcode', 'minname']
});

var combo5 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'กรม'
	,hiddenName: 'combo5'
	,width: 200
	,valueField: 'deptcode'
	,displayField: 'deptname'
	,urlStore: pre_url + '/code/cdept'
	,fieldStore: ['deptcode', 'deptname']
});

var combo6 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'กลุ่มภารกิจ'
	,hiddenName: 'combo6'
	,width: 200
	,valueField: 'subsdcode'
	,displayField: 'subsdname'
	,urlStore: pre_url + '/code/csubsdcode'
	,fieldStore: ['subsdcode', 'subsdname']
});

var combo7 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'งาน'
	,hiddenName: 'combo7'
	,width: 200
	,valueField: 'jobcode'
	,displayField: 'jobname'
	,urlStore: pre_url + '/code/cjob'
	,fieldStore: ['jobcode', 'jobname']
});

var combo8 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'ระดับ'
	,hiddenName: 'combo8'
	,width: 200
	,valueField: 'ccode'
	,displayField: 'cname'
	,urlStore: pre_url + '/code/cgrouplevel'
	,fieldStore: ['ccode', 'cname']
});

var combo9 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'ความเชี่ยวชาญ'
	,hiddenName: 'combo9'
	,width: 200
	,valueField: 'epcode'
	,displayField: 'expert'
	,urlStore: pre_url + '/code/cexpert'
	,fieldStore: ['epcode', 'expert']
});

var combo10 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'กอง'
	,hiddenName: 'combo10'
	,width: 200
	,valueField: 'dcode'
	,displayField: 'division'
	,urlStore: pre_url + '/code/cdivision'
	,fieldStore: ['dcode', 'division']
});

var combo11 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'ฝ่าย / กลุ่มงาน'
	,hiddenName: 'combo11'
	,width: 200
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
	width: 200,
	triggerAction: 'all',
	valueField: 'off_id',
	displayField: 'off_name',
	store: new Ext.data.Store({
		url: pre_url+'person_pcucode.php',
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
	,width: 200
	,valueField: 'ptcode'
	,displayField: 'ptname'
	,urlStore: pre_url + '/code/cpostype'
	,fieldStore: ['ptcode', 'ptname']
});

var combo20 = new Ext.form.ComboBox({
	hiddenName: 'combo20',
	editable: true,
	fieldLabel: 'คำนำหน้าชื่อ',
	mode: 'local',
	width: 100,
	allowBlank: false,
	triggerAction: 'all',
	valueField: 'pcode',
	displayField: 'prefix',
	store: new Ext.data.Store({
		url: pre_url+'/code/cprefix',
		autoLoad: true,
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['pcode', 'prefix']
		}),
		listeners: {
			load : function( Store, records, options ) {
				
			}
		}
	}),
	listeners: {
		select : function( me, record, index ) {
			if(me.getValue() == "1"){
				combo30.setValue("1");
			} else if(me.getValue() == "2"){
				combo30.setValue("2");
			} else if(me.getValue() == "3"){
				combo30.setValue("2");
			} else {
				combo30.setValue("");
			}
		}
	}
});

var combo21 = new Ext.form.ComboBox({
	hiddenName: 'combo21',
	editable: true,
	fieldLabel: 'ปฏิบัติงานจริง',
	mode: 'local',
	width: 320,
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

var combo22 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'รักษาการในตำแหน่ง'
	,hiddenName: 'combo22'
	,width: 320
	,valueField: 'excode'
	,displayField: 'exname'
	,urlStore: pre_url + '/code/cexecutive'
	,fieldStore: ['excode', 'exname']
});

var combo23 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'กระทรวง'
	,hiddenName: 'combo23'
	,width: 200
	,valueField: 'mcode'
	,displayField: 'minname'
	,urlStore: pre_url + '/code/cministry'
	,fieldStore: ['mcode', 'minname']
});

var combo24 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'กรม'
	,hiddenName: 'combo24'
	,width: 200
	,valueField: 'deptcode'
	,displayField: 'deptname'
	,urlStore: pre_url + '/code/cdept'
	,fieldStore: ['deptcode', 'deptname']
});

var combo25 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'กอง'
	,hiddenName: 'combo25'
	,width: 200
	,valueField: 'dcode'
	,displayField: 'division'
	,urlStore: pre_url + '/code/cdivision'
	,fieldStore: ['dcode', 'division']
});

var combo26 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'กลุ่มภารกิจ'
	,hiddenName: 'combo26'
	,width: 200
	,valueField: 'subsdcode'
	,displayField: 'subsdname'
	,urlStore: pre_url + '/code/csubsdcode'
	,fieldStore: ['subsdcode', 'subsdname']
});

var combo27 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'ฝ่าย / กลุ่มงาน'
	,hiddenName: 'combo27'
	,width: 200
	,valueField: 'seccode'
	,displayField: 'secname'
	,urlStore: pre_url + '/code/csection'
	,fieldStore: ['seccode', 'secname']
});

var combo28 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'งาน'
	,hiddenName: 'combo28'
	,width: 200
	,valueField: 'jobcode'
	,displayField: 'jobname'
	,urlStore: pre_url + '/code/cjob'
	,fieldStore: ['jobcode', 'jobname']
});

var combo29 = new Ext.form.ComboBox({
	hiddenName: 'combo29',
	editable: true,
	fieldLabel: 'โครงสร้างภายใน',
	mode: 'local',
	width: 200,
	triggerAction: 'all',
	valueField: 'off_id',
	displayField: 'off_name',
	store: new Ext.data.Store({
		url: pre_url+'person_pcucode.php',
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

var combo30 = new Ext.form.ComboBox({
	hiddenName: 'combo30',
	editable: true,
	fieldLabel: 'เพศ',
	mode: 'local',
	width: 80,
	allowBlank: false,
	triggerAction: 'all',
	valueField: 'sex_id',
	displayField: 'sex_name',
	store: new Ext.data.ArrayStore({
        fields: ['sex_id', 'sex_name'],
		data: [[1, 'ชาย'], [2, 'หญิง']],
		listeners: {
			load : function( Store, records, options ) {
				
			}
		}
    })
});

var combo31 = new Ext.form.ComboBox({
	hiddenName: 'combo31',
	editable: true,
	fieldLabel: 'กลุ่มเลือด',
	mode: 'local',
	width: 80,
	allowBlank: false,
	triggerAction: 'all',
	valueField: 'blood',
	displayField: 'blood',
	store: new Ext.data.ArrayStore({
        fields: ['blood', 'blood'],
		data: [['A', 'A'], ['B', 'B'], ['AB', 'AB'], ['O', 'O']],
		listeners: {
			load : function( Store, records, options ) {
				
			}
		}
    })
});

var combo32 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'วุฒิในตำแหน่ง'
	,hiddenName: 'combo32'
	,width: 340
	,valueField: 'qcode'
	,displayField: 'qualify'
	,urlStore: pre_url + '/code/cqualify'
	,fieldStore: ['qcode', 'qualify']
});

var combo33 = new Ext.ux.form.PisComboBox({
	fieldLabel: 'วิชาเอก'
	,hiddenName: 'combo33'
	,width: 340
	,valueField: 'macode'
	,displayField: 'major'
	,urlStore: pre_url + '/code/cmajor'
	,fieldStore: ['macode', 'major']
});

var combo34 = new Ext.form.ComboBox({
	hiddenName: 'combo34',
	editable: true,
	fieldLabel: 'ใบอนุญาตประกอบวิชาชีพ',
	mode: 'local',
	width: 640,
	triggerAction: 'all',
	valueField: 'codetrade',
	displayField: 'trade',
	store: new Ext.data.Store({
		url: pre_url+'/code/ctrade',
		autoLoad: true,
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['codetrade', 'trade']
		}),
		listeners: {
			load : function( Store, records, options ) {
				
			}
		}
	})
});

var radio1 = new Ext.form.RadioGroup({
	id: 'radio1',
	fieldLabel: 'สมาชิก กบข.',
	columns: 2,
	width: 160,
	items: [{
		name: 'radio1',
		inputValue: '1',
		boxLabel: 'สมัคร'
	},{
		name: 'radio1',
		inputValue: '2',
		boxLabel: 'ไม่สมัคร'
	}]
});

var fieldset1 = new Ext.form.FieldSet({
	title: '',
	//autoWidth: true,
	//autoHeight: true,
	width: 980,
	items : [
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
					style: 'padding-left:20px'
				},
				{
					layout: 'form',
					items: [text5],
					style: 'padding-left:20px'
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
					style: 'padding-left:20px'
				},
				{
					layout: 'form',
					items: [combo13],
					style: 'padding-left:20px'
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
					style: 'padding-left:20px'
				},
				{
					layout: 'form',
					items: [combo10],
					style: 'padding-left:20px'
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
				},
				{
					layout: 'form',
					items: [combo6],
					style: 'padding-left:20px'
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo11]
				},
				{
					layout: 'form',
					items: [combo7],
					style: 'padding-left:20px'
				},
				{
					layout: 'form',
					items: [combo12],
					style: 'padding-left:20px'
				}
			]
		}
	]
});

var fieldset2 = new Ext.form.FieldSet({
	title: 'หน่วยงานปฏิบัติงานจริง',
	width: 980,
	labelWidth: 100,
	items : [
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo23]
				},
				{
					layout: 'form',
					items: [combo24],
					style: 'padding-left:20px'
				},
				{
					layout: 'form',
					items: [combo25],
					style: 'padding-left:20px'
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text23]
				},
				{
					layout: 'form',
					items: [text24]
				},
				{
					layout: 'form',
					items: [button4]
				},
				{
					layout: 'form',
					items: [combo26],
					style: 'padding-left:20px'
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo27]
				},
				{
					layout: 'form',
					items: [combo28],
					style: 'padding-left:20px'
				},
				{
					layout: 'form',
					items: [combo29],
					style: 'padding-left:20px'
				}
			]
		}
	]
});

var panel1 = new Ext.Panel({
	style: {
		background: '#EEEEEE'
	},
	labelWidth: 155,
	labelAlign: 'right',
	items: [
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [hidOld]
				},
				{
					layout: 'form',
					items: [text20]
				},
				{
					layout: 'form',
					items: [button3]
				},
				{
					layout: 'form',
					items: [combo20],
					labelWidth: 80
				},
				{
					layout: 'form',
					items: [text21],
					labelWidth: 40
				},
				{
					layout: 'form',
					items: [text22],
					labelWidth: 80
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo21]
				},
				{
					layout: 'form',
					items: [combo22]
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [fieldset2]
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo30]
				},
				{
					layout: 'form',
					items: [combo31],
					labelWidth: 80
				},
				{
					layout: 'form',
					items: [date2],
					labelWidth: 60
				},
				{
					layout: 'form',
					items: [text25],
					labelWidth: 50
				},
				{
					layout: 'form',
					items: [text26],
					labelWidth: 100
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [date3]
				},
				{
					layout: 'form',
					items: [text27],
					labelWidth: 80
				},
				{
					layout: 'form',
					items: [text28]
				},
				{
					layout: 'form',
					items: [date4],
					labelWidth: 100
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [date5]
				},
				{
					layout: 'form',
					items: [text29],
					labelWidth: 80
				},
				{
					layout: 'form',
					items: [date6]
				},
				{
					layout: 'form',
					items: [date7],
					labelWidth: 120
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [date8]
				},
				{
					layout: 'form',
					items: [text30],
					labelWidth: 80
				},
				{
					layout: 'form',
					items: [date9]
				},
				{
					layout: 'form',
					items: [text31],
					labelWidth: 120
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo32]
				},
				{
					layout: 'form',
					labelWidth: 80,
					items: [combo33]
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [combo34]
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [radio1]
				},
				{
					layout: 'form',
					items: [text32]
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text33]
				}
			]
		},{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text34]
				}
			]
		}
	]
});

var frmAddEdit = new Ext.form.FormPanel({
	id: 'frmAddEdit',
	title: 'บันทึกคำสั่งบรรจุ / รับย้าย / รับโอน',
	labelAlign: 'left',
	labelWidth: 100,
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
				},{
					layout: 'form',
					items: [btnTest]
				}
			]
		},
		{
			layout: 'column',
			items: [
				{
					layout: 'form',
					items: [text1]
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
					items: [text2]
				},
				{
					layout: 'form',
					items: [button1]
				}
			]
		},
		fieldset1,
		text6,
		panel1
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
					Ext.MessageBox.confirm('ยืนยัน', 'ต้องการล้างข้อมูลในฟอร์มทั้งหมดนี้ใช่หรือไม่ ?',
						function(btn) {
							if(btn == 'yes') {
								frmAddEdit.getForm().reset();	
							}
							else {
								return;
							}
						}
					);
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
	url: pre_url+'/cmd1/list_position',
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
			winPositionBlank.hide();
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
				data: [['1', 'ชื่อ-นามสกุลผู้ครองตำแหน่ง'], ['2', 'ตำแหน่งสายงาน'], ['3', 'ตำแหน่งว่าง']]
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

var winPositionBlank = new Ext.Window({
	title: 'ค้นหาข้าราชการ',
	iconCls: 'book-open',
	applyTo: 'div_window_position_blank',
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
						winPositionBlank.hide();
						text2_get_position(text2);
					} else {
						Ext.Msg.alert("Error", "กรุณาคลิกเลือกตำแหน่งว่างที่ต้องการ");
					}
				}
			}
		},
		{
			text: 'ยกเลิก',
			iconCls: 'arrow-undo',
			listeners: {
				click: function(){
					winPositionBlank.hide();
				}
			}
		}
	]
});


var GridStoreOldPerson = new Ext.data.JsonStore({
	url: pre_url+'/cmd1/list_old_person',
	root: 'Records',
	totalProperty: 'totalCount',
	idProperty: 'pispersonel_id',
	fields: [
		"pispersonel_id",
		"posid",
		"pid",
		"fullname"
	]
});

function funcSearchOldPerson(){
	GridStoreOldPerson.baseParams = {
		condition_id: cmbSearchOldPerson.getValue(),
		query: txtSearchOldPerson.getValue()
	};
	GridStoreOldPerson.load({
		params:{
			start: 0,
			limit: 100
		}
	});
}


//-----------------------------------------------------------------
//แปลงวันที่จากรูปแบบ SQL ไปเป็นวันที่รูปแบบของไทย
//เช่น '2008-02-29' จะรีเทิร์นค่าเป็น '29/2/2551'
//-----------------------------------------------------------------
function date_sql2thai(sDate)
{	if(sDate == "") return "";
	sDate = sDate.substr(0, 10);
	//Ext.Msg.alert(sDate);
	var arr = sDate.split("-");
	var yyyy = Number(arr[0]) + 543;
	return arr[2]+"/"+arr[1]+"/"+yyyy;
}

function setResultOldPerson(id){
	//id ที่ได้รับมานี้ จะมาจากหน้าต่างค้นหาอดีตข้าราชการ ซึ่งจะมีข้อมูลอยู่แล้วแน่นอน
	Ext.Ajax.request({
		method: 'post',
		url: pre_url+'/cmd1/get_old_person',
		params: {pispersonel_id: id},
		success: function(result, request ) {
			var dat = Ext.util.JSON.decode(result.responseText).Records[0];
			if(Ext.util.JSON.decode(result.responseText).Records.length > 0){
				//เลขบัตรประชาชน
				text20.setValue(dat.pid);
				//ระบุว่าเป็นข้อมูลอดีตข้าราชการ
				hidOld.setValue("1");
				
				//คำนำหน้าชื่อ
				combo20.getStore().load({
					params: {
						pcode: dat.pcode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo20.setValue(dat.pcode);
					}
				});
				
				//ชื่อ
				text21.setValue(dat.fname);
				//นามสกุล
				text22.setValue(dat.lname);
				
				
				//ปฏิบัติงานจริง
				combo21.getStore().load({
					params: {
						j18code: dat.j18code
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo21.setValue(dat.j18code);
					}
				});
				
				//กระทรวง
				combo23.getStore().load({
					params: {
						mcode: dat.mincode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo23.setValue(dat.mincode);
					}
				});
				
				//กรม
				combo24.getStore().load({
					params: {
						deptcode: dat.deptcode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo24.setValue(dat.deptcode);
					}
				});
				
				//กอง
				combo25.getStore().load({
					params: {
						dcode: dat.dcode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo25.setValue(dat.dcode);
					}
				});
				
				//หน่วยงาน
				text23.setValue(dat.sdcode);
				text24.setValue(dat.fullsubdeptname);
				
				//กลุ่มภารกิจ
				combo26.setValue('');
				
				//ฝ่าย / กลุ่มงาน
				combo27.getStore().load({
					params: {
						seccode: dat.seccode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo27.setValue(dat.seccode);
					}
				});
				
				//งาน
				combo28.getStore().load({
					params: {
						jobcode: dat.jobcode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo28.setValue(dat.jobcode);
					}
				});
				
				//โครงสร้างภายใน
				combo29.setValue('');
				
				//เพศ
				combo30.setValue(dat.sex);
				//กลุ่มเลือด
				combo31.setValue(dat.bloodgroup);
				//วันเกิด
				date2.setValue(date_sql2thai(dat.birthdate)); date2_calculate(date2);
				//วันบรรจุเข้ารับราชการ
				date3.setValue(date_sql2thai(dat.appointdate)); date_x_calculate(date3, text27);
				//วันเข้าสู่หน่วยงานปัจจุบัน
				date5.setValue(date_sql2thai(dat.deptdate)); date_x_calculate(date5, text29);
				//วันที่ออกจากราชการ
				date7.setValue(date_sql2thai(dat.exitdate));
				//วันเข้าสู่ระดับปัจจุบัน
				date8.setValue(date_sql2thai(dat.cdate)); date_x_calculate(date8, text30);
				
				//วุฒิในตำแหน่ง
				combo32.getStore().load({
					params: {
						qcode: dat.qcode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo32.setValue(dat.qcode);
					}
				});
				
				//วิชาเอก
				combo33.getStore().load({
					params: {
						macode: dat.macode
						,start: 0
						,limit: 10
					},
					callback :function(){
						combo33.setValue(dat.macode);
					}
				});
				
				//ใบอนุญาตประกอบวิชาชีพ
				combo34.setValue(dat.codetrade);
				//สมาชิก กบข.
				radio1.reset();
				if(dat.kbk == '1') radio1.setValue(1); //สมัคร
				else if(dat.kbk == '0') radio1.setValue(2); //ไม่สมัคร
				
				//ความสามารถพิเศษ
				text32.setValue(dat.specialty);
				//หมายเหตุ1
				//text33.setValue(dat.note);
				//หมายเหตุ2
				//text34.setValue(dat.note2);
				
				date1_auto_fill();
				
				date_x_calculate(date3, text27);
				date_x_calculate(date5, text29);
				date_x_calculate(date8, text30);
				date_x_calculate(date9, text31);
				
			} else {
				Ext.Msg.show({
					title:'ไม่พบข้อมูล',
					msg: 'ข้อมูลที่ค้นหานี้ จะต้องเป็นอดีตข้าราชการเท่านั้น',
					buttons: Ext.Msg.OK,
					fn: function(){},
					icon: Ext.MessageBox.ERROR
				});
			}
		}
	});
	winOldPerson.hide();
}

var GridOldPerson = new Ext.grid.GridPanel({
	id: 'GridOldPerson',
	title: '',
	frame: false,
	stripeRows: true,
	store: GridStoreOldPerson,
	viewConfig: {forceFit: true},
	loadMask: {
		msg: 'Please wait...'
	},
	columns: [
		new Ext.grid.RowNumberer(),
		{header: "เลขที่ตำแหน่ง",dataIndex: 'posid', width: 4, sortable: true},
		{header: "เลขประจำตัวประชาชน",dataIndex: 'pid', width: 8, sortable: true},
		{header: "ชื่อ - นามสกุล",dataIndex: 'fullname', width: 10, sortable: true}
	],
	listeners: {
		rowdblclick: function( me, rowIndex, e ){
			setResultOldPerson(me.selModel.selections.items[0].data.pispersonel_id);
		}
	},
	tbar: [
		'ค้นหาโดย : ',
		cmbSearchOldPerson = new Ext.form.ComboBox({
			hiddenName: 'cmbSearchOldPerson',
			mode: 'local',
			width: 200,
			triggerAction: 'all',
			valueField: 'condition_id',
			displayField: 'condition_text',
			store: new Ext.data.ArrayStore({
				fields: ['condition_id', 'condition_text'],
				data: [['1', 'เลขที่ตำแหน่ง'], ['2', 'เลขประจำตัวประชาชน'], ['3', 'ชื่อ-นามสกุล']]
			}),
			listeners: {
				select : function( me, record, index ) {
					funcSearchOldPerson();
				}
			}
		}),
		'คำค้นหา : ',
		txtSearchOldPerson = new Ext.form.TextField({
			id: 'txtSearchOldPerson',
			width: 200,
			enableKeyEvents: true,
			listeners: {
				keypress: function( me, e ){
					if(e.keyCode == e.ENTER){
						funcSearchOldPerson();
					}
				}
			}
		}),
		btnSearchOldPerson = new Ext.Button({
			id: 'btnSearchOldPerson',
			iconCls: 'zoom',
			text: '',
			listeners: {
				click: function(){
					funcSearchOldPerson();
				}
			}
		})
	],
	bbar: new Ext.PagingToolbar({
		store: GridStoreOldPerson,
		pageSize: 100,
		displayInfo: true,
		displayMsg: 'รายการที่ {0} - {1} จากทั้งหมด {2}',
		emptyMsg: "ไม่มีข้อมูล"
	})
});

var winOldPerson = new Ext.Window({
	title: 'ค้นหาอดีตข้าราชการ',
	iconCls: 'book-open',
	applyTo: 'div_window_old_person',
	layout: 'fit',
	width: 550,
	height: 420,
	autoScroll: true,
	closeAction: 'hide',
	modal: true,
	items: [
		GridOldPerson
	],
	buttons: [
		{
			text: 'ตกลง',
			iconCls: 'accept',
			formBind: true,
			listeners: {
				click: function(){
					if( GridOldPerson.selModel.selections.items.length != 0 ){
						setResultOldPerson(GridOldPerson.selModel.selections.items[0].data.pispersonel_id);
					} else {
						Ext.Msg.alert("Error", "กรุณาคลิกเลือกรายชื่ออดีตข้าราชการ");
					}
				}
			}
		},
		{
			text: 'ยกเลิก',
			iconCls: 'arrow-undo',
			listeners: {
				click: function(){
					winOldPerson.hide();
				}
			}
		}
	]
});

function funcSearchPlace(){
	GridStorePlace.baseParams = {
		provcode: cmbSearchPlace.getValue(),
		query: txtSearchPlace.getValue()
	};
	GridStorePlace.load({
		params:{
			start: 0,
			limit: 100
		}
	});
}

var cmbSearchPlace = new Ext.form.ComboBox({
	hiddenName: 'cmbSearchPlace',
	editable: true,
	mode: 'local',
	width: 150,
	triggerAction: 'all',
	valueField: 'provcode',
	displayField: 'provname',
	store: new Ext.data.Store({
		url: pre_url+'/code/cprovince',
		autoLoad: true,
		reader: new Ext.data.JsonReader({
			root: 'Records',
			fields: ['provcode', 'provname']
		})
	}),
	listeners: {
		select : function( me, record, index ) {
			if(me.getValue() != ""){
				funcSearchPlace();
			}
		}
	}
});

var txtSearchPlace = new Ext.form.TextField({
	id: 'txtSearchPlace',
	width: 200,
	enableKeyEvents: true,
	listeners: {
		keypress: function( me, e ){
			if(e.keyCode == e.ENTER){
				funcSearchPlace();
			}
		}
	}
});

var btnSearchPlace = new Ext.Button({
	id: 'btnSearchPlace',
	iconCls: 'zoom',
	text: '',
	listeners: {
		click: function(){
			funcSearchPlace();
		}
	}
});

var GridStorePlace = new Ext.data.JsonStore({
	url: pre_url+'/cmd1/list_place_dialog',
	root: 'Records',
	totalProperty: 'totalCount',
	idProperty: 'sdcode',
	fields: [
		"sdcode",
		"fullsubdeptname"
	]
});

function setResultPlace(){
	var arr = winPlaceTarget.getValue().split("|");
	
	//text4.setValue(GridPlace.selModel.selections.items[0].data.sdcode);
	//text7.setValue(GridPlace.selModel.selections.items[0].data.fullsubdeptname);
	//text4_selected();
	Ext.ComponentMgr.get(arr[0]).setValue(GridPlace.selModel.selections.items[0].data.sdcode);
	Ext.ComponentMgr.get(arr[1]).setValue(GridPlace.selModel.selections.items[0].data.fullsubdeptname);
	winPlace.hide();
}

var GridPlace = new Ext.grid.GridPanel({
	title: '',
	frame: false,
	stripeRows: true,
	store: GridStorePlace,
	viewConfig: {forceFit: true},
	loadMask: {
		msg: 'Please wait...'
	},
	columns: [
		new Ext.grid.RowNumberer(),
		{header: "รหัสหน่วยงาน",dataIndex: 'sdcode', width: 2, sortable: true},
		{header: "ชื่อหน่วยงาน",dataIndex: 'fullsubdeptname', width: 10, sortable: true}
	],
	listeners: {
		rowdblclick: function( me, rowIndex, e ){
			setResultPlace();
		}
	},
	tbar: [
		'จังหวัด : ',
		cmbSearchPlace,
		'คำค้นหาชื่อหน่วยงาน : ',
		txtSearchPlace,
		btnSearchPlace
	],
	bbar: new Ext.PagingToolbar({
		store: GridStorePlace,
		pageSize: 100,
		displayInfo: true,
		displayMsg: 'รายการที่ {0} - {1} จากทั้งหมด {2}',
		emptyMsg: "ไม่มีข้อมูล"
	})
});

var winPlaceTarget = new Ext.form.Hidden({
	id: 'winPlaceTarget'
});

var winPlace = new Ext.Window({
	title: 'ค้นหาหน่วยงาน',
	iconCls: 'book-open',
	applyTo: 'div_window_place',
	layout: 'fit',
	width: 550,
	height: 450,
	autoScroll: true,
	closeAction: 'hide',
	modal: true,
	showAnimDuration: 0.5,
	hideAnimDuration: 0.5,
	items: [
		GridPlace,winPlaceTarget
	],
	buttons: [{
			text: 'ตกลง',
			iconCls: 'accept',
			formBind: true,
			listeners: {
				click: function(){
					if( GridPlace.selModel.selections.items.length != 0 ){
						setResultPlace();
					} else {
						Ext.Msg.alert("Error", "กรุณาคลิกเลือกชื่อหน่วยงานที่ต้องการ");
					}
				}
			}
		},{
			text: 'ยกเลิก',
			iconCls: 'arrow-undo',
			listeners: {
				click: function(){
					winPlace.hide();
				}
			}
		}
	]
});


//อ่านค่าจาก RadioGroup
//ถ้าไม่เลือก item ใดเลย จะ return ""
//ถ้าเลือก item แล้วจะ return inputValue ของ item นั้นๆออกมา
function RadioGroupGetValue(RadioGroupObject) {
	var obj = RadioGroupObject;
	for(var i=0; i<obj.items.length; i++) {
		if(obj.items.items[i].checked == true) {
			return obj.items.items[i].inputValue;
		}
	}
	return "";
}

function save_data(){
	//ตรวจสอบความถูกต้อง
	//วันเกิดต้องมี 18 ปีบริบูรณ์ นับจากวันที่มีผลบังคับใช้
	//กรณีเพิ่มข้อมูลคนใหม่ ต้องเช็คเลข 13 หลักต้องไม่ซ้ำกับที่มีอยู่
	//เช็คเลข 13 หลักให้ถูกตามหลักการ
	
	//สุ่มตัวเลข id
	Ext.Ajax.request({
		url: pre_url + "/cmd1/random_pispersonel_id"
		,success: function(response,opts){
			obj = Ext.util.JSON.decode(response.responseText);
			var pispersonel_id = obj.dat;
			Ext.Ajax.request({
				method: 'post',
				url: pre_url+'/cmd1/age_valid',
				params: {birthDate: date2.getValue(), validDate: date1.getValue()},
				success: function(result, request ) {
					var dat = Ext.util.JSON.decode(result.responseText).Records;
					if(Number(dat.age_year) < 18){
						Ext.Msg.show({
							title:'ข้อมูลไม่สมบูรณ์',
							msg: 'อายุที่นับจากวันที่มีผลบังคับใช้ จะต้องครบ 18 ปีบริบูรณ์',
							buttons: Ext.Msg.OK,
							fn: function(){},
							animEl: 'date2',
							icon: Ext.MessageBox.ERROR
						});
						return;
					} else {
						//Ext.Msg.alert('อายุ '+dat.age_year+' ถูกต้อง');
						//อ่านค่าของ สมาชิก กบข
						var kbk = RadioGroupGetValue(radio1);
						if(kbk == "2") kbk = "0";
						Ext.Ajax.request({
							method: 'post',
							url: pre_url+'/cmd1/save_new',
							params: {
								id: pispersonel_id,
								pcode: combo20.getValue(), //คำนำหน้าชื่อ
								fname: text21.getValue(), //ชื่อ
								lname: text22.getValue(), //นามสกุล
								sex: combo30.getValue(), //เพศ
								birthdate: date2.getValue(), //วันเกิด
								appointdate: date3.getValue(), //วันบรรจุเข้ารับราชการ
								deptdate: date5.getValue(), //วันเข้าสู่หน่วยงานปัจจุบัน
								cdate: date8.getValue(), //วันเข้าสู่ระดับปัจจุบัน
								deptcode: combo24.getValue(), //กรม
								dcode: combo25.getValue(), //กอง
								sdcode: text23.getValue(), //รหัสหน่วยงาน
								seccode: combo27.getValue(), //ฝ่าย /กลุ่มงาน
								jobcode: combo28.getValue(), //งาน
								poscode: combo2.getValue(), //ตำแหน่งสายงาน
								excode: combo3.getValue(), //ตำแหน่งบริหาร
								epcode: combo9.getValue(), //ความเชี่ยวชาญ
								macode: combo33.getValue(), //วิชาเอก
								qcode: combo32.getValue(), //วุฒิในตำแหน่ง
								posid: text2.getValue(), //เลขที่ตำแหน่ง
								c: combo8.getValue(), //กลุ่ม/ระดับ
								salary: text5.getValue(), //เงินเดือน
								j18code: combo21.getValue(), //ปฏิบัติงานจริง
								note: text33.getValue(), //หมายเหตุ1
								upddate: '', //วันที่บันทึก เดี๋ยวให้ทาง postgres บันทึกเวลาเอง
								upduser: 'admin', //user ที่บันทึก
								codetrade: combo34.getValue(), //ใบอนุญาตประกอบวิชาชีพ
								kbk: kbk, //สมาชิก กบข.
								pstatus: '1', //มีค่า 1 กับ 0หรือว่างเปล่า เข้าใจว่า 1=เป็นข้าราชการ 0=อดีตข้าราชการ
								ptcode: combo13.getValue(), //ว./วช./ชช.
								pid: text20.getValue(), //เลขประจำตัวประชาชน
								mincode: combo23.getValue(), //กระทรวง
								note2: text34.getValue(), //หมายเหตุ2
								specialty: text32.getValue(), //ความสามารถพิเศษ
								bloodgroup: combo31.getValue(), //กลุ่มเลือด
								
								combo2: combo2.getValue(),
								combo3: combo3.getValue(),
								combo4: combo4.getValue(),
								combo5: combo5.getValue(),
								combo6: combo6.getValue(),
								combo7: combo7.getValue(),
								combo8: combo8.getValue(),
								combo9: combo9.getValue(),
								combo10: combo10.getValue(),
								combo11: combo11.getValue(),
								combo12: combo12.getValue(),
								combo13: combo13.getValue(),
								text6: text6.getValue(),
								
								updcode: combo1.getValue(), //การเคลื่อนไหว
								refcmnd: text1.getValue(), //คำสั่ง
								forcedate: date1.getValue(), //วันที่มีผลบังคับใช้
								
								hidOld: hidOld.getValue() //ถ้าไม่ใช่ค่าว่างเปล่า แสดงว่าเป็นอดีตข้าราชการ
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
				}
			});
		}
	});
}
