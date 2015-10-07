  function initUIPopover(){
    var selector = ".order_popover";
    $(selector).popover({ html : true });
    $(selector).mouseover(function () {
      $(selector).popover('hide');
    });

  }

  function updateViewSystemSuggestion(){
    $('body').delegate(".stock_on_hand", 'keyup', function(){
      $elm = $(this);
      // updateSystemSuggestion($elm); 
    }).delegate(".stock_on_hand", 'change',function(){
      $elm = $(this);
      // updateSystemSuggestion($elm); 
    })
  }

  function updateSystemSuggestion($elm){
    var ref =  $elm.attr('data-ref'); 
    var object = getOrderLineObject(ref);
    var value = object.systemSuggestion();
    $("#quantity_system_calculation_" + ref).html(value);
  }

  function loadOrderLinesTab(){
    $("#order_site_id").on('change', function(){
       _loadOrderLinesTab();
    });

    $("#order_order_date").on('change', function(){
       _loadOrderLinesTab();
    });
  }


  function _loadOrderLinesTab(){
    var site_id = $("#order_site_id").val();
    var date   = $("#order_order_date").val();
    var order_id = $("#table-order-order-id").val();
    var url = $('#table-order-tab-order-id').val();

    if(!site_id || !date)
      return ;
    showLoading();
    $.ajax({
        url    : url,
        data   : {'site_id' : site_id, 'order_date': date, 'id' : order_id, pp: 'disable'},
        method : 'GET',
        success: function(response){
          $('#order_lines_tab').html(response);
          startupValidation();

        },
        complete: function(){
          hideLoading();
        }
    });
  }

  function initEventValidateField(){
    $('body').delegate(".validate_field", 'keyup', function(){
      validateCriteria($(this).attr("data-ref"));
    }).delegate(".validate_field","change", function(){
      validateCriteria($(this).attr("data-ref"));
    }).delegate(".validate_field", 'focus', function(){
      hidePopup($(this).attr("data-ref"));
    });
  }

  function getOrderLineObject(ref){
    //$datasets =  $("input[data-ref=" + ref + "]");

    var orderLine = {
          commodityName                       : $('#commodity_name_' + ref).val() ,
          commodityId                         : ref,
          siteId                              : $("#site_" + ref).val(),
          arvType                             : $("#arv_type_" + ref ).val(),

          siteSuggestion                      : $("#suggestion_order").val(),
          testKitWasteAcceptable              : $("#test_kit_waste_acceptable").val(),
          orderFrequency                      : $("#order_frequency").val(),

          numberOfClient                      : cleanInput($("#number_of_client_" + ref ).val()),
          consumtionPerClient                 : cleanInput($("#consumption_per_client_per_month_" + ref ).val()) ,
          stockOnHand                         : cleanInput($("#stock_on_hand_" + ref ).val()),
          monthlyUse                          : cleanInput($("#monthly_use_" + ref ).val()),
          quantitySuggested                   : cleanInput($("#quantity_suggested_" + ref ).val()),
          errors                              : {},
          


          errorMessage: function(type){
            var message = "" ;
            if(type == appConfig.typeDrug)
              message = "<b>" + this.commodityName + "</b>: Quantity Suggested is not within " + filter(this.siteSuggestion) + " of population consumption";
            else
              message = "<b>" + this.commodityName + "</b>: Monthly use declared by site is greater than " + filter(this.testKitWasteAcceptable)  + " of acceptable wastage";
            return message;
          },

          hasError: function(){
            console.dir(this.errors)
            var error = false;
            for( prop in this.errors){
              error = true;
              break;
            }
            return error;
          },

          fullErrorMessages: function(){
             return this.errors;
          },

          systemSuggestion : function(){
            consumtion = parseFloat(this.numberOfClient) * parseFloat(this.consumtionPerClient) * parseFloat(this.orderFrequency)
            var systemSuggestion = consumtion - parseFloat(this.stockOnHand)
            return systemSuggestion;
          },

          calQuantitySuggested : function() {
             var systemSuggestion = this.systemSuggestion();
             var cal = 100 * Math.abs( this.quantitySuggested - systemSuggestion) / Math.max(this.quantitySuggested , systemSuggestion) ;
             return formatNumber(cal);
          },

          calQuantityWastage : function(){
            systemSuggestion = this.systemSuggestion();
            return formatNumber( 100 * (this.monthlyUse - systemSuggestion) / systemSuggestion )
          },

          validateQuantitySuggestedAcceptable: function(){
            if(this.stockOnHand && this.quantitySuggested && this.consumtionPerClient  && this.numberOfClient ){
              cal = this.calQuantitySuggested();
              if(cal > parseFloat(this.siteSuggestion)){
                 this.errors["quantity_suggested"] =  "<b>" + this.commodityName + "</b>: Quantity Suggested is not within " + filter(this.siteSuggestion) + " of population consumption" ;
                 return false
              }
            }
          },

          validateWastageAcceptable: function(){
            this.validateField();
            this.validateMonthlyUse();
            
            if(this.stockOnHand  && this.monthlyUse && this.consumtionPerClient  && this.numberOfClient ){
              var cal = this.calQuantityWastage() ;
              if( cal > parseFloat(this.testKitWasteAcceptable)){
                this.errors["wastage"] = "<b>" + this.commodityName + "</b>: Monthly use declared by site is greater than " + filter(this.testKitWasteAcceptable)  + " of acceptable wastage " ;
                return false;
              }
            }
            return true ;
          },

          validateMonthlyUse: function(){
            if(this.invalidNumber(this.monthlyUse)){
              this.errors["monthly_use"] = "<b> Monthly use </b> must be a valid number";
            }

            if(this.consumtionPerClient  && this.numberOfClient ){   
              if(this.monthlyUse == "" && this.stockOnHand ==""){
                return;
              }
              else if(this.stockOnHand != "" && this.monthlyUse == "" ){
                this.errors["monthly_use"] = "<b> Monthly use </b> is required";
              }
              else if (this.stockOnHand == "" && this.monthlyUse != ""){
                this.errors["stock_on_hand"] = "<b> Stock on hand </b> must be a valid number";
              }          
            }
          },

          validateField: function(){
            if(this.orderFrequency == ""){
              this.errors['site'] = 'Please select a valid site';
            }

            if(this.invalidNumber(this.stockOnHand)){
              this.errors["stock_on_hand"] = "<b> Stock on hand </b> must be a valid number";
            }

            if(this.invalidNumber(this.quantitySuggested)){
              this.errros["quantity_suggested"] = "<b> Quantity Suggested </b> must be a valid number";
            }


            if(this.hasError())
              return ;

            if(this.consumtionPerClient  && this.numberOfClient ) {
              if(this.stockOnHand == "" && this.quantitySuggested == ""){
                return ;
              }

              else if(this.stockOnHand == "" && this.quantitySuggested != ""){
                this.errors["stock_on_hand"] = "<b> Stock on hand </b> is required";
              }
              else if(this.stockOnHand != "" && this.quantitySuggested == ""){
                this.errors["quantity_suggested"] = "<b> Quantity Suggested </b> is required";
              }
            }
          },
          invalidNumber: function(field){
            invalid = field != "" && ( isNaN(field) || parseFloat(field)<0 ) ;
            return invalid;
          }
    }
    return orderLine;
  }

  function  validateCriteria(ref){
    var object = getOrderLineObject(ref);
    hidePopup(object.commodityId);

    if(!object.siteId)
      return ;

    if(object.arvType == appConfig.typeDrug){
        object.validateField();
        if(!object.hasError())
          object.validateQuantitySuggestedAcceptable() ;
    }
    else{
       object.validateField();
       object.validateMonthlyUse();
       if(!object.hasError()){
          object.validateQuantitySuggestedAcceptable() ;
          object.validateWastageAcceptable();  
       }  
    }
    if(object.hasError()){
      var fullErrorMessages = object.fullErrorMessages();
      errorMessage  = "";
      for(prop in fullErrorMessages){
        errorMessage += "<li>" + fullErrorMessages[prop] + "</li>";
        
      } 
      showError(object.commodityId, "<ul>" + errorMessage + "</ul>");
    }
    else{
      hideError(object.commodityId)
    }
  }

  function initPopoverContent(){
     for(ref in popover_contents){
       $el = $("#error_" +ref)
       var msg = popover_contents[ref];
       showError(ref, msg);
     }    
  }

  function startupValidation(){
    $rows = $(".order_line_row")
    for(var i=0; i< $rows.length; i++){
      $row = $($rows.get(i));
      var ref = $row.attr("data-ref");
      console.log("ref " + ref  + ": " + i);
      validateCriteria(ref)
    }
  }

  function showError(ref, msg){
    var $el = $("#error_" + ref);
    $el.attr("data-content", msg );
    $el.show();
    $el.popover({ html : true});
    $("#tr_" + ref + " td").addClass("row-error");
  }

  function hideError(ref){
    var $el = $("#error_" + ref);
    $el.hide();
    $el.popover('hide');
    $("#tr_" + ref + " td").removeClass("row-error");

  }

  function hidePopup(ref){
    var $el = $("#error_" + ref);
    $el.popover('hide');
  }

  function cleanInput(str){
    return $.trim(str);
  }
  function formatNumber(cal){
    return cal.toFixed(2);
  }

  function filter(number){
    return "<b>" + number + "% </b>" ;
  }

  $(function(){
    loadOrderLinesTab();
    initEventValidateField();
    updateViewSystemSuggestion();
    // initUIPopover();
    startupValidation();
  });
