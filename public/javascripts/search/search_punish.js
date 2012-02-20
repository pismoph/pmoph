work_place = {
    mcode: "work_place[mcode]"
    ,deptcode: "work_place[deptcode]"
    ,dcode: "work_place[dcode]"
    ,sdcode: "work_place[sdcode]"
    ,sdcode_show: "work_place_subdept_show"
    ,sdcode_button: "work_place_subdept_button"
    ,seccode: "work_place[seccode]"
    ,jobcode: "work_place[jobcode]"
};
/*************************************************************************/
/*Grid Search*/
/*************************************************************************/
var value_query_trigger = new Ext.form.TriggerField({
        triggerClass: "trigger"
        ,id: "value_query_trigger"
        //,readOnly: true
        ,onTriggerClick: function(){
                if (data_queryGrid.nowRecordEdit.data.field == ""){
                        Ext.Msg.alert("สถานะ","กรุณาเลือกข้อมูลให้ถูกต้อง");
                        return false;
                }
                data_queryGrid.stopEditing();
                switch(data_queryGrid.nowRecordEdit.data.field){
                            case "codetrade":
                                     QueryTrade(data_queryGrid.nowRecordEdit);
                                     break;
                            case "recode":
                                     QueryRelig(data_queryGrid.nowRecordEdit);
                                     break;
                            case "provcode":
                                     QueryProvince(data_queryGrid.nowRecordEdit);
                                     break;
                            case "mrcode":
                                     QueryMarital(data_queryGrid.nowRecordEdit);
                                     break;
                            case "sex":
                                     QuerySex(data_queryGrid.nowRecordEdit);
                                     break;
                            case "forcedate":
                                     QueryDate(data_queryGrid.nowRecordEdit);
                                     break;
                            case "pncode":
                                     QueryPunish(data_queryGrid.nowRecordEdit);
                                     break;
                            case "description":
                                     SetValueQueryGrid(data_queryGrid.nowRecordEdit);
                                     break;
                            case "cmdno":
                                     SetValueQueryGrid(data_queryGrid.nowRecordEdit);
                                     break;
                }			
        }
});
col_prepare = ["codetrade","recode","provcode","mrcode","sex","forcedate","pncode","description","cmdno"];
var data_field_query_trigger  = [
    ["codetrade","รหัสใบประกอบวิชาชีพ"]
    ,["recode","รหัสศาสนา"]
    ,["provcode","รหัสภูมิลำเนา"]
    ,["mrcode","รหัสสถานภาพสมรส"]
    ,["sex","เพศ"]
    ,["forcedate","ปีที่มีผลบังคับ"]
    ,["pncode","รหัสโทษที่ได้รับ"]
    ,["description","กรณีความผิด"]
    ,["cmdno","เอกสารอ้างอิง"]
];
var field_query_trigger = new Ext.form.ComboBox({
        editable: false
        ,id:'field_query_trigger'
        ,store: new Ext.data.SimpleStore({
                fields: ['id', 'type']
                ,data: data_field_query_trigger
        })
        ,valueField:'id'
        ,displayField:'type'
        ,typeAhead: true
        ,mode: 'local'
        ,triggerAction: 'all'
        ,selectOnFocus:true		
        ,listeners: {
                select : function( combo,  record,  index ) {
                        if (data_queryGrid.nowColumnEdit == 2){
                                data_queryGrid.nowRecordEdit.data["field"] = '';
                                data_queryGrid.nowRecordEdit.data["value"] = '';
                                data_queryGrid.nowRecordEdit.data["id"] = '';
                                data_queryGrid.nowRecordEdit.data["operator"] = '';
                                data_queryGrid.nowRecordEdit.data["operator2"] = '';
                                data_queryGrid.nowRecordEdit.data["code"] = '';
                                data_queryGrid.nowRecordEdit.commit();
                        }
                }
                   ,blur: function(el){
                          if (el.getValue() == el.getRawValue()){
                                  el.clearValue();    
                          }                                                                                                                                       
                   }                        
        }
})


var data_operator_query_trigger  = [
        ['=' ,'เท่ากับ']
        ,['<=' ,'น้อยกว่าเท่ากับ']
        ,['>=' ,'มากกว่าเท่ากับ']
        ,['<' ,'น้อยกว่า']
        ,['>' ,'มากกว่า']
        ,['!=' ,'ไม่เท่ากับ']
        ,['like' ,'คล้ายกับ']
];
var operator_query_trigger = new Ext.form.ComboBox({
        editable: false
        ,id:'operator_query_trigger'
        ,store: new Ext.data.SimpleStore({
                fields: ['id', 'type']
                ,data: data_operator_query_trigger
        })
        ,valueField:'id'
        ,displayField:'type'
        ,typeAhead: true
        ,mode: 'local'
        ,triggerAction: 'all'
        ,selectOnFocus:true
        ,listeners:{
                   blur: function(el){
                          if (el.getValue() == el.getRawValue()){
                                  el.clearValue();    
                          }                                                                                                                                       
                  }                   
        }                
});

var data_operator2_query_trigger  = [
          ['' ,'']
          ,['and' ,'และ']
          ,['or' ,'หรือ']				
];
var operator2_query_trigger = new Ext.form.ComboBox({
        editable: false
        ,id:'operator2_query_trigger'
        ,store: new Ext.data.SimpleStore({
                fields: ['id', 'type']
                ,data: data_operator2_query_trigger
        })
        ,valueField:'id'
        ,displayField:'type'
        ,typeAhead: true
        ,mode: 'local'
        ,triggerAction: 'all'
        ,selectOnFocus:true
        ,listeners:{
                   blur: function(el){
                          if (el.getValue() == el.getRawValue()){
                                  el.clearValue();    
                          }                                                                                                                                       
                  }                   
        }                
});

var smdata_queryGrid = new Ext.grid.CheckboxSelectionModel({singleSelect: false})
var data_queryFields = [
        {name: "field", type: "string"}        
        ,{name: "value", type: "string"}
        ,{name: "id", type: "string"}
        ,{name: "code", type: "string"}
        ,{name: "operator", type: "string"}
        ,{name: "operator2", type: "string"}
];
    
var data_queryCols = [
        smdata_queryGrid
        ,{
                header: "#"
                ,width: 80
                ,renderer: rowNumberer.createDelegate(this)
                ,sortable: false
        }
        ,{header: "Field",width: 200, sortable: false, dataIndex: 'field',editor:field_query_trigger,renderer: function(value ,metadata ,record ,rowIndex  ,colIndex ,store ){
                var index_ = field_query_trigger.getStore().find('id',value)
                store.commitChanges();
                if (index_ == -1){
                        return "";
                }
                else{
                        return data_field_query_trigger[index_][1];
                }
        }}
        ,{header: "Operator",width: 200, sortable: false, dataIndex: 'operator',editor:operator_query_trigger,renderer: function(value ,metadata ,record ,rowIndex  ,colIndex ,store ){
                var index_ = operator_query_trigger.getStore().find('id',value)
                store.commitChanges();
                if (index_ == -1){
                        return "";
                }
                else{
                        return data_operator_query_trigger[index_][1];
                }
        }}
        ,{header: "Value",width: 200, sortable: false, dataIndex: 'value',editor:value_query_trigger}
        ,{header: "Operator",width: 200, sortable: false, dataIndex: 'operator2',editor:operator2_query_trigger,renderer: function(value ,metadata ,record ,rowIndex  ,colIndex ,store ){
                var index_ = operator2_query_trigger.getStore().find('id',value)
                store.commitChanges();
                if (index_ == -1){
                        return "";
                }
                else{
                        return data_operator2_query_trigger[index_][1];
                }
        }}
        ,{header: "Code",width: 70, sortable: false, dataIndex: 'code'}
];
    
var data_queryGridStore = new Ext.data.JsonStore({
        url:""
        ,root: "records"
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,fields: data_queryFields
        ,idProperty: 'id'
});     
	
var data_queryGrid = new Ext.grid.EditorGridPanel({
        title: "เงื่อนไขสอบถาม"
        ,region: 'north'
        ,height: 200
        ,clicksToEdit: 1
        ,split: true
        ,store: data_queryGridStore
        ,columns: data_queryCols
        ,stripeRows: true
        ,loadMask: {msg:'Loading...'}
        ,sm: smdata_queryGrid
        ,bbar: [
                        {
                                text: "เพิ่ม"
                                ,iconCls: "table-add"
                                ,handler: function(){
                                        var data_queryNewRecord = Ext.data.Record.create(data_queryFields);
                                        var e = new data_queryNewRecord({
                                                field: ''
                                                ,value: ''
                                                ,id: ''
                                                ,operator: ''
                                                ,operator2: ''
                                                ,code: ''
                                        });
                                        data_queryGridStore.data.insert(data_queryGrid.getStore().getCount(), e);
                                        e.join(data_queryGridStore);
                                        data_queryGrid.getView().refresh();
                                }
                        },"-"
                        ,{
                                ref: '../insertBtn'
                                ,text: "แทรก"
                                ,disabled: true
                                ,iconCls: "table-row-insert"
                                ,handler: function(){
                                        var data_queryNewRecord = Ext.data.Record.create(data_queryFields);
                                        var e = new data_queryNewRecord({
                                                        field: ''
                                                        ,value: ''
                                                        ,id: ''
                                                        ,operator: ''
                                                        ,operator2: ''
                                                        ,code: ''
                                        });
                                        data_queryGridStore.data.insert(data_queryGrid.getStore().indexOf(data_queryGrid.getSelectionModel().getSelected()), e);
                                        e.join(data_queryGridStore);
                                        data_queryGrid.getView().refresh();
                                }
                        },"-"
                        ,{
                                ref: '../removeBtn'
                                ,text: "ลบ"
                                ,disabled: true
                                ,iconCls: "table-delete"
                                ,handler: function (){
                                        data_queryGridStore.remove(smdata_queryGrid.getSelections());
                                }
                        },"->"
                        ,{
                                text: "ล้างข้อมูล"
                                ,handler: function (){
                                        data_queryGridStore.removeAll();
                                        data_querydetailGridStore.removeAll();
                                }
                        },"-"
                        ,{
                                text: "ค้นหา"
                                ,iconCls: "search"
                                ,handler: function(){
                                        tmp_case = data_queryGridStore.data.items
                                        if (tmp_case.length == 0){
                                                Ext.Msg.alert("สถานะ","กรุณาทำรายารให้ครบถ้วน");
                                                return false;
                                        }
                                        else{
                                                for (i=0;i<tmp_case.length ;i++ ){
                                                        if (i != tmp_case.length -1){
                                                                if (tmp_case[i].data["field"] == "" || tmp_case[i].data["value"] == "" || tmp_case[i].data["id"] == "" || tmp_case[i].data["operator"] == "" || tmp_case[i].data["operator2"] == ""){
                                                                        Ext.Msg.alert("สถานะ","กรุณาทำรายารให้ครบถ้วน");
                                                                        return false;
                                                                }
                                                        }

                                                        if (i == tmp_case.length -1){
                                                                if (tmp_case[i].data["field"] == "" || tmp_case[i].data["value"] == "" || tmp_case[i].data["id"] == "" || tmp_case[i].data["operator"] == ""){
                                                                        Ext.Msg.alert("สถานะ","กรุณาทำรายารให้ครบถ้วน");
                                                                        return false;
                                                                }
                                                        }
                                                        
                                                       if (tmp_case[i].data["field"] == "work_place"){
                                                              if (tmp_case[i].data["operator"] != "="){
                                                                       Ext.Msg.alert("สถานะ","กรุณาเลือก Operator ในบรรทัด รหัสหน่วยงานตามประวัติ เป็น \"เท่ากับ\"");
                                                                       return false;
                                                              }
                                                       }                                                        
                                                }
                                        }
                                        tmp_case = readDataGrid(tmp_case);
                                        tmp_col = select_col_querydetail.split(",");
                                        col_prepare = ['fname','lname','minname','division','deptname','subdeptname','secname','jobname','posname','exname','expert','ptname','salary','posid','appointdate','birthdate','retiredate','age','ageappoint'];
                                        col_dis = ['ชื่อ','นามสกุล','กระทรวงตาม จ.18','กองตาม จ.18','กรมตาม จ.18','หน่วยงานตาม จ.18','ฝ่าย/กลุ่มงานตาม จ.18','งานตาม จ.18','ตำแหน่งสายงานตาม จ.18','ตำแหน่งบริหารตาม จ.18','ตำแหน่งวิชาการตาม จ.18','ว./วช./ชช. ตาม จ.18','เงินเดือน ตาม จ.18','ตำแหน่งเลขที่ ตาม จ.18','วันที่บรรจุ ตาม จ.18','วันเกิด','วันที่เกษียณ','อายุ','อายุราชการ'];
                                        col_width = [200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200]
                                        new_col = [{
                                                                header: "#"
                                                                ,width: 80
                                                                ,renderer: rowNumberer.createDelegate(this)
                                                                ,sortable: false
                                        }];
                                       for (i=0;i<tmp_col.length ;i++ ){
                                                new_col.push({
                                                       header: col_dis[Number(col_prepare.indexOf(tmp_col[i]))]
                                                       ,width: col_width[Number(col_prepare.indexOf(tmp_col[i]))]
                                                       , sortable: false
                                                       , dataIndex: col_prepare[Number(col_prepare.indexOf(tmp_col[i]))]
                                                });
                                        }
                                        Col = new Ext.grid.ColumnModel(new_col);								
                                                                                                                                                                                
                                        data_querydetailGrid.reconfigure(data_querydetailGridStore, Col);
                                        data_querydetailGridStore.baseParams = {
                                                col: select_col_querydetail
                                                ,where: tmp_case
                                        }
                                        data_querydetailGridStore.load({params: {start: 0,limit: 20}});
                                }
                        }
        ]
        ,listeners: {
                beforeedit: function(obj){
                   this.nowRecordEdit = obj.record;
                   this.nowColumnEdit = obj.column;
                }
                ,afteredit: function(obj){
                   if (obj.column == 4){
                            data_field_tmp = obj.record.data.field;
                            if (data_field_tmp == ""){
                                     obj.record.data.id = "";
                                     obj.record.data.value = "";
                                     obj.record.data.code = "";
                                     obj.record.commit();
                                     Ext.Msg.alert("สถานะ","กรุณาเลือกข้อมูลให้ถูกต้อง");
                                     return false;
                            }                                    
                            if ( data_field_tmp == "description" || data_field_tmp == "cmdno" ){
                                     obj.record.data.id = obj.record.data.value;
                                     obj.record.commit();
                            }
                            else{
                                     obj.record.data.id = "";
                                     obj.record.data.value = "";
                                     obj.record.data.code = "";
                                     obj.record.commit();
                                     Ext.Msg.alert("สถานะ","สามารถพิมพ์ข้อมูลได้เฉพาะ กรณีความผิด,เอกสารอ้างอิง");
                            }
                   }      
                }
        }
});

data_queryGrid.getSelectionModel().on('selectionchange', function(sm){
                data_queryGrid.removeBtn.setDisabled(sm.getCount() < 1);
                data_queryGrid.insertBtn.setDisabled(sm.getCount() < 1);
});
/***************************************************************************/
/* Grid Detail */
/*************************************************************************/
var select_col_querydetail = "fname,lname,subdeptname,posname";
var data_querydetailFields =  [
        {name: "fname", type: "string"}
        ,{name: "lname", type: "string"}
        ,{name: "minname", type: "string"}
        ,{name: "division", type: "string"}
        ,{name: "deptname", type: "string"}
        ,{name: "subdeptname", type: "string"}
        ,{name: "secname", type: "string"}
        ,{name: "jobname", type: "string"}
        ,{name: "posname", type: "string"}
        ,{name: "exname", type: "string"}
        ,{name: "expert", type: "string"}
        ,{name: "ptname", type: "string"}
        ,{name: "salary", type: "int"}
        ,{name: "posid", type: "int"}
        ,{name: "appointdate", type: "string"}
        ,{name: "birthdate", type: "string"}
        ,{name: "retiredate", type: "string"}
        ,{name: "age", type: "string"}
        ,{name: "ageappoint", type: "string"}
];
	
var data_querydetailCols = [
        {
                   header: "#"
                   ,width: 80
                   ,renderer: rowNumberer.createDelegate(this)
                   ,sortable: false
        }            
];
    
var data_querydetailGridStore = new Ext.data.JsonStore({
        url: pre_url + "/query_all/punish"
        ,root: "records"
        ,autoLoad: false
        ,totalProperty: 'totalCount'
        ,fields: data_querydetailFields
});
    
var data_querydetailGrid = new Ext.grid.GridPanel({
    title: "รายละเอียด"
    ,region: 'center'
    ,split: true
    ,store: data_querydetailGridStore
    ,columns: data_querydetailCols
    ,stripeRows: true
    ,loadMask: {msg:'Loading...'}
    ,sm: new Ext.grid.RowSelectionModel({singleSelect: true})
    ,bbar: new Ext.PagingToolbar({
                    pageSize: 20
                    ,autoWidth: true
                    ,store: data_querydetailGridStore
                    ,displayInfo: true
                    ,displayMsg	    : 'Displaying {0} - {1} of {2}'
                    ,emptyMsg: "Not found"
    })
    ,tbar: [
        {
                text: "เลือกคอลัมน์"
                ,handler: function(){
                        QueryDetailPunish();
                }
        },"-"
        ,{
                text: "Excel"
                ,iconCls: "excel"
                ,handler: function(){
                        tmp_case = data_queryGridStore.data.items
                        if (tmp_case.length == 0){
                                Ext.Msg.alert("สถานะ","กรุณาทำรายารให้ครบถ้วน");
                                return false;
                        }
                        else{
                                    for (i=0;i<tmp_case.length ;i++ ){
                                            if (i != tmp_case.length -1){
                                                    if (tmp_case[i].data["field"] == "" || tmp_case[i].data["value"] == "" || tmp_case[i].data["id"] == "" || tmp_case[i].data["operator"] == "" || tmp_case[i].data["operator2"] == ""){
                                                            Ext.Msg.alert("สถานะ","กรุณาทำรายารให้ครบถ้วน");
                                                            return false;
                                                    }
                                            }

                                            if (i == tmp_case.length -1){
                                                    if (tmp_case[i].data["field"] == "" || tmp_case[i].data["value"] == "" || tmp_case[i].data["id"] == "" || tmp_case[i].data["operator"] == ""){
                                                            Ext.Msg.alert("สถานะ","กรุณาทำรายารให้ครบถ้วน");
                                                            return false;
                                                    }
                                            }
                                            
                                           if (tmp_case[i].data["field"] == "work_place"){
                                                  if (tmp_case[i].data["operator"] != "="){
                                                           Ext.Msg.alert("สถานะ","กรุณาเลือก Operator ในบรรทัด รหัสหน่วยงานตามประวัติ เป็น \"เท่ากับ\"");
                                                           return false;
                                                  }
                                           }                                                        
                                    }
                        }
                        tmp_case = readDataGrid(tmp_case);
                        tmp_col = select_col_querydetail.split(",");
                        col_prepare = ['fname','lname','minname','division','deptname','subdeptname','secname','jobname','posname','exname','expert','ptname','salary','posid','appointdate','birthdate','retiredate','age','ageappoint'];
                        col_dis = ['ชื่อ','นามสกุล','กระทรวงตาม จ.18','กองตาม จ.18','กรมตาม จ.18','หน่วยงานตาม จ.18','ฝ่าย/กลุ่มงานตาม จ.18','งานตาม จ.18','ตำแหน่งสายงานตาม จ.18','ตำแหน่งบริหารตาม จ.18','ตำแหน่งวิชาการตาม จ.18','ว./วช./ชช. ตาม จ.18','เงินเดือน ตาม จ.18','ตำแหน่งเลขที่ ตาม จ.18','วันที่บรรจุ ตาม จ.18','วันเกิด','วันที่เกษียณ','อายุ','อายุราชการ'];
                        col_width = [200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200]
                        col_show = ""
                        for (i=0;i<tmp_col.length ;i++ ){
                                 col_show += col_dis[col_prepare.indexOf(tmp_col[i])] + ",";									
                        }	
                        col_show = col_show.substr(0,col_show.length -1);
                        var form = document.createElement("form");
                        form.setAttribute("method", "post");
                        form.setAttribute("action" , pre_url + "/query_all/reportpunish?format=xls");
                        form.setAttribute("target", "_blank");
                        var hiddenField = document.createElement("input");
                        hiddenField.setAttribute("name", "col");
                        hiddenField.setAttribute("value", select_col_querydetail);
                        
                        var hiddenField2 = document.createElement("input");
                        hiddenField2.setAttribute("name", "where");
                        hiddenField2.setAttribute("value", tmp_case);

                        var hiddenField3 = document.createElement("input");
                        hiddenField3.setAttribute("name", "col_show");
                        hiddenField3.setAttribute("value", col_show);

                        form.appendChild(hiddenField);
                        form.appendChild(hiddenField2);
                        form.appendChild(hiddenField3);

                        document.body.appendChild(form);
                        form.submit();
                        document.body.removeChild(form);
                }
        },"-",{
                text: "PDF"
                ,iconCls: "pdf"
                ,handler: function(){
                        tmp_case = data_queryGridStore.data.items
                        if (tmp_case.length == 0){
                                Ext.Msg.alert("สถานะ","กรุณาทำรายารให้ครบถ้วน");
                                return false;
                        }
                        else{
                                    for (i=0;i<tmp_case.length ;i++ ){
                                            if (i != tmp_case.length -1){
                                                    if (tmp_case[i].data["field"] == "" || tmp_case[i].data["value"] == "" || tmp_case[i].data["id"] == "" || tmp_case[i].data["operator"] == "" || tmp_case[i].data["operator2"] == ""){
                                                            Ext.Msg.alert("สถานะ","กรุณาทำรายารให้ครบถ้วน");
                                                            return false;
                                                    }
                                            }

                                            if (i == tmp_case.length -1){
                                                    if (tmp_case[i].data["field"] == "" || tmp_case[i].data["value"] == "" || tmp_case[i].data["id"] == "" || tmp_case[i].data["operator"] == ""){
                                                            Ext.Msg.alert("สถานะ","กรุณาทำรายารให้ครบถ้วน");
                                                            return false;
                                                    }
                                            }
                                            
                                           if (tmp_case[i].data["field"] == "work_place"){
                                                  if (tmp_case[i].data["operator"] != "="){
                                                           Ext.Msg.alert("สถานะ","กรุณาเลือก Operator ในบรรทัด รหัสหน่วยงานตามประวัติ เป็น \"เท่ากับ\"");
                                                           return false;
                                                  }
                                           }                                                        
                                    }
                        }
                        tmp_case = readDataGrid(tmp_case);
                        tmp_col = select_col_querydetail.split(",");                                
                        col_prepare = ['fname','lname','minname','division','deptname','subdeptname','secname','jobname','posname','exname','expert','ptname','salary','posid','appointdate','birthdate','retiredate','age','ageappoint'];
                        col_dis = ['ชื่อ','นามสกุล','กระทรวงตาม จ.18','กองตาม จ.18','กรมตาม จ.18','หน่วยงานตาม จ.18','ฝ่าย/กลุ่มงานตาม จ.18','งานตาม จ.18','ตำแหน่งสายงานตาม จ.18','ตำแหน่งบริหารตาม จ.18','ตำแหน่งวิชาการตาม จ.18','ว./วช./ชช. ตาม จ.18','เงินเดือน ตาม จ.18','ตำแหน่งเลขที่ ตาม จ.18','วันที่บรรจุ ตาม จ.18','วันเกิด','วันที่เกษียณ','อายุ','อายุราชการ'];
                        col_width = [200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200]
                        col_show = ""
                        for (i=0;i<tmp_col.length ;i++ ){
                                 col_show += col_dis[col_prepare.indexOf(tmp_col[i])] + ",";									
                        }	
                        col_show = col_show.substr(0,col_show.length -1);
                        var form = document.createElement("form");
                        form.setAttribute("method", "post");
                        form.setAttribute("action" , pre_url + "/query_all/reportpunish?format=pdf");
                        form.setAttribute("target", "_blank");
                        var hiddenField = document.createElement("input");
                        hiddenField.setAttribute("name", "col");
                        hiddenField.setAttribute("value", select_col_querydetail);
                        
                        var hiddenField2 = document.createElement("input");
                        hiddenField2.setAttribute("name", "where");
                        hiddenField2.setAttribute("value", tmp_case);

                        var hiddenField3 = document.createElement("input");
                        hiddenField3.setAttribute("name", "col_show");
                        hiddenField3.setAttribute("value", col_show);

                        form.appendChild(hiddenField);
                        form.appendChild(hiddenField2);
                        form.appendChild(hiddenField3);

                        document.body.appendChild(form);
                        form.submit();
                        document.body.removeChild(form);
                }
        }		
    ]
});
/***************************************************************************/
/* Panel Main */
/*************************************************************************/
var panelMainSearch  = new Ext.Panel({
        title: "สอบถามข้อมูลโทษทางวินัย"
        ,layout:  "border"
        ,items: [
                data_queryGrid
                ,data_querydetailGrid
        ]
});
/***************************************************************************/
/* Function */
/*************************************************************************/

function QueryDetailPunish(){
       archive_select =  select_col_querydetail.split(",");
       col_select = [];
       col_unselect = []
       col_compare = {
          fname:'ชื่อ'
          ,lname:'นามสกุล'
          ,minname: 'กระทรวงตาม จ.18'
          ,division: 'กองตาม จ.18'
          ,deptname: 'กรมตาม จ.18'				
          ,subdeptname: 'หน่วยงานตาม จ.18'
          ,secname: 'ฝ่าย/กลุ่มงานตาม จ.18'
          ,jobname: 'งานตาม จ.18'				
          ,posname: 'ตำแหน่งสายงานตาม จ.18'
          ,exname: 'ตำแหน่งบริหารตาม จ.18'
          ,expert: 'ตำแหน่งวิชาการตาม จ.18'
          ,ptname: 'ว/วช/ชช ตาม จ.18'  
          ,salary: 'เงินเดือนตาม จ.18'
          ,posid: 'ตำแหน่งเลขที่ตาม จ.18'
          ,appointdate: 'วันที่บรรจุ'
          ,birthdate: 'วันเกิด'
          ,retiredate: 'วันที่เกษียณ'
          ,age: 'อายุ'
          ,ageappoint: 'อายุราชการ' 
        };
        for(i=0;i<archive_select.length;i++){
          col_select.push([
                   archive_select[i]
                   ,col_compare[archive_select[i]]
          ])
        }
        for(i in col_compare){
             if (archive_select.indexOf(i) == -1){
                   col_unselect.push([
                            i
                            ,col_compare[i]
                   ])    
             }                     
        }                  
        var ds = new Ext.data.ArrayStore({
                data: col_unselect
                ,fields: ['id','value']
        });

        var isForm = new Ext.form.FormPanel({
                width:580,
                frame: true,
                bodyStyle: 'padding:10px;',
                items:[
                {
                        xtype: 'itemselector',
                        name: 'itemselector',
                        id: 'itemselector',
                        hideLabel: true,
                        imagePath: pre_url + '/javascripts/extjs/examples/ux/images/',
                        multiselects: [{
                                width: 250,
                                height: 200,
                                store: ds,
                                displayField: 'value',
                                valueField: 'id'
                        },{
                                width: 250,
                                height: 200,
                                store: new Ext.data.ArrayStore({
                                        data: col_select
                                        ,fields: ['id','value']
                                }),
                                displayField: 'value',
                                valueField: 'id',
                                tbar:[{
                                        text: 'clear',
                                        handler:function(){							
                                                isForm.getForm().findField('itemselector').reset();
                                        }
                                }]
                        }]
                }],
                buttons: [{
                        text: 'ยืนยัน',
                        handler: function(){
                                if(isForm.getForm().isValid()){
                                                var tmp = Ext.getCmp("itemselector").getValue();
                                                select_col_querydetail =tmp;
                                                win.close();							
                                }
                        }
                }]
        });

        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,width: 600
                        ,height: 300
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable : true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [isForm]
                });
        }
        win.show();	
        win.center();
}
