  // Initial page load b/f Turbolinks kicks in
$(function() {
  wireSearch();
  displayResults();
});

var displayResults = function() {

  // Make sure results html is displayed
  if($("#results .choice").size() > 0) {
    $("#results").show();
  } else {
    $("#results").hide();
  }
};

var searchField = function() {
  return $("#top_search_form #command-bar");
};

var wireSearch = function() {

  var selectedClass = 'selected';

  searchField().select();

  // Live search

  searchField().typeWatch({
    callback: function() { submitSearch(); },
    wait: 250,
    highlight: false,
    captureLength: 2
  });

  // Pass form submits through PJAX
  $("#top_search_form").submit(function(e) {
    return submitSearch();
  });

  var submitSearch = function() {
    form = $("#top_search_form");
    $.pjax({
      url: form.attr('action') + '?' + form.serialize(),
      container: '#results',
      timeout: 2500
    });
    return false;
  };

  $(window).bind('pjax:start', function() {
    $("#search-error").hide();
    $(".indicator").css("visibility", "visible");
  });

  $(window).bind('pjax:complete', function() {
    $(".indicator").css("visibility", "hidden");
  });

  $(window).bind('pjax:success', function() {
    $("#search-error").hide();
    displayResults();
  });

  $(window).bind('pjax:timeout', function() {
    searchTimeout();
    return false;
  });

  $(window).bind('pjax:error', function() {
    searchError();
    return false;
  });

  // Search errors

  var searchTimeout = function() {
    $("#results").hide();
    $("#search-error").show();
    $("#search-error .timeout").show();
    $("#search-error .error").hide();
  }

  var searchError = function() {
    $("#results").hide();
    $("#search-error").show();
    $("#search-error .error").show();
    $("#search-error .timeout").hide();
  }

  // Keyboard nav

  Mousetrap.bind(['down'], function(e) {
    navigateList('down', $("#results .choice:first"));
    haltEvent(e);
  });

  Mousetrap.bind(['up'], function(e) {
    navigateList('up', $("#results .choice:last"));
    haltEvent(e);
  });

  Mousetrap.bind(['enter'], function(e) {
    executeOutsideInputFields(e, function() {
      goToSelectedResult();
      haltEvent(e);
    });
  });

  Mousetrap.bind(['/'], function(e) {
    executeOutsideInputFields(e, function() {
      searchField().focus().select();
      $("#results .choice.selected").removeClass(selectedClass);
      haltEvent(e);
    });
  });

  Mousetrap.bind(['escape'], function(e) {
    searchField().val('').focus().select();
    $("#results").hide();
    $("#search-error").hide();
    haltEvent(e);
  });

  var haltEvent = function(event) {
    event.stopPropagation();
    event.preventDefault();   
  };

  // direction == up|down
  var navigateList = function(direction, defaultEl) {

    previouslySelectedEl = $("#results .choice.selected");

    if(previouslySelectedEl.size() <= 0) {
      defaultEl.addClass(selectedClass);
      searchField().blur();
    } else {
      previouslySelectedEl.removeClass(selectedClass);
      newlySelectedEl = direction == 'up' ? previouslySelectedEl.prev(".choice") : previouslySelectedEl.next(".choice");
      newlySelectedEl.addClass(selectedClass);
      if(newlySelectedEl.size() <= 0) {
        searchField().focus();
      }
    }
  }

  var goToSelectedResult = function() {
    selectedEl = $("#results .choice.selected");
    if(selectedEl.size() >= 1) {
      location.href = selectedEl.find("a.gist-url").attr('href');
    }
  };

  var executeOutsideInputFields = function(event, fire) {
    if(!$(event.srcElement).is('input')) {
      fire();
    }
  }
};