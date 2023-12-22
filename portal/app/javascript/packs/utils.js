/**
 * Listen to turbolinks request-start event
 *
 * @type {HTMLElement} - the target of the event
 * @Listens document#turbolinks:request-start
 * @description This event get fired before Turbolinks issues a network request to fetch the page.
 * In this event we are replacing the main content with the loader and
 * hiding it until 200ms to avoid the loader display for small content load
 * Ref: https://github.com/turbolinks/turbolinks#full-list-of-events
 *
 */
$(document).on('turbolinks:request-start', function() {
  $('.show-overlay').remove();
  $('main.main-container .main-content').html($('.loader-content'));
  $('main.main-container .main-content .loader-content').hide();

  setTimeout(function(){
    $('main.main-container .main-content .loader-content').show();
  }, 200);
});

$(window).on('popstate', function(event) {
  window.location.reload();
});

$(document).on('shown.bs.tab', 'a[data-toggle="pill"]', function (e) {
  $('.show-overlay').remove();
  $('.content_scroller').css('overflow', 'auto');
  $('.content_scroller').css('overflow', 'hidden');
});

$(document).on('shown.bs.modal', '#status_change_history_modal', function() {
  $('.content_scroller').niceScroll({ spacebarenabled: false });
});
var qi = qi || {};

qi.logoutPath = "/logout";

qi.Utility = {
  idleTime: 0,
  showTimer: false,
  counterTimeLimit: 120,
  counterTime: 120,
  idleTimeThreshold: 780,

  incrementIdleTime: function(){

   if( $('body').hasClass('login') )  {
    qi.Utility.idleTime ++;

    if (qi.Utility.idleTime > qi.Utility.idleTimeThreshold) {
      qi.Utility.showTimer = true;

      if ($(".logout-modal-confirm").length == 0) {
        var timerContent = '';

        if(qi.Utility.showTimer) {
          setInterval(qi.Utility.setCounterTime, 1000)
          var min = Math.floor(qi.Utility.counterTime / 60)
          var sec = Math.floor(qi.Utility.counterTime % 60)
          timerContent = '<b><p class="session-timeout-time"><span id="session-timeout-timer" class="session-timeout-timer">' + min + ' minutes ' + '</span> <span class="unit"></span></p></b>';
        }

        var popupContent = '<div>\
                              <div class="modal-body text-center">\
                                <p>Your session is about to expire in</p>' + timerContent + ' Please click "Continue" to keep working\
                              </div>\
                              <div class= "modal-footer justify-content-center border-0">\
                                <button name="button" type="submit" class="btn btn-primary" data-dismiss="modal">Continue</button>\
                                <a rel="nofollow" class="btn btn-secondary" data-method="delete" href="/logout">Sign Out</a>\
                              </div>\
                            </div>';

        qi.Utility.showModal("Are you still here?", popupContent, 'modal-md logout-modal-confirm');
      }

      if (qi.Utility.idleTime > qi.Utility.idleTimeThreshold + qi.Utility.counterTimeLimit) {
        qi.Utility.showTimer = false;
        $.ajax({ url: '/logout', type: 'DELETE' });
      }
    }
  }
  },

  setCounterTime: function() {
    if (qi.Utility.counterTime > 1) {
      qi.Utility.counterTime = qi.Utility.counterTime - 1;
      var min = Math.floor(qi.Utility.counterTime / 60)
      var sec = Math.floor(qi.Utility.counterTime % 60)
      $("#session-timeout-timer").html( min > 0 ? min + ' minute ' + (sec > 0 ? sec : '') : sec );
      if(sec == 0 ) {
        $(".unit").html("")
      }
      else {
        if( sec == 1) {
          $(".unit").html("second")
        }
        else{
          $(".unit").html("seconds")
        }
      }
    }
  },

  checkOnlineStatus: function() {
    if (document.visibilityState === 'visible') {
      if($('body').hasClass('login') && (qi.Utility.idleTime < qi.Utility.idleTimeThreshold)) {
        $.ajax({ url: '/check_online_status', type: 'GET' });
      }
    }
  },

  showModal: function(title, content, modal_class){
    qi.Utility.close();
    if(!title){
      var modal_content = $('<div class="modal fade"><div class="modal-dialog"><div class="modal-content"><div class="modal-body all-categories clearfix"></div></div></div></div>');
    } else {
      var header = '<div class="modal-header"><h4 class="modal-title">' + title + '</h4><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button></div>';
      var modal_content = $('<div class="modal fade"><div class="modal-dialog"><div class="modal-content">' + header + '<div class="modal-body all-categories clearfix"></div></div></div></div>');
    }
    modal_content.find('.modal-body').html(content);
    if (modal_class) {
      modal_content.find('.modal-dialog').addClass(modal_class);
    }
    modal_content.modal('show');

    modal_content.on('hidden.bs.modal', function () {
        modal_content.remove();
        window.location.reload();
      });
  },

  close: function () {
    $('.modal').modal('hide');
  }
};

$(document).on('turbolinks:load', function() {
  $('.js-change-fontsize').removeClass('active');
  $('#export_data_modal').on('hidden.bs.modal', function (e) {
    $(this).find('form').trigger('reset');
    $(this).find('form').find('.year-month').hide();
  });

  $('#date_range_modal').on('hidden.bs.modal', function (e) {
    var $this = $(this);
    $this.find("input[name='start']").val('');
    $this.find("input[name='end']").val('');
    $this.find('.error').text('');
  });

  if(typeof(Storage) !== "undefined") {
    var selectedFontSize = localStorage.getItem("fontSizeClass");

    if(selectedFontSize == 'font-resize_small') {
      $('.js-change-fontsize[data-font-type="-1"]').addClass('active');
    } else if (selectedFontSize == 'font-resize_large') {
      $('.js-change-fontsize[data-font-type="+1"]').addClass('active');
    } else {
      $('.js-change-fontsize[data-font-type="0"]').addClass('active');
    }

    $('body').removeClass('font-resize_small');
    $('body').removeClass('font-resize_large');
    $('body').addClass(selectedFontSize);
  } else {
    $('.js-change-fontsize[data-font-type="0"]').addClass('active');
    $('body').removeClass('font-resize_small');
    $('body').removeClass('font-resize_large');
  }

  var today = new Date();
  $('.datepicker').datepicker({
      dateFormat: 'd M yy',
      maxDate: today,
      changeYear: true,
      changeMonth: true,
      autoclose: true
  });

  $('.content_scroller').niceScroll({ spacebarenabled: false });

  if($('.flash-messages').text().trim() == "Sorry, you are no longer allowed to do this action. Please contact the administrator for more details.") {
    $('.flash-messages').delay(8000).fadeOut(2000);
  } else {
    $('.flash-messages').delay(5000).fadeOut(2000);
  }

  // $('.chart-container').load();

  $.each($('.chart-container'), function(index, i) {
    var canvasId = $(i).data('chart-id');
    var chartData = $(i).data('chart-data');
    var ylabel = $(i).data('ylabel');
    var entry = $(i).data('entry');
    var labels = chartData[0];
    var data = chartData[1];
    var ctx = document.getElementById(canvasId).getContext('2d');
    var datasets;
    if(data.length > 0) {
      datasets = [{
            label: entry,
            data: data,
            backgroundColor: '#0098d0'
          }];
    } else {
      datasets = [];
    }

    var chart = new Chart(ctx, {
      type: 'bar',
      plugins: [
        {
          afterDraw: function(chart) {
            if (chart.data.datasets[0].data.every(item => item === 0)) {
              var width = chart.chart.width;
              var height = chart.chart.height;

              ctx.save();
              ctx.textAlign = 'center';
              ctx.textBaseline = 'middle';
              ctx.font = "13px normal 'IBM Plex Sans',sans-serif";
              ctx.fillStyle = "#59666C";
              ctx.fillText('No Activity for this period', width / 2, height / 3);
              ctx.restore();
            }
          }
        }
      ],
      data: {
        labels: labels,
        datasets: datasets
      },

      options: {
        maintainAspectRatio: false,
        scaleShowVerticalLines: false,

        legend: {
          display: false
        },

        scales: {
          xAxes: [
            {
               scaleLabel: {
                display: true,
                labelString: 'Last 7 Days'
              },
              gridLines: {
                drawOnChartArea: false
              },
              ticks: {
                padding: 0,
                maxRotation: 0,
                callback: function(value, index, values) {
                  return value.split(' ');
                }
              }
            }
          ],

          yAxes: [
            {
              scaleLabel: {
                display: true,
                labelString: ylabel
              },
              gridLines: {
                drawOnChartArea: false,
                lineWidth: 1
              },
              ticks: {
                beginAtZero: true,
                maxTicksLimit: 5,
                padding: 5,
                precision:0
              }
            }
          ]
        }
      }
    });
  });

  initOtpCountDown();
});

var initOtpCountDown = function() {
  var current_date = new Date();
  var countDownDate = new Date(current_date.getTime() + 1 * 60000).getTime();

  var x = setInterval(function() {
    var now = new Date().getTime();
    var distance = countDownDate - now;
    var seconds = Math.floor((distance % (1000 * 60)) / 1000);

    $('.js-resend-otp-countdown .otp-countdown').html(seconds + "s ");
    $('.js-resend-otp-countdown').show();

    if (distance < 1000) {
      clearInterval(x);
      $('.js-resend-otp').show();
      $('.js-resend-otp-countdown').hide();
      $('.js-resend-otp-countdown .otp-countdown').html('');
    }
  }, 1);
};

$(function() {
  $(document).on('click', '.js-change-fontsize', function() {
    var $this = $(this);
    var fontType = $this.data('font-type');

    $('.js-change-fontsize').removeClass('active');
    $this.addClass('active');

    if(fontType == '0') {
      $('body').removeClass('font-resize_small');
      $('body').removeClass('font-resize_large');
      localStorage.setItem("fontSizeClass", "");

    }

    if(fontType == '-1') {
      $('body').addClass('font-resize_small');
      $('body').removeClass('font-resize_large');
      localStorage.setItem("fontSizeClass", "font-resize_small");
    }

    if(fontType == '+1') {
      $('body').removeClass('font-resize_small');
      $('body').addClass('font-resize_large');
      localStorage.setItem("fontSizeClass", "font-resize_large");
    }
  });

  $('.js-resend-otp').bind('click', function() {
    $('.js-resend-otp').hide();
    initOtpCountDown();
  });

  setInterval(qi.Utility.incrementIdleTime, 1000);
  setInterval(qi.Utility.checkOnlineStatus, 60000);

  document.addEventListener("visibilitychange", function() {
    if (document.visibilityState === 'visible') {
      if (((new Date().getTime() - localStorage.getItem('time'))/1000 > 900) && ($(".logout-modal-confirm").length == 0) && $('body').hasClass('login')) {
        qi.Utility.showTimer = false;
        localStorage.setItem('time', 0);
        $.ajax({ url: '/logout', type: 'DELETE' });
      }
    } else {
      localStorage.setItem('time', +new Date);
    }
  });

  $(document).on("click keypress keyup keydown scroll mousemove", function(e){
    if ($(".logout-modal-confirm").length == 0) {
      qi.Utility.idleTime = 0;
    }
  });


  $(document).on('click', '.overlay-container', function(e) {
    $('.dropdown-menu.show').removeClass("show");
    e.stopPropagation();
  });

  $(document).on('click', '.js-status-filter', function() {
    var $this = $(this);
    var $form = $this.parents('form');
    var selectedText = $this.text();
    $form.find('#status').val($this.data('val'));
    $form.find('.dropdown-toggle').text(selectedText);
    $form.find('.status-filter-button').click();
  });

   $(document).on('click', '.js-recipient-filter', function() {
    var $this = $(this);
    var $form = $this.parents('form');
    var selectedText = $this.text();
    $form.find('#recipient').val($this.data('val'));
    $form.find('.dropdown-toggle').text(selectedText);
    $form.find('.status-filter-button').click();
  });

   $(document).on('click', '.js-recipients-filter', function() {
    var $this = $(this);
    var $form = $this.parents('form');
    var selectedText = $this.text();
    $form.find('#email_recipient').val($this.data('val'));
    $form.find('.dropdown-toggle').text(selectedText);
    $(this).dropdown('toggle');
  });

  $(document).on('click', '.js-log-filter', function() {
    var $this = $(this);
    var selectedOption = $this.data('val');
    var $container = $this.parents('.form-group');
    var $target = $("#" + $container.data('target'));

    if($target.val() != selectedOption) {
      var selectedText = $this.text();
      $container.find('.dropdown-toggle').text(selectedText);
      $target.val(selectedOption).trigger('change');
    }
  });

  $(document).on('click', '.js-date-filter', function() {
    var $this = $(this);
    var selectedRange = $this.data('val');
    var $container = $this.parents('.form-group');
    var $target = $("#" + $container.data('target'));

    if($target.val() != selectedRange){
      $container.find('.dropdown-toggle').text(selectedRange);
      $target.val(selectedRange).trigger('change');
    }
  });

  $(document).on('change', '.js-audit-filter-form input', function() {
    $(this).parents('form').find('input[type="submit').removeClass('disabled');
  });

  $(document).on('click', '.js-apply', function() {
    var startDate, endDate, days;
    var date = $('.js-audit-filter-form').find('input#date_range').val();
    var dateSplit = date.split("-");
    var selectedStartDate = dateSplit[0];
    var selectedEndDate = dateSplit.pop();
    if (selectedStartDate && selectedEndDate) {
      startDate = new Date(selectedStartDate);
      endDate = new Date(selectedEndDate);
      days = (endDate - startDate) / (1000 * 3600 * 24);
    }
    var no_permission = $('.export-now').hasClass('not-permitted')
    if (startDate && endDate && (days <= 90) && !no_permission) {
      $('.export-now').removeClass('disabled');
    } else {
      $('.export-now').addClass('disabled');
    }

    var url = $('.export-now').data('base-url');
    var data = $('.js-audit-filter-form').serialize();
    var path = url + '?' + data;
    $('.export-now').attr("href", path);

  });

  $(document).on('click', '.js-confirm-date-range', function(e) {
    e.preventDefault();

    var selectedStartDate = $('#start').val();
    var selectedEndDate = $('#end').val();
    var startDate = new Date(selectedStartDate);
    var endDate = new Date(selectedEndDate);
    var currentDate = new Date;
    var days = (endDate - startDate) / (1000 * 3600 * 24);
    var reportsBlockLength = $('#date_range_modal').siblings('.reports-block').length;

    if(selectedStartDate && selectedEndDate && (currentDate >= startDate) && (currentDate >= endDate) && (endDate >= startDate) && ((reportsBlockLength != 1) || (days <= 90))) {
      var dateRangeText = selectedStartDate + ' - ' + selectedEndDate;
      var $target = $('#date_range');

      if($target.val() != dateRangeText){
        $target.parents('.form-group').find('.dropdown-toggle').text(dateRangeText);
        $target.val(dateRangeText).trigger('change');
      }

      $('#date_range_modal .error').text('');
      $('#date_range_modal').modal('hide');
    } else {
      if((reportsBlockLength == 1) && (days > 90)){
        $('#date_range_modal .error').text('To download the selected report,please select a date range of less than 90 days.');
      } else {
        $('#date_range_modal .error').text('Please select a valid date range.');
      }
    }
  });

  $('#date_range_modal').on('hidden.bs.modal', function (e) {
    $(this).find('.error').text('');
  });

  $(document).on('click', '.js-open-remote-modal', function(e) {
    e.preventDefault();
    e.stopPropagation();

    var $this = $(this);
    var url = $this.attr('href');

    $.ajax({
      url: url,
    }).done(function(data) {
      if ($(data).find('.user-login').length > 0) {
        window.location.reload();
      }
      else {
        $target = $(data);
        $target.modal({
          backdrop: 'static',
          keyboard: false
        });
      }
    });
  });

  $(document).on('click', '.js-display-details', function() {
    var $this = $(this);
    var $cont = $(this).parents('.content')
    $('.dropdown-menu.show').removeClass("show");
    $this.parents('.show-overlay').remove();
    var url = $this.data('url');

    $.ajax({
      url: url,
    }).done(function(data) {
      if ($(data).find('.user-login').length > 0) {
        window.location.reload();
      }
      else {
        $target = $(data);
        $cont.append($target);
        $('.content_scroller').niceScroll({ spacebarenabled: false });
        $target.show();
      };
    });
  });

  $(document).on('click', '.js-display-edit-modal', function(e) {
    e.preventDefault();
    e.stopPropagation();
    $('.dropdown-menu.show').removeClass("show");
    var $this = $(this);
    $this.addClass('disabled');
    $this.prop('disabled', true);

    $('.show-overlay').remove();
    var url = $this.attr('href');

    $.ajax({
      url: url
    }).done(function(data, textStatus, jqXHR) {
      if (jqXHR.getResponseHeader('content-type').indexOf('text/html') >= 0){
        if ($(data).find('.user-login').length > 0) {
          window.location.reload();
        }
        else {
          $target = $(data);
          $('.main-content section.content, .main-content article.content').append($target);
          $('.content_scroller').niceScroll({ spacebarenabled: false });
          $target.show();
        }
      }
    });
  });

  $(document).on('click', '.js-close-detail, .show-overlay', function() {
    if($('.js-compose-email-overlay').length > 0) {
      $('.js-compose-email-overlay').find('.js-modal-open').trigger('click');
      return;
    }

    var $this = $('.js-display-edit-modal');
    if(!$this.hasClass('no-permission')) {
      $this.removeClass('disabled');
      $this.prop('disabled', false);
    }

    $('.show-overlay').remove();
  });

  $(document).on('click', '.js-discard-email', function() {
    var $this = $('.js-display-edit-modal');
    if(!$this.hasClass('no-permission')) {
      $this.removeClass('disabled');
      $this.prop('disabled', false);
    }

    $('.show-overlay').remove();
  });

  $(document).on('click', '.js-close-message', function() {
    var $this = $(this);
    $this.parents('.flash-messages').hide();
  });

  $(document).on('click', '.js-modal-open', function(e) {
    e.preventDefault();
    e.stopPropagation();

    var $modal = $("#" + $(this).data('modal-id'));
    $modal.find('.error').text('');
    $modal.modal({
      backdrop: 'static',
      keyboard: false
    });
  });

  $(document).on('click', '.js-update-status, .js-confirm-action', function(e) {
    e.preventDefault();
    e.stopPropagation();

    var $this = $(this);
    var url = $this.data('url');
    var confirmationMessage = $this.data('modal-content');
    var reasonForm = $this.data('modal-reason-form');
    var modalTitle = $this.data('modal-title');
    var modalButton = $this.data('modal-button');

    if(confirmationMessage && (confirmationMessage.length > 0)) {
      $('#confirmation_modal .modal-body').html("<p>" + confirmationMessage + "</p>");

      if(reasonForm && (reasonForm.length > 0)) {
        $('#confirmation_modal .modal-body').append(reasonForm);
      }
    } else {
      $('#confirmation_modal .modal-body').html('<p>Are you sure?</p>');
    }

    if(modalTitle && (modalTitle.length > 0)) {
      $('#confirmation_modal .modal-header h2').html(modalTitle);
    } else {
      $('#confirmation_modal .modal-header h2').html('Confirming');
    }

    if(modalButton && (modalButton.length > 0)) {
      $('#confirmation_modal #confirm_ok_button').replaceWith(modalButton);
    } else {
      $('#confirmation_modal #confirm_ok_button').replaceWith('<button name="button" type="submit" class="btn btn-primary" id="confirm_ok_button" data-dismiss="modal">Yes</button>');
    }

    $('#confirmation_modal').modal({
        backdrop: 'static',
        keyboard: false
    }).off('click.confirm').on('click.confirm', '#confirm_ok_button', function() {
      if($('#reason').length > 0) {
        if($('#reason').val().trim()) {
          var currentVersion = $this.data("current-version");
          var formData = { reason: $('#reason').val(), current_version: currentVersion };

          $.ajax({
            url: url,
            data: formData,
            method: 'post'
          });

          $('#confirmation_modal').modal('toggle');
        } else {
          if($('#confirmation_modal .error').length == 0) {
            $('#confirmation_modal #reason').addClass('invalid');
            $('#confirmation_modal .modal-body').append('<p class="error">Please enter your reason for the status change.</p>');
          }
        }
      } else {
        $.ajax({
          url: url,
          method: 'post'
        });

        $('#confirmation_modal').modal('toggle');
      }
    });
  });

  $(document).on('click', '.js-status-change-icon', function(e) {
    e.preventDefault();
    e.stopPropagation();
  });

  $(document).on('click.confirm', '#status_change_confirm_button', function(e) {
    e.preventDefault();
    e.stopPropagation();
    var $this = $(this);
    var $modal = $this.parents('#confirmation_modal.js-update-status-form');
    var url = $modal.data('url');
    var currentVersion = $modal.find("#current_version").val();
    var $reason = $modal.find('#reason');

    if($reason.length > 0) {
      if($reason.val().trim()) {
        var formData = { reason: $reason.val(), current_version: currentVersion };

        $.ajax({
          url: url,
          data: formData,
          method: 'post'
        });
        $modal.modal('toggle');
      } else {
        if($modal.find('.error').length == 0) {
          $modal.find('#reason').addClass('invalid');
          $modal.find('.modal-body').append('<p class="error">Please enter your reason for the status change.</p>');
        }
      }
    }
  });

  $(document).on('click', '.js-change-search-type', function(e) {
    var $this = $(this);
    var $form = $this.parents('form');
    var selectedVal = $this.text();
    var path;
    var $selectedLink = $this.parents('.dropdown').find('#search_type_dropdown');
    $selectedLink.text(selectedVal);

    switch(selectedVal) {
    case 'Developers':
      path = '/admin/search/developers';
      break;
    case 'Apps':
      path = '/admin/search/apps';
      break;
    case 'Admins':
      path = '/admin/search/users';
      break;
    case 'Mails':
      path = '/admin/search/mails';
      break;
    default:
      path = '/admin/search/all';
    }

    $form.attr('action', path);
  });

  $(document).on('click', '.js-save-settings', function(e) {
    e.preventDefault();
    e.stopPropagation();

    var $this = $(this);
    var $container = $this.parents('.js-settings-container');
    var formdata = $container.find('.js-settings-field-edit').serializeArray();
    var currentVersion = $container.find('#current_version').val();
    var hasError = false;
    var url = $this.attr('href');

    $container.find('.error').text('');
    $(formdata).each(function(index, obj){
      if(obj.value == '') {
        $("."+ obj.name + "."+"error").text('Value cannot be blank');
        hasError = true;
      }
    });

    if(!hasError) {
      formdata.push({ name: 'current_version', value: currentVersion });

      $.ajax({
        url: url,
        data: $.param(formdata),
        method: 'post'
      });
    }
  });

  $(document).on('click', '.js-cancel-settings', function(e) {
    e.preventDefault();
    e.stopPropagation();

    $('.js-settings-container').removeClass('block-overlay');
    var $this = $(this);
    var $container = $this.parents('.js-settings-container');
    $container.find('.error').text('');
    $container.find('.settings-field-display').show();
    $container.find('.js-settings-field-edit').hide();
    $container.find('.config-value').show();
    $container.find('.js-cancel-settings').hide();
    $container.find('.js-save-settings').hide();
    $container.find('.js-edit-settings').show();
  });

  $(document).on('click', '.js-sort-by-column', function(e) {
    e.preventDefault();
    e.stopPropagation();

    var $this = $(this);

    $.ajax({
      url: $this.attr('href'),
      dataType: 'script'
    });
  })

  $(document).on('click', '.js-display-new-modal', function(e) {
    e.preventDefault();
    e.stopPropagation();

    var $this = $(this);
    $('.show-overlay').remove();
    var url = $this.attr('href');

    $.ajax({
      url: url,
    }).done(function(data) {
      if ($(data).find('.user-login').length > 0) {
        window.location.reload();
      }
      else {
        $target = $(data);
        $target.modal({
          backdrop: 'static',
          keyboard: false
        });
      }
    });
  });

  $(document).on('click', '.js-toggle-password-visibility', function(e) {
    var $this = $(this);
    var $inputField = $this.parents('.form-label-group').find('input');

    if($inputField.attr('type') == 'password') {
      $inputField.attr('type', 'text');
      $this.removeClass('icon-visibility-no');
      $this.addClass('icon-visibility-yes');
    } else {
      $inputField.attr('type', 'password');
      $this.addClass('icon-visibility-no');
      $this.removeClass('icon-visibility-yes');
    }
  });

  $(document).on('input', '.js-disable-negative-number-input', function(e) {
    var num = this.value.match(/^\d+$/);

    if (num === null) {
      this.value = "";
    }
  });

  $(document).on('input', '.js-max-value', function(e) {
    var len = this.value.length;
    var val = this.value;
    if (len > 15) {
      this.value = val.slice(0, 15);
    }
  });

  $(document).on('ajax:before', '.js-validate-forgot-password-form', function(e) {
    var $this = $(this);
    var $inputField = $this.find('.js-validate-email-input');
    var emailInput = $inputField.val();

    if((emailInput == '') || !emailInput.match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/)) {
      $inputField.addClass('is-invalid');

      if($this.find('.form-validation-error').length == 0) {
        $inputField.parents('.form-label-group').after('<p class="form-validation-error" role="alert">Please provide a valid Email.</p>');
      }

      return false;
    }
  });

  $(document).on('submit', '.js-validate-signin-form', function(e) {
    var $this = $(this);
    var $emailField = $this.find('.js-validate-email-input');
    var emailInput = $emailField.val();
    var $passwordField = $this.find('.js-validate-password-input');
    var passwordInput = $passwordField.val();
    var errors = [];

    if(emailInput == '') {
      errors.push('Email is required.');
    }

    if(emailInput && !emailInput.match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/)) {
      errors.push('Please provide a valid Email.');
    }

    if(passwordInput == '') {
      errors.push('Password is required.');
    }

    if(errors.length > 0) {
      $emailField.addClass('is-invalid');
      $passwordField.addClass('is-invalid');

      var fullError = errors.join(' <br> ');
      var validationError = '<p class="form-validation-error" role="alert">' + fullError + '</p>';

      if($this.find('.form-validation-error').length == 0) {
        $this.find('.form-label-group').last().after(validationError);
      } else {
        $this.find('.form-validation-error').replaceWith(validationError);
      }

      return false;
    }
  });

  $(document).on('submit','.js-validate-search', function(e) {
    var len = $(this).find('#search').val().trim().length;
    if (len < 2) {
      $(this).parents('.navbar').find('.search-invalid').remove();
      $(this).before("<span class='search-invalid'>Please enter at least 2 characters to start search </span>");
      return false;
    }
  });

  $(document).on('input', '.js-validate-search input', function(e) {
    var len = $(this).val().trim().length;

    if (len > 2) {
      $(this).parents('.navbar').find('.search-invalid').remove();
    }
  })

  $(document).on('click', '.js-click-chekbox', function() {
    $(this).find('input').trigger('change');
  });

  $(document).on('focus keyup', '.js-display-password-validator input', function(e){
    var $container = $(this).parents('.js-display-password-validator').find('.password-validator');
    var $form = $container.parents('form');
    var passwordTxt = $form.find('#user_password').val()
    var confirmPasswordTxt = $form.find('#user_password_confirmation').val()

    $('.password-validator').hide();
    $container.show();

    var inputText = $(this).val();
    $container.find('li').addClass('error');

    if(!(inputText.match(/(?=.{12,})/) == null)) {
      $container.find('li[data-err="invalid_length"]').removeClass('error');
    }

    if(!(inputText.match(/(?=.*[a-z])/) == null)) {
      $container.find('li[data-err="missing_lowercase"]').removeClass('error');
    }

    if(!(inputText.match(/(?=.*[A-Z])/) == null)) {
      $container.find('li[data-err="missing_uppercase"]').removeClass('error');
    }

    if(!(inputText.match(/(?=.*\d)/) == null) && !(inputText.match(/(?=.*\W)/) == null)) {
      $container.find('li[data-err="missing_number_or_symbol"]').removeClass('error');
    }

    if(($container.find('li.error').length == 0) && passwordTxt && confirmPasswordTxt && (passwordTxt == confirmPasswordTxt)) {
      $container.parents('form').find('.icon-check-circle-green').addClass('success');
    } else {
      $container.parents('form').find('.icon-check-circle-green').removeClass('success');
    }
  });

  $(document).on('change', '.js-report-date-range', function(e){
    var v = $(this).parents('form').find("input[name=type]:checked").val();
    $('.js-date-field .error').text('');
    if (v != 'distinct_activations' && v != 'total_sdk_activations' && v != 'total_registered_developers')
    {
      $('.js-select-date').hide();
      $('.js-not-applicable-date').show();
      $('.js-not-applicable-date').parents('.form-group').addClass('disabled');
      $('.js-not-applicable-date').parents('.form-group').addClass('not-applicable-date');
      $('.js-select-date').find('.dropdown-toggle').addClass('disabled');
    }
    else
    {
      $(this).parents('form').find('.dropdown-toggle').removeClass('disabled');
      $(this).parents('form').find('.dropdown-toggle').prop('disabled', false);
      $('.js-select-date').show();
      $('.js-not-applicable-date').parents('.form-group').removeClass('disabled');
      $('.js-not-applicable-date').parents('.form-group').removeClass('not-applicable-date');
      $('.js-not-applicable-date').hide();
    }
  });

  $(document).on('change', '.js-date-field', function(e){
    $('.js-date-field .error').text('');
  });

  $(document).on('click', '.js-confirm-data_export', function(e) {
    var checkCount = $(this).parents('form').find('input[type="checkbox"]:checked').length;

    if(checkCount > 0 && ($(this).parents('form').find('input[value="activations"]:checked').length == 0)) {
      $('#export_data_modal .module.error').text('');
      $('#export_data_modal').modal('hide');
    }
    if (checkCount == 0) {
      e.preventDefault();
      $('#export_data_modal .module.error').text('To export the data, select at least one module');
    }
    else {
      if($(this).parents('form').find('input[value="activations"]:checked').length == 1) {
        var mon = $('#date_month').val();
        var year = $('#date_year').val();
        var startingyear = $('.year-month').data('starting-year');
        var startingmonth = $('.year-month').data('starting-month');
        var months = [ "January", "February", "March", "April", "May", "June",
           "July", "August", "September", "October", "November", "December" ];
        if( new Date(year,mon-1) > new Date()){
          e.preventDefault();
          $('#export_data_modal .month.error').text('Please select the current or a previous month.');
        }
        else {
          if( new Date(year,mon-1) < new Date(startingyear,startingmonth)){
            e.preventDefault();
            $('#export_data_modal .month.error').text('Please select a month after '+ months[startingmonth-1] + " "+startingyear + ".");
          }
          else {
            $('#export_data_modal .error').text('');
            $('#export_data_modal').modal('hide');
          }
        }
      }
    }
  });

  $(document).on('submit','.js-report-download-form', function(e) {
    var v = $(this).find("input[name=type]:checked").val();

    if(v == 'distinct_activations' || v =='total_sdk_activations' || v =='total_registered_developers'){
      if($('#date_range').val() == "") {
        e.preventDefault();
        $('.js-date-field .error').text('Please select a date range.');
      }
      else {
        $('.js-date-field .error').text('');
      }
    }
    else {
      $('.js-date-field .error').text('');
    }
  });

  $(document).on('click', '.js-module-select', function(e) {
    $('#export_data_modal .module.error').text('');
    if($(this).parents('form').find('input[value="activations"]:checked').length == 1){
      $(this).parents('form').find('.year-month').show();
      // $('#export_data_modal .month.error').text('');
    }
    else {
      $(this).parents('form').find('.year-month').hide();
      $('#export_data_modal .month.error').text('');
    }
  });

  $(document).on('change', '.year-month', function() {
    $('#export_data_modal .month.error').text('');
  });


  $(document).on('keypress', '.js-only-number', function(e) {
    var charCode = (e.which) ? e.which : e.keyCode;
    if (e.which < 48 || e.which > 57 ) {
      if (e.which != 13) {
        e.preventDefault();
      }
    }
  });

  $(document).on('change', '.js-admin-permission', function(e){
    var exportPermission = $(this).parents('form').find("input[id=permissions_export_data]:checked").val();
    var superAdminPermission = $(this).parents('form').find("input[id=permissions_super_admin]:checked").val();
    if (exportPermission == 'export_data' && superAdminPermission != 'super_admin'){
      $(this).parents('form').find('.information-with-tooltip').show();
    }
    else{
      $(this).parents('form').find('.information-with-tooltip').hide();
    }
  });

  window.onresize = function(){
    setTimeout(function(){
        $(".reports_left-panel").getNiceScroll().resize();
      }, 500
    );
  };

  $(document).on('click', '.left-panel', function(e) {
    if($('.js-compose-email-overlay').length > 0) {
      e.preventDefault();
      e.stopPropagation();
      $('.js-compose-email-overlay').find('.js-modal-open').trigger('click');
      return;
    }
  });

  $(document).on('click', '.js-confirm-mail-send', function(e) {
    e.preventDefault();
    e.stopPropagation();

    var $this = $(this);
    var subject = $("#email_subject").val().trim();
    var body = $("#email_body").text().trim();

    if(subject.length > 0 && body.length > 0) {
      var selectedRecipient = $('#email_recipient').val();
      var $selectedRecipient = $('.js-recipients-filter[data-val="' + selectedRecipient + '"]');
      var recipientType = $selectedRecipient.data('recipient-type');
      var recipientCount = $selectedRecipient.data('recipient-count');

      $('.recipients-type').html(recipientType);
      $('.recipients-count').html(recipientCount);

      $('#confirm_send_modal').modal({
        backdrop: 'static',
        keyboard: false
      }).off('click.confirm').on('click.confirm', '#confirm_ok_button', function() {
        var $form = $('form#new_email');

        $.ajax({
          url: $form.attr("action"),
          data: $form.serialize(),
          method: 'post' });
      });
    } else {
      var $form = $('form#new_email');

      /* To use server side variadtion */
      $.ajax({
        url: $form.attr("action"),
        data: $form.serialize(),
        method: 'post' });
    }
  });
});
