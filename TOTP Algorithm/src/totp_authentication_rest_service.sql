function(cfg) {
	console.log(cfg);
	var td = apex.jQuery.apex.interactiveGrid.copyDefaultToolbar(), 
	sg = td.toolbarFind("search"),
	a1g = td.toolbarFind("actions1"),
	a2g = td.toolbarFind("actions2"),
	a3g = td.toolbarFind("actions3"),
	a4g = td.toolbarFind("actions4");
	console.log(td);
	sg.controls = [];
	a3g.controls = [];
	a4g.controls = [];
	sg.controls.push(a1g.controls.pop());
	ub = {
            type: "BUTTON",
            hot: false,
            action: "bulk-upload"
        };
	flb = {
            type: "BUTTON",
            hot: false,
            action: "fy-lov",
			id: "nb0lUr4FUd0dJDWMU7sA"
        };
	sb = {
            type: "BUTTON",
            hot: false,
            action: "grid-submit"
        };
	rb = {
            type: "BUTTON",
            hot: false,
            action: "grid-refresh"
        };
	ab = {
            type: "BUTTON",
            hot: true,
            action: "bulk-approve"
        };
	rjb = {
            type: "BUTTON",
            hot: true,
            action: "bulk-reject"
        };
	svc=a2g.controls.pop();
	a2g.controls.pop();
	a3g.controls.push(sb);
	a3g.controls.push(svc);
	a3g.controls.push(rb);	
	a4g.controls.push(ab);
	a4g.controls.push(rjb);
	a1g.controls.push( flb );
	a2g.controls.push( ub );
	cfg.initActions = function(act) {
console.log(act.list());
		var save = act.lookup("save");
		save.id="piF8k7FWl1JgjbkrfPMS";
        act.add({
            name: "bulk-upload",
            labelKey: "NTXZYB3HL4ZDXWX5C5BZ",
			iconBeforeLabel: true,
            action: function(){ 
				var d=new Date();
				d.setMonth(d.getMonth()-3);
			    var chk=((d.getFullYear().toString())<=($("#YZUODBTD6ASWXUNVRLCC").val()).split("-")[0]);
				if(chk){ 
					$("#zsYQa6SFShPFFHOb51wY").trigger('click');
				}
				else{
					apex.message.alert("Bulk budget upload is not available for past financial years!");
				}
			}
        });
		act.add({
            name: "fy-lov",
            labelKey: "TMXUH1AL55OHLTEIPU1R",
			iconBeforeLabel: true,
            action: function(){
				$('#YZUODBTD6ASWXUNVRLCC_lov_btn').trigger('click');
			}        
        });
		act.add({
            name: "grid-submit",
            labelKey: "QRPIEYVWN1DA9HFT7BS6",
			iconBeforeLabel: true,
            action: function(){
			    var d=new Date();
				d.setMonth(d.getMonth()-3);
				var chk=((d.getFullYear().toString())<=($("#YZUODBTD6ASWXUNVRLCC").val()).split("-")[0]);
				if(chk){ 
					apex.message.confirm( "Do you want to submit?", function( okPressed ) {
						if( okPressed ) {
							$("button[data-action='save']").trigger('click');					
							submit_for_approval();	    
							var m = apex.region("EUUp9KMQFjpEkGWIi8tf").widget().interactiveGrid("getViews").grid.model; 
							window.setTimeout(function(){ m.fetch();},200);		
						}
					});
				}
				else{
					apex.message.alert("Budget cannot be submitted for past financial years!");
				} 				
			}        
        });	
		act.add({
            name: "grid-refresh",
            label: "Refresh",
			iconBeforeLabel: true,
            action: function(){
				act.invoke("selection-revert");								
			}        
        });	
		act.add({
            name: "bulk-approve",
            label: "Approve",
			iconBeforeLabel: true,
            action: function(){
			    processTransaction('HWM_WORKFORCE_BUDGET','Approve',$('#OLMPWBBAUMQHNQXGCVUY').val());
				$('#OLMPWBBAUMQHNQXGCVUY').val('');							
			}        
        });	
		
		act.add({
            name: "bulk-reject",
            label: "Reject",
			iconBeforeLabel: true,
            action: function(){
				processTransaction('HWM_WORKFORCE_BUDGET','Reject',$('#OLMPWBBAUMQHNQXGCVUY').val());
				$('#OLMPWBBAUMQHNQXGCVUY').val('');							
			}        
        });	
    };
	cfg.toolbarData = td; 
	if (!cfg.toolbar) {
		cfg.toolbar = {};
	}
	return cfg;
}