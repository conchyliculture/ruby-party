function partyfail(msg) {
    $('#result').html("<font color='red'>"+msg+"</font>");
}
function partywin(msg) {
    $('#result').html("<font color='green'>"+msg+"</font>");
}

function search_text_changed() {
    var query = document.getElementById("search").value;
    if ( query.length >= 3 ){
        $.ajax({ url: "/lookup",
                data: "query="+query ,
                dataType: "html",
                success: function(data) {
                    $('#result').html(data);
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) { 
                    partyfail("Status: " + textStatus + " <br/> "+"Error: " + XMLHttpRequest.responseText);
                }

        });
    }
}

function insert_text_changed() {
    var query = document.getElementById("insert").value;
    if ( query.length >= 3 ){
        if (query.indexOf("http://")==0 || query.indexOf("https://") ==0 ){
            console.log("http");
            $.ajax({    url: "/insert_http",
                        data: "url="+encodeURIComponent(query),
                        dataType: "html",
                        error: function(XMLHttpRequest, textStatus, errorThrown) { 
                            partyfail("Status: " + textStatus + " <br/> "+"Error: " + XMLHttpRequest.responseText);
                        }
        });
        }
        else if (query.length==11) {
            console.log("yt");
            $.ajax({    url: "/insert_http",
                        data: "url="+encodeURIComponent("https://www.youtube.com/watch?v="+query),
                        dataType: "html",
                        success: partywin("New video inserted"),
                        error: function(XMLHttpRequest, textStatus, errorThrown) { 
                            partyfail("Status: " + textStatus + " <br/> "+"Error: " + errorThrown);
                        }
        });
        }
    }
}
