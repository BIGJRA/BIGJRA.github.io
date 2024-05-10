

$(document).ready(function () {
  // Enables images to open into new tab on click
  $("img.tabImage").each(function () {
    $(this).attr("onclick", "window.open(this.src, '_blank');")
  });

  // Enables spoiler buttons
  $('.spoilerBtn').click(function() {
    $(this).parent().find('.spoilerText').css('display', 'block');
    $(this).hide();
  })

  // When the user scrolls down 20px from the top of the document, show the button
  window.onscroll = () => {
    btn = document.getElementById("toTopButton")
    if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
      btn.style.display = "block";
    } else {
      btn.style.display = "none";
    }
  }
});

// When the user clicks on the button, scroll to the top of the document
function topFunction() {
  document.body.scrollTop = 0; // For Safari
  document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
}
