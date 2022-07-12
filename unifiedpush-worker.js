// Add the following line to web/index.html, right before "serviceWorkerUrl = 'flutter_service_worker.js?v='""
// navigator.serviceWorker.register('/unifiedpush-worker.js');
// Make sure to update this file if major version updates of the library require it


// if true, it will send to all windows
// if false, it will only send to the active/visible window
const SEND_FG_MESSAGE_TO_ALL_WINDOWS = true;

// library code, don't modify

// consts
const ON_FG_MESSAGE = "org.unifiedpush.flutter.webpush.on_fg_message";

//returns Promise<Array<Client>>
function getAllWindowClients() {
  return clients
    .matchAll({
      type: 'window',
      includeUncontrolled: true,
    })
}

async function getFocusedClient() {
  var allc = await getAllWindowClients();
  return allc.find((client) => client.focused);
}


self.addEventListener('push', function (event) {

  const focusedClient = getFocusedClient();

  if (focusedClient === undefined) // run BG processor
    event.waitUntil(
      new Promise(function (resolve, reject) {
        processBGPush(event.data.arrayBuffer())
        resolve(null);
      }));
  else { // there does exist a FG window
    focusedClient.postMessage({
      type: ON_FG_MESSAGE,
      time: new Date().toString(),
      data: event.data.arrayBuffer(),
    });
  }

});

// you can modify the following
// great open source examples of webpush handlers
// https://github.com/vector-im/hydrogen-web/blob/13428bd03c7ec3821352ab13eb631fb0bbe23e94/src/platform/web/sw.js
// https://github.com/mastodon/mastodon/blob/main/app/javascript/mastodon/service_worker/web_push_notifications.js

function processBGPush(messageArrayBuffer) {
  // you MUST show a notification here for browsers like chrome, or they might block you

  // to get string
  // https://stackoverflow.com/a/11058858
  const string = String.fromCharCode.apply(null, new Uint8Array(messageArrayBuffer));
  // tset this?  const dataString JSON.stringify(Array.from(new Uint8Array(arrayBuffer)));
  self.Notification('my notification' + string);

  //to get JSON
  const jsonobj = Buffer.from(yourArrayBufferValue).toJSON();
  self.Notification('mynotification:' + jsonobj.title);


}