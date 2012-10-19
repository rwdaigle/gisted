// Initial page load b/f Turbolinks kicks in
$(function() {
  wireSearch();
  setInitialElementStates();
});

// Subsequent loads
$(window).bind('pjax:end', function() {
  setInitialElementStates();
});

var setInitialElementStates = function() {

  searchField().select();

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

  // Pass form submits through PJAX
  $("#top_search_form").submit(function() {
    form = $(this);
    $.pjax({
      url: form.attr('action') + '?' + form.serialize(),
      container: '#results'
    })
    return false;
  }); 

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