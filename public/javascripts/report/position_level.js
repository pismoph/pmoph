work_place = {
         mcode: "work_place[mcode]"
         ,deptcode: "work_place[deptcode]"
         ,dcode: "work_place[dcode]"
         ,sdcode: "work_place[sdcode]"
         ,sdcode_show: "position_level_subdept_show"
         ,sdcode_button: "position_level_sdcode_button"
         ,seccode: "work_place[seccode]"
         ,jobcode: "work_place[jobcode]"
}
///////////////////////////////////////////////
//                      panleSearch
///////////////////////////////////////////////
var panleSearch = new Ext.Panel({
    region: "north"
    //,collapsible: true
    ,height: 220
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
                                                ,enableKeyEvents: true
                                                ,listeners: {
                                                    specialkey : function( el,e ){
                                                        Ext.getCmp("position_level_subdept_show").setValue("");
                                                        if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
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
                                                                     Ext.getCmp("position_level_subdept_show").setValue("");
                                                                  }
                                                                  else{
                                                                     Ext.getCmp("work_place[sdcode]").setValue(obj.records[0].sdcode);
                                                                     Ext.getCmp("position_level_subdept_show").setValue(obj.records[0].subdeptname);
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
                                                             if (Ext.getCmp("position_level_subdept_show").getValue() == ""){
                                                                      Ext.getCmp("work_place[sdcode]").setValue("");
                                                                      Ext.getCmp("position_level_subdept_show").setValue("");    
                                                             }
                                                    }
                                                         
                                                }
                                            }
                                            ,{
                                                xtype: "textfield"
                                                ,id: "position_level_subdept_show"
                                                ,readOnly: true
                                                ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:75%;"
                                            }
                                            ,{
                                                xtype: "button"
                                                ,id: "position_level_sdcode_button"
                                                ,text: "..."
                                                ,handler: function(){
                                                         searchSubdept(Ext.getCmp("work_place[sdcode]"),Ext.getCmp("position_level_subdept_show"));
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
                                if (reportGridStore.lastOptions && reportGridStore.lastOptions.params) {
                                    delete(reportGridStore.lastOptions.params["mcode"]);
                                    delete(reportGridStore.lastOptions.params["deptcode"]);
                                    delete(reportGridStore.lastOptions.params["dcode"]);
                                    delete(reportGridStore.lastOptions.params["sdcode"]);
                                    delete(reportGridStore.lastOptions.params["seccode"]);
                                    delete(reportGridStore.lastOptions.params["jobcode"]);
                                }
                                reportGridStore.baseParams = {
                                    mcode:  Ext.getCmp("work_place[mcode]").getValue()
                                    ,deptcode:  Ext.getCmp("work_place[deptcode]").getValue()
                                    ,dcode:  Ext.getCmp("work_place[dcode]").getValue()
                                    ,sdcode:  Ext.getCmp("work_place[sdcode]").getValue()
                                    ,seccode:  Ext.getCmp("work_place[seccode]").getValue()
                                    ,jobcode:  Ext.getCmp("work_place[jobcode]").getValue()
                                };
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
                                if (reportGridStore.lastOptions && reportGridStore.lastOptions.params) {
                                    delete(reportGridStore.lastOptions.params["mcode"]);
                                    delete(reportGridStore.lastOptions.params["deptcode"]);
                                    delete(reportGridStore.lastOptions.params["dcode"]);
                                    delete(reportGridStore.lastOptions.params["sdcode"]);
                                    delete(reportGridStore.lastOptions.params["seccode"]);
                                    delete(reportGridStore.lastOptions.params["jobcode"]);
                                }
                                Ext.getCmp("work_place[jobcode]").clearValue();
                                Ext.getCmp("work_place[seccode]").clearValue();
                                Ext.getCmp("work_place[sdcode]").setValue("");
                                Ext.getCmp("position_level_subdept_show").setValue("");
                                Ext.getCmp("work_place[dcode]").clearValue();
                                Ext.getCmp("work_place[deptcode]").clearValue();
                                Ext.getCmp("work_place[mcode]").clearValue();
                                Ext.getCmp("excel_report").disable();
                                 Ext.getCmp("pdf_report").disable();
                                reportGridStore.removeAll();
                                if (type_group_user == "1"){
                                    setWorkPlace();
                                }
                                if (type_group_user == "2"){
                                    setWorkPlaceSSJ();
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
            if (type_group_user == "2"){
                setWorkPlaceSSJ();
            } 
	}
    }
});
////////////////////////////////////
//          reportGrid
///////////////////////////////////
var reportFields = [
         {name: "posname", type: "string"}
         ,{name: "cname", type: "string"}
         ,{name: "n", type: "string"}
         ,{name: "n_empty", type: "string"}
];

var reportCols = [
         {
                 header: "#"
                 ,width: 70
                 ,renderer: rowNumberer.createDelegate(this)
                 ,sortable: false
         }
         ,{header: "ตำแหน่งสายงาน",width: 250, sortable: false, dataIndex: 'posname'}
         ,{header: "ระดับ",width: 250, sortable: false, dataIndex: 'cname'}
         ,{header: "จำนวนที่ครองตำแหน่ง",width: 150, sortable: false, dataIndex: 'n'}
          ,{header: "จำนวนที่ตำแหน่งว่าง",width: 150, sortable: false, dataIndex: 'n_empty'}
];

var reportGridStore = new Ext.data.JsonStore({
         url: pre_url + "/report/position_level"
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
                    }
                    */
                    var form = document.createElement("form");
                    form.setAttribute("method", "post");
                    form.setAttribute("action" , pre_url + "/report/report_position_level?format=xls");
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
                    form.appendChild(field2);
                    form.appendChild(field3);
                    form.appendChild(field4);
                    form.appendChild(field5);
                    form.appendChild(field6);
                    form.appendChild(field7);
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
                    form.setAttribute("action" , pre_url + "/report/report_position_level?format=pdf");
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
                    form.appendChild(field2);
                    form.appendChild(field3);
                    form.appendChild(field4);
                    form.appendChild(field5);
                    form.appendChild(field6);
                    form.appendChild(field7);
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
    title: "จำนวนข้าราชการจำแนกตามตำแหน่งสายงาน-ระดับ"
    ,layout: "border"
    ,items: [
        panleSearch
        ,reportGrid
    ]
});