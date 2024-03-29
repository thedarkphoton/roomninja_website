// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
// require jquery-ui
//= require turbolinks
//= require jquery.turbolinks
//= require bootstrap-sprockets
//= require cocoon
//= require_tree .

function remote_call(method, path){
    $.ajax({
        dataType: 'script',
        type: method,
        url: path
    });
}

function assign_show_target(identifier){
    $(identifier).find('[show-target]').click(function(){
        $($(this).attr('show-target')).show();
    });
}

function assign_hide_target(identifier){
    $(identifier).find('[hide-target]').click(function(){
        $($(this).attr('hide-target')).hide();
    });
}

$(document).ready(function(){
    $('[show-target]').click(function(){
        $($(this).attr('show-target')).show();
    });

    $('[hide-target]').click(function(){
        $($(this).attr('hide-target')).hide();
    });
});