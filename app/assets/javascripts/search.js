// Initial page load b/f Turbolinks kicks in
$(function() {
  wireSearch();
  setInitialElementStates();
});

// Subsequent loads
$(window).bind('page:load', function() {
  setInitialElementStates();
});

var setInitialElementStates = function() {
  searchField().select();

  // Pass form submits through Turbolinks
  $("#top_search_form").submit(function() {
    form = $(this);
    Turbolinks.visit(form.attr('action') + '?' + form.serialize());
    return false;
  });  
};

var searchField = function() {
  return $("#top_search_form #command-bar");
};

var wireSearch = function() {

  var selectedClass = 'selected';

  Mousetrap.bind(['down'], function(e) {
    navigateList('down', $(".display .choice:first"));
    haltEvent(e);
  });

  Mousetrap.bind(['up'], function(e) {
    navigateList('up', $(".display .choice:last"));
    haltEvent(e);
  });

  Mousetrap.bind(['enter', 'o'], function(e) {
    executeOutsideInputFields(e, function() {
      goToSelectedResult();
      haltEvent(e);
    });
  });

  Mousetrap.bind(['/', 's'], function(e) {
    executeOutsideInputFields(e, function() {
      searchField().focus().select();
      $(".display .choice.selected").removeClass(selectedClass);
      haltEvent(e);
    });
  });

  var haltEvent = function(event) {
    event.stopPropagation();
    event.preventDefault();   
  };

  // direction == up|down
  var navigateList = function(direction, defaultEl) {

    previouslySelectedEl = $(".display .choice.selected");

    if(previouslySelectedEl.size() <= 0) {
      defaultEl.addClass(selectedClass);
      searchField().blur();
    } else {
      previouslySelectedEl.removeClass(selectedClass);
      newlySelectedEl = direction == 'up' ? previouslySelectedEl.prev() : previouslySelectedEl.next();
      newlySelectedEl.addClass(selectedClass);
      if(newlySelectedEl.size() <= 0) {
        searchField().focus();
      }
    }
  }

  var goToSelectedResult = function() {
    selectedEl = $(".display .choice.selected");
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