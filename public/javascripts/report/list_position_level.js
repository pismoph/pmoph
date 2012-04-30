work_place = {
    mcode: "work_place[mcode]"
    ,deptcode: "work_place[deptcode]"
    ,dcode: "work_place[dcode]"
    ,sdcode: "work_place[sdcode]"
    ,sdcode_show: "list_position_level_subdept_show"
    ,sdcode_button: "list_position_level_subdept_button"
    ,seccode: "work_place[seccode]"
    ,jobcode: "work_place[jobcode]"
}
///////////////////////////////////////////////
//                      panleSearch
///////////////////////////////////////////////
var panleSearch = new Ext.Panel({
    region: "north"
    //,collapsible: true
    ,height: 280
    ,border: false
    ,autoScroll: true
    ,frame: true
    ,items: [
        {
            width: 650
            ,style: "padding-left:50%;margin-left:-300px"
            ,items: [
                {
                    layout: "hbox"
                    ,border: false
                    ,layoutConfig: {
                        pack: 'center'
                        ,align: 'middle'
                        ,padding: 5
                    }
                    ,items: [
                        {
                            layout: "form"
                            ,labelWidth: 100
                            ,labelAlign: "right"
                            ,width: 600
                            ,border: false
                            ,items: [
				new Ext.ux.form.PisComboBox({//กระทรวง
				    fieldLabel: "กระทรวง"
				    ,hiddenName: 'work_place[mcode]'
				    ,id: 'work_place[mcode]'
				    ,valueField: 'mcode'
				    ,displayField: 'minname'
				    ,urlStore: pre_url + '/code/cministry'
				    ,fieldStore: ['mcode', 'minname']
				    ,width: 450                                                               
				})
				,new Ext.ux.form.PisComboBox({//กรม
				    fieldLabel: "กรม"
				    ,hiddenName: 'work_place[deptcode]'
				    ,id: 'work_place[deptcode]'
				    ,valueField: 'deptcode'
				    ,displayField: 'deptname'
				    ,urlStore: pre_url + '/code/cdept'
				    ,fieldStore: ['deptcode', 'deptname']
				    ,width: 450
				})
				,new Ext.ux.form.PisComboBox({//กอง
				    fieldLabel: "กอง"
				    ,hiddenName: 'work_place[dcode]'
				    ,id: 'work_place[dcode]'
				    ,fieldLabel: "กอง"
				    ,valueField: 'dcode'
				    ,displayField: 'division'
				    ,urlStore: pre_url + '/code/cdivision'
				    ,fieldStore: ['dcode', 'division']
				    ,width: 450
				})
				
				
				,{
				    xtype: "compositefield"
				    ,fieldLabel: "หน่วยงาน"
				    ,anchor: "100%"
				    ,items: [
					{
					    xtype: "numberfield"
					    ,id: "work_place[sdcode]"
					    ,width: 80
					    ,enableKeyEvents: true//(user_work_place.sdcode == undefined)? true : false
					    ,listeners: {
						keydown : function( el,e ){
						    Ext.getCmp("list_position_level_subdept_show").setValue("");
						    if (e.keyCode == e.RETURN){
							loadMask.show();
							Ext.Ajax.request({
							   url: pre_url + '/code/csubdept_search'
							   ,params: {
							      sdcode: el.getValue()
							   }
							   ,success: function(response,opts){
							      obj = Ext.util.JSON.decode(response.responseText);
							      if (obj.totalcount == 0){
								 Ext.Msg.alert("สถานะ", "ไม่พบข้อมูล");
								 Ext.getCmp("work_place[sdcode]").setValue("");
								 Ext.getCmp("list_position_level_subdept_show").setValue("");
							      }
							      else{
								 Ext.getCmp("work_place[sdcode]").setValue(obj.records[0].sdcode);
								 Ext.getCmp("list_position_level_subdept_show").setValue(obj.records[0].subdeptname);
							      }
							      
							      loadMask.hide();
							   }
							   ,failure: function(response,opts){
							      Ext.Msg.alert("สถานะ",response.statusText);
							      loadMask.hide();
							   }
							});                                                                                           
						    }        
						}
						,blur: function(el){
							 if (Ext.getCmp("list_position_level_subdept_show").getValue() == ""){
								  Ext.getCmp("work_place[sdcode]").setValue("");
								  Ext.getCmp("list_position_level_subdept_show").setValue("");    
							 }
						}
						     
					    }
					}
					,{
					    xtype: "textfield"
					    ,id: "list_position_level_subdept_show"
					    ,readOnly: true
					    ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:75%;"
					}
					,{
					    xtype: "button"
					    ,id: "list_position_level_subdept_button"
					    ,text: "..."
					    ,handler: function(){
						     searchSubdept(Ext.getCmp("work_place[sdcode]"),Ext.getCmp("list_position_level_subdept_show"));
					    }
					}
				    ]
				}
				,new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
				    fieldLabel: "ฝ่าย/กลุ่มงาน"
				    ,hiddenName: 'work_place[seccode]'
				    ,id: 'work_place[seccode]'
				    ,valueField: 'seccode'
				    ,displayField: 'secname'
				    ,urlStore: pre_url + '/code/csection'
				    ,fieldStore: ['seccode', 'secname']
				    ,width: 450
					 
				})
				,new Ext.ux.form.PisComboBox({//งาน
				    fieldLabel: "งาน"
				    ,hiddenName: 'work_place[jobcode]'
				    ,id: 'work_place[jobcode]'
				    ,valueField: 'jobcode'
				    ,displayField: 'jobname'
				    ,urlStore: pre_url + '/code/cjob'
				    ,fieldStore: ['jobcode', 'jobname']
				    ,width: 450
				})
                                ,new Ext.ux.form.PisComboBox({//ตำแหน่งสายงาน
                                    fieldLabel: "ตำแหน่งสายงาน"
                                    ,hiddenName: 'poscode'
                                    ,id: 'poscode'
                                    ,valueField: 'poscode'
                                    ,displayField: 'posname'
                                    ,urlStore: pre_url + '/code/cposition'
                                    ,fieldStore: ['poscode', 'posname']
                                    ,width: 450
                                })
                                ,new Ext.ux.form.PisComboBox({//ระดับ
                                    fieldLabel: "ระดับ"
                                    ,hiddenName: 'ccode'
                                    ,id: 'ccode'
                                    ,valueField: 'ccode'
                                    ,displayField: 'cname'
                                    ,urlStore: pre_url + '/code/cgrouplevel'
                                    ,fieldStore: ['ccode', 'cname']
                                    ,width: 450
                                })                                
                            ]
                        }
                    ]
                    ,buttons: [
                        {
                            text: "ค้นหา"
                            ,handler: function(){
                                /*if (Ext.getCmp("work_place[mcode]").getValue() == ""){
                                    Ext.Msg.alert("คำแนะนำ","กรุณาเลือกข้อมูลให้ถูกต้อง");
                                    return 0;
                                }*/
                                delete(reportGridStore.baseParams["mcode"]);
                                delete(reportGridStore.baseParams["deptcode"]);
                                delete(reportGridStore.baseParams["dcode"]);
                                delete(reportGridStore.baseParams["sdcode"]);
                                delete(reportGridStore.baseParams["seccode"]);
                                delete(reportGridStore.baseParams["jobcode"]);
                                delete(reportGridStore.baseParams["poscode"]);
                                delete(reportGridStore.baseParams["ccode"]);
                                if (reportGridStore.lastOptions && reportGridStore.lastOptions.params) {
                                    delete(reportGridStore.lastOptions.params["mcode"]);
                                    delete(reportGridStore.lastOptions.params["deptcode"]);
                                    delete(reportGridStore.lastOptions.params["dcode"]);
                                    delete(reportGridStore.lastOptions.params["sdcode"]);
                                    delete(reportGridStore.lastOptions.params["seccode"]);
                                    delete(reportGridStore.lastOptions.params["jobcode"]);                                    
                                    delete(reportGridStore.lastOptions.params["poscode"]);
                                    delete(reportGridStore.lastOptions.params["ccode"]);
                                }
                                reportGridStore.baseParams = {
                                    mcode:  Ext.getCmp("work_place[mcode]").getValue()
                                    ,deptcode:  Ext.getCmp("work_place[deptcode]").getValue()
                                    ,dcode:  Ext.getCmp("work_place[dcode]").getValue()
                                    ,sdcode:  Ext.getCmp("work_place[sdcode]").getValue()
                                    ,seccode:  Ext.getCmp("work_place[seccode]").getValue()
                                    ,jobcode:  Ext.getCmp("work_place[jobcode]").getValue()                                         
                                    ,poscode:  Ext.getCmp("poscode").getValue()
                                    ,ccode:  Ext.getCmp("ccode").getValue()
                                }
                                reportGridStore.load({ params: { start: 0, limit: 20} });
                                Ext.getCmp("excel_report").enable();
                                Ext.getCmp("pdf_report").enable();
                            }
                        }
                        ,{
                            text: "ยกเลิก"
                            ,handler: function(){
                                delete(reportGridStore.baseParams["mcode"]);
                                delete(reportGridStore.baseParams["deptcode"]);
                                delete(reportGridStore.baseParams["dcode"]);
                                delete(reportGridStore.baseParams["sdcode"]);
                                delete(reportGridStore.baseParams["seccode"]);
                                delete(reportGridStore.baseParams["jobcode"]);
                                delete(reportGridStore.baseParams["poscode"]);
                                delete(reportGridStore.baseParams["ccode"]);
                                if (reportGridStore.lastOptions && reportGridStore.lastOptions.params) {
                                    delete(reportGridStore.lastOptions.params["mcode"]);
                                    delete(reportGridStore.lastOptions.params["deptcode"]);
                                    delete(reportGridStore.lastOptions.params["dcode"]);
                                    delete(reportGridStore.lastOptions.params["sdcode"]);
                                    delete(reportGridStore.lastOptions.params["seccode"]);
                                    delete(reportGridStore.lastOptions.params["jobcode"]);                                    
                                    delete(reportGridStore.lastOptions.params["poscode"]);
                                    delete(reportGridStore.lastOptions.params["ccode"]);
                                }
                                Ext.getCmp("work_place[jobcode]").clearValue();
                                Ext.getCmp("work_place[seccode]").clearValue();
                                Ext.getCmp("work_place[sdcode]").setValue("");
                                Ext.getCmp("list_position_level_subdept_show").setValue("");
                                Ext.getCmp("work_place[dcode]").clearValue();
                                Ext.getCmp("work_place[deptcode]").clearValue();
                                Ext.getCmp("work_place[mcode]").clearValue();                                
                                Ext.getCmp("poscode").clearValue();
                                Ext.getCmp("ccode").clearValue();
                                Ext.getCmp("excel_report").disable();
                                Ext.getCmp("pdf_report").disable();
                                reportGridStore.removeAll();
                                if (type_group_user == "1"){
                                    setWorkPlace();
                                }
                            }
                        }
                    ]
                }
            ]
        }
    ]
    ,listeners: {
	afterrender: function(el){
	    if (type_group_user == "1"){
		setWorkPlace();
	    }
	}
    }
});
////////////////////////////////////
//          reportGrid
///////////////////////////////////
var reportFields = [
    {name: "fname", type: "string"}
    ,{name: "lname", type: "string"}
    ,{name: "posid", type: "string"}
    ,{name: "posname", type: "string"}
    ,{name: "appointdate", type: "string"}
    ,{name: "birthdate", type: "string"}
    ,{name: "retiredate", type: "string"}
    ,{name: "age", type: "string"}
    ,{name: "ageappoint", type: "string"}
    ,{name: "j18_subdept", type: "string"}
];

var reportCols = [
    {
            header: "#"
            ,width: 70
            ,renderer: rowNumberer.createDelegate(this)
            ,sortable: false
    }
    ,{header: "ชื่อ",width: 100, sortable: false, dataIndex: 'fname'}
    ,{header: "นามสกุล",width: 100, sortable: false, dataIndex: 'lname'}
    ,{header: "ตำแหน่งเลขที่",width: 100, sortable: false, dataIndex: 'posid'}
    ,{header: "ตำแหน่ง",width: 100, sortable: false, dataIndex: 'posname'}
    ,{header: "วันที่บรรจุ",width: 200, sortable: false, dataIndex: 'appointdate'}
    ,{header: "วันเกิด",width: 200, sortable: false, dataIndex: 'birthdate'}
    ,{header: "วันที่เกษียณ",width: 200, sortable: false, dataIndex: 'retiredate'}
    ,{header: "อายุ",width: 200, sortable: false, dataIndex: 'age'}
    ,{header: "อายุราชการ",width: 200, sortable: false, dataIndex: 'ageappoint'}
    ,{header: "หน่วยงานตามจ.18",width: 350, sortable: false, dataIndex: 'j18_subdept'}
];

var reportGridStore = new Ext.data.JsonStore({
         url: pre_url + "/report/list_position_level"
         ,root: "records"
         ,autoLoad: false
         ,totalProperty: 'totalCount'
         ,fields: reportFields
});

var reportGrid = new Ext.grid.GridPanel({
         region: 'center'
         ,split: true
         ,store: reportGridStore
         ,columns: reportCols
         ,stripeRows: true
         ,loadMask: {msg:'Loading...'}
         ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
         ,bbar: new Ext.PagingToolbar({
                  pageSize: 20
                  ,autoWidth: true
                  ,store: reportGridStore
                  ,displayInfo: true
                  ,displayMsg: 'Displaying {0} - {1} of {2}'
                  ,emptyMsg: "Not found"
         })
         ,listeners: {
            afterrender: function(el){
              el.doLayout();
            }
         }
         ,tbar:[
            {
                text: "Excel"
                ,iconCls: "excel"
                ,id: "excel_report"
                ,disabled: true
                ,handler: function(){
                    /*if (Ext.getCmp("work_place[mcode]").getValue() == ""){
                        Ext.Msg.alert("คำแนะนำ","กรุณาเลือกข้อมูลให้ถูกต้อง");
                        return 0;
                    }*/
                    var form = document.createElement("form");
                    form.setAttribute("method", "post");
                    form.setAttribute("action" , pre_url + "/report/report_list_position_level?format=xls");
                    form.setAttribute("target", "_blank");
                    var field2 = document.createElement("input");
                    field2.setAttribute("name", "jobcode");
                    field2.setAttribute("value", Ext.getCmp("work_place[jobcode]").getValue() );
                    var field3 = document.createElement("input");
                    field3.setAttribute("name", "seccode");
                    field3.setAttribute("value", Ext.getCmp("work_place[seccode]").getValue() );
                    var field4 = document.createElement("input");
                    field4.setAttribute("name", "sdcode");
                    field4.setAttribute("value", Ext.getCmp("work_place[sdcode]").getValue() );
                    var field5 = document.createElement("input");
                    field5.setAttribute("name", "dcode");
                    field5.setAttribute("value", Ext.getCmp("work_place[dcode]").getValue() );
                    var field6 = document.createElement("input");
                    field6.setAttribute("name", "deptcode");
                    field6.setAttribute("value", Ext.getCmp("work_place[deptcode]").getValue() );
                    var field7 = document.createElement("input");
                    field7.setAttribute("name", "mcode");
                    field7.setAttribute("value", Ext.getCmp("work_place[mcode]").getValue() );
                    var field8 = document.createElement("input");
                    field8.setAttribute("name", "poscode");
                    field8.setAttribute("value", Ext.getCmp("poscode").getValue() );
                    var field9 = document.createElement("input");
                    field9.setAttribute("name", "ccode");
                    field9.setAttribute("value", Ext.getCmp("ccode").getValue() );
                    form.appendChild(field2);
                    form.appendChild(field3);
                    form.appendChild(field4);
                    form.appendChild(field5);
                    form.appendChild(field6);
                    form.appendChild(field7);
                    form.appendChild(field8);
                    form.appendChild(field9);
                    document.body.appendChild(form);
                    form.submit();
                    document.body.removeChild(form);                    
                }
            },"-",{
                text: "PDF"
                ,iconCls: "pdf"
                ,id: "pdf_report"
                ,disabled: true
                ,handler: function(){
                    /*if (Ext.getCmp("work_place[mcode]").getValue() == ""){
                        Ext.Msg.alert("คำแนะนำ","กรุณาเลือกข้อมูลให้ถูกต้อง");
                        return 0;
                    }*/
                    var form = document.createElement("form");
                    form.setAttribute("method", "post");
                    form.setAttribute("action" , pre_url + "/report/report_list_position_level?format=pdf");
                    form.setAttribute("target", "_blank");
                    var field2 = document.createElement("input");
                    field2.setAttribute("name", "jobcode");
                    field2.setAttribute("value", Ext.getCmp("work_place[jobcode]").getValue() );
                    var field3 = document.createElement("input");
                    field3.setAttribute("name", "seccode");
                    field3.setAttribute("value", Ext.getCmp("work_place[seccode]").getValue() );
                    var field4 = document.createElement("input");
                    field4.setAttribute("name", "sdcode");
                    field4.setAttribute("value", Ext.getCmp("work_place[sdcode]").getValue() );
                    var field5 = document.createElement("input");
                    field5.setAttribute("name", "dcode");
                    field5.setAttribute("value", Ext.getCmp("work_place[dcode]").getValue() );
                    var field6 = document.createElement("input");
                    field6.setAttribute("name", "deptcode");
                    field6.setAttribute("value", Ext.getCmp("work_place[deptcode]").getValue() );
                    var field7 = document.createElement("input");
                    field7.setAttribute("name", "mcode");
                    field7.setAttribute("value", Ext.getCmp("work_place[mcode]").getValue() );
                    var field8 = document.createElement("input");
                    field8.setAttribute("name", "poscode");
                    field8.setAttribute("value", Ext.getCmp("poscode").getValue() );
                    var field9 = document.createElement("input");
                    field9.setAttribute("name", "ccode");
                    field9.setAttribute("value", Ext.getCmp("ccode").getValue() );
                    form.appendChild(field2);
                    form.appendChild(field3);
                    form.appendChild(field4);
                    form.appendChild(field5);
                    form.appendChild(field6);
                    form.appendChild(field7);
                    form.appendChild(field8);
                    form.appendChild(field9);
                    document.body.appendChild(form);
                    form.submit();
                    document.body.removeChild(form);
                }
            }
         ]
});



///////////////////////////////////
//              panelReport
//////////////////////////////////
var panelReport = new Ext.Panel({
    title: "ข้าราชการจำแนกตามตำแหน่งสายงาน-ระดับ"
    ,layout: "border"
    ,items: [
        panleSearch
        ,reportGrid
    ]
});