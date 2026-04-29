(function () {
  function initMobileTopbar(container) {
    if (!container) return;

    var sections = [];
    [
      '.nav-links',
      '.search-wrap',
      '.nav-right',
      '.navbar-nav.flex-row',
      '.navbar-nav.ms-auto',
      '.navbar-collapse'
    ].forEach(function (selector) {
      container.querySelectorAll(selector).forEach(function (node) {
        if (!sections.includes(node)) sections.push(node);
      });
    });

    if (!sections.length) return;

    container.classList.add('mobile-nav-ready');
    sections.forEach(function (section) {
      section.classList.add('mobile-nav-section');
    });

    var brand = container.querySelector('.navbar-brand') || container.firstElementChild;
    var toggle = document.createElement('button');
    toggle.type = 'button';
    toggle.className = 'mobile-menu-toggle';
    toggle.setAttribute('aria-label', 'Toggle menu');
    toggle.setAttribute('aria-expanded', 'false');
    toggle.innerHTML = '<span></span><span></span><span></span>';

    toggle.addEventListener('click', function () {
      var open = container.classList.toggle('mobile-menu-open');
      toggle.setAttribute('aria-expanded', String(open));
    });

    if (brand && brand.parentNode === container) {
      brand.insertAdjacentElement('afterend', toggle);
    } else {
      container.insertAdjacentElement('afterbegin', toggle);
    }

    window.addEventListener('resize', function () {
      if (window.innerWidth > 992) {
        container.classList.remove('mobile-menu-open');
        toggle.setAttribute('aria-expanded', 'false');
      }
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.topbar .container').forEach(initMobileTopbar);
  });
})();
