//ตรวจสอบเลขบัตรประชาขน ถ้ากรอกถูกต้องจะ return true
function isNationalID(id) {
	if(id.length != 13) return false;
	for(i=0, sum=0; i < 12; i++){
		sum += parseFloat(id.charAt(i))*(13-i);
	}
	if((11-sum%11)%10!=parseFloat(id.charAt(12))) return false;
	return true;
}

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
