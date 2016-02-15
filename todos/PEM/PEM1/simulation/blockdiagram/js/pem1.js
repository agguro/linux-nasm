var clockpuls = 0;
var opcode = "null";

// JQuery extension to set, reset, invert, disable and enable
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
 $.fn.extend({ 
      disable: function() {
           return this.each(function() {
                $(this).attr("disabled","disabled");
           });
      }
 });
 $.fn.extend({ 
      enable: function() {
           return this.each(function() {
                $(this).removeAttr("disabled");
           });
      }
 });
})(jQuery);

$(document).ready(function(){
     // FIRST ACTION: CLEAR
     $("button#bttnclear").click(function () {
          $(".active").reset();
          $("button#bttnstart").enable();
          $("button#bttnclock").disable();
          $(".clear,#pc,#ir,#con,#busir2con,#busctrllines").set();
          clockpuls=0;
          opcode=null;
     });
     
     // SECOND ACTION: START
     $("button#bttnstart").click(function () {
          $("button#bttnstart").disable();
          $(".active,.clear").reset();
          $("#t0,#hlt,#con,#busctrllines,.ctrlep,.ctrllm").set();
          $("button#bttnclock").enable();
     });
     
     // THIRD ACTION: SELECT OPCODE, IS EITHER "HLT" OR A CHOOSEN OPCODE
     $(".topc,.opc").click(function () {
          $(".topc,.opc").reset();
          var opcode = $(this).attr("id").slice(-3);
          $("#"+opcode+",#remark"+opcode).set();
     });
     
     // FOURTH (FINAL AND MANUAL) ACTION: THE CLOCKCYCLES
     // each click simulates a half clockcycle
     $("button#bttnclock").click(function () {
          clockpuls++;                //add clockcycle
                  // get opcode
                          opcode = $(".topc.active").attr("id");
                          $(".clear").reset();
                          $(".clock").invert();
                          var t = ($(".tctrl.active").attr("id")).slice(-1);
                          var tnext = parseInt(t)+1;
                          if((clockpuls % 2)=== 0){
                               $("#t"+t).reset();
                               $("#t"+tnext).set();
                          }
                                  switch(clockpuls){
                                       case 1 :
                                            $("#pc,#mar,#buspc2wbus,#buswbus2mar,#busmar2prom,#prom,#wbus").set();
                                            break;
                                       case 2 :
                                            $(".ctrlep,.ctrllm,#pc,#mar,#buspc2wbus,#buswbus2mar,#busmar2prom,#prom,#wbus").reset();
                                            $(".ctrler,.ctrlli").set();
                                            break;
                                       case 3 :
                                            $("#mar,#busmar2prom,#prom,#ir,#busprom2wbus,#buswbus2ir,#busir2con,#wbus").set();
                                            break;
                                       case 4 :
                                            $(".ctrler,.ctrlli,#mar,#busmar2prom,#prom,#ir,#busprom2wbus,#buswbus2ir,#busir2con,#wbus").reset();
                                            $(".ctrlcp").set();
                                            break;
                                       case 5 :
                                            $("#pc").set();
                                            break;
                                       case 6 :
                                            $(".ctrlcp,#pc").reset();
                                            switch(opcode){
                                                 case "hlt":
                                                      alert("einde simulatie opcode HLT");
                                                      window.location.reload(true);
                                                      break;
                                                 case "lda":
                                                 case "add":
                                                 case "sub":
                                                      $(".ctrllm,.ctrlei").set();
                                                      break;
                                                 case "out":
                                                      $(".ctrlea,.ctrllo").set();
                                                      break;
                                            }
                                                            break;
                                                 case 7 :
                                                      switch(opcode){
                                                           case "lda":
                                                           case "add":
                                                           case "sub":
                                                                $("#mar,#prom,#busmar2prom,#ir,#wbus,#buswbus2mar,#busir2wbus,#busir2con").set();
                                                                break;
                                                           case "out":
                                                                $("#busaccu2alu,#accu,#busaccu2wbus,#wbus,#buswbus2out,#outreg,#busout2d,#bin").set();
                                                                break;
                                                      }
                                                                      break;
                                                           case 8 :
                                                                switch(opcode){
                                                                     case "lda":
                                                                          $(".ctrllm,.ctrlei,#mar,#prom,#busmar2prom,#ir,#buswbus2mar,#wbus,#busir2wbus,#busir2con").reset();
                                                                          $(".ctrler,.ctrlla").set();
                                                                          break;
                                                                     case "add":
                                                                     case "sub":
                                                                          $(".ctrllm,.ctrlei,#mar,#prom,#busmar2prom,#ir,#buswbus2mar,#wbus,#busir2wbus,#busir2con").reset();
                                                                          $(".ctrler,.ctrllb").set();
                                                                          break;
                                                                     case "out":
                                                                          $(".ctrlea,.ctrllo,#busaccu2alu,#accu,#busaccu2wbus,#wbus,#buswbus2out,#outreg,#busout2d,#bin").reset();
                                                                          break;
                                                                }
                                                                                break;
                                                                     case 9 :
                                                                          switch(opcode){
                                                                               case "lda":
                                                                                    $("#prom,#busprom2wbus,#wbus,#buswbus2accu,#accu,#busaccu2alu").set();
                                                                                    break;
                                                                               case "add":
                                                                               case "sub":
                                                                                    $("#prom,#busprom2wbus,#wbus,#buswbus2breg,#breg,#busbreg2alu").set();
                                                                                    break;
                                                                          }
                                                                                          break;
                                                                               case 10 :
                                                                                    switch(opcode){
                                                                                         case "lda":
                                                                                              $(".ctrler,.ctrlla,#prom,#busprom2wbus,#wbus,#buswbus2accu,#busaccu2alu").reset();
                                                                                              break;
                                                                                         case "add":
                                                                                         case "sub":
                                                                                              $(".ctrler,.ctrllb,#prom,#busprom2wbus,#wbus,#buswbus2breg,#breg,#busbreg2alu").reset();
                                                                                              $(".ctrleu,.ctrlla").set();
                                                                                              break;
                                                                                    }
                                                                                                    break;
                                                                                         case 11 :
                                                                                              switch(opcode){
                                                                                                   case "lda":
                                                                                                        alert("einde simulatie opcode LDA");
                                                                                                        window.location.reload(true);
                                                                                                        break;
                                                                                                   case "add":
                                                                                                   case "sub":
                                                                                                        $("#alu,#busalu2wbus,#wbus,#buswbus2accu,#accu,#busaccu2alu,#breg,#busbreg2alu").set();
                                                                                                        break;
                                                                                              }
                                                                                                              break;
                                                                                                   case 12 :
                                                                                                        alert("einde simulatie opcode "+ opcode.toUpperCase());
                                                                                                        window.location.reload(true);
                                                                                                        break;
                                  }
     });
});
