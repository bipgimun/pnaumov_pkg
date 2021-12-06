console.log('Under construction!');
/*
var availableTags = [
  "Позиция 0",
  "Позиция 1",
  "Позиция 2",
  "Позиция 3",
  "Позиция 4"
];
*/
var DEBUG = true;
//var prefixURL = "/sn1041";
var prefixURL = ".";

(function () {
   if (DEBUG) { console.log("start sn1041_req script!"); }
   var script = document.createElement('script');

   script.language = 'javascript';
   script.src = prefixURL + "/sn1041/jquery-3.4.1.js";
   script.onload = function () {
      var script = document.createElement('script');
      document.head.appendChild(script);
      script.language = 'javascript';
      script.src = prefixURL + "/sn1041/jquery-migrate-1.4.1.js";
      script.onload = function () {
         var script = document.createElement('script');
         document.head.appendChild(script);
         script.language = 'javascript';
         script.src = prefixURL + "/sn1041/jquery-ui.js";
      }
   }
   document.head.appendChild(script);
   
   initPage();
})();


function initPage() {
   var head = document.getElementsByTagName('head')[0];
   var cssIncl1 = document.createElement('link');
   cssIncl1.href = prefixURL + '/sn1041/jquery-ui.css';
   //cssIncl1.href = './script/jquery-ui.css';
   cssIncl1.type = 'text/css';
   cssIncl1.charset = 'UTF-8';
   cssIncl1.rel = 'stylesheet';
   head.appendChild(cssIncl1);

   if (window.jQuery) jQueryCode();
   else {
      if (DEBUG) { console.log('No JQuery!'); }
      var script = document.createElement('script');
      document.head.appendChild(script);
      script.type = 'text/javascript';
      script.src = prefixURL + "/sn1041/jquery-3.4.1.js";

      script.onload = function () {
         var script = document.createElement('script');
         document.head.appendChild(script);
         script.language = 'javascript';
         script.src = prefixURL + "/sn1041/jquery-migrate-1.4.1.js";
         script.onload = function () {
            var script = document.createElement('script');
            document.head.appendChild(script);
            script.language = 'javascript';
            script.src = prefixURL + "/sn1041/jquery-ui.js";
            script.onload = jQueryCode;
         }
      }
   }

   if (DEBUG) {
      console.log(window.location.pathname);
      console.log('initPage - OK!');
   }
}


var jQueryCode = function () {

   if (DEBUG) { console.log('jQueryCode - Start!'); }

   $(document).click(            
      function () {
         if (DEBUG) { console.log("Click"); }
         highlightNullPriceRows();
      }
   );

   $(document).ready(
      function () {
         
         highlightNullPriceRows();
      }
   );

   
}


function highlightNullPriceRows() {

   var tbl = document.getElementById("Table5:Content");
   //var tbl = $("#'FoundItemsTbl:Content'");
   if (tbl != null) {
      if (DEBUG) { console.log("tbl - found!"); }


      $(tbl).find("[id*='ReqLineId']").each(function () {
		 
		 var reqLineId = $(this).val();
		 if (DEBUG) { console.log("loop-reqLineId = "+reqLineId.length); }
		 
		 if (reqLineId.length > 0){
			if (DEBUG) { console.log("loop-reqLineId(not null) = "+reqLineId); }
		 
			$(this).closest("tr").find("input[name^='Table5:selected']").each(function () {
				if (DEBUG) { console.log("loop-disable chkbox) = "+reqLineId); }
                  $(this).prop("checked", false);
                  $(this).attr("disabled", true);
               });
		 }
      });

   }

   if (DEBUG) {
      console.log("highlightNullPriceRows2 - OK!");
   }
}