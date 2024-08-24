// ==UserScript==
// @name        avito-sort.js
// @namespace   Violentmonkey Scripts
// @match       https://www.avito.ru/*
// @grant       none
// @version     1.0
// @author      -
// @description 24/08/2024, 02:14:45
// ==/UserScript==
(function() {
  const sort_order = new URLSearchParams(window.location.search).get("s");
  const buttons = document.querySelector('ul[data-marker=pagination-button]');
  buttons.querySelectorAll('a').forEach( (el) => {
        const href = el.getAttribute('href');
        if (!href.includes("&s=")) {
          el.setAttribute('href', href+"&s="+sort_order);
        }
    });
})();
