var topwindowClients;
const ON_FG_MESSAGE = "org.unifiedpush.onFGMessage";
function isClientFocused() {
  return clients
    .matchAll({
      type: 'window',
      includeUncontrolled: true,
    })
    .then((windowClients) => {
	    topwindowClients = windowClients;
      let clientIsFocused = false;

      for (let i = 0; i < windowClients.length; i++) {
        const windowClient = windowClients[i];
        if (windowClient.focused) {
          clientIsFocused = true;
          break;
        }
      }

      return clientIsFocused;
    });
}


self.addEventListener('push', function(event) {

const promiseChain = isClientFocused().then((clientIsFocused) => {
  if (clientIsFocused) {
    topwindowClients.forEach((windowClient) => {
	    windowClient.postMessage({
        message: event.data.arrayBuffer(),
        time: new Date().toString(),
      });
    });
  }  else {
    return self.registration.showNotification('No focused windows', {
	    body: 'Background notif: ' + event.data.text(),
  });
  
}});

event.waitUntil(promiseChain);

});

