pre_url = "";
cur_ref = "";
data_personel_id = "";
Date.monthNames = ['ม.ค','ก.พ','มี.ค','เม.ย','พ.ค','มิ.ย','ก.ค','ส.ค','ก.ย','ต.ค','พ.ย','ธ.ค'];
var loadMask = new Ext.LoadMask(Ext.getBody(), {msg:"Please wait..."});	
var rowNumberer = function(value, p, record) {
    var ds = record.store
    var i = (ds.lastOptions != null && ds.lastOptions.params)? ds.lastOptions.params.start:0;
    if (isNaN ( i )) {
            i = 0;
    }
    return ds.indexOf(record)+i+1;
};

Array.prototype.max = function() {
    var max = this[0];
    var len = this.length;
    for (var i = 1; i < len; i++) if (this[i] > max) max = this[i];
    return max;
}
Array.prototype.min = function() {
    var min = this[0];
    var len = this.length;
    for (var i = 1; i < len; i++) if (this[i] < min) min = this[i];
    return min;
}
//new Ext.ux.IFrameComponent({ id: "mframe", url: "#" })
Ext.ux.IFrameComponent = Ext.extend(Ext.BoxComponent, {
    onRender : function(ct, position){
        this.el = ct.createChild(
            {
                tag: 'iframe', 
                id: this.id,
                frameBorder: 0, 
                src: this.url,
                width: "100%",
                height: "100%"
            }
        );
    }
});

////////////////////////////////////////////////////////////////////////////////////////////////////
function initInfoDetail(){
    obj = tab_personel.getActiveTab();
    obj.removeAll();
    if (cur_ref == 'j18'){
        obj.add(panelJ18);
        obj.getLayout().setActiveItem(panelJ18);
        j18GridStore.baseParams = { start: 0, limit: 20}
        if (data_personel_id != ""){
            searchJ18ById(data_personel_id);
        }
        else{
            panelJ18.getLayout().setActiveItem(panelJ18First);
            j18GridStore.load({
                params: { start: 0, limit: 20}
                ,callback :function(){
                    loadMask.hide();
                }
            });
        }                      
    }
    else if (cur_ref == "perform_person_now"){
        obj.add(panelPerformPersonnow);
        obj.getLayout().setActiveItem(panelPerformPersonnow);
        perform_personGridStore.baseParams = { start: 0, limit: 20};
        if (data_personel_id != ""){
            searchPerformPersonById(data_personel_id);
        }
        else{
            panelPerformPersonnow.getLayout().setActiveItem(panelPerformPersonnowFirst);
            perform_personGridStore.load({
                params: { start: 0, limit: 20}
                ,callback :function(){
                    loadMask.hide();
                }
            });
        }        
    }
    else if (cur_ref == "data_pisposhis"){
        obj.add(panelPosHis);
        obj.getLayout().setActiveItem(panelPosHis);
        data_pisposhisGridStore.baseParams = { start: 0, limit: 20};
        if (data_personel_id != ""){
            panelPosHis.getLayout().setActiveItem(panelPosHisSecond);
            searchPositionHistById(data_personel_id);
        }
        else{
            data_pisposhisGridStore.load({
                params: { start: 0, limit: 20}
                ,callback :function(){
                    loadMask.hide();
                }
            });
        }
    }
    else if (cur_ref == "data_personal"){
        obj.add(panelPersonalnow);
        obj.getLayout().setActiveItem(panelPersonalnow);
        data_personalGridStore.baseParams = { start: 0, limit: 20};
        if (data_personel_id != ""){
            panelPersonalnow.getLayout().setActiveItem(data_personal_panel);
            searchPersonelById(data_personel_id);
        }
        else{
            data_personalGridStore.load({
                params: { start: 0, limit: 20}
                ,callback :function(){
                    loadMask.hide();
                }
            });            
        }
    }
    else if (cur_ref == "data_education"){
        obj.removeAll();
        obj.add(data_educationGrid);
        obj.add(panelEducation);
        data_educationGridStore.baseParams = { start: 0, limit: 20};
        if (data_personel_id != ""){
            obj.getLayout().setActiveItem(panelEducation);
            searchEducationById(data_personel_id);
        }
        else{
            obj.getLayout().setActiveItem(data_educationGrid);
            data_educationGridStore.load({
                params: { start: 0, limit: 20}
                ,callback :function(){
                    loadMask.hide();
                }
            });            
        }
    }
    else if (cur_ref == "data_pis_absent"){
        obj.removeAll();
        obj.add(data_pis_absentGrid);
        //obj.add(data_absent_detailGrid);
        obj.add(panel_absent);
        data_pis_absentGridStore.baseParams = { start: 0, limit: 20};
        if (data_personel_id != ""){
            //obj.getLayout().setActiveItem(data_absent_detailGrid);
            obj.getLayout().setActiveItem(panel_absent);
            searchAbsentById(data_personel_id);
        }
        else{
            obj.getLayout().setActiveItem(data_pis_absentGrid);
            data_pis_absentGridStore.load({
                params: { start: 0, limit: 20}
                ,callback :function(){
                    loadMask.hide();
                }
            });            
        }
    }
    else if (cur_ref == "data_pis_trainning"){
        obj.add(data_pis_trainningGrid);
        obj.add(data_trainning_detailGrid);
        data_pis_trainningGridStore.baseParams = { start: 0, limit: 20};
        if (data_personel_id != ""){
            obj.getLayout().setActiveItem(data_trainning_detailGrid);
            searchTrainningById(data_personel_id);
        }
        else{
            obj.getLayout().setActiveItem(data_pis_trainningGrid);
            data_pis_trainningGridStore.load({
                params: { start: 0, limit: 20}
                ,callback :function(){
                    loadMask.hide();
                }
            });            
        }
    }
    else if (cur_ref == "data_pis_insig"){
        obj.add(data_pis_insigGrid);
        obj.add(data_insig_detailGrid);
        data_pis_insigGridStore.baseParams = { start: 0, limit: 20};
        if (data_personel_id != ""){
            obj.getLayout().setActiveItem(data_insig_detailGrid);
            searchInsigById(data_personel_id,"working");
        }
        else{
            obj.getLayout().setActiveItem(data_pis_insigGrid);
            data_pis_insigGridStore.load({
                params: { start: 0, limit: 20}
                ,callback :function(){
                    loadMask.hide();
                }
            });            
        }
    }
    else if (cur_ref == "data_pis_punish"){
        obj.add(data_pis_punishGrid);
        obj.add(data_punish_detailGrid);
        data_pis_punishGridStore.baseParams = { start: 0, limit: 20};
        if (data_personel_id != ""){
            obj.getLayout().setActiveItem(data_punish_detailGrid);
            searchPunishById(data_personel_id,"working");
        }
        else{
            obj.getLayout().setActiveItem(data_pis_punishGrid);
            data_pis_punishGridStore.load({
                params: { start: 0, limit: 20}
                ,callback :function(){
                    loadMask.hide();
                }
            });
        }
    }
}
function initInfo(){
    obj = Ext.getCmp('mainCenter');
    obj.removeAll();
    data_personel_id = "";
    if (cur_ref == 'tab_pasonel'){
        obj.add(tab_personel);
        obj.getLayout().setActiveItem(tab_personel);
    }
    else if (cur_ref == 'user'){
        obj.add(user_panel);
        obj.getLayout().setActiveItem(user_panel);
        loadMask.hide();
    }
    else if(cur_ref == "search"){
        obj.add(panelMainSearch);
        obj.getLayout().setActiveItem(panelMainSearch);
        loadMask.hide();
    }
}

function initCmd(){
    obj = Ext.getCmp('mainCenter');
    obj.removeAll();
    if (cur_ref == 'calc_up_salary'){
        obj.add(panelCalcUpSalary);
        obj.getLayout().setActiveItem(panelCalcUpSalary);
        loadMask.hide();
    }
    else if(cur_ref == "config_group_sal") {
        obj.add(panelConfigGroupSalary);
        obj.getLayout().setActiveItem(panelConfigGroupSalary);
        loadMask.hide();
    }
    else if(cur_ref == "config_personel") {
        obj.add(panelConfigPersonel);
        obj.getLayout().setActiveItem(panelConfigPersonel);
        loadMask.hide();
    }
    else if(cur_ref == "save_process") {
        obj.add(saveProcessPanel);
        obj.getLayout().setActiveItem(saveProcessPanel);
        loadMask.hide();
    } 
}

function  initCode(){
    var store, grid, obj;
    if (cur_ref == 'position'){
            store = code_positionGridStore;
            grid = code_positionGrid;
    }
    else if (cur_ref == 'executive'){
            store = code_executiveGridStore;
            grid = code_executiveGrid;
    }
    else if (cur_ref == 'expert'){
            store = code_expertGridStore;
            grid = code_expertGrid;
    }
    else if (cur_ref == 'postype'){
            store = code_postypeGridStore;
            grid = code_postypeGrid;
    }
    else if (cur_ref == 'grouplevel'){
            store = code_grouplevelGridStore;
            grid = code_grouplevelGrid;
    }
    else if (cur_ref == 'epngroup'){
            store = code_epngroupGridStore;
            grid = code_epngroupGrid;
    }
    else if (cur_ref == 'epnsubgroup'){
            store = code_epnsubgroupGridStore;
            grid = code_epnsubgroupGrid;
    }
    else if (cur_ref == 'epnposwork'){
            store = code_epnposworkGridStore;
            grid = code_epnposworkGrid;
    }
    else if (cur_ref == 'update'){
            store = code_updateGridStore;
            grid = code_updateGrid;
    }
    else if (cur_ref == 'code_j18status'){
            store = code_j18statusGridStore;
            grid = code_j18statusGrid;
    }
    else if (cur_ref == "code_ministry"){
            store = code_ministryGridStore;
            grid = code_ministryGrid;        
    }
    else if (cur_ref == "code_dept"){
            store = code_deptGridStore;
            grid = code_deptGrid;        
    }
    else if (cur_ref == "code_division"){
            store = code_divisionGridStore;
            grid = code_divisionGrid;        
    }
    else if (cur_ref == "code_subdept"){
            store = code_subdeptGridStore;
            grid = code_subdeptGrid;        
    }
    else if (cur_ref == "code_section"){
            store = code_sectionGridStore;
            grid = code_sectionGrid;        
    }
    else if (cur_ref == "code_job"){
            store = code_jobGridStore;
            grid = code_jobGrid;        
    }
    else if (cur_ref == "code_country"){
            store = code_countryGridStore;
            grid = code_countryGrid;        
    }
    else if (cur_ref == "code_area"){
            store = code_areaGridStore;
            grid = code_areaGrid;        
    }
    else if (cur_ref == "code_province"){
            store = code_provinceGridStore;
            grid = code_provinceGrid;        
    }
    else if (cur_ref == "code_amphur"){
            obj = Ext.getCmp('mainCenter');
            obj.add(code_amphurPanel);
            obj.getLayout().setActiveItem(code_amphurPanel);
            return false;        
    }
    else if (cur_ref == "code_tumbon"){
            obj = Ext.getCmp('mainCenter');
            obj.add(code_tumbonPanel);
            obj.getLayout().setActiveItem(code_tumbonPanel);
            return false;        
    }
    else if (cur_ref == 'prefix'){
            store = code_prefixGridStore;
            grid = code_prefixGrid;
    }
    else if (cur_ref == 'marital'){
            store = code_maritalGridStore;
            grid = code_maritalGrid;
    }
    else if (cur_ref == 'religion'){
            store = code_religGridStore;
            grid = code_religGrid;
    }
    else if (cur_ref == 'qualify'){
            store = code_qualifyGridStore;
            grid = code_qualifyGrid;
    }
    else if (cur_ref == 'edulevel'){
            store = code_edulevelGridStore;
            grid = code_edulevelGrid;
    }
    else if (cur_ref == 'major'){
            store = code_majorGridStore;
            grid = code_majorGrid;
    }
    else if (cur_ref == 'code_trade'){
            store = code_tradeGridStore;
            grid = code_tradeGrid;
    }
    else if (cur_ref == 'punish'){
            store = code_punishGridStore;
            grid = code_punishGrid;
    }
    else if (cur_ref == 'code_decoratype'){
            store = code_decoratypeGridStore;
            grid = code_decoratypeGrid;
    }
    else if (cur_ref == 'absenttype'){
            store = code_abtypeGridStore;
            grid = code_abtypeGrid;
    }
    store.load({ params: { start: 0, limit: 20} });
    obj = Ext.getCmp('mainCenter');
    obj.removeAll();
    obj.add(grid);
    obj.getLayout().setActiveItem(grid);
}

function initReport(){
    obj = Ext.getCmp('mainCenter');
    obj.removeAll();
    if(cur_ref == 'retire'){
        obj.add(panelReport);
        obj.getLayout().setActiveItem(panelReport);
        loadMask.hide();
    }
    else if (cur_ref == "position_level"){
        obj.add(panelReport);
        obj.getLayout().setActiveItem(panelReport);
        loadMask.hide();
    }
    else if (cur_ref == "position_work_place"){
        obj.add(panelReport);
        obj.getLayout().setActiveItem(panelReport);
        loadMask.hide();
    }
    else if (cur_ref == "list_position_level"){
        obj.add(panelReport);
        obj.getLayout().setActiveItem(panelReport);
        loadMask.hide();
    }
    else if (cur_ref == "work_place"){
        obj.add(panelReport);
        obj.getLayout().setActiveItem(panelReport);
        loadMask.hide();
    }   
}

function to_date_app(dt){
        if(dt == "" || dt == null){
            return "";
        }
        dt = dt.substr(0,10)
        if (dt == null || dt == ""){
                return "";
        }
        dt = dt.split("-");
        return dt[2]+"/"+dt[1]+"/"+(Number(dt[0])+543);
}
function readDataGrid(Json){
        var txtsend = new Array();
        for (keys in Json)
        {
                if (Json[keys].data)
                {										
                        var myJSONText = JSON.stringify(Json[keys].data, function (key, value) {return value;});										
                        txtsend.push(myJSONText);
                }
        }								
        return	'['+txtsend.join(',')+']';
}
function DaysInMonth(Y, M) {
    return new Date(Y,M + 1,0).getDate();
}
function dateDiff(date_max, date_min) {
    date1 = date_max;
    date2 = date_min;
    date1.setDate(date1.getDate() + 1 );
    var y1 = date1.getFullYear(), m1 = date1.getMonth(), d1 = date1.getDate(),
         y2 = date2.getFullYear(), m2 = date2.getMonth(), d2 = date2.getDate();
    if (d1 < d2) {
        m1--;
        d1 += DaysInMonth(y2, m2);
    }
    if (m1 < m2) {
        y1--;
        m1 += 12;
    }
    return [y1 - y2, m1 - m2, d1 - d2];
}
function calage(dt,dt_min){
        var dat = new Date();
        var curday = dat.getDate();
        var curmon = dat.getMonth()+1;
        var curyear = dat.getFullYear();
        dt = dt.split("/");
        var calday = Number(dt[0]);
        var calmon = Number(dt[1]);
        var calyear = Number(dt[2]);
        if(curday == "" || curmon=="" || curyear=="" || calday=="" || calmon=="" || calyear=="")
        {
                alert("กรุณาตรวจข้อมูลวันที่ให้ถูกต้อง");
        }	
        else
        {
                var curd = new Date(curyear,curmon-1,curday);
                var cald = new Date(calyear,calmon-1,calday);
                if (dt_min != undefined){				
                        var curday = Number(dt[0]);
                        var curmon = Number(dt[1]);
                        var curyear = Number(dt[2]);				
                        dt_min = dt_min.split("/");
                        var calday = Number(dt_min[0]);
                        var calmon = Number(dt_min[1]);
                        var calyear = Number(dt_min[2]);				
                        var curd = new Date(curyear,curmon-1,curday);
                        var cald = new Date(calyear,calmon-1,calday);
                }			
                //var diff =  Date.UTC(curyear,curmon,curday,0,0,0) - Date.UTC(calyear,calmon,calday,0,0,0);
                var diff = dateDiff(curd,cald);
                return diff;			
        }
}

function searchSubdept(valueField,displayField){
       if(!form){
      var form = new Ext.FormPanel({ 
	 labelWidth: 100
	 ,autoScroll: true
	 ,url: ""
	 ,frame: true
	 ,monitorValid: true
	 ,defaults: {
	    anchor: "95%"
	 }
        ,items:[
            new Ext.ux.form.PisComboBox({
	       fieldLabel: 'จังหวัด'
	       ,hiddenName: 'search_provcode'
	       ,id: 'search_provcode'
	       ,valueField: 'provcode'
	       ,displayField: 'provname'
	       ,urlStore: pre_url + '/code/cprovince'
	       ,fieldStore: ['provcode', 'provname']
	       ,listeners: {
			select: function(){
                                prov = Ext.getCmp("search_provcode");
                                subdept = Ext.getCmp("search_sdcode");
                                delete(subdept.getStore().baseParams["provcode"]);
                                if (subdept.getStore().lastOptions && subdept.getStore().lastOptions.params) {
                                         delete(subdept.getStore().lastOptions.params["provcode"]);					
                                }
                                subdept.getStore().removeAll();
                                subdept.getStore().baseParams = {	
                                        random: Math.random()
                                        ,provcode: prov.getValue()
                                };
                                subdept.clearValue();
                                subdept.getStore().load({params:{start:0,limit:10}});
                            
			}		  
			,blur: function(el){
                                if (el.getValue() == el.getRawValue()){
                                    el.clearValue();
                                    subdept = Ext.getCmp("search_sdcode");
                                    delete(subdept.getStore().baseParams["provcode"]);
                                    if (subdept.getStore().lastOptions && subdept.getStore().lastOptions.params) {
                                             delete(subdept.getStore().lastOptions.params["provcode"]);					
                                    }
                                    subdept.getStore().removeAll();
                                    subdept.clearValue();
                                    subdept.getStore().load({params:{start:0,limit:10}});                           
                                }

			}
	       }
	    })
            ,new Ext.ux.form.PisComboBox({//หน่วยงาน
                fieldLabel: 'หน่วยงาน'
                ,hiddenName: 'search_sdcode'
                ,id: 'search_sdcode'
                ,valueField: 'sdcode'
                ,displayField: 'subdeptname'
                ,urlStore: pre_url + '/code/csubdept'
                ,fieldStore: ['sdcode', 'subdeptname']
                    
            })
        ]
        ,buttons	:[
		 { 
			 text:'บันทึก'
			 ,formBind: true 
			 ,handler:function(){
                            subdept = Ext.getCmp("search_sdcode");
                            valueField.setValue(subdept.getValue());
                            displayField.setValue(subdept.getRawValue());
                            win.close();
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
	      title: 'ค้นหาหน่วยงาน'
	      ,width: 600
	      ,height: 200
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
   win.show();
   win.center();
}

function fiscalYear(dt){
    year = "";
    if(dt.getMonth() < 10 ){
        year = dt.getFullYear();
    }
    else{
        year = dt.getFullYear() + 1;
    }
    
    return year;
}
function pad2(number) {
   
     return (number < 10 ? '0' : '') + number
   
}


function setReadOnlyWorkPlace(){
    idx = [];
    for(k in user_work_place){
	idx.push( work_place_seq.indexOf(k) );
    }
    for(i=0;i<=idx.max();i++){
	
	if (work_place_seq[i] == "sdcode"){
	    Ext.getCmp(work_place.sdcode_button).disable();
	}
	Ext.getCmp(work_place[work_place_seq[i]]).setReadOnly(true);
    }
}

function setWorkPlace(){
    loadMask.show();
    n = 0
    for(m in user_work_place){
	n = n + 1;
    }
    nc = 0;
    for(k in user_work_place){
	nc = nc + 1;
	if (k == "sdcode" || k == "sdcode_show"){
	    Ext.getCmp(work_place.sdcode).setValue(user_work_place.sdcode);
	    Ext.getCmp(work_place.sdcode_show).setValue(user_work_place.sdcode_show);
	    Ext.getCmp(work_place.sdcode_button).disable();
	    if (n == nc){
		loadMask.hide();
	    }
	}
	else{
	    if (n == nc){
		setValueWP(work_place[k],k,user_work_place[k],true)
	    }
	    else{
		setValueWP(work_place[k],k,user_work_place[k])
	    }
	}
    }
    setReadOnlyWorkPlace();
}

function setValueWP(el,namep,valp,last){
    if(last == undefined){
	last = false;
    }
    params = {}
    params["start"] = 0;
    params["limit"] = 10;
    params[namep] = valp
    Ext.getCmp(el).getStore().load({
	params: params
	,callback :function(){
	    Ext.getCmp(el).setValue(valp);
	    if (last == true){
		loadMask.hide();
	    }
	}
    });
}

/////////////////////////////////////////////////////////////
// SEARCH
////////////////////////////////////////////////////////////
function SetValueQueryGrid(record){
        if(!form){
                var form = new Ext.FormPanel({ 
                        labelWidth: 50
                        ,autoScroll: true
                        ,url: ''
                        ,frame: true
                        ,monitorValid: true
                        ,items:[
                                {
                                        xtype: "textfield"
                                        ,id: "set_value_query_grid_value"
                                        ,fieldLabel: "Value"
                                        ,anchor: "95%"
                                }	
                        ]
                        ,buttons:[
                                { 
                                        text:'ยืนยัน'
                                        ,formBind: true 
                                        ,handler:function(){ 
                                                record.data["value"] = Ext.getCmp("set_value_query_grid_value").getValue();
                                                record.data["id"] = Ext.getCmp("set_value_query_grid_value").getValue();
                                                record.commit();
                                                win.close();	
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
                        title: ''
                        ,width: 400
                        ,height: 150
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [form]
                });
        }
        win.show();
        win.center();	
}
function QueryWorkPlacename(record){
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
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 80
                                ,labelAlign: "right"
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
						,enableKeyEvents: (user_work_place.sdcode == undefined)? true : false
						,listeners: {
							 keydown : function( el,e ){
								  Ext.getCmp("work_place_subdept_show").setValue("");
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
										    Ext.getCmp("work_place_subdept_show").setValue("");
										 }
										 else{
										    Ext.getCmp("work_place[sdcode]").setValue(obj.records[0].sdcode);
										    Ext.getCmp("work_place_subdept_show").setValue(obj.records[0].subdeptname);
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
								  if (Ext.getCmp("work_place_subdept_show").getValue() == ""){
									   Ext.getCmp("work_place[sdcode]").setValue("");
									   Ext.getCmp("work_place_subdept_show").setValue("");    
								  }
							 }
							 
						}
					    }
					    ,{
						xtype: "textfield"
						,id: "work_place_subdept_show"
						,readOnly: true
						,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:345px;"
					    }
					    ,{
						xtype: "button"
						,id: "work_place_subdept_button"
						,text: "..."
						,handler: function(){
							 searchSubdept(Ext.getCmp("work_place[sdcode]"),Ext.getCmp("work_place_subdept_show"));
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
                                ,{
                                    html: "<br /><b>*หมายเหตุ  Operator หัวข้อที่เลือกจะได้เฉพาะ \"เท่ากับ\" เท่านั้น</b>"
                                }
			    ]
                                ,buttons: [
                                        {
                                                text: "ยืนยัน"
                                                ,handler: function(){
                                                        if (Ext.getCmp("work_place[mcode]").getValue() == "" && Ext.getCmp("work_place[dcode]").getValue() == "" && Ext.getCmp("work_place[deptcode]").getValue() == "" && Ext.getCmp("work_place[jobcode]").getValue() == "" && Ext.getCmp("work_place[sdcode]").getValue() == "" && Ext.getCmp("work_place[seccode]").getValue() == ""){
                                                                Ext.Msg.alert("คำเตือน","กรุณาทำรายการให้ถูกต้อง")
                                                        }
                                                        else{
                                                                //mcode,deptcode,dcode,sdcode,seccode,jobcode
                                                                str_id = {};
                                                                str_code = new Array();
                                                                str_value = new Array();
                                                                if (Ext.getCmp("work_place[mcode]").getValue() != ""){
                                                                    str_id.mcode = Ext.getCmp("work_place[mcode]").getValue();
                                                                    str_code.push(Ext.getCmp("work_place[mcode]").getValue());
                                                                    str_value.push(Ext.getCmp("work_place[mcode]").getRawValue());
                                                                }                                                                
                                                                if (Ext.getCmp("work_place[deptcode]").getValue() != ""){
                                                                    str_id.deptcode = Ext.getCmp("work_place[deptcode]").getValue();
                                                                    str_code.push(Ext.getCmp("work_place[deptcode]").getValue());
                                                                    str_value.push(Ext.getCmp("work_place[deptcode]").getRawValue());
                                                                }                                                                
                                                                if (Ext.getCmp("work_place[dcode]").getValue() != ""){
                                                                    str_id.dcode = Ext.getCmp("work_place[dcode]").getValue();
                                                                    str_code.push(Ext.getCmp("work_place[dcode]").getValue());
                                                                    str_value.push(Ext.getCmp("work_place[dcode]").getRawValue());
                                                                }                                                                
                                                                if (Ext.getCmp("work_place[sdcode]").getValue() != ""){
                                                                    str_id.sdcode = Ext.getCmp("work_place[sdcode]").getValue();
                                                                    str_code.push(Ext.getCmp("work_place[sdcode]").getValue());
                                                                    str_value.push(Ext.getCmp("work_place_subdept_show").getValue());
                                                                }                                                                
                                                                if (Ext.getCmp("work_place[seccode]").getValue() != ""){
                                                                    str_id.seccode = Ext.getCmp("work_place[seccode]").getValue();
                                                                    str_code.push(Ext.getCmp("work_place[seccode]").getValue());
                                                                    str_value.push(Ext.getCmp("work_place[seccode]").getRawValue());
                                                                }                                                                
                                                                if (Ext.getCmp("work_place[jobcode]").getValue() != ""){
                                                                    str_id.jobcode = Ext.getCmp("work_place[jobcode]").getValue();
                                                                    str_code.push(Ext.getCmp("work_place[jobcode]").getValue());
                                                                    str_value.push(Ext.getCmp("work_place[jobcode]").getRawValue());
                                                                }                                                                
                                                                record.data["value"] = str_value.join("<br />");
                                                                record.data["id"] = str_id;
                                                                record.data["code"] = str_code.join(",");
                                                                record.commit();
                                                                win.close();                                                                
                                                        }
                                                }
                                        },{
                                                text: "ยกเลิก"
                                                ,handler: function	(){
                                                        win.close();
                                                }
                                        }
                                ]
                        }]
                });
        }
        win.show();	
        win.center();
        setWorkPlace();
}

function QueryPosname(record){
        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,height: 150
                        ,width: 600
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 120
                                ,labelAlign: "right"
                                ,items: [
                                        new Ext.ux.form.PisComboBox({//ตำแหน่งสายงาน
                                                 fieldLabel: "ตำแหน่งสายงาน"
                                                 ,hiddenName: 'search[poscode]'
                                                 ,id: 'search[poscode]'
                                                 ,valueField: 'poscode'
                                                 ,displayField: 'posname'
                                                 ,urlStore: pre_url + '/code/cposition'
                                                 ,fieldStore: ['poscode', 'posname']
                                                 ,anchor: "90%"
                                        })                                    
                                ]
                                ,buttons: [
                                                {
                                                       text: "ยืนยัน"
                                                       ,handler: function(){
                                                                combo = Ext.getCmp("search[poscode]");
                                                                record.data["value"] = combo.getRawValue();
                                                                record.data["id"] = combo.getValue();
                                                                record.data["code"] = combo.getValue();
                                                                record.commit();
                                                                win.close();
                                                       }
                                                }
                                ]
                        }]
                                
                });
        }
        win.show();
        win.center();
}

function QueryExname(record){
        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,height: 150
                        ,width: 600
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 120
                                ,labelAlign: "right"
                                ,items: [
                                    new Ext.ux.form.PisComboBox({//ตำแหน่งบริหาร
                                        hiddenName: 'search[excode]'
                                        ,fieldLabel: "ตำแหน่งบริหาร"
                                        ,id: 'search[excode]'
                                        ,valueField: 'excode'
                                        ,displayField: 'exname'
                                        ,urlStore: pre_url + '/code/cexecutive'
                                        ,fieldStore: ['excode', 'exname']
                                        ,anchor: "90%"
                                    })                                    
                                ]
                                ,buttons: [
                                    {
                                        text: "ยืนยัน"
                                        ,handler: function(){
                                            combo = Ext.getCmp("search[excode]");
                                            record.data["value"] = combo.getRawValue();
                                            record.data["id"] = combo.getValue();
                                            record.data["code"] = combo.getValue();
                                            record.commit();
                                            win.close();
                                        }
                                    }
                                ]
                        }]
                                
                });
        }
        win.show();
        win.center();
}

function QueryExpert(record){
        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,height: 150
                        ,width: 600
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 120
                                ,labelAlign: "right"
                                ,items: [
                                    new Ext.ux.form.PisComboBox({//ความเชี่ยวชาญ
                                        fieldLabel: "ความเชี่ยวชาญ"
                                        ,hiddenName: 'search[epcode]'
                                        ,id: 'search[epcode]'
                                        ,valueField: 'epcode'
                                        ,displayField: 'expert'
                                        ,urlStore: pre_url + '/code/cexpert'
                                        ,fieldStore: ['epcode', 'expert']
                                        ,anchor: "90%"
                                    })
                                ]
                                ,buttons: [
                                    {
                                        text: "ยืนยัน"
                                        ,handler: function(){
                                            combo = Ext.getCmp("search[epcode]");
                                            record.data["value"] = combo.getRawValue();
                                            record.data["id"] = combo.getValue();
                                            record.data["code"] = combo.getValue();
                                            record.commit();
                                            win.close();                                                                         
                                        }
                                    }
                                ]
                        }]
                                
                });
        }
        win.show();
        win.center();
}

function QueryPtname(record){
        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,height: 150
                        ,width: 600
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 120
                                ,labelAlign: "right"
                                ,items: [
                                    new Ext.ux.form.PisComboBox({//ว./ว.ช/ชช.
                                        fieldLabel: "ว./ว.ช/ชช."
                                        ,hiddenName: 'search[ptcode]'
                                        ,id: 'search[ptcode]'
                                        ,valueField: 'ptcode'
                                        ,displayField: 'ptname'
                                        ,urlStore: pre_url + '/code/cpostype'
                                        ,fieldStore: ['ptcode', 'ptname']
                                        ,anchor: "90%"
                                    })
                                ]
                                ,buttons: [
                                    {
                                        text: "ยืนยัน"
                                        ,handler: function(){
                                            combo = Ext.getCmp("search[ptcode]");
                                            record.data["value"] = combo.getRawValue();
                                            record.data["id"] = combo.getValue();
                                            record.data["code"] = combo.getValue();
                                            record.commit();
                                            win.close();                                                                                                                                                   
                                        }
                                    }
                                ]
                        }]
                                
                });
        }
        win.show();
        win.center();
}

function QueryInt(record){
        if(!form){
                var form = new Ext.FormPanel({ 
                        labelWidth: 50
                        ,autoScroll: true
                        ,url: ''
                        ,frame: true
                        ,monitorValid: true
                        ,items:[
                                {
                                        xtype: "numberfield"
                                        ,id: "set_value_query_grid_value"
                                        ,fieldLabel: "Value"
                                        ,anchor: "95%"
                                }	
                        ]
                        ,buttons:[
                                { 
                                        text:'ยืนยัน'
                                        ,formBind: true 
                                        ,handler:function(){ 
                                                record.data["value"] = Ext.getCmp("set_value_query_grid_value").getValue();
                                                record.data["id"] = Ext.getCmp("set_value_query_grid_value").getValue();
                                                record.commit();
                                                win.close();	
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
                        title: ''
                        ,width: 400
                        ,height: 150
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [form]
                });
        }
        win.show();
        win.center();	
}

function QueryDate(record){
        if(!form){
                var form = new Ext.FormPanel({ 
                        labelWidth: 50
                        ,autoScroll: true
                        ,url: ''
                        ,frame: true
                        ,monitorValid: true
                        ,items:[
                                {
                                        xtype: "datefield"
                                        ,id: "set_value_query_grid_value"
                                        ,fieldLabel: "Value"
                                        ,anchor: "95%"
                                        ,format: 'd/m/Y'
                                }	
                        ]
                        ,buttons:[
                                { 
                                        text:'ยืนยัน'
                                        ,formBind: true 
                                        ,handler:function(){
                                                record.data["value"] = Ext.getCmp("set_value_query_grid_value").getRawValue();
                                                record.data["id"] = Ext.getCmp("set_value_query_grid_value").getRawValue();
                                                record.commit();
                                                win.close();	
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
                        title: ''
                        ,width: 400
                        ,height: 150
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [form]
                });
        }
        win.show();
        win.center();	
}

function QueryJ18Status(record){
        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,height: 150
                        ,width: 600
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 120
                                ,labelAlign: "right"
                                ,items: [
                                    new Ext.ux.form.PisComboBox({
                                        fieldLabel: "ปฏิบัติงานจริง"
                                        ,id: 'search[j18code]'
                                        ,hiddenName:'search[j18code]'
                                        ,valueField: 'j18code'
                                        ,displayField: 'j18status'
                                        ,urlStore: pre_url + '/code/cj18status'
                                        ,fieldStore: ['j18code', 'j18status']
                                        ,anchor: "90%"
                                    })                                    
                                ]
                                ,buttons: [
                                    {
                                        text: "ยืนยัน"
                                        ,handler: function(){
                                            combo = Ext.getCmp("search[j18code]");
                                            record.data["value"] = combo.getRawValue();
                                            record.data["id"] = combo.getValue();
                                            record.data["code"] = combo.getValue();
                                            record.commit();
                                            win.close();                                                                             
                                        }
                                    }
                                ]
                        }]
                                
                });
        }
        win.show();
        win.center();
}

function QueryUpdate(record){
        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,height: 150
                        ,width: 600
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 80
                                ,labelAlign: "right"
                                ,items: [
                                    new Ext.ux.form.PisComboBox({//การเคลื่อนไหว
                                             fieldLabel: 'การเคลื่อนไหว'
                                             ,hiddenName: 'search[updcode]'
                                             ,id: 'search[updcode]'
                                             ,width: 250
                                             ,valueField: 'updcode'
                                             ,displayField: 'updname'
                                             ,urlStore: pre_url + '/code/cupdate'
                                             ,fieldStore: ['updcode', 'updname']
                                             ,anchor: "90%"
                                    })                                    
                                ]
                                ,buttons: [
                                    {
                                        text: "ยืนยัน"
                                        ,handler: function(){
                                            combo = Ext.getCmp("search[updcode]");
                                            record.data["value"] = combo.getRawValue();
                                            record.data["id"] = combo.getValue();
                                            record.data["code"] = combo.getValue();
                                            record.commit();
                                            win.close();                                                                           
                                        }
                                    }
                                ]
                        }]
                                
                });
        }
        win.show();
        win.center();
}
function QueryQualify(record){
        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,height: 150
                        ,width: 600
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 80
                                ,labelAlign: "right"
                                ,items: [
                                    new Ext.ux.form.PisComboBox({//วุฒิการศึกษา
                                         fieldLabel: 'วุฒิการศึกษา'
                                         ,id: 'search[qcode]'
                                         ,hiddenName:'search[qcode]'
                                         ,valueField: 'qcode'
                                         ,displayField: 'qualify'
                                         ,urlStore: pre_url + '/code/cqualify'
                                         ,fieldStore: ['qcode', 'qualify']
                                         ,anchor: "90%"
                                    })                        
                                ]
                                ,buttons: [
                                    {
                                        text: "ยืนยัน"
                                        ,handler: function(){
                                            combo = Ext.getCmp("search[qcode]");
                                            record.data["value"] = combo.getRawValue();
                                            record.data["id"] = combo.getValue();
                                            record.data["code"] = combo.getValue();
                                            record.commit();
                                            win.close();                                                                        
                                        }
                                    }
                                ]
                        }]
                                
                });
        }
        win.show();
        win.center();
}

function QueryMajor(record){
        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,height: 150
                        ,width: 600
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 80
                                ,labelAlign: "right"
                                ,items: [
                                    new Ext.ux.form.PisComboBox({//วิชาเอก
                                        fieldLabel: 'วิชาเอก'
                                        ,id: 'search[macode]'
                                        ,hiddenName:'search[macode]'
                                        ,valueField: 'macode'
                                        ,displayField: 'major'
                                        ,urlStore: pre_url + '/code/cmajor'
                                        ,fieldStore: ['macode', 'major']
                                        ,anchor: "90%"
                                    })                                    
                                ]
                                ,buttons: [
                                    {
                                        text: "ยืนยัน"
                                        ,handler: function(){
                                            combo = Ext.getCmp("search[macode]");
                                            record.data["value"] = combo.getRawValue();
                                            record.data["id"] = combo.getValue();
                                            record.data["code"] = combo.getValue();
                                            record.commit();
                                            win.close();                                                                          
                                        }
                                    }
                                ]
                        }]
                                
                });
        }
        win.show();
        win.center();
}

function QueryTrade(record){
        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,height: 150
                        ,width: 600
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 100
                                ,labelAlign: "right"
                                ,items: [
                                    new Ext.ux.form.PisComboBox({
                                        fieldLabel: "ใบอนุญาตประกอบอาชีพ"
                                        ,id: 'search[codetrade]'
                                        ,hiddenName:'search[codetrade]'
                                        ,valueField: 'codetrade'
                                        ,displayField: 'trade'
                                        ,urlStore: pre_url + '/code/ctrade'
                                        ,fieldStore: ['codetrade', 'trade']
                                        ,anchor: "90%"
                                    })                                    
                                ]
                                ,buttons: [
                                    {
                                        text: "ยืนยัน"
                                        ,handler: function(){
                                            combo = Ext.getCmp("search[codetrade]");
                                            record.data["value"] = combo.getRawValue();
                                            record.data["id"] = combo.getValue();
                                            record.data["code"] = combo.getValue();
                                            record.commit();
                                            win.close();                                                                        
                                        }
                                    }
                                ]
                        }]
                                
                });
        }
        win.show();
        win.center();
}

function QueryRelig(record){
        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,height: 150
                        ,width: 600
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 80
                                ,labelAlign: "right"
                                ,items: [
                                    new Ext.ux.form.PisComboBox({//ศาสนา
                                        fieldLabel: 'ศาสนา'
                                        ,hiddenName: 'search[recode]'
                                        ,id: 'search[recode]'
                                        ,valueField: 'recode'
                                        ,displayField: 'renname'
                                        ,urlStore: pre_url + '/code/creligion'
                                        ,fieldStore: ['recode', 'renname']
                                        ,anchor: "90%"       
                                    })                                    
                                ]
                                ,buttons: [
                                    {
                                        text: "ยืนยัน"
                                        ,handler: function(){
                                            combo = Ext.getCmp("search[recode]");
                                            record.data["value"] = combo.getRawValue();
                                            record.data["id"] = combo.getValue();
                                            record.data["code"] = combo.getValue();
                                            record.commit();
                                            win.close();                                                                      
                                        }
                                    }
                                ]
                        }]
                                
                });
        }
        win.show();
        win.center();
}

function QueryMarital(record){
        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,height: 150
                        ,width: 600
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 80
                                ,labelAlign: "right"
                                ,items: [
                                    new Ext.ux.form.PisComboBox({//สถานภาพสมรส
                                        fieldLabel: 'สถานภาพสมรส'
                                        ,hiddenName: 'search[mrcode]'
                                        ,id: 'search[mrcode]'
                                        ,valueField: 'mrcode'
                                        ,displayField: 'marital'
                                        ,urlStore: pre_url + '/code/cmarital'
                                        ,fieldStore: ['mrcode', 'marital']
                                        ,anchor: "90%"
                                    })
                                    
                                ]
                                ,buttons: [
                                    {
                                        text: "ยืนยัน"
                                        ,handler: function(){
                                            combo = Ext.getCmp("search[mrcode]");
                                            record.data["value"] = combo.getRawValue();
                                            record.data["id"] = combo.getValue();
                                            record.data["code"] = combo.getValue();
                                            record.commit();
                                            win.close();                                                                         
                                        }
                                    }
                                ]
                        }]
                                
                });
        }
        win.show();
        win.center();
}

function QuerySex(record){
        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,height: 150
                        ,width: 600
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 80
                                ,labelAlign: "right"
                                ,items: [
                                    new Ext.form.ComboBox({//เพศ
                                        fieldLabel: "เพศ"
                                        ,editable: true
                                        ,id: "search[sex]"										
                                        ,hiddenName: 'search[sex]'
                                        ,anchor: "90%"
                                        ,store: new Ext.data.SimpleStore({
                                            fields: ['id', 'type']
                                            ,data: [
                                                ["1", "ชาย"]
                                                ,["2", "หญิง"]                                                                           
                                            ] 
                                        })
                                        ,valueField	:'id'
                                        ,displayField:'type'
                                        ,typeAhead	: true
                                        ,mode: 'local'
                                        ,triggerAction: 'all'
                                        ,emptyText	:'Select ...'
                                    })
                                ]
                                ,buttons: [
                                    {
                                        text: "ยืนยัน"
                                        ,handler: function(){
                                            record.data["value"] = Ext.getCmp("search[sex]").getRawValue();
                                            record.data["id"] = Ext.getCmp("search[sex]").getValue();
                                            record.commit();
                                            win.close();
                                        }
                                    }
                                ]
                        }]
                                
                });
        }
        win.show();
        win.center();
}
function QueryProvince(record){
    if(!win){
            var win = new Ext.Window({
                    title: ''
                    ,height: 150
                    ,width: 600
                    ,closable: true
                    ,resizable: false
                    ,plain: true
                    ,border: false
                    ,draggable: true 
                    ,modal: true
                    ,layout: "fit"
                    ,items: [{
                            layout: "form"
                            ,frame: true
                            ,labelWidth: 80
                            ,labelAlign: "right"
                            ,items: [
                                new Ext.ux.form.PisComboBox({//ภูมิลำเนา
                                    fieldLabel: 'ภูมิลำเนา'
                                    ,hiddenName: 'search[provcode]'
                                    ,id: 'search[provcode]'
                                    ,valueField: 'provcode'
                                    ,displayField: 'provname'
                                    ,urlStore: pre_url + '/code/cprovince'
                                    ,fieldStore: ['provcode', 'provname']
                                    ,anchor: "90%"                                                                       
                                })                                    
                             ]
                            ,buttons: [
                                {
                                    text: "ยืนยัน"
                                    ,handler: function(){
                                        combo = Ext.getCmp("search[provcode]");
                                        record.data["value"] = combo.getRawValue();
                                        record.data["id"] = combo.getValue();
                                        record.data["code"] = combo.getValue();
                                        record.commit();
                                        win.close();                                                                           
                                    }
                                }
                            ]
                    }]
                            
            });
    }
        win.show();
        win.center();
}
function QueryEduLevel(record){
    if(!win){
            var win = new Ext.Window({
                    title: ''
                    ,height: 150
                    ,width: 600
                    ,closable: true
                    ,resizable: false
                    ,plain: true
                    ,border: false
                    ,draggable: true 
                    ,modal: true
                    ,layout: "fit"
                    ,items: [{
                            layout: "form"
                            ,frame: true
                            ,labelWidth: 120
                            ,labelAlign: "right"
                            ,items: [
                                new Ext.ux.form.PisComboBox({//ระบดับการการศึกษา
                                     fieldLabel: 'ระบดับการการศึกษา'
                                     ,id: 'search[ecode]'
                                     ,hiddenName:'search[ecode]'
                                     ,valueField: 'ecode'
                                     ,displayField: 'edulevel'
                                     ,urlStore: pre_url + '/code/cedulevel'
                                     ,fieldStore: ['ecode', 'edulevel']
                                     ,anchor: "90%"
                                })                                    
                             ]
                            ,buttons: [
                                {
                                    text: "ยืนยัน"
                                    ,handler: function(){
                                        combo = Ext.getCmp("search[ecode]");
                                        record.data["value"] = combo.getRawValue();
                                        record.data["id"] = combo.getValue();
                                        record.data["code"] = combo.getValue();
                                        record.commit();
                                        win.close();                                                                                
                                    }
                                }
                            ]
                    }]
                            
            });
    }
    win.show();
    win.center();
}
function QueryCountry(record){
        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,height: 150
                        ,width: 600
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 80
                                ,labelAlign: "right"
                                ,items: [
                                    new Ext.ux.form.PisComboBox({//ประเทศ
                                         fieldLabel: 'ประเทศ'
                                         ,id: 'search[cocode]'
                                         ,hiddenName:'search[cocode]'
                                         ,valueField: 'cocode'
                                         ,displayField: 'coname'
                                         ,urlStore: pre_url + '/code/ccountry'
                                         ,fieldStore: ['cocode', 'coname']
                                         ,anchor: "90%"
                                    })                                    
                                 ]
                                ,buttons: [
                                    {
                                        text: "ยืนยัน"
                                        ,handler: function(){
                                            combo = Ext.getCmp("search[cocode]");
                                            record.data["value"] = combo.getRawValue();
                                            record.data["id"] = combo.getValue();
                                            record.data["code"] = combo.getValue();
                                            record.commit();
                                            win.close();
                                        }
                                    }
                                ]
                        }]
                                
                });
        }
        win.show();
        win.center();
}
function QueryPunish(record){
        if(!win){
                var win = new Ext.Window({
                        title: ''
                        ,height: 150
                        ,width: 600
                        ,closable: true
                        ,resizable: false
                        ,plain: true
                        ,border: false
                        ,draggable: true 
                        ,modal: true
                        ,layout: "fit"
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 80
                                ,labelAlign: "right"
                                ,items: [
                                    new Ext.ux.form.PisComboBox({//โทษที่ได้รับ
                                        fieldLabel: 'โทษที่ได้รับ'   
                                        ,hiddenName: 'search[pncode]'
                                        ,id: 'search[pncode]'
                                        ,valueField: 'pncode'
                                        ,displayField: 'pnname'
                                        ,urlStore: pre_url + '/code/cpunish'
                                        ,fieldStore: ['pncode', 'pnname']
                                        ,anchor: "90%"                                                                                  
                                    })                                    
                                 ]
                                ,buttons: [
                                    {
                                        text: "ยืนยัน"
                                        ,handler: function(){
                                            combo = Ext.getCmp("search[pncode]");
                                            record.data["value"] = combo.getRawValue();
                                            record.data["id"] = combo.getValue();
                                            record.data["code"] = combo.getValue();
                                            record.commit();
                                            win.close();                                                                          
                                        }
                                    }
                                ]
                        }]  
                });
        }
        win.show();
        win.center();
}

function QueryWorkPlacenameNotSet(record){
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
                        ,items: [{
                                layout: "form"
                                ,frame: true
                                ,labelWidth: 80
                                ,labelAlign: "right"
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
						,enableKeyEvents: (user_work_place.sdcode == undefined)? true : false
						,listeners: {
							 keydown : function( el,e ){
								  Ext.getCmp("work_place_subdept_show").setValue("");
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
										    Ext.getCmp("work_place_subdept_show").setValue("");
										 }
										 else{
										    Ext.getCmp("work_place[sdcode]").setValue(obj.records[0].sdcode);
										    Ext.getCmp("work_place_subdept_show").setValue(obj.records[0].subdeptname);
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
								  if (Ext.getCmp("work_place_subdept_show").getValue() == ""){
									   Ext.getCmp("work_place[sdcode]").setValue("");
									   Ext.getCmp("work_place_subdept_show").setValue("");    
								  }
							 }
							 
						}
					    }
					    ,{
						xtype: "textfield"
						,id: "work_place_subdept_show"
						,readOnly: true
						,style: "color: #ffffff;background-color:#888888;background-image:url('#');width:345px;"
					    }
					    ,{
						xtype: "button"
						,id: "work_place_subdept_button"
						,text: "..."
						,handler: function(){
							 searchSubdept(Ext.getCmp("work_place[sdcode]"),Ext.getCmp("work_place_subdept_show"));
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
                                ,{
                                    html: "<br /><b>*หมายเหตุ  Operator หัวข้อที่เลือกจะได้เฉพาะ \"เท่ากับ\" เท่านั้น</b>"
                                }
			    ]
                                ,buttons: [
                                        {
                                                text: "ยืนยัน"
                                                ,handler: function(){
                                                        if (Ext.getCmp("work_place[mcode]").getValue() == "" && Ext.getCmp("work_place[dcode]").getValue() == "" && Ext.getCmp("work_place[deptcode]").getValue() == "" && Ext.getCmp("work_place[jobcode]").getValue() == "" && Ext.getCmp("work_place[sdcode]").getValue() == "" && Ext.getCmp("work_place[seccode]").getValue() == ""){
                                                                Ext.Msg.alert("คำเตือน","กรุณาทำรายการให้ถูกต้อง")
                                                        }
                                                        else{
                                                                //mcode,deptcode,dcode,sdcode,seccode,jobcode
                                                                str_id = {};
                                                                str_code = new Array();
                                                                str_value = new Array();
                                                                if (Ext.getCmp("work_place[mcode]").getValue() != ""){
                                                                    str_id.mcode = Ext.getCmp("work_place[mcode]").getValue();
                                                                    str_code.push(Ext.getCmp("work_place[mcode]").getValue());
                                                                    str_value.push(Ext.getCmp("work_place[mcode]").getRawValue());
                                                                }                                                                
                                                                if (Ext.getCmp("work_place[deptcode]").getValue() != ""){
                                                                    str_id.deptcode = Ext.getCmp("work_place[deptcode]").getValue();
                                                                    str_code.push(Ext.getCmp("work_place[deptcode]").getValue());
                                                                    str_value.push(Ext.getCmp("work_place[deptcode]").getRawValue());
                                                                }                                                                
                                                                if (Ext.getCmp("work_place[dcode]").getValue() != ""){
                                                                    str_id.dcode = Ext.getCmp("work_place[dcode]").getValue();
                                                                    str_code.push(Ext.getCmp("work_place[dcode]").getValue());
                                                                    str_value.push(Ext.getCmp("work_place[dcode]").getRawValue());
                                                                }                                                                
                                                                if (Ext.getCmp("work_place[sdcode]").getValue() != ""){
                                                                    str_id.sdcode = Ext.getCmp("work_place[sdcode]").getValue();
                                                                    str_code.push(Ext.getCmp("work_place[sdcode]").getValue());
                                                                    str_value.push(Ext.getCmp("work_place_subdept_show").getValue());
                                                                }                                                                
                                                                if (Ext.getCmp("work_place[seccode]").getValue() != ""){
                                                                    str_id.seccode = Ext.getCmp("work_place[seccode]").getValue();
                                                                    str_code.push(Ext.getCmp("work_place[seccode]").getValue());
                                                                    str_value.push(Ext.getCmp("work_place[seccode]").getRawValue());
                                                                }                                                                
                                                                if (Ext.getCmp("work_place[jobcode]").getValue() != ""){
                                                                    str_id.jobcode = Ext.getCmp("work_place[jobcode]").getValue();
                                                                    str_code.push(Ext.getCmp("work_place[jobcode]").getValue());
                                                                    str_value.push(Ext.getCmp("work_place[jobcode]").getRawValue());
                                                                }                                                                
                                                                record.data["value"] = str_value.join("<br />");
                                                                record.data["id"] = str_id;
                                                                record.data["code"] = str_code.join(",");
                                                                record.commit();
                                                                win.close();                                                                
                                                        }
                                                }
                                        },{
                                                text: "ยกเลิก"
                                                ,handler: function	(){
                                                        win.close();
                                                }
                                        }
                                ]
                        }]
                });
        }
        win.show();	
        win.center();
}


function personelNow(posid,show,id){


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
             ,{name: "posid", type: "string"}
             ,{name: "id", type: "string"}
    ];
    personelNowCols = [
         {
                  header: "#"
                  ,width: 80
                  ,renderer: rowNumberer.createDelegate(this)
                  ,sortable: false
         }
         ,{header: "เลขที่ตำแหน่ง",width: 100, sortable: false, dataIndex: 'posid'}		
         ,{header: "คำนำหน้า",width: 70, sortable: false, dataIndex: 'prefix'}
         ,{header: "ชื่อ",width: 100, sortable: false, dataIndex: 'fname'}
         ,{header: "นามสกุล",width: 100, sortable: false, dataIndex: 'lname'}
         
    ];
        
    personelNowGridStore = new Ext.data.JsonStore({
            url: pre_url + "/info_personal/read"
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
        posid.setValue(data_select.posid);
        show.setValue(data_select.prefix+data_select.fname+" "+data_select.lname);
        id.setValue(data_select.id);
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
