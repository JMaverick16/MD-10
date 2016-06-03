#
# secondary mfd engine panel
# jylebleu
#

var engN2Rpm = {
	R:82,
	MaxRpm:105,
	MaxAngle:210,
	StrokeColor:"rgba(255,255,255,1)",
	MaxColor:"rgba(255,0,0,1)",
	FillColor:"rgba(127,127,127,1)",
	x:0,
	y:0,
	indicator:{},
	label: {},

        new : func(group,x,y,name) {
		var m = { parents: [engN2Rpm] };
		m.x = x;
		m.y = y;
		m.indicator = group.createChild("path");
		m.label = group.getElementById(name);
		m.drawScale(group);
		return m;
	},

	drawScale : func(group) {
		var n2angleRad = -(me.MaxAngle * math.pi)/180;
		var cx = math.cos(n2angleRad)*me.R -me.R;
		var cy = -math.sin(n2angleRad)*me.R;
            
		group.createChild("path")
		.setStrokeLineWidth(4)
		.moveTo(me.x, me.y)
		.arcLargeCW(me.R, me.R, 0,  cx, cy)
		.set("stroke", me.StrokeColor);
    
		group.createChild("path")
		.setStrokeLineWidth(4)
		.moveTo(me.x+cx,me.y+cy)
		.line(-27,-16)
		.set("stroke", me.MaxColor);
	},

	update: func(n2rpm) {	
		var n2r=1;
		if (n2rpm!=nil) {
			n2r=n2rpm;
		}
		var n2angle=(-me.MaxAngle/me.MaxRpm)*n2r;
		var n2angleRad = (n2angle * math.pi)/180;
		var cx = math.cos(n2angleRad)*me.R -me.R;
		var cy = -math.sin(n2angleRad)*me.R;
		me.indicator.reset()
		.setStrokeLineWidth(4)
		.set("stroke", me.StrokeColor)
		.moveTo(me.x, me.y);
		if (cy < 0) {
			me.indicator.arcLargeCW(me.R, me.R, 0,  cx, cy);
		} else {
			me.indicator.arcSmallCW(me.R, me.R, 0,  cx, cy);
		}
		me.indicator
		.lineTo(me.x-me.R,me.y)
		.lineTo(me.x,me.y)
		.set("fill",me.FillColor);

		me.label.setText(sprintf("%2.2f",n2rpm));
	}
}; # End of engN2Rpm
    
var indicator = {
	linearFactor : 1.0,
	LimitColor:"rgba(255,0,0,1)",
	CautionColor:"rgba(212,170,0,1)",
	NormalColor:"rgba(255,255,255,1)",
	minDisplayed : 35,
	maxDisplayed : 148,
	minOperating : 50,
	maxOperating : 130,
	minLimit:0,
	maxLimit:999,
	valueLabel : {},
	pointer : {},

	new : func(group,rootname,linearFactor) {
		var m = { parents: [indicator] };
		m.valueLabel = group.getElementById(rootname);
		m.pointer = group.getElementById(rootname~"Cursor");
		m.linearFactor = linearFactor;
		return m;
        },

	setDisplayRange : func(min,max) {
		me.minDisplayed = min;
		me.maxDisplayed = max;
	},

        setOperatingRange : func(min,max) {
		me.minOperating = min;
		me.maxOperating = max;
	},

	setLimits : func(min,max) {
		me.minLimit = min;
		me.maxLimit = max;
        },

	inRange : func(value) {
		var val=(me.maxOperating-me.minOperating)/2+me.minOperating;
		if (value!=nil) {
			val=value;
		}
		return (val > me.minOperating and val < me.maxOperating);
        },

	inCaution : func(value) {
		var val=(me.maxOperating-me.minOperating)/2+me.minOperating;
		if (value!=nil) {
			val=value;
		}
		return (val <= me.minOperating or val >= me.maxOperating);
        },

	inLimit : func(value) {
			var val=(me.maxOperating-me.minOperating)/2+me.minOperating;
			if (value!=nil) {
				val=value;
			}
		return (val <= me.minLimit or val >= me.maxLimit);
		}, updateColor : func(color) {
		me.pointer.set("stroke", color);
		me.pointer.set("fill", color);
		me.valueLabel.set("fill", color);
	},

        update : func(value) {
		var val=(me.maxOperating-me.minOperating)/2+me.minOperating;
		if (value!=nil) {
			val=value;
		}
		if (me.inRange(val)) me.updateColor(me.NormalColor);			
		if (me.inCaution(val)) me.updateColor(me.CautionColor);
		if (me.inLimit(val)) me.updateColor(me.LimitColor);

		me.valueLabel.setText(sprintf("%3.0f",val));
		var tempForCursorPos = val; 
		if (val > me.maxDisplayed) tempForCursorPos = me.maxDisplayed;
		if (val < me.minDisplayed) tempForCursorPos = me.minDisplayed;
		me.pointer.setTranslation(0,-me.linearFactor*(tempForCursorPos-me.minDisplayed));
	}
}; # End of indicator

var oilTemperatureIndicator = {

	new : func(group,engineNb) {
		var m = indicator.new(group,"eng"~engineNb~"OilTemperature",1.0);
		m.setDisplayRange(35,148);
		m.setOperatingRange(50,130);
		m.setLimits(-999,148);
		return m;
	}
}; # End of oilTemperatureIndicator

var oilPressureIndicator = {

	new : func(group,engineNb) {
		var m = indicator.new(group,"eng"~engineNb~"OilPressure",2.0);
		m.setDisplayRange(2,58);
		m.setOperatingRange(10,58);
		m.setLimits(2,999);
		return m;
	}
}; # End of oilPressureIndicator

var canvas_eng = {
	eng0n2rpm: {},
	eng1n2rpm: {},
	eng2n2rpm: {},
	eng0fuelFlowPph: {},
	eng1fuelFlowPph: {},
	eng2fuelFlowPph: {},
	eng0OilTempIndic: {},
	eng1OilTempIndic: {},
	eng2OilTempIndic: {},
	eng0OilPressureIndic : {},
	eng1OilPressIndic : {},
	eng2OilPressIndic : {},
	eng0OilQuantity : {},
	eng1OilQuantity : {},
	eng2OilQuantity : {},

	new : func(canvas_group) {
		var m = { parents: [canvas_eng, MfDPanel.new("eng",canvas_group,"Aircraft/MD-10/Models/Flightdeck/Instruments/Center-mfd/eng.svg",canvas_eng.update)] };
		m.context = m;
		m.initSvgIds(m.group);
		return m;
	},

	initSvgIds: func(group) {
		me.eng0fuelFlowPph = group.getElementById("eng0fuelFlowPph");
		me.eng1fuelFlowPph = group.getElementById("eng1fuelFlowPph");
		me.eng2fuelFlowPph = group.getElementById("eng2fuelFlowPph");
		me.eng0n2rpm = engN2Rpm.new(group,273,165,"eng0N2");
		me.eng1n2rpm = engN2Rpm.new(group,518,165,"eng1N2");
		me.eng2n2rpm = engN2Rpm.new(group,763,165,"eng2N2");

		me.eng0OilTempIndic = oilTemperatureIndicator.new(group,0);
		me.eng1OilTempIndic = oilTemperatureIndicator.new(group,1);
		me.eng2OilTempIndic = oilTemperatureIndicator.new(group,2);

		me.eng0OilPressIndic = oilPressureIndicator.new(group,0);
		me.eng1OilPressIndic = oilPressureIndicator.new(group,1);
		me.eng2OilPressIndic = oilPressureIndicator.new(group,2);

		me.eng0OilQuantity = group.getElementById("eng0OilQuantity");
		me.eng1OilQuantity = group.getElementById("eng1OilQuantity");
		me.eng2OilQuantity = group.getElementById("eng2OilQuantity");
	},

	update: func() {
		me.eng0n2rpm.update(getprop("engines/engine[0]/n2"));
		me.eng1n2rpm.update(getprop("engines/engine[1]/n2"));
		me.eng0OilTempIndic.update(getprop("engines/engine[0]/oilt-norm"));
		me.eng1OilTempIndic.update(getprop("engines/engine[1]/oilt-norm"));
		me.eng0OilPressIndic.update(getprop("engines/engine[0]/oilp-norm"));
		me.eng1OilPressIndic.update(getprop("engines/engine[1]/oilp-norm"));
		me.eng0fuelFlowPph.setText(sprintf("%1.1f",getprop("engines/engine[0]/fuel-flow_pph")));
		me.eng1fuelFlowPph.setText(sprintf("%1.1f",getprop("engines/engine[1]/fuel-flow_pph")));
#		me.eng0OilQuantity.setText(sprintf("%2.0f",getprop("engines/engine[0]/oil-quantity")));
#		me.eng1OilQuantity.setText(sprintf("%2.0f",getprop("engines/engine[1]/oil-quantity")));
	}
}; # End of canvas_eng
