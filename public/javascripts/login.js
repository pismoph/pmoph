Ext.onReady(function(){
  Ext.QuickTips.init();
  var win;

  var login = new Ext.FormPanel({
    labelWidth: 80
    ,url: pre_url + '/sessions/login'
    ,frame:true
    ,title:'PIS LOGIN'
    ,defaultType: 'textfield'
    ,items:[{
      fieldLabel: 'ผู้ใช้งาน'
      ,name: 'login'
      ,allowBlank: false
    },{
      fieldLabel: 'รหัสผ่าน'
      ,name: 'password'
      ,inputType: 'password'
      ,allowBlank: false
      ,enableKeyEvents: true
      ,listeners: {
        specialkey: function(field, el){
          if (el.getKey() == Ext.EventObject.ENTER)
            Ext.getCmp('loginButton').fireEvent('click');
        }
      }
    }]
    ,buttonAlign: 'center'
    ,buttons:[{
      text:'Login'
      ,id: 'loginButton'
      ,formBind: true
      ,listeners: {
        click: function(){
          login.getForm().submit({
            method: 'POST'
            ,waitTitle: 'Connecting'
            ,waitMsg: 'Sending data...'
            ,success: function(form, action){
	      json = Ext.util.JSON.decode(action.response.responseText);
              if (json.msg == "invalid"){
		Ext.Msg.alert("คำเตือน","ผู้ใช้งาน/รหัสผ่าน ไม่ถูกต้อง")
	      	return false;
              }
	      if (pre_url == ""){
		var url = "/";
	      }
	      else{
		var url = pre_url;
	      }
              win.hide();
              window.location = url;
            } //eo success
            ,failure: function(form, action){
              json = Ext.util.JSON.decode(action.response.responseText);
              Ext.Msg.alert('Login Failed!', json.msg);
              login.getForm().reset();
            } //eo failure
          }); //eo submit
        } //eo click
      } //eo listeners
    }]
  });
  win = new Ext.Window({
    layout: 'fit'
    ,width: 300
    ,height: 150
    ,closable: false
    ,resizable: false
    ,plain: true
    ,border: false
    ,items: [ login ]
  });
  win.show();
});

