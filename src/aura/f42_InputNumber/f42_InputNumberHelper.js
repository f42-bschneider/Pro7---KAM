({
	handleChange: function(component, helper) {
		if(component.isValid()){
			var required 	= component.get("v.required"),
			min 			= component.get("v.min"),
			max 			= component.get("v.max"),
			isInteger 		= component.get("v.isInteger"),
			value 			= component.get("v.value"),
			input 			= component.find("inputNumber"),
			decimalPlaces		= component.get("v.decimalPlaces"),
			replaceNull		= component.get("v.replaceNull"),
			errors 			= [];

			if(input.isValid()){
				input.set("v.errors", null);

				component.set("v.isValid", true);

				if(value === null && replaceNull){
					component.set("v.value", 0);
					value = 0;
				}

				if(typeof value == 'undefined' || value === '' || value === null){
					if(required){
						errors.push({"message":"Complete this field"});
						component.set("v.isValid", false);
					}
				}else if(!isNaN(value) && value !== null){
					if(typeof min !== 'undefined' && typeof max !== 'undefined'){
						if(!(value >= min && value <= max)){
							errors.push({"message":"Allowed range: "+ min + " to " + max});
							component.set("v.isValid", false);
						}
					}else if(typeof min !== 'undefined'){
						if(value < min){
							errors.push({"message":min+" is the minimum"});
							component.set("v.isValid", false);
						}
					}else if(typeof max !== 'undefined'){
						if(value > max){
							errors.push({"message":max+" is the maximum"});
							component.set("v.isValid", false);
						}
					}

					if(value !== null){
						if(isInteger && value.toString().indexOf(".") !== -1){
							errors.push({"message":"Integers only"});
							component.set("v.isValid", false);
						}

						if(typeof decimalPlaces != 'undefined' && decimalPlaces > 0 && !isInteger){
							component.set("v.value", parseFloat(parseFloat(value).toFixed(decimalPlaces)));
						}
					}
				}else {
					errors.push({"message":"Invalid number"});
					component.set("v.isValid", false);
				}

				input.set("v.errors", errors);
			}
		}
	}
})