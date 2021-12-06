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
var endOfLine = "{-}";
var availableTagsProxy = [];
var DEBUG = true;
//var prefixURL = "/sn1041";
var prefixURL = ".";

(function () {
   if (DEBUG) { console.log("start sn1041 script!"); }
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
})();

var jQueryCode = function () {

   if (DEBUG) { console.log('jQueryCode - Start!'); }

   $('#SearchTextInput').width(300);

   $('#SearchTextInput').autocomplete({
      http: true,
      source: function (req, resp) {
         callProxy(resp)
      },
      search: function () {
      },
      minLength: 2
   });

   //$('#SearchTextInput').autocomplete('disable');
   if ($('#cbElasticEnabled').is(':checked')) {
      if (DEBUG) { console.log("is checked = true"); }
      $('#SearchTextInput').autocomplete('enable');
   } else {
      if (DEBUG) { console.log("is checked = false"); }
      $('#SearchTextInput').autocomplete('disable');
   }

   $("#cbElasticEnabled").change(function () {
      if (DEBUG) { console.log("checked = " + this.checked); }
      if (this.checked) {
         $('#SearchTextInput').autocomplete('enable');
      } else {
         $('#SearchTextInput').autocomplete('disable');
      }
   });

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

function callProxy(pResp) {
   var searchString = $('#SearchTextInput').val();
   if (DEBUG) { console.log("searchString = " + searchString); }

   var store = $('#fvStore').val();
   if (store != undefined) {
      var idx = store.indexOf(endOfLine);
      var storeId = store.substr(0, idx);
   }
   if (DEBUG) { console.log("storeId = " + storeId); }

   var orgIdFV = $('#fvOrgId').val();
   if (orgIdFV != undefined) {
      var idx2 = orgIdFV.indexOf(endOfLine);
      var orgId = orgIdFV.substr(0, idx2);
   }
   if (DEBUG) { console.log("orgId = " + orgId); }


   var requestData = '{\"searchString\":\"' + searchString.replace('"','&quot;').replace('\\','\\\\')
      + '\",\"storeId\":\"' + storeId
      + '\",\"orgId\":\"' + orgId
      + '\"' + '}';
   if (DEBUG) { console.log("requestData = " + requestData); }

   var servletUrl = $('#fvSrvUrl').val();
   var idx1 = servletUrl.indexOf(endOfLine);
   var servletUrl1 = servletUrl.substr(0, idx1);
   if (DEBUG) { console.log("servletUrl1 = " + servletUrl1); }

   var availableTags = [];

   $.ajax({
      url: servletUrl1,
      crossDomain: true,
      method: 'POST',
      processData: true,
      data: requestData,
      //dataType: 'json',
      //contentType: 'application/json',
      success: function (retData, status) {
         if ('success' === status) {
            if (DEBUG) {
               console.log('Ajax - успешно');
               console.log(retData);
            }

            $.each(retData, function (i, obj) {
               availableTags[i] = obj.descr;
            });

            pResp(availableTags);
         }
         else {
            if (DEBUG) { console.log('Ajax - ошибка!!!'); }
         }
      },
      error: reportError
   });
}

function reportError(request, status, errorMsg) {
   if (DEBUG) { console.log("Status: " + status + " Error Message: " + errorMsg); }
}

function highlightNullPriceRows() {

   var tbl = document.getElementById("FoundItemsTbl:Content");
   //var tbl = $("#'FoundItemsTbl:Content'");
   if (tbl != null) {
      if (DEBUG) { console.log("tbl - found!"); }


      $(tbl).find("[id*='PriceMST']").each(function () {
         var price = $(this).text();

         var durtyIndexName = $(this).closest('td').find("[id*='IndexNameMST']").first().val();
         if (durtyIndexName.indexOf('positions_oebs') >= 0) {
            console.log("durtyIndexName  found! " + durtyIndexName);

            if (price == null || price == "") {
               $(this).closest("tr").find("span").each(function () {
                  $(this).css({ "color": "red" });
               });
               $(this).closest("tr").find("input[name^='FoundItemsTbl:selected']").each(function () {
                  $(this).prop("checked", false);
                  $(this).attr("disabled", true);

               });

            } else if (price != null && price == 0) {
               $(this).css("color", "red");
               $(this).closest("tr").find("span").each(function () {
                  $(this).css({ "color": "red" });
               });
               $(this).closest("tr").find("input[name^='FoundItemsTbl:selected']").each(function () {
                  $(this).prop("checked", false);
                  $(this).attr("disabled", true);
               });
            }
         }
      });

   }

   if (DEBUG) {
      console.log("highlightNullPriceRows - OK!");
   }
}