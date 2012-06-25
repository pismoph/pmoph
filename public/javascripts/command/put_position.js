work_place = {
         mcode: "pisj18[mincode]"
         ,deptcode: "pisj18[deptcode]"
         ,dcode: "pisj18[dcode]"
         ,sdcode: "pisj18[sdcode]"
         ,sdcode_show: "subdept_show"
         ,sdcode_button: "sdcode_button"
         ,seccode: "pisj18[seccode]"
         ,jobcode: "pisj18[jobcode]"
}
etc4_blank = "<table style='font:12px tahoma,arial,helvetica,sans-serif;margin-left:10px;'>" +
         "<tr ><td style='padding-bottom:4px;width:140px' align='right' height='22px'>ระยะเวลา:</td><td style='padding-left: 5px;width:130px;background-color: rgb(204, 204, 204);'></td></tr>" + 
"</table>";
etc3_blank = "<table style='font:12px tahoma,arial,helvetica,sans-serif;margin-left:10px;'>" +
         "<tr ><td style='padding-bottom:4px;width:130px' align='right' height='22px'>ระยะเวลาครบเกษียณ:&nbsp;</td><td style='padding-left: 5px;width:130px;background-color: rgb(204, 204, 204);'></td></tr>" + 
"</table>";
etc2_blank = "<table style='font:12px tahoma,arial,helvetica,sans-serif;margin-left:10px;'>" +
         "<tr ><td style='padding-bottom:4px' align='right' height='22px'>อายุราชการ:</td><td style='padding-left: 5px;width:130px;background-color: rgb(204, 204, 204);'></td></tr>" + 
         "<tr ><td style='padding-bottom:4px' align='right' height='22px'>ระยะเวลา:</td><td style='padding-left: 5px;width:130px;background-color: rgb(204, 204, 204);'></td></tr>" + 
         "<tr ><td style='padding-bottom:4px' align='right' height='22px'>ระยะเวลา:</td><td style='padding-left: 5px;width:130px;background-color: rgb(204, 204, 204);'></td></tr>" + 
"</table>";
etc1_blank = "<table style='font:12px tahoma,arial,helvetica,sans-serif;margin-left:10px;'>" +
         "<tr >" +
                  "<td style='padding-bottom:4px' align='right' height='24px'>อายุ:</td>"+
                  "<td style='padding-left: 5px;width:130px;background-color: rgb(204, 204, 204);'></td>"+
                  "<td style='padding-bottom:4px;padding-left:30px;' align='right' height='24px'>วันครบเกษียณ:</td>"+
                  "<td style='padding-left: 5px;width:130px;background-color: rgb(204, 204, 204);'></td>"+
         "</tr>" + 
"</table>";
//-------------------------------------
// Form Center
//-------------------------------------
var putPositionForm = new Ext.FormPanel({
    labelWidth: 100
    ,autoScroll: true
    ,url: pre_url + '/put_position/process_put_position'
    ,frame: true
    ,monitorValid: true
    ,bodyStyle: "padding:10px"
    ,region: "center"
    ,items: [
        {
            xtype: "panel"
            ,width: 1000
            ,layout: "form"
            ,labelAlign: "right"
            ,items: [
                  {
                           xtype: "hidden"
                           ,id: "pispersonel[retiredate]"
                  }
                  ,{
                           xtype: "fieldset"
                           ,id: "pisj18"
                           ,style: "padding: 5px 5px 5px 5px;"
                           ,items: [
                                    new Ext.ux.form.PisComboBox({//การเคลื่อนไหว
                                        fieldLabel: 'การเคลื่อนไหว'
                                        ,hiddenName: 'cmd[updcode]'
                                        ,id: 'cmd[updcode]'
                                        ,width: 250
                                        ,valueField: 'updcode'
                                        ,displayField: 'updname'
                                        ,urlStore: pre_url + '/code/cupdate'
                                        ,fieldStore: ['updcode', 'updname']
                                        ,anchor: "100%"
                                        ,allowBlank: false
                                    })
                                    ,{
                                        xtype: "compositefield"
                                        ,fieldLabel: "คำสั่ง"
                                        ,items: [
                                            {
                                                xtype: "textfield"
                                                ,id: "cmd[refcmnd]"
                                                ,width: 580
                                                ,allowBlank: false
                                            }
                                            ,{
                                                xtype: "displayfield"
                                                ,value: "วันที่คำสั่งมีผลบังคับ"
                                                ,style: "padding: 4px;text-align: right;padding-left: 10px"
                                            }
                                            ,{
                                                xtype: "datefield"
                                                ,id: "cmd[forcedate]"
                                                ,width: 173
                                                ,allowBlank: false
                                                ,format: "d/m/Y"
                                            }
                                        ]
                                    }
                                    ,{
                                        xtype: "compositefield"
                                        ,fieldLabel: "เลขที่ตำแหน่ง"
                                        ,anchor: "100%"
                                        ,items: [
                                            {
                                                xtype: "numberfield"
                                                ,id: "pisj18[posid]"
                                                ,width: 100
                                                ,allowBlank: false
                                                ,readOnly: true
                                                ,style: "background-color:rgb(204, 204, 204);background-image:url('#');"
                                            }
                                            ,{
                                                xtype: "button"
                                                ,text: "..."
                                                ,handler: function(){
                                                    putPositionPosid(Ext.getCmp("pisj18[posid]"));
                                                }
                                            }
                                        ]
                                    }
                                    ,{
                                        xtype: "fieldset"
                                        ,items: [
                                            {
                                                layout: "column"
                                                ,items: [
                                                    {
                                                        width: 320
                                                        ,layout: "form"
                                                        ,labelWidth: 90
                                                        ,items: [
                                                            new Ext.ux.form.PisComboBox({//ตำแหน่งสายงาน
                                                                fieldLabel: "ตำแหน่งสายงาน"
                                                                ,hiddenName: 'pisj18[poscode]'
                                                                ,id: 'pisj18[poscode]'
                                                                ,valueField: 'poscode'
                                                                ,displayField: 'posname'
                                                                ,urlStore: pre_url + '/code/cposition'
                                                                ,fieldStore: ['poscode', 'posname']
                                                                ,anchor: "100%"
                                                           })
                                                            ,new Ext.ux.form.PisComboBox({//ตำแหน่งบริหาร
                                                                fieldLabel: "ตำแหน่งบริหาร"
                                                                ,hiddenName: 'pisj18[excode]'
                                                                ,id: 'pisj18[excode]'
                                                                ,valueField: 'excode'
                                                                ,displayField: 'exname'
                                                                ,urlStore: pre_url + '/code/cexecutive'
                                                                ,fieldStore: ['excode', 'exname']
                                                                ,anchor: "100%"
                                                            })
                                                            ,new Ext.ux.form.PisComboBox({//กระทรวง
                                                                fieldLabel: "กระทรวง"
                                                                ,hiddenName: 'pisj18[mincode]'
                                                                ,id: 'pisj18[mincode]'
                                                                ,valueField: 'mcode'
                                                                ,displayField: 'minname'
                                                                ,urlStore: pre_url + '/code/cministry'
                                                                ,fieldStore: ['mcode', 'minname']
                                                                ,anchor: "100%"                                                              
                                                            })
                    
                                                        ]
                                                    }
                                                    ,{
                                                        width: 320
                                                        ,layout: "form"
                                                        ,labelWidth: 90
                                                        ,items: [
                                                            new Ext.ux.form.PisComboBox({//ระดับ
                                                                fieldLabel: "กลุ่ม/ระดับ"
                                                                ,hiddenName: 'pisj18[c]'
                                                                ,id: 'pisj18[c]'
                                                                ,valueField: 'ccode'
                                                                ,displayField: 'cname'
                                                                ,urlStore: pre_url + '/code/cgrouplevel'
                                                                ,fieldStore: ['ccode', 'cname']
                                                                ,anchor: "100%" 
                                                            })
                                                            ,new Ext.ux.form.PisComboBox({//ความเชี่ยวชาญ
                                                                fieldLabel: "ความเชี่ยวชาญ"
                                                                ,hiddenName: 'pisj18[epcode]'
                                                                ,id: 'pisj18[epcode]'
                                                                ,valueField: 'epcode'
                                                                ,displayField: 'expert'
                                                                ,urlStore: pre_url + '/code/cexpert'
                                                                ,fieldStore: ['epcode', 'expert']
                                                                ,anchor: "100%" 
                                                            })
                                                            ,new Ext.ux.form.PisComboBox({//กรม
                                                                fieldLabel: "กรม"
                                                                ,hiddenName: 'pisj18[deptcode]'
                                                                ,id: 'pisj18[deptcode]'
                                                                ,valueField: 'deptcode'
                                                                ,displayField: 'deptname'
                                                                ,urlStore: pre_url + '/code/cdept'
                                                                ,fieldStore: ['deptcode', 'deptname']
                                                                ,anchor: "100%" 
                                                            })                                                      
                                                            
                                                        ]
                                                    }
                                                    ,{
                                                        width: 320
                                                        ,layout: "form"
                                                        ,labelWidth: 90
                                                        ,items: [
                                                            {
                                                                xtype: "numericfield"
                                                                ,fieldLabel: "เงินเดือน"
                                                                ,id: "pisj18[salary]"
                                                                ,anchor: "100%" 
                                                            }
                                                            ,new Ext.ux.form.PisComboBox({//ว./ว.ช/ชช.
                                                                fieldLabel: "ว./ว.ช/ชช."
                                                                ,hiddenName: 'pisj18[ptcode]'
                                                                ,id: 'pisj18[ptcode]'
                                                                ,valueField: 'ptcode'
                                                                ,displayField: 'ptname'
                                                                ,urlStore: pre_url + '/code/cpostype'
                                                                ,fieldStore: ['ptcode', 'ptname']
                                                                ,anchor: "100%" 
                                                            })
                                                            ,new Ext.ux.form.PisComboBox({//กอง
                                                                fieldLabel: "กอง"
                                                                ,hiddenName: 'pisj18[dcode]'
                                                                ,id: 'pisj18[dcode]'                                            
                                                                ,valueField: 'dcode'
                                                                ,displayField: 'division'
                                                                ,urlStore: pre_url + '/code/cdivision'
                                                                ,fieldStore: ['dcode', 'division']
                                                                ,anchor: "100%" 
                                                            })
                                                        ]
                                                    }
                                                ]
                                            }
                                            ,{
                                                layout: "column"
                                                ,items: [
                                                    {
                                                        width: 640
                                                        ,layout: "form"
                                                        ,labelWidth: 90
                                                        ,items: [
                                                            {
                                                                 xtype: "compositefield"
                                                                 ,fieldLabel: "หน่วยงาน"
                                                                 ,anchor: "100%"
                                                                 ,items: [
                                                                    {
                                                                        xtype: "numberfield"
                                                                        ,id: "pisj18[sdcode]"
                                                                        ,width: 80
                                                                        ,allowBlank: false
                                                                        ,enableKeyEvents: true
                                                                        ,listeners: {
                                                                            specialkey : function( el,e ){
                                                                                Ext.getCmp("subdept_show").setValue("");
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
                                                                                             Ext.getCmp("pisj18[sdcode]").setValue("");
                                                                                             Ext.getCmp("subdept_show").setValue("");
                                                                                          }
                                                                                          else{
                                                                                             Ext.getCmp("pisj18[sdcode]").setValue(obj.records[0].sdcode);
                                                                                             Ext.getCmp("subdept_show").setValue(obj.records[0].subdeptname);
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
                                                                                if (Ext.getCmp("subdept_show").getValue() == ""){
                                                                                    Ext.getCmp("pisj18[sdcode]").setValue("");
                                                                                    Ext.getCmp("subdept_show").setValue("");    
                                                                                }
                                                                           } 
                                                                        }
                                                                    }
                                                                    ,{
                                                                        xtype: "textfield"
                                                                        ,id: "subdept_show"
                                                                        ,readOnly: true
                                                                        ,style: "background-color: rgb(204, 204, 204);background-image:url('#');width:80%;"
                                                                    }
                                                                    ,{
                                                                        xtype: "button"
                                                                        ,id: "sdcode_button"
                                                                        ,text: "..."
                                                                        ,handler: function(){
                                                                            searchSubdept(Ext.getCmp("pisj18[sdcode]"),Ext.getCmp("subdept_show"));
                                                                        }
                                                                    }
                                                                 ]
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                            ,{
                                                layout: "column"
                                                ,items: [
                                                    {
                                                        width: 320
                                                        ,layout: "form"
                                                        ,labelWidth: 90
                                                        ,items: [
                                                            new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
                                                                fieldLabel: "ฝ่าย/กลุ่มงาน"
                                                                ,hiddenName: 'pisj18[seccode]'
                                                                ,id: 'pisj18[seccode]'
                                                                ,valueField: 'seccode'
                                                                ,displayField: 'secname'
                                                                ,urlStore: pre_url + '/code/csection'
                                                                ,fieldStore: ['seccode', 'secname']
                                                                ,anchor: "100%"
                                                            })
                    
                                                        ]
                                                    }
                                                    ,{
                                                        width: 320
                                                        ,layout: "form"
                                                        ,labelWidth: 90
                                                        ,items: [
                                                            new Ext.ux.form.PisComboBox({//งาน
                                                                fieldLabel: "งาน"
                                                                ,hiddenName: 'pisj18[jobcode]'
                                                                ,id: 'pisj18[jobcode]'
                                                                ,valueField: 'jobcode'
                                                                ,displayField: 'jobname'
                                                                ,urlStore: pre_url + '/code/cjob'
                                                                ,fieldStore: ['jobcode', 'jobname']
                                                                ,anchor: "100%"
                                                            })
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                    ,{
                                        xtype: "textfield"
                                        ,id: 'cmd[note]'
                                        ,fieldLabel: "หมายเหตุ"
                                        ,anchor: "100%"
                                    }
                           ]
                  }
                  ,{
                    xtype: "fieldset"
                    ,id: "pispersonel"
                    ,disabled: true
                    ,style: "padding: 5px 5px 5px 5px; background-color:white"
                    ,items: [
                           {
                                    xtype: "compositefield"
                                    //,fieldLabel: "เลขประจำตัวประชาชน"
                                    ,hideLabel: true
                                    ,items: [
                                             {
                                                      xtype: "displayfield"
                                                      ,style: "padding: 4px;text-align: right"
                                                      ,value: "เลขประจำตัวประชาชน:"
                                             }
                                             ,{
                                                      xtype: "numberfield"
                                                      ,id: "pispersonel[pid]"
                                                      ,width: 150
                                                      ,enableKeyEvents: true
                                                      ,allowBlank: false
                                                      ,minLength: 13
                                                      ,maxLength: 13
                                                      ,vtype: "pid"
                                                      ,listeners: {
                                                               focus: function( el ){
                                                                        //pid = Ext.getCmp("pispersonel[pid]").getValue();
                                                                        //resetPispersonel();
                                                                        //Ext.getCmp("pispersonel").enable();
                                                                        //Ext.getCmp("pispersonel[pid]").setValue(pid);
                                                               }
                                                               ,specialkey: function( el,e ){
                                                                        if (e.keyCode == e.RETURN  || e.keyCode == e.TAB){
                                                                                 putPositionSearchPid(el);     
                                                                        }        
                                                               }
                                                               ,blur: function(el){
                                                                   if (Ext.getCmp("pispersonel[pid]").getValue() == ""){
                                                                      Ext.getCmp("pispersonel[id]").setValue("");
                                                                      Ext.getCmp("pispersonel[pid]").setValue("");
                                                                   }
                                                                   else{
                                                                        if (Ext.getCmp("pispersonel[pid]").validate()){
                                                                                 putPositionSearchPid(el);
                                                                        }
                                                                   }
                                                               }
                                                      }
                                             }
                                             ,{
                                                      xtype: "button"
                                                      ,text: "..."
                                                      ,handler: function(){
                                                               putPositionPid(Ext.getCmp("pispersonel[pid]")
                                                                           ,Ext.getCmp("pispersonel[id]"));
                                                      }
                                             },{
                                               xtype: "hidden"
                                               ,id:  "pispersonel[id]"
                                             }
                                             ,{
                                                      xtype: "displayfield"
                                                      ,style: "padding: 4px;text-align: right"
                                                      ,value: "คำนำหน้า"
                                             }
                                             ,new Ext.ux.form.PisComboBox({//คำนำหน้า
                                                      hiddenName: 'pispersonel[pcode]'
                                                      ,id: 'pispersonel[pcode]'
                                                      ,valueField: 'pcode'
                                                      ,displayField: 'longprefix'
                                                      ,urlStore: pre_url + '/code/cprefix'
                                                      ,fieldStore: ['pcode', 'longprefix']
                                                      ,width: 220
                                             })
                                             ,{
                                                      xtype: "displayfield"
                                                      ,style: "padding: 4px;text-align: right"
                                                      ,value: "ชื่อ"
                                             }
                                             ,{
                                                      xtype: "textfield"
                                                      ,id: "pispersonel[fname]"
                                             }
                                             ,{
                                                      xtype: "displayfield"
                                                      ,style: "padding: 4px;text-align: right"
                                                      ,value: "นามสกุล"
                                             }
                                             ,{
                                                      xtype: "textfield"
                                                      ,id: "pispersonel[lname]"
                                             }
                                             
                                    ]
                           }
                           ,{
                                    xtype: "compositefield"
                                    ,fieldLabel: "ปฎิบัติงานจริง"
                                    ,items: [
                                             new Ext.ux.form.PisComboBox({
                                                      id: 'pispersonel[j18code]'
                                                      ,hiddenName:'pispersonel[j18code]'
                                                      ,valueField: 'j18code'
                                                      ,displayField: 'j18status'
                                                      ,urlStore: pre_url + '/code/cj18status'
                                                      ,fieldStore: ['j18code', 'j18status']
                                                      ,width: 200
                                             })
                                             ,{
                                                      xtype: "displayfield"
                                                      ,style: "padding: 4px;text-align: right"
                                                      ,value: "รักษาการในตำแหน่ง"
                                             }
                                             ,new Ext.ux.form.PisComboBox({
                                                      hiddenName: 'pispersonel[excode]'
                                                      ,id: 'pispersonel[excode]'
                                                      ,valueField: 'excode'
                                                      ,displayField: 'exname'
                                                      ,urlStore: pre_url + '/code/cexecutive'
                                                      ,fieldStore: ['excode', 'exname']
                                                      ,width: 250
                                             })
                                             
                                    ]
                           }
                           ,{
                                    xtype: "fieldset"
                                    ,title: "หน่วยงานปฎิบัติงานจริง"
                                    ,items: [
                                             {
                                                      layout: "column"
                                                      ,items: [
                                                               {
                                                                        width: 320
                                                                        ,layout: "form"
                                                                        ,labelWidth: 90
                                                                        ,items: [
                                                                                 new Ext.ux.form.PisComboBox({//กระทรวง
                                                                                          fieldLabel: "กระทรวง"
                                                                                          ,hiddenName: 'pispersonel[mincode]'
                                                                                          ,id: 'pispersonel[mincode]'
                                                                                          ,valueField: 'mcode'
                                                                                          ,displayField: 'minname'
                                                                                          ,urlStore: pre_url + '/code/cministry'
                                                                                          ,fieldStore: ['mcode', 'minname']
                                                                                          ,anchor: "100%"                                                              
                                                                                 })
                                                                        ]
                                                               }
                                                               ,{
                                                                        width: 320
                                                                        ,layout: "form"
                                                                        ,labelWidth: 90
                                                                        ,items: [
                                                                                 new Ext.ux.form.PisComboBox({//กรม
                                                                                          fieldLabel: "กรม"
                                                                                          ,hiddenName: 'pispersonel[deptcode]'
                                                                                          ,id: 'pispersonel[deptcode]'
                                                                                          ,valueField: 'deptcode'
                                                                                          ,displayField: 'deptname'
                                                                                          ,urlStore: pre_url + '/code/cdept'
                                                                                          ,fieldStore: ['deptcode', 'deptname']
                                                                                          ,anchor: "100%" 
                                                                                 })                                                      
                                                                            
                                                                        ]
                                                               }
                                                               ,{
                                                                        width: 320
                                                                        ,layout: "form"
                                                                        ,labelWidth: 90
                                                                        ,items: [
                                                                                 new Ext.ux.form.PisComboBox({//กอง
                                                                                          fieldLabel: "กอง"
                                                                                          ,hiddenName: 'pispersonel[dcode]'
                                                                                          ,id: 'pispersonel[dcode]'                                            
                                                                                          ,valueField: 'dcode'
                                                                                          ,displayField: 'division'
                                                                                          ,urlStore: pre_url + '/code/cdivision'
                                                                                          ,fieldStore: ['dcode', 'division']
                                                                                          ,anchor: "100%" 
                                                                                 })
                                                                        ]
                                                               }
                                                      ]
                                             }
                                            ,{
                                                      layout: "column"
                                                      ,items: [
                                                               {
                                                                        width: 640
                                                                        ,layout: "form"
                                                                        ,labelWidth: 90
                                                                        ,items: [
                                                                                 {
                                                                                          xtype: "compositefield"
                                                                                          ,fieldLabel: "หน่วยงาน"
                                                                                          ,anchor: "100%"
                                                                                          ,items: [
                                                                                                   {
                                                                                                       xtype: "numberfield"
                                                                                                       ,id: "pispersonel[sdcode]"
                                                                                                       ,width: 80
                                                                                                       ,enableKeyEvents: true
                                                                                                       ,listeners: {
                                                                                                           specialkey : function( el,e ){
                                                                                                               Ext.getCmp("subdept_person_show").setValue("");
                                                                                                               if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
                                                                                                                   loadMask.show();
                                                                                                                   Ext.Ajax.request({
                                                                                                                      url: pre_url + '/code/csubdept_search_all'
                                                                                                                      ,params: {
                                                                                                                         sdcode: el.getValue()
                                                                                                                      }
                                                                                                                      ,success: function(response,opts){
                                                                                                                         obj = Ext.util.JSON.decode(response.responseText);
                                                                                                                         if (obj.totalcount == 0){
                                                                                                                            Ext.Msg.alert("สถานะ", "ไม่พบข้อมูล");
                                                                                                                            Ext.getCmp("pispersonel[sdcode]").setValue("");
                                                                                                                            Ext.getCmp("subdept_person_show").setValue("");
                                                                                                                         }
                                                                                                                         else{
                                                                                                                            Ext.getCmp("pispersonel[sdcode]").setValue(obj.records[0].sdcode);
                                                                                                                            Ext.getCmp("subdept_person_show").setValue(obj.records[0].subdeptname);
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
                                                                                                               if (Ext.getCmp("subdept_person_show").getValue() == ""){
                                                                                                                   Ext.getCmp("pispersonel[sdcode]").setValue("");
                                                                                                                   Ext.getCmp("subdept_person_show").setValue("");    
                                                                                                               }
                                                                                                          } 
                                                                                                       }
                                                                                                   }
                                                                                                   ,{
                                                                                                       xtype: "textfield"
                                                                                                       ,id: "subdept_person_show"
                                                                                                       ,readOnly: true
                                                                                                       ,style: "background-color:rgb(204, 204, 204);background-image:url('#');width:80%;"
                                                                                                   }
                                                                                                   ,{
                                                                                                       xtype: "button"
                                                                                                       ,id: "sdcode_person_button"
                                                                                                       ,text: "..."
                                                                                                       ,handler: function(){
                                                                                                           searchSubdeptAll(Ext.getCmp("pispersonel[sdcode]"),Ext.getCmp("subdept_person_show"));
                                                                                                       }
                                                                                                   }
                                                                                          ]
                                                                                 }
                                                                        ]
                                                               }
                                                      ]
                                            }
                                            ,{
                                                      layout: "column"
                                                      ,items: [
                                                          {
                                                              width: 320
                                                              ,layout: "form"
                                                              ,labelWidth: 90
                                                              ,items: [
                                                                  new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
                                                                      fieldLabel: "ฝ่าย/กลุ่มงาน"
                                                                      ,hiddenName: 'pispersonel[seccode]'
                                                                      ,id: 'pispersonel[seccode]'
                                                                      ,valueField: 'seccode'
                                                                      ,displayField: 'secname'
                                                                      ,urlStore: pre_url + '/code/csection'
                                                                      ,fieldStore: ['seccode', 'secname']
                                                                      ,anchor: "100%"
                                                                  })
                          
                                                              ]
                                                          }
                                                          ,{
                                                              width: 320
                                                              ,layout: "form"
                                                              ,labelWidth: 90
                                                              ,items: [
                                                                  new Ext.ux.form.PisComboBox({//งาน
                                                                      fieldLabel: "งาน"
                                                                      ,hiddenName: 'pispersonel[jobcode]'
                                                                      ,id: 'pispersonel[jobcode]'
                                                                      ,valueField: 'jobcode'
                                                                      ,displayField: 'jobname'
                                                                      ,urlStore: pre_url + '/code/cjob'
                                                                      ,fieldStore: ['jobcode', 'jobname']
                                                                      ,anchor: "100%"
                                                                  })
                                                              ]
                                                          }
                                                      ]
                                            }
                                    ]
                           }
                           ,{
                                    xtype: "compositefield"
                                    ,fieldLabel: "เพศ"
                                    ,items: [
                                             new Ext.form.ComboBox({
                                                      editable: true
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
                                                      ,valueField:'id'
                                                      ,displayField:'type'
                                                      ,typeAhead: true
                                                      ,mode: 'local'
                                                      ,triggerAction: 'all'
                                                      ,emptyText:'Select ...'
                                             })
                                             ,{
                                                      xtype: "displayfield"
                                                      ,value: "กลุ่มเลือด:"
                                                      ,style: "padding: 4px;text-align: right;padding-left: 10px"
                                             }
                                             ,new Ext.form.ComboBox({//กรุ๊ปเลือด
                                                     editable: true
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
                                                     ,valueField:'id'
                                                     ,displayField:'type'
                                                     ,typeAhead	: true
                                                     ,mode: 'local'
                                                     ,triggerAction: 'all'
                                                     ,emptyText:'Select ...'
                                             })
                                             ,{
                                                      xtype: "displayfield"
                                                      ,value: "วันเกิด:"
                                                      ,style: "padding: 4px;text-align: right;padding-left: 10px"
                                             }
                                             ,{
                                                      xtype: "datefield"
                                                      ,fieldLabel: "วันเกิด"
                                                      ,id: "pispersonel[birthdate]"
                                                      ,format: "d/m/Y"
                                                      ,listeners: {
                                                               select: function(el,date ){
                                                                        SetAgePutPosition();
                                                               } 
                                                      }
                                             }
                                             ,new Ext.BoxComponent({
                                                      autoEl: {
                                                               tag: "div"
                                                               ,id: "temp_etc1"
                                                               ,html: etc1_blank
                                                      }
                                             })
                                             
                                    ]
                           }
                           ,{
                                    layout: "column"
                                    ,items: [
                                             {
                                                      width: 250
                                                      ,layout: "form"
                                                      ,labelWidth: 130
                                                      ,items: [
                                                               {//วันบรรจุเข้ารับราชการ
                                                                        xtype: "datefield"
                                                                        ,fieldLabel: "วันบรรจุเข้ารับราชการ"
                                                                        ,format: "d/m/Y"
                                                                        ,id: "pispersonel[appointdate]"
                                                                        ,listeners: {
                                                                                 select: function(el,date ){
                                                                                          SetAgePutPosition();											
                                                                                 } 
                                                                        }
                                                              }
                                                              ,{//วันเข้าสู่หน่วยงานปัจจุบัน
                                                                        xtype: "datefield"
                                                                        ,fieldLabel: "วันเข้าสู่หน่วยงานปัจจุบัน"
                                                                        ,format: "d/m/Y"
                                                                        ,id: "pispersonel[deptdate]"
                                                                        ,listeners: {
                                                                                 select: function(el,date ){
                                                                                          SetAgePutPosition();											
                                                                                 } 
                                                                        }
                                                              }
                                                              ,{//วันที่เข้าสู่ระดับปัจจุบัน
                                                                        xtype: "datefield"
                                                                        ,fieldLabel: "วันที่เข้าสู่ระดับปัจจุบัน"
                                                                        ,format: "d/m/Y"
                                                                        ,id: "pispersonel[cdate]"
                                                                        ,listeners: {
                                                                                 select: function(el,date ){
                                                                                          SetAgePutPosition();										
                                                                                 } 
                                                                        }
                                                               }
                                                      ]
                                             }
                                             ,{
                                                      width: 215
                                                      ,layout: "form"
                                                      ,labelWidth: 130
                                                      ,items: [
                                                               new Ext.BoxComponent({
                                                                        autoEl: {
                                                                                 tag: "div"
                                                                                 ,id: "temp_etc2"
                                                                                 ,html: etc2_blank
                                                                        }
                                                               })
                                                      ]
                                             }
                                             ,{
                                                      width: 260
                                                      ,layout: "form"
                                                      ,labelWidth: 130
                                                      ,items: [
                                                               new Ext.BoxComponent({
                                                                        autoEl: {
                                                                                 tag: "div"
                                                                                 ,id: "temp_etc3"
                                                                                 ,html: etc3_blank
                                                                        }
                                                               })
                                                               ,{//วันที่บรรจุกลับ
                                                                        xtype: "datefield"
                                                                        ,fieldLabel: "วันที่บรรจุกลับ"
                                                                        ,format: "d/m/Y"
                                                                        ,id: "pispersonel[reentrydate]"
                                                               }
                                                               ,{//วันที่มาช่วยราชการ
                                                                        xtype: "datefield"
                                                                        ,fieldLabel: "วันที่มาช่วยราชการ"
                                                                        ,format: "d/m/Y"
                                                                        ,id: "pispersonel[attenddate]"
                                                                        ,listeners: {
                                                                                 select: function(el,date ){
                                                                                          SetAgePutPosition();											
                                                                                 } 
                                                                        }
                                                               }
                                                      ]
                                             }
                                             ,{
                                                      width: 250
                                                      ,layout: "form"
                                                      ,labelWidth: 130
                                                      ,items: [
                                                               {//วันที่รับโอน
                                                                        xtype: "datefield"
                                                                        ,fieldLabel: "วันที่รับโอน"
                                                                        ,format: "d/m/Y"
                                                                        ,id: "pispersonel[getindate]"
                                                               }
                                                               ,{//วันที่ออกจากราชการ
                                                                        xtype: "datefield"
                                                                        ,fieldLabel: "วันที่ออกจากราชการ"
                                                                        ,format: "d/m/Y"
                                                                        ,id: "pispersonel[quitdate]"
                                                               }
                                                               ,new Ext.BoxComponent({
                                                                        autoEl: {
                                                                                 tag: "div"
                                                                                 ,id: "temp_etc4"
                                                                                 ,html: etc4_blank
                                                                        }
                                                               })
                                                      ]
                                             }
                                    ]
                           }
                           ,{
                                    xtype: "compositefield"
                                    ,fieldLabel: "วุฒิในตำแหน่ง"
                                    ,items: [
                                             new Ext.ux.form.PisComboBox({
                                                      id: 'pispersonel[qcode]'
                                                      ,hiddenName:'pispersonel[qcode]'
                                                      ,valueField: 'qcode'
                                                      ,displayField: 'qualify'
                                                      ,urlStore: pre_url + '/code/cqualify'
                                                      ,fieldStore: ['qcode', 'qualify']
                                                      ,width: 400
                                             })
                                             ,{
                                                      xtype: "displayfield"
                                                      ,style: "padding: 4px;text-align: right;"
                                                      ,width: 70
                                                      ,value: "วิชาเอก:"
                                             }
                                             ,new Ext.ux.form.PisComboBox({
                                                      id: 'pispersonel[macode]'
                                                      ,hiddenName:'pispersonel[macode]'
                                                      ,valueField: 'macode'
                                                      ,displayField: 'major'
                                                      ,urlStore: pre_url + '/code/cmajor'
                                                      ,fieldStore: ['macode', 'major']
                                                      ,width: 400
                                             })                                    
                                    ]
                           }
                           ,new Ext.ux.form.PisComboBox({
                                    fieldLabel: "ใบอนุญาตประกอบอาชีพ"
                                    ,id: 'pispersonel[codetrade]'
                                    ,hiddenName:'pispersonel[codetrade]'
                                    ,valueField: 'codetrade'
                                    ,displayField: 'trade'
                                    ,urlStore: pre_url + '/code/ctrade'
                                    ,fieldStore: ['codetrade', 'trade']
                                    ,anchor: "100%"
                           })
                           ,{
                                    layout: "column"
                                    ,items: [
                                             {
                                                      width : 300
                                                      ,layout: "form"
                                                      ,items: [
                                                               {
                                                                        xtype: 'radiogroup',
                                                                        fieldLabel: 'สมาชิก กบข.',
                                                                        columns: 2,
                                                                        items: [
                                                                                 {boxLabel: 'สมัคร', name: 'kbk',id: "kbk1", inputValue: 1,checked: true},
                                                                                 {boxLabel: 'ไม่สมัคร', name: 'kbk',id: "kbk2", inputValue: 0}
                                                                        ]
                                                               }
                                                      ]
                                             }
                                             ,{
                                                      width : 680
                                                      ,layout: "form"
                                                      ,defaults: {
                                                               anchor: "100%"
                                                      }
                                                      ,items: [
                                                               {
                                                                        xtype: "textfield"
                                                                        ,fieldLabel: "ความสามารถพิเศษ"
                                                                        ,id: "pispersonel[specialty]"
                                                               }
                                                      ]
                                             }
                                             
                                    ]
                                    ,listeners: {
                                             afterrender: function(el){
                                                      el.doLayout();
                                             }
                                    }
                           }
                           ,{
                                    xtype: "textfield"
                                    ,fieldLabel: "หมายเหตุ1"
                                    ,anchor: "100%"
                                    ,id: "pispersonel[note]"
                           }
                           ,{
                                    xtype: "textfield"
                                    ,fieldLabel: "หมายเหตุ2"
                                    ,anchor: "100%"
                                    ,id: "pispersonel[note2]"
                           }

                    ]
                  }
            ]
        }
    ]
    ,buttons:[
    { 
        text:'บันทึก'
        ,formBind: true 
        ,handler:function(){ 					
            putPositionForm.getForm().submit(
            { 
                method:'POST'
                ,waitTitle:'Saving Data'
                ,waitMsg:'Sending data...'
                ,success:function(){
                           putPositionForm.getForm().reset();
                           tpl = new Ext.Template(etc1_blank);
                           tpl.overwrite(Ext.get("temp_etc1"), {});
                           tpl = new Ext.Template(etc2_blank);
                           tpl.overwrite(Ext.get("temp_etc2"), {});
                           tpl = new Ext.Template(etc3_blank);
                           tpl.overwrite(Ext.get("temp_etc3"), {});
                           tpl = new Ext.Template(etc4_blank);
                           tpl.overwrite(Ext.get("temp_etc4"), {});
                           Ext.getCmp("pispersonel").disable();
                           Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย");                                                                   
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
                  putPositionForm.getForm().reset();
                  tpl = new Ext.Template(etc1_blank);
                  tpl.overwrite(Ext.get("temp_etc1"), {});
                  tpl = new Ext.Template(etc2_blank);
                  tpl.overwrite(Ext.get("temp_etc2"), {});
                  tpl = new Ext.Template(etc3_blank);
                  tpl.overwrite(Ext.get("temp_etc3"), {});
                  tpl = new Ext.Template(etc4_blank);
                  tpl.overwrite(Ext.get("temp_etc4"), {});
                  Ext.getCmp("pispersonel").disable();
                  
        }
    }
] 

});
//-------------------------------------
// Panel Main
//-------------------------------------
var putPositionPanel = new Ext.Panel({
    layout: "border"
    ,title: "คำสั่งบรรจุ / รับย้าย / รับโอน"
    ,items: [
        putPositionForm   
    ]
    ,listeners: {
        afterrender: function(el){
                  el.doLayout();
                  if (type_group_user == "1"){
                           setReadOnlyWorkPlace();
                  }
                  if (type_group_user == "2"){
                           setReadOnlyWorkPlaceSSJ();
                  }
        }
    }
});
//--------------------------------
// Function
//---------------------------------
function putPositionPosid(posid){
    personelNowLeftSearch = new Ext.ux.grid.Search({
             iconCls: 'search'
             ,minChars: 3
             ,autoFocus: true
             ,position: "top"
             ,width: 200
    });
    personelNowLeftFields = [
        {name: "id", type: "string"}
        ,{name: "posid",type:"init"}
        ,{name: "status",type:"string"}
        ,{name: "posname",type:"string"}
        ,{name: "cname",type:"string"}
        ,{name: "salary",type:"string"}
        ,{name: "subdeptname",type:"string"}
        ,{name: "deptname",type:"string"}
    ];
    personelNowLeftCols = [
         {
                 header: "#"
                 ,width: 80
                 ,renderer: rowNumberer.createDelegate(this)
                 ,sortable: false
         }		
         ,{header: "ตำแหน่งเลขที่",width: 100, sortable: false, dataIndex: 'posid'	}
         ,{header: "สถานะตำแหน่ง",width:150,sortable:false,dataIndex:"status"}
         ,{header: "ตำแหน่งสายงาน",width: 200, sortable: false, dataIndex: 'posname'	}
         
    ];      
    personelNowLeftGridStore = new Ext.data.JsonStore({
            url: pre_url + "/info_pis_j18/read"
            ,root: "records"
            ,autoLoad: false
            ,totalProperty: 'totalCount'
            ,fields: personelNowLeftFields
            ,idProperty: 'id'
    });   
    personelNowLeftGridStore.baseParams = {
        status: '0'
    }
    personelNowLeftGrid = new Ext.grid.GridPanel({
            split: true
            ,store: personelNowLeftGridStore
            ,columns: personelNowLeftCols
            ,stripeRows: true
            ,loadMask: {msg:'Loading...'}
            ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
            ,plugins: [personelNowLeftSearch]
            ,bbar: new Ext.PagingToolbar({
                      pageSize: 20
                      ,autoWidth: true
                      ,store: personelNowLeftGridStore
                      ,displayInfo: true
                      ,displayMsg	: 'Displaying {0} - {1} of {2}'
                      ,emptyMsg: "Not found"
            })
            ,tbar: []
    });
    personelNowLeftGrid.on('rowdblclick', function(grid, rowIndex, e ) {
        data_select = grid.getSelectionModel().getSelected().data;
        posid.setValue(data_select.posid);
        putPositonSearchEditJ18(data_select);
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
            ,items: [personelNowLeftGrid]
            });
    }
    win.show();	
    win.center();
    personelNowLeftGridStore.load({params:{start: 0,limit: 20}});
}
function putPositonSearchEditJ18(data_select){
         loadMask.show();
         Ext.Ajax.request({
                  url: pre_url + "/info_pis_j18/search_edit"
                  ,params: {
                           posid: data_select.posid
                  }
                  ,success: function(response,opts){
                           obj = Ext.util.JSON.decode(response.responseText);
                           if (obj.success){
                                    data = obj.data.pisj18;
                                    
                                    Ext.getCmp("pisj18[posid]").setValue(data.posid);
                                    Ext.getCmp("subdept_show").setValue(data.subdept_show);
                                    Ext.getCmp("pisj18[salary]").setValue(data.salary);
                                    Ext.getCmp("pisj18[sdcode]").setValue(data.sdcode);
                                    
                                    
                                    Ext.getCmp("pisj18[poscode]").getStore().load({
                                             params: {
                                                      poscode: data.poscode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[poscode]").setValue(data.poscode);
                                             }
                                    });

                                    Ext.getCmp("pisj18[excode]").getStore().load({
                                             params: {
                                                      excode: data.excode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[excode]").setValue(data.excode);
                                             }
                                    });

                                    Ext.getCmp("pisj18[mincode]").getStore().load({
                                             params: {
                                                      mcode: data.mincode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[mincode]").setValue(data.mincode);
                                             }
                                    });
                                    
                                    Ext.getCmp("pisj18[c]").getStore().load({
                                             params: {
                                                      ccode: data.c
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[c]").setValue(data.c);
                                             }
                                    });
                                    
                                    Ext.getCmp("pisj18[epcode]").getStore().load({
                                             params: {
                                                      epcode: data.epcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[epcode]").setValue(data.epcode);
                                             }
                                    });

                                    Ext.getCmp("pisj18[deptcode]").getStore().load({
                                             params: {
                                                      deptcode: data.deptcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[deptcode]").setValue(data.deptcode);
                                             }
                                    });

                                    Ext.getCmp("pisj18[ptcode]").getStore().load({
                                             params: {
                                                      ptcode: data.ptcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[ptcode]").setValue(data.ptcode);
                                             }
                                    });

                                    Ext.getCmp("pisj18[dcode]").getStore().load({
                                             params: {
                                                      dcode: data.dcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[dcode]").setValue(data.dcode);
                                             }
                                    });

                                    Ext.getCmp("pisj18[seccode]").getStore().load({
                                             params: {
                                                      seccode: data.seccode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[seccode]").setValue(data.seccode);
                                             }
                                    });

                                    Ext.getCmp("pisj18[jobcode]").getStore().load({
                                             params: {
                                                      jobcode: data.jobcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pisj18[jobcode]").setValue(data.jobcode);
                                                      loadMask.hide();
                                                      Ext.getCmp("pispersonel").enable();
                                             }
                                    });
                                    
                                    Ext.getCmp("pispersonel[mincode]").getStore().load({
                                             params: {
                                                      mcode: data.mincode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[mincode]").setValue(data.mincode);
                                             }
                                    });
                                    
                                    Ext.getCmp("pispersonel[deptcode]").getStore().load({
                                             params: {
                                                      deptcode: data.deptcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[deptcode]").setValue(data.deptcode);
                                             }
                                    });

                                    Ext.getCmp("pispersonel[dcode]").getStore().load({
                                             params: {
                                                      dcode: data.dcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[dcode]").setValue(data.dcode);
                                             }
                                    });
                                    
                                    Ext.getCmp("subdept_person_show").setValue(data.subdept_show);
                                    Ext.getCmp("pispersonel[sdcode]").setValue(data.sdcode);
                                    
                                    Ext.getCmp("pispersonel[seccode]").getStore().load({
                                             params: {
                                                      seccode: data.seccode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[seccode]").setValue(data.seccode);
                                             }
                                    });

                                    Ext.getCmp("pispersonel[jobcode]").getStore().load({
                                             params: {
                                                      jobcode: data.jobcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[jobcode]").setValue(data.jobcode);
                                                      loadMask.hide();
                                                      Ext.getCmp("pispersonel").enable();
                                             }
                                    });                                                                        
                                    
                                    
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
function putPositionPid(pid,id){
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
             ,{name: "pid", type: "string"}
             ,{name: "id", type: "string"}
    ];
    personelNowCols = [
         {
                  header: "#"
                  ,width: 80
                  ,renderer: rowNumberer.createDelegate(this)
                  ,sortable: false
         }
         ,{header: "เลขประจำตัวประชาชน",width: 140, sortable: false, dataIndex: 'pid'}		
         ,{header: "คำนำหน้า",width: 70, sortable: false, dataIndex: 'prefix'}
         ,{header: "ชื่อ",width: 100, sortable: false, dataIndex: 'fname'}
         ,{header: "นามสกุล",width: 100, sortable: false, dataIndex: 'lname'}
         
    ];
    personelNowGridStore = new Ext.data.JsonStore({
            url: pre_url + "/info_personal_old/read"
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
        pid.setValue(data_select.pid);
        id.setValue(data_select.id);
        putPositionSearchEditPerformPerson(data_select);
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
function putPositionSearchEditPerformPerson(data_select){
         loadMask.show();
         Ext.Ajax.request({
                  url: pre_url + "/info_perform_now/search_edit"
                  ,params: {
                           id: data_select.id
                  }
                  ,success: function(response,opts){
                           obj = Ext.util.JSON.decode(response.responseText);
                           data = obj.data.pispersonel;
                           if (obj.success){
                                    if(data.kbk == "1"){
                                             Ext.getCmp("kbk1").setValue(data.kbk);       
                                    }
                                    else if(data.kbk == "0"){
                                             Ext.getCmp("kbk2").setValue(data.kbk);       
                                    }
                                    Ext.getCmp("pispersonel[pid]").setValue(data.pid);
                                    Ext.getCmp("pispersonel[id]").setValue(data.id);
                                    
                                    Ext.getCmp("pispersonel[fname]").setValue(data.fname);
                                    Ext.getCmp("pispersonel[lname]").setValue(data.lname);
                                    Ext.getCmp("pispersonel[sex]").setValue(data.sex);
                                    Ext.getCmp("pispersonel[bloodgroup]").setValue(data.bloodgroup);
                                    Ext.getCmp("pispersonel[birthdate]").setValue(to_date_app(data.birthdate));
                                    Ext.getCmp("pispersonel[appointdate]").setValue(to_date_app(data.appointdate));
                                    Ext.getCmp("pispersonel[deptdate]").setValue(to_date_app(data.deptdate));
                                    Ext.getCmp("pispersonel[cdate]").setValue(to_date_app(data.cdate));
                                    Ext.getCmp("pispersonel[reentrydate]").setValue(to_date_app(data.reentrydate));
                                    Ext.getCmp("pispersonel[attenddate]").setValue(to_date_app(data.attenddate));
                                    Ext.getCmp("pispersonel[getindate]").setValue(to_date_app(data.getindate));
                                    Ext.getCmp("pispersonel[quitdate]").setValue(to_date_app(data.quitdate));
                                    Ext.getCmp("pispersonel[specialty]").setValue(data.specialty);
                                    Ext.getCmp("pispersonel[note]").setValue(data.note);
                                    Ext.getCmp("pispersonel[note2]").setValue(data.note2);
                                    Ext.getCmp("pispersonel[codetrade]").getStore().load({
                                             params: {
                                                      codetrade: data.codetrade
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[codetrade]").setValue(data.codetrade);
                                                      loadMask.hide();
                                             }
                                    });
                                    Ext.getCmp("pispersonel[macode]").getStore().load({
                                             params: {
                                                      macode: data.macode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[macode]").setValue(data.macode);
                                             }
                                    });
                                    Ext.getCmp("pispersonel[qcode]").getStore().load({
                                             params: {
                                                      qcode: data.qcode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[qcode]").setValue(data.qcode);
                                             }
                                    });
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
                                    Ext.getCmp("pispersonel[excode]").getStore().load({
                                             params: {
                                                      excode: data.excode
                                                      ,start: 0
                                                      ,limit: 10
                                             }
                                             ,callback :function(){
                                                      Ext.getCmp("pispersonel[excode]").setValue(data.excode);
                                                      SetAgePutPosition();
                                                      loadMask.hide(); 
                                             }
                                    });        
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
function resetPisj18(){
         Ext.getCmp("pisj18[posid]").setValue("");
         Ext.getCmp("subdept_show").setValue("");
         Ext.getCmp("pisj18[salary]").setValue("");
         Ext.getCmp("pisj18[sdcode]").setValue("");
         Ext.getCmp("pisj18[poscode]").clearValue();
         Ext.getCmp("pisj18[excode]").clearValue();
         Ext.getCmp("pisj18[mincode]").clearValue();
         Ext.getCmp("pisj18[c]").clearValue();
         Ext.getCmp("pisj18[epcode]").clearValue();
         Ext.getCmp("pisj18[deptcode]").clearValue();
         Ext.getCmp("pisj18[ptcode]").clearValue();
         Ext.getCmp("pisj18[dcode]").clearValue();
         Ext.getCmp("pisj18[seccode]").clearValue();
         Ext.getCmp("pisj18[jobcode]").clearValue();
         Ext.getCmp("pispersonel[mincode]").clearValue();
         Ext.getCmp("pispersonel[deptcode]").clearValue();
         Ext.getCmp("pispersonel[dcode]").clearValue();
         Ext.getCmp("pispersonel[seccode]").clearValue();
         Ext.getCmp("pispersonel[jobcode]").clearValue();
         Ext.getCmp("subdept_person_show").setValue("");
         Ext.getCmp("pispersonel[sdcode]").setValue("");         
}
function resetPispersonel(){
         Ext.getCmp("pispersonel[pid]").setValue("");
         Ext.getCmp("pispersonel[id]").setValue("");
         Ext.getCmp("pispersonel[fname]").setValue("");
         Ext.getCmp("pispersonel[lname]").setValue("");
         Ext.getCmp("pispersonel[birthdate]").setValue("");
         Ext.getCmp("pispersonel[appointdate]").setValue("");
         Ext.getCmp("pispersonel[deptdate]").setValue("");
         Ext.getCmp("pispersonel[cdate]").setValue("");
         Ext.getCmp("pispersonel[reentrydate]").setValue("");
         Ext.getCmp("pispersonel[attenddate]").setValue("");
         Ext.getCmp("pispersonel[getindate]").setValue("");
         Ext.getCmp("pispersonel[quitdate]").setValue("");
         Ext.getCmp("pispersonel[note]").setValue("");
         Ext.getCmp("pispersonel[note2]").setValue("");
         Ext.getCmp("pispersonel[specialty]").setValue("");
         Ext.getCmp("pispersonel[pcode]").clearValue();
         Ext.getCmp("pispersonel[excode]").clearValue();
         Ext.getCmp("pispersonel[sex]").clearValue();
         Ext.getCmp("pispersonel[bloodgroup]").clearValue();
         Ext.getCmp("pispersonel[codetrade]").clearValue();
         Ext.getCmp("pispersonel[qcode]").clearValue();
         Ext.getCmp("pispersonel[macode]").clearValue();
         Ext.getCmp("kbk1").setValue(1);
         tpl = new Ext.Template(etc1_blank);
         tpl.overwrite(Ext.get("temp_etc1"), {});
         tpl = new Ext.Template(etc2_blank);
         tpl.overwrite(Ext.get("temp_etc2"), {});
         tpl = new Ext.Template(etc3_blank);
         tpl.overwrite(Ext.get("temp_etc3"), {});
         tpl = new Ext.Template(etc4_blank);
         tpl.overwrite(Ext.get("temp_etc4"), {});
         Ext.getCmp("pispersonel").disable();
}
function SetAgePutPosition(){
         var data = {
                 age: ''
                 ,age_gov:''
                 ,term_task:''
                 ,period1:''
                 ,period2:""
                 ,date_retire: ""
                 ,term_retire: ""
         };
        if (Ext.getCmp("pispersonel[birthdate]").getRawValue() != ""){
                  dt = new Date();
                  birthdate = Ext.getCmp("pispersonel[birthdate]").getValue();
                  age =  dateDiff(new Date(),birthdate)
                  data.age = age[0]+" ปี  " + age[1] + " เดือน  " + age[2] + " วัน" ;
                  if ( birthdate.getMonth() >= 9 ){
                           if (birthdate.getMonth() == 9 && birthdate.getDate() == 1){
                                    date_retire = new Date(birthdate.getFullYear()+60,8,30);      
                           }
                           else{
                                    date_retire = new Date(birthdate.getFullYear()+61,8,30);     
                           }
                  }
                  else{
                           date_retire = new Date(birthdate.getFullYear()+60,8,30); 
                  }
                  if (new Date() > date_retire){
                           duration_retire = dateDiff(new Date(),date_retire);
                           date_retire.setDate(date_retire.getDate() - 1 );
                  }
                  else{
                           duration_retire = dateDiff(date_retire,new Date());
                           date_retire.setDate(date_retire.getDate() - 1 );
                  }
                  
                  duration_retire = duration_retire[0]+" ปี  " + duration_retire[1] + " เดือน  " + duration_retire[2] + " วัน" ;
                  date_retire = pad2(date_retire.getDate()) + "/" + pad2(date_retire.getMonth()+1) + "/" + (date_retire.getFullYear() + 543);
                  data.date_retire = date_retire
                  data.term_retire = duration_retire
                  
                  var tpl = new Ext.Template(
                           "<table style='font:12px tahoma,arial,helvetica,sans-serif;margin-left:10px;'>" +
                                    "<tr >" +
                                             "<td style='padding-bottom:4px' align='right' height='24px'>อายุ:</td>"+
                                             "<td style='padding-left: 5px;width:130px;background-color: rgb(204, 204, 204);'>{age}</td>"+
                                             "<td style='padding-bottom:4px;padding-left:30px;' align='right' height='24px'>วันครบเกษียณ:</td>"+
                                             "<td style='padding-left: 5px;width:130px;background-color: rgb(204, 204, 204);'>{date_retire}</td>"+
                                    "</tr>" + 
                           "</table>"
                  );
                  tpl.overwrite(Ext.get("temp_etc1"), data);
                  Ext.getCmp("pispersonel[retiredate]").setValue(date_retire);									 
        }

        if (Ext.getCmp("pispersonel[appointdate]").getRawValue() != ""){
                tmp_date = Ext.getCmp("pispersonel[appointdate]").getValue();
                tmp_date = dateDiff(new Date(),tmp_date)
                data.age_gov = tmp_date[0]+" ปี  " + tmp_date[1] + " เดือน  " + tmp_date[2] + " วัน" ;
        }

        if (Ext.getCmp("pispersonel[deptdate]").getRawValue() != ""){
                tmp_date = Ext.getCmp("pispersonel[deptdate]").getValue();
                tmp_date = dateDiff(new Date(),tmp_date)
                data.term_task = tmp_date[0]+" ปี  " + tmp_date[1] + " เดือน  " + tmp_date[2] + " วัน" ;
        }

        if (Ext.getCmp("pispersonel[cdate]").getRawValue() != ""){
                tmp_date = Ext.getCmp("pispersonel[cdate]").getValue();
                tmp_date = dateDiff(new Date(),tmp_date)
                data.period1 = tmp_date[0]+" ปี  " + tmp_date[1] + " เดือน  " + tmp_date[2] + " วัน" ;
        }
         if (Ext.getCmp("pispersonel[attenddate]").getRawValue() != ""){
                tmp_date = Ext.getCmp("pispersonel[attenddate]").getValue();
                tmp_date = dateDiff(new Date(),tmp_date)
                data.period2 = tmp_date[0]+" ปี  " + tmp_date[1] + " เดือน  " + tmp_date[2] + " วัน" ;
         }
         tpl = new Ext.Template(
                  "<table style='font:12px tahoma,arial,helvetica,sans-serif;margin-left:10px;'>" +
                           "<tr ><td style='padding-bottom:4px;width:140px' align='right' height='22px'>ระยะเวลา:</td><td style='padding-left: 5px;width:130px;background-color: rgb(204, 204, 204);'>{period2}</td></tr>" + 
                  "</table>" 
         );
         tpl.overwrite(Ext.get("temp_etc4"), data);

         tpl = new Ext.Template(
                  "<table style='font:12px tahoma,arial,helvetica,sans-serif;margin-left:10px;'>" +
                           "<tr ><td style='padding-bottom:4px;width:130px' align='right' height='22px'>ระยะเวลาครบเกษียณ:&nbsp;</td><td style='padding-left: 5px;width:130px;background-color: rgb(204, 204, 204);'>{term_retire}</td></tr>" + 
                  "</table>"
         );
         tpl.overwrite(Ext.get("temp_etc3"), data);

         tpl = new Ext.Template(
                  "<table style='font:12px tahoma,arial,helvetica,sans-serif;margin-left:10px;'>" +
                           "<tr ><td style='padding-bottom:4px' align='right' height='22px'>อายุราชการ:</td><td style='padding-left: 5px;width:130px;background-color: rgb(204, 204, 204);'>{age_gov}</td></tr>" + 
                           "<tr ><td style='padding-bottom:4px' align='right' height='22px'>ระยะเวลา:</td><td style='padding-left: 5px;width:130px;background-color: rgb(204, 204, 204);'>{term_task}</td></tr>" + 
                           "<tr ><td style='padding-bottom:4px' align='right' height='22px'>ระยะเวลา:</td><td style='padding-left: 5px;width:130px;background-color: rgb(204, 204, 204);'>{period1}</td></tr>" + 
                  "</table>"
         );
         tpl.overwrite(Ext.get("temp_etc2"), data);
}

function putPositionSearchPid(el){
         loadMask.show();
         Ext.Ajax.request({
                  url: pre_url + '/info_personal_old/search_pid'
                  ,params: {
                           pid: el.getValue()
                  }
                  ,success: function(response,opts){
                           obj = Ext.util.JSON.decode(response.responseText);
                           loadMask.hide();
                           if (obj.success){
                                    putPositionSearchEditPerformPerson(obj.data[0]);
                           }
                           else{
                                    pid = Ext.getCmp("pispersonel[pid]").getValue();
                                    resetPispersonel();
                                    Ext.getCmp("pispersonel").enable();
                                    Ext.getCmp("pispersonel[id]").setValue("");
                                    Ext.getCmp("pispersonel[pid]").setValue(pid);
                                    Ext.Msg.alert("สถานะ", "ไม่พบข้อมูล");
                           }
                  }
                  ,failure: function(response,opts){
                           Ext.Msg.alert("สถานะ",response.statusText);
                           loadMask.hide();
                  }
         });    
}