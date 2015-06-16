
function partyfail(msg) {
    $('#results').html("<font color='red'>"+msg+"</font>");
}
// /pushpl?id=#{res[:id]

function push_to_playlist(id) {
    $.ajax({ url: "/pushpl",
            data: "id="+id ,
            dataType: "html",
            complete: function(jqXHR,textStatus) {
                if (textStatus == "success") {
                    toastr.options.timeOut = 1500;
                    toastr.success("Video successfully added to playlist");
                }
                else if (textStatus == "error") {
                    partyfail("Status: " + textStatus + " <br/> "+"Error: " + jqXHR.responseText);
                } else {
                    console.log("status "+textStatus);
                }
            },
    });

}


function submitForm(id) {
    if (id>-1) {
    $.ajax({ url: "/changeinfo",
            data: "id="+id+"&data=" +$( "#comment" ).val() ,
            type: 'POST',
            dataType: "html",
            complete: function(jqXHR,textStatus) {
                if (textStatus == "success") {
                    toastr.options.timeOut = 1500;
                    toastr.success("Comment successfully added");
                }
                else if (textStatus == "error") {
                    partyfail("Status: " + textStatus + " <br/> "+"Error: " + jqXHR.responseText);
                } else {
                    console.log("status "+textStatus);
                }
            },
    });
    } else {
        console.log("fail "+id);
    }
}

function search_text_changed() {
    var query = document.getElementById("search").value;
    if (query.length == 0) {
        $.ajax({ url: "/get10",
                dataType: "html",
                success: function(data) {
                    $('#results').html(data);
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) { 
                    partyfail("Status: " + textStatus + " <br/> "+"Error: " + XMLHttpRequest.responseText);
                }
        });
    }

    if ( query.length >= 2 ){
        $.ajax({ url: "/lookup",
                data: "query="+query ,
                dataType: "html",
                success: function(data) {
                    $('#results').html(data);
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) { 
                    partyfail("Status: " + textStatus + " <br/> "+"Error: " + XMLHttpRequest.responseText);
                }
        });
    }
}

function dl(url) {
    $.ajax({    url: "/insert_http",
                data: "url="+encodeURIComponent(url),
                dataType: "html",
                complete: function(jqXHR,textStatus) {
                    if (textStatus == "success") {
                        toastr.options.timeOut = 1500;
                        toastr.success("Video successfully added");
                        $('#insert_wait').hide();
                        $('#insert').val('');
                    }
                    else if (textStatus == "error") {
                        partyfail("Status: " + textStatus + " <br/> "+"Error: " + jqXHR.responseText);
                        $('#insert_wait').hide();
                        $('#insert').val('');
                    } else {
                        console.log("status "+textStatus);
                    }
                },
                beforeSend: function(jqXHR, settings) {
                    $('#insert_wait').height($('#h_insert').height());
                    $('#insert_wait').show();
                },
    });
}

function insert_text_changed() {
    var query = document.getElementById("insert").value;
    if ( query.length >= 2 ){
        if (query.indexOf("http://")==0 || query.indexOf("https://") ==0 ){
            dl(query);
        }
        else if (query.length==11) {
            dl("https://www.youtube.com/watch?v="+query);
        }
    }

}

function reindex_videos() {
    $.ajax({ url: "/reindex",
            dataType: "html",
            complete: function(jqXHR,textStatus) {
                if (textStatus == "success") {
                    toastr.options.timeOut = 1500;
                    toastr.success(jqXHR.responseText+" videos successfully reindexed");
                }
                else if (textStatus == "error") {
                    partyfail("Status: " + textStatus + " <br/> "+"Error: " + jqXHR.responseText);
                } else {
                    console.log("status "+textStatus);
                }
            },
    });
}
