
function init() {
	var radios = ['comparison_by_dates', 'comparison_by_periods'];
	var current;
	while (radios.length) {
		var radio_id = radios.shift();
		var radio = document.getElementById(radio_id);
		radio.addEventListener('click', 
			function(e){
				var my_id = this.getAttribute('id');
				show_hide_details(my_id);
				return true;
			}, false);
		if (radio.checked) current = radio_id;
	}
	var periods = document.getElementById('comparison-periods');
	periods.addEventListener('input', 
		function(e){
			var my_id = this.getAttribute('id');
			show_hide_details(my_id);
			return true;
		}, false);
	show_hide_details(current);
}

function show_hide_details(type_id){
	var e_id = "comparison_dates";
	var e = document.getElementById(e_id);

	if (type_id != "comparison-periods") {
		e.style = type_id == "comparison_by_dates" ? "" : "display:none";
	} else {
		var c = document.getElementById('comparison-periods').value;
		document.getElementById('comparison_periods_text').innerHTML = c;

		for ( i = 1 ; i <= 9 ; i++ ) {
			var ei_id = e_id + "_" + i;
			var p_ei_id = document.getElementById(ei_id);
			if ( p_ei_id ) {
				p_ei_id.style = i <= c ? "" : "display:none";
			}
		}
	}
	return true;
}
