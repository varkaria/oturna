function hide(el) {
    el.classList.add('hide');
    el.classList.remove('show')
  }
  function show(el) {
    el.classList.remove('hide');
    el.classList.add('show')
  }

function toggleFunction() {
    if(document.getElementById('one').classList.contains("show")){
        hide(document.getElementById('one'))
        show(document.getElementById('two'));
    } else {
        show(document.getElementById('one'));
        hide(document.getElementById('two'));
    }
  }
  let toggleStatus;

setInterval(toggleFunction, 10000);