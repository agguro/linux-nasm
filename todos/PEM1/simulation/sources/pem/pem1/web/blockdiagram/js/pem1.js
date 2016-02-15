var clocks = 1;
var opcode = "null";

// JQuery uitbreiding voor setten en resetten van de individuele html tags
(function($){
    $.fn.extend({ 
        set: function() {
            return this.each(function() {
                $(this).addClass("active");
            });
        }
    }),

    $.fn.extend({ 
        reset: function() {
            return this.each(function() {
                $(this).removeClass("active");
            });
        }
    }),
    $.fn.extend({ 
        invert: function() {
            return this.each(function() {
                $(this).toggleClass("active");
            });
        }
    });
})(jQuery);

$(document).ready(function(){
    // keuze van de opcode, initieel staat deze op HLT
    $(".topc,.opc").click(function () {
        $(".topc,.opc").reset();
        var opcode = $(this).attr("id").slice(-3);
        $("#"+opcode+",#remark"+opcode).set();
    });
	
    // eerste actie, clear
    $("button#start").click(function () {
        $(".active,.clear").reset();
        $("#t0,#hlt,#con,#busctrllines,.ctrlep,.ctrllm").set();
        $("button#clock").removeAttr("disabled");
    });        
    // manuele clock bediening
    $("button#clock").click(function () {
        // opcode is initieel HLT of een gekozen opcode
        opcode = $(".topc.active").attr("id");
        $(".clear").reset();
        $(".clock").invert();
        if($(".tctrl.active")[0]){
            clocks++;
            if(clocks===2){clocks=0;};
            var t = ($(".tctrl.active").attr("id")).slice(-1);
            var tnext = parseInt(t)+1;
            if(clocks===1){
                // dalende klokflank //
                $("#t"+t).reset();
                $("#t"+tnext).set();
                switch(tnext){
                    /* adresfase */						
                    case 0 :
                        $(".ctrlep,.ctrllm").set();
                        break;
                    /* geheugenfase */
                    case 1 :
                        $(".ctrlep,.ctrllm").reset();
                        $(".ctrler,.ctrlli").set();
                        break;
                    /* incrementeerfase */					
                    case 2 :
                        $(".ctrler,.ctrlli").reset();
                        $(".ctrlcp").set();						
                        break;
                    /* eerste uitvoeringsfase */
                    case 3 :
                        $(".ctrlcp").reset();
                        if(opcode==="lda" || opcode==="add" || opcode==="sub"){
                            $(".ctrllm,.ctrlei").set();
                        }else{
                            if(opcode==="out"){
                                $(".ctrlea,.ctrllo").set();
                            }else{ //HLT
                                $("button#clock").attr("disabled","disabled");
                                $("#t0").set();
                                $("#t3").reset();
                                if(!(alert("einde simulatie " + opcode.toUpperCase()))){window.location.reload(true);};
                            }
                        }
                        break;
                     /* tweede uitvoeringsfase */   
                    case 4 :
                        if(opcode==="lda" || opcode==="add" || opcode==="sub"){
                            $(".ctrllm,.ctrlei").reset();
                            $(".ctrler").set();
                            if(opcode==="lda"){
                                $(".ctrlla").set();
                            }else{
                                $(".ctrllb").set();
                            }
                        }else{
                            $(".ctrlea,.ctrllo").reset();
                        }
                        break;
                    /* derde uitvoeringsfase */
                    case 5 :
                        $(".ctrler").reset();
                        if(opcode==="lda"){
                            $(".ctrlla").reset() ;
                        }else{
                            if(opcode==="add" || opcode==="sub"){
                                $(".ctrlla,.ctrleu").set();
                                $(".ctrllb").reset();
                                if(opcode==="sub"){
                                    $(".ctrlsu").set();
                                }
                            }
                        }
                        break;
                     /* einde simulatie */   
                    case 6 :
                        $("button#clock").attr("disabled","disabled");
                        $("#t0").set();
                        if(!(alert("einde simulatie " + opcode.toUpperCase()))){window.location.reload(true);};
                        break;
                };
            }else{
                // rijzende klokflank
                $("#wbus").set();
                switch(tnext){
                   /* adresfase */	 					
                   case 1 :
                       $("#pc,#buspc2wbus,#mar,#busmar2prom,#buswbus2mar").set();
                       break;
                   /* geheugenfase */
                   case 2 :
                       $("#pc,#buspc2wbus,#buswbus2mar").reset();
                       $("#mar,#busmar2prom,#prom,#busprom2wbus,#ir,#busir2con,#buswbus2ir").set();
                       break;
                   /* incrementeerfase */					
                   case 3 :
                       $("#mar,#busmar2prom,#prom,#busprom2wbus,#ir,#busir2con,#buswbus2ir,#wbus").reset();
                       $("#pc").set();
                       break;
                   /* eerste uitvoeringsfase */
                   case 4 :
                       $("#ir,#busir2con").set();
                       $("#pc").reset();
                       if(opcode==="out"){
                           $("#accu,#busaccu2alu,#busaccu2wbus,#outreg,#busout2d,#bin,#buswbus2out").set();
                       }else{ // HLT
                           $("#mar,#busmar2prom,#buswbus2mar,#busir2wbus").set();
                       }
                       break;
                   case 5 :
                       $("#ir,#busir2con").set();
                       if(opcode==="lda" || opcode==="add" || opcode==="sub"){
                           $("#mar,#busmar2prom,#prom,#busprom2wbus").set();
                           $("#buswbus2mar,#busir2wbus").reset();
                           if(opcode==="lda"){
                               $("#accu,#busaccu2alu,#buswbus2accu").set();
                           }else{// ADD en SUB
                               $("#breg,#busbreg2alu,#buswbus2breg").set();
                           }    
                       }else{// OUT
                           $("#busaccu2wbus,#buswbus2out,#wbus,#accu,#busaccu2alu").reset();
                       };
                       break;
                   case 6 :
                       $("#ir,#busir2con").set();
                       if(opcode==="lda"){
                           $("#mar,#busmar2prom,#prom,#busprom2wbus,#alu,#busalu2wbus,#accu,#busaccu2alu,#buswbus2accu").reset();
                       }else{
                            if(opcode==="add" || opcode==="sub"){
                                $("#breg,#busbreg2alu,#alu,#busalu2wbus,#accu,#busaccu2alu,#buswbus2accu").set();
                                $("#mar,#busmar2prom,#prom,#busprom2wbus,#buswbus2breg").reset();
                            }else{// OUT
                                $("#wbus").reset();
                            }
                        }
                       break;
               };
            };
        };
    });
});
