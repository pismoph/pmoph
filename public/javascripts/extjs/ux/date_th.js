Ext.override(Ext.DatePicker, {
	buddhaEraRender : null,
	// private
	initComponent : function(){
		Ext.DatePicker.superclass.initComponent.call(this);

		this.value = this.value ?
		this.value.clearTime() : new Date().clearTime();

		this.addEvents(
		/**
		* @event select
		* Fires when a date is selected
		* @param {DatePicker} this
		* @param {Date} date The selected date
		*/
		'select'
		);

		if(this.handler){
			this.on('select', this.handler, this.scope || this);
		}

		this.initDisabledDays();
	},

	// private
	initDisabledDays : function(){
		if(!this.disabledDatesRE && this.disabledDates){
			var dd = this.disabledDates,
			len = dd.length - 1,
			re = '(?:';

			Ext.each(dd, function(d, i){
				re += Ext.isDate(d) ? '^' + Ext.escapeRe(d.dateFormat(this.format)) + '$' : dd[i];
				if(i != len){
					re += '|';
				}
			}, this);
			this.disabledDatesRE = new RegExp(re + ')');
		}
	},

	/**
	* Replaces any existing disabled dates with new values and refreshes the DatePicker.
	* @param {Array/RegExp} disabledDates An array of date strings (see the {@link #disabledDates} config
	* for details on supported values), or a JavaScript regular expression used to disable a pattern of dates.
	*/
	setDisabledDates : function(dd){
		if(Ext.isArray(dd)){
			this.disabledDates = dd;
			this.disabledDatesRE = null;
		}else{
			this.disabledDatesRE = dd;
		}
		this.initDisabledDays();
		this.update(this.value, true);
	},

	/**
	* Replaces any existing disabled days (by index, 0-6) with new values and refreshes the DatePicker.
	* @param {Array} disabledDays An array of disabled day indexes. See the {@link #disabledDays} config
	* for details on supported values.
	*/
	setDisabledDays : function(dd){
		this.disabledDays = dd;
		this.update(this.value, true);
	},

	/**
	* Replaces any existing {@link #minDate} with the new value and refreshes the DatePicker.
	* @param {Date} value The minimum date that can be selected
	*/
	setMinDate : function(dt){
		this.minDate = dt;
		this.update(this.value, true);
	},

	/**
	* Replaces any existing {@link #maxDate} with the new value and refreshes the DatePicker.
	* @param {Date} value The maximum date that can be selected
	*/
	setMaxDate : function(dt){
		this.maxDate = dt;
		this.update(this.value, true);
	},

	/**
	* Sets the value of the date field
	* @param {Date} value The date to set
	*/
	setValue : function(value){
		var old = this.value;
		this.value = value.clearTime(true);
		if(this.el){
			this.update(this.value);
		}
	},

	/**
	* Gets the current selected value of the date field
	* @return {Date} The selected date
	*/
	getValue : function(){
		return this.value;
	},

	// private
	focus : function(){
		if(this.el){
			this.update(this.activeDate);
		}
	},

	// private
	onEnable: function(initial){
		Ext.DatePicker.superclass.onEnable.call(this);
		this.doDisabled(false);
		this.update(initial ? this.value : this.activeDate);
		if(Ext.isIE){
			this.el.repaint();
		}
	},

	// private
	onDisable: function(){
		Ext.DatePicker.superclass.onDisable.call(this);
		this.doDisabled(true);
		if(Ext.isIE && !Ext.isIE8){
			/* Really strange problem in IE6/7, when disabled, have to explicitly
			* repaint each of the nodes to get them to display correctly, simply
			* calling repaint on the main element doesn't appear to be enough.
			*/
			Ext.each([].concat(this.textNodes, this.el.query('th span')), function(el){
				Ext.fly(el).repaint();
			});
		}
	},

	// private
	doDisabled: function(disabled){
		this.keyNav.setDisabled(disabled);
		this.prevRepeater.setDisabled(disabled);
		this.nextRepeater.setDisabled(disabled);
		if(this.showToday){
			this.todayKeyListener.setDisabled(disabled);
			this.todayBtn.setDisabled(disabled);
		}
	},

	// private
	onRender : function(container, position){
		var m = [
		'<table cellspacing="0">',
		'<tr><td class="x-date-left"><a href="#" title="', this.prevText ,'"> </a></td><td class="x-date-middle" align="center"></td><td class="x-date-right"><a href="#" title="', this.nextText ,'"> </a></td></tr>',
		'<tr><td colspan="3"><table class="x-date-inner" cellspacing="0"><thead><tr>'],
		dn = this.dayNames,
		i;
		for(i = 0; i < 7; i++){
			var d = this.startDay+i;
			if(d > 6){
				d = d-7;
			}
			m.push('<th><span>', dn[d].substr(0,1), '</span></th>');
		}
		m[m.length] = '</tr></thead><tbody><tr>';
		for(i = 0; i < 42; i++) {
			if(i % 7 === 0 && i !== 0){
				m[m.length] = '</tr><tr>';
			}
			m[m.length] = '<td><a href="#" hidefocus="on" class="x-date-date" tabIndex="1"><em><span></span></em></a></td>';
		}
		m.push('</tr></tbody></table></td></tr>',
			this.showToday ? '<tr><td colspan="3" class="x-date-bottom" align="center"></td></tr>' : '',
			'</table><div class="x-date-mp"></div>');

		var el = document.createElement('div');
		el.className = 'x-date-picker';
		el.innerHTML = m.join('');

		container.dom.insertBefore(el, position);

		this.el = Ext.get(el);
		this.eventEl = Ext.get(el.firstChild);

		this.prevRepeater = new Ext.util.ClickRepeater(this.el.child('td.x-date-left a'), {
			handler: this.showPrevMonth,
			scope: this,
			preventDefault:true,
			stopDefault:true
		});

		this.nextRepeater = new Ext.util.ClickRepeater(this.el.child('td.x-date-right a'), {
			handler: this.showNextMonth,
			scope: this,
			preventDefault:true,
			stopDefault:true
		});

		this.monthPicker = this.el.down('div.x-date-mp');
		this.monthPicker.enableDisplayMode('block');

		this.keyNav = new Ext.KeyNav(this.eventEl, {
			'left' : function(e){
				if(e.ctrlKey){
					this.showPrevMonth();
				}else{
					this.update(this.activeDate.add('d', -1));
				}
			},

			'right' : function(e){
				if(e.ctrlKey){
					this.showNextMonth();
				}else{
					this.update(this.activeDate.add('d', 1));
				}
			},

			'up' : function(e){
				if(e.ctrlKey){
					this.showNextYear();
				}else{
					this.update(this.activeDate.add('d', -7));
				}
			},

			'down' : function(e){
				if(e.ctrlKey){
					this.showPrevYear();
				}else{
					this.update(this.activeDate.add('d', 7));
				}
			},

			'pageUp' : function(e){
				this.showNextMonth();
			},

			'pageDown' : function(e){
				this.showPrevMonth();
			},

			'enter' : function(e){
				e.stopPropagation();
				return true;
			},

			scope : this
		});

		this.el.unselectable();

		this.cells = this.el.select('table.x-date-inner tbody td');
		this.textNodes = this.el.query('table.x-date-inner tbody span');

		this.mbtn = new Ext.Button({
			text: ' ',
			tooltip: this.monthYearText,
			renderTo: this.el.child('td.x-date-middle', true)
		});
		this.mbtn.el.child('em').addClass('x-btn-arrow');

		if(this.showToday){
			this.todayKeyListener = this.eventEl.addKeyListener(Ext.EventObject.SPACE, this.selectToday, this);
			var today = (new Date()).dateFormat(this.format);
			this.todayBtn = new Ext.Button({
				renderTo: this.el.child('td.x-date-bottom', true),
				text: String.format(this.todayText, today),
				tooltip: String.format(this.todayTip, today),
				handler: this.selectToday,
				scope: this
			});
		}
		this.mon(this.eventEl, 'mousewheel', this.handleMouseWheel, this);
		this.mon(this.eventEl, 'click', this.handleDateClick, this, {delegate: 'a.x-date-date'});
		this.mon(this.mbtn, 'click', this.showMonthPicker, this);
		this.onEnable(true);
	},

	// private
	createMonthPicker : function(){
		if(!this.monthPicker.dom.firstChild){
			var buf = ['<table border="0" cellspacing="0">'];
			for(var i = 0; i < 6; i++){
				buf.push(
					'<tr><td class="x-date-mp-month"><a href="#">', Date.monthNames[i], '</a></td>',
					'<td class="x-date-mp-month x-date-mp-sep"><a href="#">', Date.monthNames[i + 6], '</a></td>',
					i === 0 ?
					'<td class="x-date-mp-ybtn" align="center"><a class="x-date-mp-prev"></a></td><td class="x-date-mp-ybtn" align="center"><a class="x-date-mp-next"></a></td></tr>' :
					'<td class="x-date-mp-year"><a href="#"></a></td><td class="x-date-mp-year"><a href="#"></a></td></tr>'
				);
			}
			buf.push(
				'<tr class="x-date-mp-btns"><td colspan="4"><button type="button" class="x-date-mp-ok">',
				this.okText,
				'</button><button type="button" class="x-date-mp-cancel">',
				this.cancelText,
				'</button></td></tr>',
				'</table>'
			);
			this.monthPicker.update(buf.join(''));

			this.mon(this.monthPicker, 'click', this.onMonthClick, this);
			this.mon(this.monthPicker, 'dblclick', this.onMonthDblClick, this);

			this.mpMonths = this.monthPicker.select('td.x-date-mp-month');
			this.mpYears = this.monthPicker.select('td.x-date-mp-year');

			this.mpMonths.each(function(m, a, i){
				i += 1;
				if((i%2) === 0){
					m.dom.xmonth = 5 + Math.round(i * 0.5);
				}else{
					m.dom.xmonth = Math.round((i-1) * 0.5);
				}
			});
		}
	},

	// private
	showMonthPicker : function(){
		if(!this.disabled){
			this.createMonthPicker();
			var size = this.el.getSize();
			this.monthPicker.setSize(size);
			this.monthPicker.child('table').setSize(size);

			this.mpSelMonth = (this.activeDate || this.value).getMonth();
			this.updateMPMonth(this.mpSelMonth);
			this.mpSelYear = (this.buddhaEraRender) || (this.activeDate || this.value).getFullYear();
			this.updateMPYear(this.mpSelYear);

			this.monthPicker.slideIn('t', {duration:0.2});
		}
	},

	// private
	updateMPYear : function(y){
		this.mpyear = y;
		var ys = this.mpYears.elements;
		for(var i = 1; i <= 10; i++){
			var td = ys[i-1], y2;
			if((i%2) === 0){
				y2 = y + Math.round(i * 0.5);
				td.firstChild.innerHTML = y2;
				td.xyear = y2;
			}else{
				y2 = y - (5-Math.round(i * 0.5));
				td.firstChild.innerHTML = y2;
				td.xyear = y2;
			}
			this.mpYears.item(i-1)[y2 == this.mpSelYear ? 'addClass' : 'removeClass']('x-date-mp-sel');
		}
	},

	// private
	updateMPMonth : function(sm){
		this.mpMonths.each(function(m, a, i){
			m[m.dom.xmonth == sm ? 'addClass' : 'removeClass']('x-date-mp-sel');
		});
	},

	// private
	selectMPMonth : function(m){

	},

	// private
	onMonthClick : function(e, t){
		e.stopEvent();
		var el = new Ext.Element(t), pn;
		if(el.is('button.x-date-mp-cancel')){
			this.hideMonthPicker();
		}
		else if(el.is('button.x-date-mp-ok')){
			var d = new Date(this.mpSelYear, this.mpSelMonth, (this.activeDate || this.value).getDate());
			if(d.getMonth() != this.mpSelMonth){
				// 'fix' the JS rolling date conversion if needed
				d = new Date(this.mpSelYear, this.mpSelMonth, 1).getLastDateOfMonth();
			}
			this.update(d);
			this.hideMonthPicker();
		}
		else if((pn = el.up('td.x-date-mp-month', 2))){
			this.mpMonths.removeClass('x-date-mp-sel');
			pn.addClass('x-date-mp-sel');
			this.mpSelMonth = pn.dom.xmonth;
			this.mpSelYear = Number(this.getValue().getFullYear());
		}
		else if((pn = el.up('td.x-date-mp-year', 2))){
			this.mpYears.removeClass('x-date-mp-sel');
			pn.addClass('x-date-mp-sel');
			this.mpSelYear = pn.dom.xyear;
			this.mpSelYear = this.mpSelYear - 543;
		}
		else if(el.is('a.x-date-mp-prev')){
			this.updateMPYear(this.mpyear-10);
		}
		else if(el.is('a.x-date-mp-next')){
			this.updateMPYear(this.mpyear+10);
		}
	},

	// private
	onMonthDblClick : function(e, t){
		e.stopEvent();
		var el = new Ext.Element(t), pn;
		if((pn = el.up('td.x-date-mp-month', 2))){
			this.update(new Date(this.mpSelYear, pn.dom.xmonth, (this.activeDate || this.value).getDate()));
			this.hideMonthPicker();
		}
		else if((pn = el.up('td.x-date-mp-year', 2))){
			this.update(new Date((pn.dom.xyear - 543), this.mpSelMonth, (this.activeDate || this.value).getDate()));
			this.hideMonthPicker();
		}
	},

	// private
	hideMonthPicker : function(disableAnim){
		if(this.monthPicker){
			if(disableAnim === true){
				this.monthPicker.hide();
			}else{
				this.monthPicker.slideOut('t', {duration:0.2});
			}
		}
	},

	// private
	showPrevMonth : function(e){
		this.update(this.activeDate.add('mo', -1));
	},

	// private
	showNextMonth : function(e){
		this.update(this.activeDate.add('mo', 1));
	},

	// private
	showPrevYear : function(){
		this.update(this.activeDate.add('y', -1));
	},

	// private
	showNextYear : function(){
		this.update(this.activeDate.add('y', 1));
	},

	// private
	handleMouseWheel : function(e){
		e.stopEvent();
		if(!this.disabled){
			var delta = e.getWheelDelta();
			if(delta > 0){
				this.showPrevMonth();
			} else if(delta < 0){
				this.showNextMonth();
			}
		}
	},

	// private
	handleDateClick : function(e, t){
		e.stopEvent();
		if(!this.disabled && t.dateValue && !Ext.fly(t.parentNode).hasClass('x-date-disabled')){
			this.setValue((new Date(t.dateValue)).add(Date.YEAR , 543));
			this.fireEvent('select', this, this.value);
		}
	},

	// private
	selectToday : function(){
		if(this.todayBtn && !this.todayBtn.disabled){
			var today = (new Date().add(Date.YEAR,543));
			this.setValue(today.clearTime());
			this.fireEvent('select', this, this.value);
		}
	},

	// private
	update : function(date, forceRefresh){
		if(date > new Date()){
			date.add(Date.YEAR, 543);
		}
		var vd = this.activeDate, vis = this.isVisible();
		this.activeDate = date;
		if(!forceRefresh && vd && this.el){
			var t = date.getTime();
			if(vd.getMonth() == date.getMonth() && vd.getFullYear() == date.getFullYear()){
				this.cells.removeClass('x-date-selected');
				this.cells.each(function(c){
					if(c.dom.firstChild.dateValue == t){
						c.addClass('x-date-selected');
						if(vis){
							Ext.fly(c.dom.firstChild).focus(50);
						}
						return false;
					}
				});
				return;
			}
		}
		var days = date.getDaysInMonth();
		var firstOfMonth = date.getFirstDateOfMonth();
		var startingPos = firstOfMonth.getDay()-this.startDay;

		if(startingPos <= this.startDay){
			startingPos += 7;
		}

		var pm = date.add('mo', -1);
		var prevStart = pm.getDaysInMonth()-startingPos;

		var cells = this.cells.elements;
		var textEls = this.textNodes;
		days += startingPos;

		// convert everything to numbers so it's fast
		var day = 86400000;

		var d = (new Date((pm.getFullYear()), pm.getMonth(), prevStart)).clearTime();
		var today = new Date().clearTime().getTime();
		var sel = date.clearTime().getTime();
		var min = this.minDate ? this.minDate.clearTime() : Number.NEGATIVE_INFINITY;
		var max = this.maxDate ? this.maxDate.clearTime() : Number.POSITIVE_INFINITY;
		var ddMatch = this.disabledDatesRE;
		var ddText = this.disabledDatesText;
		var ddays = this.disabledDays ? this.disabledDays.join('') : false;
		var ddaysText = this.disabledDaysText;
		var format = this.format;

		if(this.showToday){
			var td = new Date().clearTime();
			var disable = (td < min || td > max ||
			(ddMatch && format && ddMatch.test(td.dateFormat(format))) ||
			(ddays && ddays.indexOf(td.getDay()) != -1));

			if(!this.disabled){
				this.todayBtn.setDisabled(disable);
				this.todayKeyListener[disable ? 'disable' : 'enable']();
			}
		}

		var setCellClass = function(cal, cell){
			cell.title = '';
			var t = d.getTime();
			cell.firstChild.dateValue = t;
			if(t == today){
				cell.className += ' x-date-today';
				cell.title = cal.todayText;
			}
			if(t == sel){
				cell.className += ' x-date-selected';
				if(vis){
					Ext.fly(cell.firstChild).focus(50);
				}
			}
			// disabling
			if(t < min) {
				cell.className = ' x-date-disabled';
				cell.title = cal.minText;
				return;
			}
			if(t > max) {
				cell.className = ' x-date-disabled';
				cell.title = cal.maxText;
				return;
			}
			if(ddays){
				if(ddays.indexOf(d.getDay()) != -1){
					cell.title = ddaysText;
					cell.className = ' x-date-disabled';
				}
			}
			if(ddMatch && format){
				var fvalue = d.dateFormat(format);
				if(ddMatch.test(fvalue)){
					cell.title = ddText.replace('%0', fvalue);
					cell.className = ' x-date-disabled';
				}
			}
		};

		var i = 0;
		for(; i < startingPos; i++) {
			textEls[i].innerHTML = (++prevStart);
			d.setDate(d.getDate()+1);
			cells[i].className = 'x-date-prevday';
			setCellClass(this, cells[i]);
		}
		for(; i < days; i++){
			var intDay = i - startingPos + 1;
			textEls[i].innerHTML = (intDay);
			d.setDate(d.getDate()+1);
			cells[i].className = 'x-date-active';
			setCellClass(this, cells[i]);
		}
		var extraDays = 0;
		for(; i < 42; i++) {
			textEls[i].innerHTML = (++extraDays);
			d.setDate(d.getDate()+1);
			cells[i].className = 'x-date-nextday';
			setCellClass(this, cells[i]);
		}
		this.monthNames = ['มกราคม','กุมภาพันธ์','มีนาคม','เมษายน','พฤษภาคม','มิถุนายน','กรกฎาคม','สิงหาคม','กันยายน','ตุลาคม','พฦศจิกายน','ธันวาคม'];
		this.buddhaEraRender = (date.getFullYear() + 543);
		this.mbtn.setText(this.monthNames[date.getMonth()] + ' ' + this.buddhaEraRender);

		if(!this.internalRender){
			var main = this.el.dom.firstChild;
			var w = main.offsetWidth;
			this.el.setWidth(w + this.el.getBorderWidth('lr'));
			Ext.fly(main).setWidth(w);
			this.internalRender = true;
			// opera does not respect the auto grow header center column
			// then, after it gets a width opera refuses to recalculate
			// without a second pass
			if(Ext.isOpera && !this.secondPass){
				main.rows[0].cells[1].style.width = (w - (main.rows[0].cells[0].offsetWidth+main.rows[0].cells[2].offsetWidth)) + 'px';
				this.secondPass = true;
				this.update.defer(10, this, [date]);
			}
		}
	},

	// private
	beforeDestroy : function() {
		if(this.rendered){
			this.keyNav.disable();
			this.keyNav = null;
			Ext.destroy(
				this.leftClickRpt,
				this.rightClickRpt,
				this.monthPicker,
				this.eventEl,
				this.mbtn,
				this.todayBtn
			);
		}
	}
});

Ext.override(Ext.form.DateField,{
	isMinPassByValue : false,
	onTriggerClick : function(){
		if(this.disabled){
			return;
		}
		if(this.menu == null){
			this.menu = new Ext.menu.DateMenu({
				hideOnClick: false,
				focusOnSelect: false
			});
		}
		this.onFocus();

		if(this.isMinPassByValue){
			var value = this.getValue();
			if(value != "" && value != null){
				this.minValue = value;
			}
		}

		Ext.apply(this.menu.picker, {
			minDate : this.minValue,
			maxDate : this.maxValue,
			disabledDatesRE : this.disabledDatesRE,
			disabledDatesText : this.disabledDatesText,
			disabledDays : this.disabledDays,
			disabledDaysText : this.disabledDaysText,
			format : this.format,
			showToday : this.showToday,
			minText : String.format(this.minText, this.formatDate(this.minValue)),
			maxText : String.format(this.maxText, this.formatDate(this.maxValue))
		});
		var value = this.getValue();
		var dateSetPicker = (value != "") ? value.add(Date.YEAR, 543) : value;
		if(dateSetPicker == ""){
			dateSetPicker = new Date();
		}else{
			dateSetPicker = dateSetPicker.add(Date.YEAR, -543);
		}
		this.menu.picker.setValue(dateSetPicker);
		this.menu.show(this.el, "tl-bl?");
		this.menuEvents('on');
	},

	/**
	* Replaces any existing <tt>{@link #minValue}</tt> with the new value and refreshes the DatePicker.
	* @param {Date} value The minimum date that can be selected
	*/
	setMinValue : function(dt){
		this.minValue = (Ext.isString(dt) ? this.parseDate(dt) : dt);
		if(this.menu){
			this.menu.picker.setMinDate(this.minValue);
		}
	},

	/**
	* Replaces any existing <tt>{@link #maxValue}</tt> with the new value and refreshes the DatePicker.
	* @param {Date} value The maximum date that can be selected
	*/
	setMaxValue : function(dt){
		this.maxValue = (Ext.isString(dt) ? this.parseDate(dt) : dt);
		if(this.menu){
			this.menu.picker.setMaxDate(this.maxValue);
		}
	},

	getValue : function(){
		var result = (this.parseDate(Ext.form.DateField.superclass.getValue.call(this)) || "");
		if(result!="") result = result.add(Date.YEAR,-543);
			return result;
	},

	validateValue : function(value){
		value = this.formatDate(value);
		if(!Ext.form.DateField.superclass.validateValue.call(this, value)){
			return false;
		}
		if(value.length < 1){ // if it's blank and textfield didn't flag it then it's valid
			return true;
		}
		var svalue = value;
		value = this.parseDate(value);
		if(!value){
			this.markInvalid(String.format(this.invalidText, svalue, this.format));
			return false;
		}

		var time = value.getTime();
		var changeMinValue = false;
		if(value > new Date()){
			this.minValue = (this.minValue) ? this.minValue.add(Date.YEAR,-543) : this.minValue;
			changeMinValue = true;
		}
		if(this.minValue && time < this.minValue.getTime()){
			this.markInvalid(String.format(this.minText, this.formatDate(this.minValue)));
			return false;
		}
		if(changeMinValue){
			this.minValue = (this.minValue) ? this.minValue.add(Date.YEAR,543) : this.minValue;
		}

		var changeMaxValue = false;
		if(value > new Date()){
			this.maxValue = (this.maxValue) ? this.maxValue.add(Date.YEAR,543) : this.maxValue;
			changeMaxValue = true;
		}

		if(this.maxValue && time > this.maxValue.getTime()){
			this.markInvalid(String.format(this.maxText, this.formatDate(this.maxValue)));
			return false;
		}
		if(changeMaxValue){
			this.maxValue = (this.maxValue) ? this.maxValue.add(Date.YEAR,-543) : this.maxValue;
		}

		if(this.disabledDays){
			var day = value.getDay();
			for(var i = 0; i < this.disabledDays.length; i++) {
				if(day === this.disabledDays[i]){
					this.markInvalid(this.disabledDaysText);
					return false;
				}
			}
		}
		var fvalue = this.formatDate(value);
		if(this.disabledDatesRE && this.disabledDatesRE.test(fvalue)){
			this.markInvalid(String.format(this.disabledDatesText, fvalue));
		return false;
		}
		return true;
	},

	setValue : function(date){
		return Ext.form.DateField.superclass.setValue.call(this, this.formatDate(this.parseDate(date)));
	}
}) ;