$(function() {

  var selectedClass = 'selected';
  var searchField = $("#search-form #q");

  searchField.select();

  Mousetrap.bind(['down'], function(e) {
    navigateList('down', $("ul.search-results li:first"));
    haltEvent(e);
  });

  Mousetrap.bind(['up'], function(e) {
    navigateList('up', $("ul.search-results li:last"));
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
      searchField.focus().select();
      $("ul.search-results li.selected").removeClass(selectedClass);
      haltEvent(e);
    });
  });

  var haltEvent = function(event) {
    event.stopPropagation();
    event.preventDefault();   
  };

  // direction == up|down
  var navigateList = function(direction, defaultEl) {

    previouslySelectedEl = $("ul.search-results li.selected");

    if(previouslySelectedEl.size() <= 0) {
      defaultEl.addClass(selectedClass);
      searchField.blur();
    } else {
      previouslySelectedEl.removeClass(selectedClass);
      newlySelectedEl = direction == 'up' ? previouslySelectedEl.prev() : previouslySelectedEl.next();
      newlySelectedEl.addClass(selectedClass);
      if(newlySelectedEl.size() <= 0) {
        searchField.focus();
      }
    }
  }

  var goToSelectedResult = function() {
    selectedEl = $("ul.search-results li.selected");
    if(selectedEl.size() >= 1) {
      location.href = selectedEl.find("a.gist-url").attr('href');
    }
  };

  var executeOutsideInputFields = function(event, fire) {
    console.log($(event.srcElement));
    if(!$(event.srcElement).is('input')) {
      fire();
    }
  }
});