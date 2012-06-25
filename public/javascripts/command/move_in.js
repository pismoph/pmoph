work_place = {
    mcode: ""
    ,deptcode: ""
    ,dcode: "newed[dcode]"
    ,sdcode: "newed[sdcode]"
    ,sdcode_show: "subdept_show_right"
    ,sdcode_button: "sdcode_button"
    ,seccode: "newed[seccode]"
    ,jobcode: "newed[jobcode]"
}
tmp_move_in_blank = "<table style='font:12px tahoma,arial,helvetica,sans-serif' >" +
        "<tr >"+
           "<td style='padding-bottom:4px;width:100px;padding-right:10px' align='right' height='24px'>กรม:</td>" +
           "<td style='width:300px;background-color:rgb(204, 204, 204);border: 1px solid #B5B8C8;'></td>"+
           "<td style='padding-bottom:4px;width:100px;padding-right:10px' align='right' height='24px'>กอง:</td>"+
           "<td style='width:300px;background-color:rgb(204, 204, 204);border: 1px solid #B5B8C8;'></td>"+
       "</tr>" +
        "<tr >"+
           "<td style='padding-bottom:4px;width:100px;padding-right:10px' align='right' height='24px'>ชื่อหน่วยงาน:</td>"+
           "<td style='background-color:rgb(204, 204, 204);border: 1px solid #B5B8C8;' colspan=3></td>"+
       "</tr>" +
        "<tr >"+
           "<td style='padding-bottom:4px;width:100px;padding-right:10px' align='right' height='24px'>ฝ่าย/กลุ่มงาน:</td>" +
           "<td style='width:300px;background-color:rgb(204, 204, 204);border: 1px solid #B5B8C8;'></td>"+
           "<td style='padding-bottom:4px;width:100px;padding-right:10px' align='right' height='24px'>งาน:</td>"+
           "<td style='width:300px;background-color:rgb(204, 204, 204);border: 1px solid #B5B8C8;'></td>"+
       "</tr>" +
"</table>"

tmp_move_in = "<table style='font:12px tahoma,arial,helvetica,sans-serif' >" +
        "<tr >"+
           "<td style='padding-bottom:4px;width:100px;padding-right:10px' align='right' height='24px'>กรม:</td>" +
           "<td style='width:300px;background-color:rgb(204, 204, 204);border: 1px solid #B5B8C8;'>{wdeptname}</td>"+
           "<td style='padding-bottom:4px;width:100px;padding-right:10px' align='right' height='24px'>กอง:</td>"+
           "<td style='width:300px;background-color:rgb(204, 204, 204);border: 1px solid #B5B8C8;'>{wdivision}</td>"+
       "</tr>" +
        "<tr >"+
           "<td style='padding-bottom:4px;width:100px;padding-right:10px' align='right' height='24px'>ชื่อหน่วยงาน:</td>"+
           "<td style='background-color:rgb(204, 204, 204);border: 1px solid #B5B8C8;' colspan=3>{wsubdeptname}</td>"+
       "</tr>" +
        "<tr >"+
           "<td style='padding-bottom:4px;width:100px;padding-right:10px' align='right' height='24px'>ฝ่าย/กลุ่มงาน:</td>" +
           "<td style='width:300px;background-color:rgb(204, 204, 204);border: 1px solid #B5B8C8;'>{wsecname}</td>"+
           "<td style='padding-bottom:4px;width:100px;padding-right:10px' align='right' height='24px'>งาน:</td>"+
           "<td style='width:300px;background-color:rgb(204, 204, 204);border: 1px solid #B5B8C8;'>{wjobname}</td>"+
       "</tr>" +
"</table>"
//-------------------------------------
// Form Center
//-------------------------------------
var moveInForm = new Ext.FormPanel({
    labelWidth: 100
    ,autoScroll: true
    ,url: pre_url + '/move_in/process_move_in'
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
                    xtype: "compositefield"
                    ,fieldLabel: "เลขที่คำสั่ง"
                    ,items: [
                        {
                            xtype: "textfield"
                            ,id: "cmd[refcmnd]"
                            ,width: 600
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
                ,new Ext.ux.form.PisComboBox({//การเคลื่อนไหว
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
                    xtype: "textfield"
                    ,id: "cmd[note]"
                    ,fieldLabel: "หมายเหตุ"
                    ,anchor: "100%"
                }
                ,{
                    xtype: 'radiogroup'
                    //,hideLabel: true
                    ,items: [
                        {boxLabel: 'สับตรง', name: 'type_action', inputValue: 1}
                        ,{boxLabel: 'สับเปลี่ยนเงิน', name: 'type_action', inputValue: 2}
                        ,{boxLabel: 'ขาดอัตรามาเบิก', name: 'type_action', inputValue: 3}
                        ,{boxLabel: 'อาศัยเบิก', name: 'type_action', inputValue: 4}
                        ,{boxLabel: 'ไม่มี', name: 'type_action', inputValue: 5,checked: true}
                    ]
                }            
                ,{
                    layout: "column"
                    ,items: [
                        {
                            width: 500
                            ,style: "padding: 5px;"
                            ,items: [
                                {
                                    xtype: "fieldset"
                                    ,height: 400
                                    ,title: "ตำแหน่งเดิม"
                                    ,items: [
                                        {
                                                xtype: "compositefield"
                                                ,fieldLabel: "เลขที่ตำแหน่ง"
                                                ,anchor: "100%"
                                                ,items: [
                                                    {
                                                        xtype: "numberfield"
                                                        ,id: "olded[posid]"
                                                        ,width: 100
                                                        ,allowBlank: false
                                                        ,enableKeyEvents: true
                                                        ,listeners: {
                                                            specialkey : function( el,e ){
                                                                if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
                                                                    MoveInSearchLeft(el.getValue());
                                                                }        
                                                            }
                                                        }
                                                    }
                                                    ,{
                                                        xtype: "button"
                                                        ,text: "..."
                                                        ,handler: function(){
                                                            MoveInPosidLeft(Ext.getCmp("olded[posid]")
                                                                        ,Ext.getCmp("olded[name]")
                                                                        ,Ext.getCmp("olded[id]"));
                                                        }
                                                    }
                                                    ,{
                                                        xtype: "hidden"
                                                        ,id: "olded[id]"
                                                    }
                                                ]
                                        }
                                        ,{
                                            xtype: "textfield"
                                            ,id: "olded[name]"
                                            ,fieldLabel: "ชื่อผู้ครองตำแหน่ง"
                                            ,anchor: "95%"
                                            ,style: "background-color:rgb(204, 204, 204);background-image:url('#');"
                                            ,readOnly: true
                                        }
                                        ,{
                                            xtype: "textfield"
                                            ,id: "olded[posname]"
                                            ,fieldLabel: "ตำแหน่งสายงาน"
                                            ,anchor: "95%"
                                            ,style: "background-color:rgb(204, 204, 204);background-image:url('#');"
                                            ,readOnly: true
                                        }
                                        ,{
                                            xtype: "textfield"
                                            ,id: "olded[cname]"
                                            ,fieldLabel: "ระดับ"
                                            ,anchor: "95%"
                                            ,style: "background-color:rgb(204, 204, 204);background-image:url('#');"
                                            ,readOnly: true
                                        }
                                        ,{
                                            xtype: "textfield"
                                            ,id: "olded[salary]"
                                            ,fieldLabel: "เงินเดือน"
                                            ,anchor: "95%"
                                            ,style: "background-color:rgb(204, 204, 204);background-image:url('#');"
                                            ,readOnly: true
                                        }
                                        ,{
                                            xtype: "textfield"
                                            ,id: "olded[exname]"
                                            ,fieldLabel: "ตำแหน่งบริหาร"
                                            ,anchor: "95%"
                                            ,style: "background-color:rgb(204, 204, 204);background-image:url('#');"
                                            ,readOnly: true
                                        }
                                        ,{
                                            xtype: "textfield"
                                            ,id: "olded[expert]"
                                            ,fieldLabel: "ความเชี่ยวชาญ"
                                            ,anchor: "95%"
                                            ,style: "background-color:rgb(204, 204, 204);background-image:url('#');"
                                            ,readOnly: true
                                        }
                                        ,{
                                            xtype: "textfield"
                                            ,id: "olded[ptname]"
                                            ,fieldLabel: "ว./วช./ชช."
                                            ,anchor: "95%"
                                            ,style: "background-color:rgb(204, 204, 204);background-image:url('#');"
                                            ,readOnly: true
                                        }
                                        ,{
                                            xtype: "textfield"
                                            ,id: "olded[division]"
                                            ,fieldLabel: "กอง"
                                            ,anchor: "95%"
                                            ,style: "background-color:rgb(204, 204, 204);background-image:url('#');"
                                            ,readOnly: true
                                        }
                                        ,{
                                            xtype: "textfield"
                                            ,id: "olded[subdeptname]"
                                            ,fieldLabel: "ชื่อหน่วยงาน"
                                            ,anchor: "95%"
                                            ,style: "background-color:rgb(204, 204, 204);background-image:url('#');"
                                            ,readOnly: true
                                        }
                                        ,{
                                            xtype: "textfield"
                                            ,id: "olded[secname]"
                                            ,fieldLabel: "ฝ่าย/กลุ่มงาน"
                                            ,anchor: "95%"
                                            ,style: "background-color:rgb(204, 204, 204);background-image:url('#');"
                                            ,readOnly: true
                                        }
                                        ,{
                                            xtype: "textfield"
                                            ,id: "olded[jobname]"
                                            ,fieldLabel: "งาน"
                                            ,anchor: "95%"
                                            ,style: "background-color:rgb(204, 204, 204);background-image:url('#');"
                                            ,readOnly: true
                                        }
                                    ]
                                }
                            ]
                        }
                        ,{
                            width: 500
                            ,style: "padding: 5px;"
                            ,items: [
                                {
                                    xtype: "fieldset"
                                    ,title: "ตำแหน่งที่แต่งตั้ง"
                                    ,height: 400
                                    ,items: [
                                        {
                                                xtype: "compositefield"
                                                ,fieldLabel: "เลขที่ตำแหน่ง"
                                                ,anchor: "100%"
                                                ,items: [
                                                    {
                                                        xtype: "numberfield"
                                                        ,id: "newed[posid]"
                                                        ,width: 100
                                                        ,allowBlank: false
                                                        ,enableKeyEvents: true
                                                        ,listeners: {
                                                            specialkey : function( el,e ){
                                                                if (e.keyCode == e.RETURN || e.keyCode == e.TAB){
                                                                    MoveInSearchRight(el.getValue());
                                                                }        
                                                            }
                                                        }
                                                    }
                                                    ,{
                                                        xtype: "button"
                                                        ,text: "..."
                                                        ,handler: function(){
                                                            MoveInPosidRight(Ext.getCmp("newed[posid]")
                                                                        ,Ext.getCmp("name_right")
                                                                        ,Ext.getCmp("newed[id]"));
                                                        }
                                                    }
                                                    ,{
                                                        xtype: "hidden"
                                                        ,id: "newed[id]"
                                                    }
                                                ]
                                        }
                                        ,{
                                            xtype: "textfield"
                                            ,id: "name_right"
                                            ,fieldLabel: "ชื่อผู้ครองตำแหน่ง"
                                            ,anchor: "95%"
                                            ,style: "background-color:rgb(204, 204, 204);background-image:url('#');"
                                            ,readOnly: true
                                        }
                                        ,new Ext.ux.form.PisComboBox({//ตำแหน่งสายงาน
                                            fieldLabel: "ตำแหน่งสายงาน"
                                            ,hiddenName: 'newed[poscode]'
                                            ,id: 'newed[poscode]'
                                            ,valueField: 'poscode'
                                            ,displayField: 'posname'
                                            ,urlStore: pre_url + '/code/cposition'
                                            ,fieldStore: ['poscode', 'posname']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//ระดับ
                                            fieldLabel: "ระดับ"
                                            ,hiddenName: 'newed[c]'
                                            ,id: 'newed[c]'
                                            ,valueField: 'ccode'
                                            ,displayField: 'cname'
                                            ,urlStore: pre_url + '/code/cgrouplevel'
                                            ,fieldStore: ['ccode', 'cname']
                                            ,anchor: "95%"
                                        })
                                        ,{
                                            xtype: "compositefield"
                                            ,fieldLabel: "ร้อยละที่ได้เลื่อน"
                                            ,items: [
                                                {
                                                    xtype: "numberfield"
                                                    ,id: "newed[uppercent]"
                                                }
                                                ,{
                                                    xtype: "displayfield"
                                                    ,style: "padding: 4px;text-align: right;padding-left: 10px"
                                                    ,value: "ค่าตอบแทนพิเศษ:"
                                                }
                                                ,{
                                                    xtype: "numericfield"
                                                    ,id: "newed[upsalary]"
                                                    ,width: 100
                                                }
                                            ]
                                        }
                                        ,{
                                            xtype: "compositefield"
                                            ,fieldLabel: "เงินเดือน"
                                            ,items: [
                                                {
                                                    xtype: "numericfield"
                                                    ,id: "newed[salary]"
                                                }
                                                ,{
                                                    xtype: "displayfield"
                                                    ,style: "padding: 4px;text-align: right;padding-left: 10px"
                                                    ,value: "เงินประจำตำแหน่ง:"
                                                }
                                                ,{
                                                    xtype: "numericfield"
                                                    ,id: "newed[posmny]"
                                                    ,width: 100
                                                }
                                            ]
                                        }
                                        ,{
                                            xtype: "numericfield"
                                            ,fieldLabel: "เงินพสร"
                                            ,id: "newed[spmny]"
                                        }
                                        ,new Ext.ux.form.PisComboBox({//ตำแหน่งบริหาร
                                            fieldLabel: "ตำแหน่งบริหาร"
                                            ,hiddenName: 'newed[excode]'
                                            ,id: 'newed[excode]'
                                            ,valueField: 'excode'
                                            ,displayField: 'exname'
                                            ,urlStore: pre_url + '/code/cexecutive'
                                            ,fieldStore: ['excode', 'exname']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//ความเชี่ยวชาญ
                                            fieldLabel: "ความเชี่ยวชาญ"
                                            ,hiddenName: 'newed[epcode]'
                                            ,id: 'newed[epcode]'
                                            ,valueField: 'epcode'
                                            ,displayField: 'expert'
                                            ,urlStore: pre_url + '/code/cexpert'
                                            ,fieldStore: ['epcode', 'expert']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//ว./ว.ช/ชช.
                                            fieldLabel: "ว./ว.ช/ชช."
                                            ,hiddenName: 'newed[ptcode]'
                                            ,id: 'newed[ptcode]'
                                            ,valueField: 'ptcode'
                                            ,displayField: 'ptname'
                                            ,urlStore: pre_url + '/code/cpostype'
                                            ,fieldStore: ['ptcode', 'ptname']
                                            ,anchor: "95%"
                                        })
                                        ,new Ext.ux.form.PisComboBox({//กอง
                                            hiddenName: 'newed[dcode]'
                                            ,id: 'newed[dcode]'
                                            ,fieldLabel: "กอง"
                                            ,valueField: 'dcode'
                                            ,displayField: 'division'
                                            ,urlStore: pre_url + '/code/cdivision'
                                            ,fieldStore: ['dcode', 'division']
                                            ,anchor: "95%"
                                        })
                                        ,{
                                            xtype: "compositefield"
                                            ,fieldLabel: "หน่วยงาน"
                                            ,anchor: "95%"
                                            ,items: [
                                                     {
                                                              xtype: "numberfield"
                                                              ,id: "newed[sdcode]"
                                                              ,width: 80
                                                              ,enableKeyEvents: true
                                                              ,listeners: {
                                                                       specialkey : function( el,e ){
                                                                                Ext.getCmp("subdept_show_right").setValue("");
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
                                                                                                  Ext.getCmp("newed[sdcode]").setValue("");
                                                                                                  Ext.getCmp("subdept_show_right").setValue("");
                                                                                               }
                                                                                               else{
                                                                                                  Ext.getCmp("newed[sdcode]").setValue(obj.records[0].sdcode);
                                                                                                  Ext.getCmp("subdept_show_right").setValue(obj.records[0].subdeptname);
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
                                                                                if (Ext.getCmp("subdept_show_right").getValue() == ""){
                                                                                         Ext.getCmp("newed[sdcode]").setValue("");
                                                                                         Ext.getCmp("subdept_show_right").setValue("");    
                                                                                }
                                                                       }
                                                                       
                                                              }
                                                        }
                                                        ,{
                                                                 xtype: "textfield"
                                                                 ,id: "subdept_show_right"
                                                                 ,readOnly: true
                                                                 ,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:220px;"
                                                        }
                                                        ,{
                                                                 xtype: "button"
                                                                 ,id: "sdcode_button"
                                                                 ,text: "..."
                                                                 ,handler: function(){
                                                                          searchSubdept(Ext.getCmp("newed[sdcode]"),Ext.getCmp("subdept_show_right"));
                                                                 }
                                                        }
                                                 ]
                                        }
                                        ,new Ext.ux.form.PisComboBox({//ฝ่าย/กลุ่มงาน
                                            fieldLabel: "ฝ่าย/กลุ่มงาน"
                                            ,hiddenName: 'newed[seccode]'
                                            ,id: 'newed[seccode]'
                                            ,valueField: 'seccode'
                                            ,displayField: 'secname'
                                            ,urlStore: pre_url + '/code/csection'
                                            ,fieldStore: ['seccode', 'secname']
                                            ,anchor: "95%"                                                
                                        })
                                        ,new Ext.ux.form.PisComboBox({//งาน
                                            fieldLabel: "งาน"
                                            ,hiddenName: 'newed[jobcode]'
                                            ,id: 'newed[jobcode]'
                                            ,valueField: 'jobcode'
                                            ,displayField: 'jobname'
                                            ,urlStore: pre_url + '/code/cjob'
                                            ,fieldStore: ['jobcode', 'jobname']
                                            ,anchor: "95%"
                                        }) 
                                    ]
                                }
                            ]
                        }
                    ]
                }
                ,{
                    xtype: "compositefield"
                    ,fieldLabel: "" 
                    ,items: [
                        new Ext.ux.form.PisComboBox({
                            fieldLabel: "ปฏิบัติงานจริง"
                            ,id: 'bottom[j18code]'
                            ,hiddenName:'bottom[j18code]'
                            ,valueField: 'j18code'
                            ,displayField: 'j18status'
                            ,urlStore: pre_url + '/code/cj18status'
                            ,fieldStore: ['j18code', 'j18status']
                            ,width: 350
                        })
                        ,{
                            xtype: "displayfield"
                            ,value: "อาศัยเบิกอันดับ"
                            ,style: "padding: 4px;text-align: right;padding-left: 10px"
                        }
                        ,{
                            xtype: "textfield"
                            ,id: "bottom[casec]"
                        }
                        ,{
                            xtype: "displayfield"
                            ,value: "ชั้น"
                            ,style: "padding: 4px;text-align: right;padding-left: 10px"
                        }
                        ,{
                            xtype: "textfield"
                            ,id: "bottom[casesalary]"
                        }
                        
                    ]
                }              
                ,new Ext.BoxComponent({
                    autoEl: {
                        tag: "div"
                        ,id: "temp_move_in"
                        ,html: tmp_move_in_blank
                    }
                })

            ]
        }
    ]
    ,buttons:[
    { 
        text:'บันทึก'
        ,formBind: true 
        ,handler:function(){ 					
            moveInForm.getForm().submit(
            { 
                method:'POST'
                ,waitTitle:'Saving Data'
                ,waitMsg:'Sending data...'
                ,success:function(){		
                    Ext.Msg.alert("สถานะ","บันทึกเสร็จเรีบยร้อย", function(btn, text){										
                        if (btn == 'ok'){
                            MoveInResetLeft();
                            MoveInResetRight();
                            Ext.getCmp("cmd[refcmnd]").setValue("");
                            Ext.getCmp("cmd[forcedate]").setValue("");
                            Ext.getCmp("cmd[note]").setValue("");
                            Ext.getCmp("olded[posid]").setValue("");
                            Ext.getCmp("newed[posid]").setValue("");
                            Ext.getCmp("cmd[updcode]").clearValue();                            
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
            MoveInResetLeft();
            MoveInResetRight();
            Ext.getCmp("cmd[refcmnd]").setValue("");
            Ext.getCmp("cmd[forcedate]").setValue("");
            Ext.getCmp("cmd[note]").setValue("");
            Ext.getCmp("cmd[updcode]").clearValue();
        }
    }
] 

});
//-------------------------------------
// Panel Main
//-------------------------------------
var MoveInPanel = new Ext.Panel({
    layout: "border"
    ,title: "คำสั่งย้าย / เลื่อนภายในหน่วยงาน"
    ,items: [
        moveInForm    
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

//===================================
// Function
//===================================
//====Left
function MoveInResetLeft(){
    var tpl = new Ext.Template(tmp_move_in_blank);
    tpl.overwrite(Ext.get("temp_move_in"), {});
    Ext.getCmp("bottom[j18code]").clearValue();
    //Ext.getCmp("olded[posid]").setValue("");
    Ext.getCmp("olded[id]").setValue("");
    Ext.getCmp("olded[name]").setValue("");
    Ext.getCmp("olded[posname]").setValue("");
    Ext.getCmp("olded[cname]").setValue("");
    Ext.getCmp("olded[salary]").setValue("");
    Ext.getCmp("olded[exname]").setValue("");
    Ext.getCmp("olded[expert]").setValue("");
    Ext.getCmp("olded[ptname]").setValue("");
    Ext.getCmp("olded[division]").setValue("");
    Ext.getCmp("olded[subdeptname]").setValue("");
    Ext.getCmp("olded[secname]").setValue("");
    Ext.getCmp("olded[jobname]").setValue("");
}
function MoveInSearchLeft(posid){
    loadMask.show();
    Ext.Ajax.request({
        url: pre_url + '/move_in/set_left'
        ,params: {
           posid: posid
        }
        ,success: function(response,opts){
            obj = Ext.util.JSON.decode(response.responseText);
            if(obj.success){
                Ext.getCmp("olded[posid]").setValue(obj.data[0].posid);
                Ext.getCmp("olded[id]").setValue(obj.data[0].id);
                Ext.getCmp("olded[name]").setValue(obj.data[0].name);
                Ext.getCmp("olded[posname]").setValue(obj.data[0].posname);
                Ext.getCmp("olded[cname]").setValue(obj.data[0].cname);
                Ext.getCmp("olded[salary]").setValue(obj.data[0].salary);
                Ext.getCmp("olded[exname]").setValue(obj.data[0].exname);
                Ext.getCmp("olded[expert]").setValue(obj.data[0].expert);
                Ext.getCmp("olded[ptname]").setValue(obj.data[0].ptname);
                Ext.getCmp("olded[division]").setValue(obj.data[0].division);
                Ext.getCmp("olded[subdeptname]").setValue(obj.data[0].subdeptname);
                Ext.getCmp("olded[secname]").setValue(obj.data[0].secname);
                Ext.getCmp("olded[jobname]").setValue(obj.data[0].jobname);
                Ext.getCmp("bottom[j18code]").getStore().load({
                    params: {
                        j18code: obj.data[0].j18code
                        ,start: 0
                        ,limit: 10
                    }
                    ,callback :function(){
                        Ext.getCmp("bottom[j18code]").setValue(obj.data[0].j18code);
                        loadMask.hide();
                        if (Ext.getCmp("newed[posid]").getValue() == "" ){
                            MoveInSearchRight(posid);
                        }
                    }
                });
                var tpl = new Ext.Template(tmp_move_in);
                tpl.overwrite(Ext.get("temp_move_in"), obj.data[0]);
            }
            else{
                Ext.Msg.alert("คำแนะนำ",obj.msg);
                loadMask.hide();
                MoveInResetLeft();
            }
        }
        ,failure: function(response,opts){
            Ext.Msg.alert("สถานะ",response.statusText);
            loadMask.hide();
            MoveInResetLeft();
        }
    });                                                                                           
    
}
function MoveInPosidLeft(posid,show,id){
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
        status: '1'
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
        show.setValue(data_select.status);
        id.setValue(data_select.id);
        MoveInSearchLeft(data_select.posid);
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
//====Right
function MoveInResetRight(){
    //Ext.getCmp("newed[posid]").setValue("");
    Ext.getCmp("newed[id]").setValue("");
    Ext.getCmp("name_right").setValue("");
    Ext.getCmp("newed[uppercent]").setValue("");
    Ext.getCmp("newed[upsalary]").setValue("");
    Ext.getCmp("newed[salary]").setValue("");
    Ext.getCmp("newed[posmny]").setValue("");
    Ext.getCmp("newed[spmny]").setValue("");
    Ext.getCmp("newed[sdcode]").setValue("");
    Ext.getCmp("subdept_show_right").setValue("");                
    Ext.getCmp("newed[poscode]").clearValue();
    Ext.getCmp("newed[c]").clearValue();
    Ext.getCmp("newed[excode]").clearValue();
    Ext.getCmp("newed[epcode]").clearValue();
    Ext.getCmp("newed[ptcode]").clearValue();
    Ext.getCmp("newed[dcode]").clearValue();
    Ext.getCmp("newed[seccode]").clearValue();
    Ext.getCmp("newed[jobcode]").clearValue();
}
function MoveInSearchRight(posid){
    loadMask.show();
    Ext.Ajax.request({
        url: pre_url + '/move_in/set_right'
        ,params: {
           posid: posid
        }
        ,success: function(response,opts){
            obj = Ext.util.JSON.decode(response.responseText);
            if(obj.success){
                Ext.getCmp("newed[posid]").setValue(obj.data[0].posid);
                Ext.getCmp("newed[id]").setValue(obj.data[0].id);
                Ext.getCmp("name_right").setValue(obj.data[0].name);
                Ext.getCmp("newed[uppercent]").setValue(obj.data[0].uppercent);
                Ext.getCmp("newed[upsalary]").setValue(obj.data[0].upsalary);
                Ext.getCmp("newed[salary]").setValue(obj.data[0].salary);
                Ext.getCmp("newed[posmny]").setValue(obj.data[0].posmny);
                Ext.getCmp("newed[spmny]").setValue(obj.data[0].spmny);
                Ext.getCmp("newed[sdcode]").setValue(obj.data[0].sdcode);
                Ext.getCmp("subdept_show_right").setValue(obj.data[0].subdept_show);                
                Ext.getCmp("newed[poscode]").getStore().load({
                    params: {
                        poscode: obj.data[0].poscode
                        ,start: 0
                        ,limit: 10
                    }
                    ,callback :function(){
                        Ext.getCmp("newed[poscode]").setValue(obj.data[0].poscode);
                    }
                });
                Ext.getCmp("newed[c]").getStore().load({
                    params: {
                        ccode: obj.data[0].c
                        ,start: 0
                        ,limit: 10
                    }
                    ,callback :function(){
                        Ext.getCmp("newed[c]").setValue(obj.data[0].c);
                    }
                });
                Ext.getCmp("newed[excode]").getStore().load({
                    params: {
                        excode: obj.data[0].excode
                        ,start: 0
                        ,limit: 10
                    }
                    ,callback :function(){
                        Ext.getCmp("newed[excode]").setValue(obj.data[0].excode);
                    }
                });
                Ext.getCmp("newed[epcode]").getStore().load({
                    params: {
                        epcode: obj.data[0].epcode
                        ,start: 0
                        ,limit: 10
                    }
                    ,callback :function(){
                        Ext.getCmp("newed[epcode]").setValue(obj.data[0].epcode);
                    }
                });
                Ext.getCmp("newed[ptcode]").getStore().load({
                    params: {
                        ptcode: obj.data[0].ptcode
                        ,start: 0
                        ,limit: 10
                    }
                    ,callback :function(){
                        Ext.getCmp("newed[ptcode]").setValue(obj.data[0].ptcode);
                    }
                });
                Ext.getCmp("newed[dcode]").getStore().load({
                    params: {
                        dcode: obj.data[0].dcode
                        ,start: 0
                        ,limit: 10
                    }
                    ,callback :function(){
                        Ext.getCmp("newed[dcode]").setValue(obj.data[0].dcode);
                    }
                });
                Ext.getCmp("newed[seccode]").getStore().load({
                    params: {
                        seccode: obj.data[0].seccode
                        ,start: 0
                        ,limit: 10
                    }
                    ,callback :function(){
                        Ext.getCmp("newed[seccode]").setValue(obj.data[0].seccode);
                    }
                });
                Ext.getCmp("newed[jobcode]").getStore().load({
                    params: {
                        jobcode: obj.data[0].jobcode
                        ,start: 0
                        ,limit: 10
                    }
                    ,callback :function(){
                        Ext.getCmp("newed[jobcode]").setValue(obj.data[0].jobcode);
                        loadMask.hide();
                    }
                });
            }
            else{
                Ext.Msg.alert("คำแนะนำ",obj.msg);
                loadMask.hide();
                MoveInResetRight();
            }
            
        }
        ,failure: function(response,opts){
            Ext.Msg.alert("สถานะ",response.statusText);
            loadMask.hide();
            MoveInResetRight();
        }
    });                                                                                           
    
}
function MoveInPosidRight(posid,show,id){
    personelNowRightSearch = new Ext.ux.grid.Search({
             iconCls: 'search'
             ,minChars: 3
             ,autoFocus: true
             ,position: "top"
             ,width: 200
    });
    personelNowRightFields = [
        {name: "id", type: "string"}
        ,{name: "posid",type:"init"}
        ,{name: "status",type:"string"}
        ,{name: "posname",type:"string"}
        ,{name: "cname",type:"string"}
        ,{name: "salary",type:"string"}
        ,{name: "subdeptname",type:"string"}
        ,{name: "deptname",type:"string"}
    ];
    personelNowRightCols = [
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
    personelNowRightGridStore = new Ext.data.JsonStore({
            url: pre_url + "/info_pis_j18/read"
            ,root: "records"
            ,autoLoad: false
            ,totalProperty: 'totalCount'
            ,fields: personelNowRightFields
            ,idProperty: 'id'
    });        
    personelNowRightGrid = new Ext.grid.GridPanel({
            split: true
            ,store: personelNowRightGridStore
            ,columns: personelNowRightCols
            ,stripeRows: true
            ,loadMask: {msg:'Loading...'}
            ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
            ,plugins: [personelNowRightSearch]
            ,bbar: new Ext.PagingToolbar({
                      pageSize: 20
                      ,autoWidth: true
                      ,store: personelNowRightGridStore
                      ,displayInfo: true
                      ,displayMsg	: 'Displaying {0} - {1} of {2}'
                      ,emptyMsg: "Not found"
            })
            ,tbar: []
    });
    personelNowRightGrid.on('rowdblclick', function(grid, rowIndex, e ) {
        data_select = grid.getSelectionModel().getSelected().data;
        posid.setValue(data_select.posid);
        show.setValue(data_select.status);
        id.setValue(data_select.id);
        MoveInSearchRight(data_select.posid);
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
            ,items: [personelNowRightGrid]
            });
    }
    win.show();	
    win.center();
    personelNowRightGridStore.load({params:{start: 0,limit: 20}});
}
